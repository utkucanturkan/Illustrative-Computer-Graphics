class Stroke { //<>//
  ArrayList<PVector> plist;
  float wid;
  color col;
  PImage texi, _texi;
  PVector start;

  Stroke() {
    col = color(0, 0, 0, 255);
    plist = new ArrayList<PVector>();
    wid = 15;
    iniTexture();
    start = new PVector(0, 0);
  }

  Stroke(PVector pp, float pw, color pc, PImage ptexi) {
    col = pc;
    wid = pw;
    texi = ptexi;
    start = pp;
    iniTexture();
    plist = new ArrayList<PVector>();
  }

  void addPoint(PVector pp) {
    plist.add(pp);
  }

  void addPoint(float px, float py) {
    plist.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    wid = pr;
  }

  void setColor(color pcol) {
    col = pcol;
  }

  ArrayList<PVector> getPoints() {
    return plist;
  }

  //-------------------------------------------------------------

  void draw() {

    if (plist.size()<2) return;

    float len = getStrokeLength();
    float l=0, x=0, y=0;

    beginShape(QUAD_STRIP);
    texture(_texi); 
    normal(0, 0, 1); // only for lights
    for (int i = 0; i < plist.size(); ++i) {

      // TODO: Build the quad strip: 
      // 1) Get the offset normal (beware of start and end!)
      // 2) Compute v using l, 
      // 3) create two points using vertex(x, y, u, v) (so two calls to vertex!) in the correct order

      PVector p = plist.get(i);
      if (i==0) { 
        x = p.x; 
        y = p.y; 
        l = 0;
      } else { 
        l += sqrt(sq(x-p.x)+sq(y-p.y)); 
        x = p.x; 
        y = p.y;
      }      

      PVector n = getOffsetNormal(plist, i);
      float v = _texi.height * l/len;
      float xoff = wid/2 * n.x;
      float yoff = wid/2 * n.y;
      vertex(x+xoff, y+yoff, 0, _texi.width, v);
      vertex(x-xoff, y-yoff, 0, 0, v);
    }
    endShape();
  }

  //-------------------------------------------------------------

  float getStrokeLength() {
    float len = 0;
    for (int i = 1; i<plist.size(); i++) {
      PVector p  = plist.get(i);
      PVector pp = plist.get(i-1);
      len += sqrt(sq(pp.x-p.x)+sq(pp.y-p.y));
    }
    return len;
  }

  int getSize() {
    return plist.size();
  }

  //-------------------------------------------------------------

  PVector getOffsetNormal(ArrayList<PVector> plist, int index) {
    PVector z = new PVector(0f, 0f, 1f);
    if (plist.size() == 1 || index > plist.size()-1) {
      z = new PVector(0f, 1f, 0f);
    }
    if (index==0) {
      PVector pN = plist.get(index);
      PVector pFirst = plist.get(index+1);
      z = PVector.sub(pFirst, pN).rotate(HALF_PI);
    }
    if (index==plist.size()-1) {
      PVector pN = plist.get(index);
      PVector pFirst = plist.get(index-1);
      z = PVector.sub(pN, pFirst).rotate(HALF_PI);
    } 
    if (index > 0 && index<plist.size()-1) {
      PVector pN = plist.get(index);
      PVector pFirst = plist.get(index-1);
      PVector pLast = plist.get(index+1);
      PVector pNpFirstVectorNormalized = PVector.sub(pN, pFirst).rotate(HALF_PI).normalize();
      PVector pNpLastVectorNormalized = PVector.sub(pLast, pN).rotate(HALF_PI).normalize();
      z = PVector.add(pNpFirstVectorNormalized, pNpLastVectorNormalized);
    }
    z.normalize();
    return z;
  }


  //-------------------------------------------------------------

  void iniTexture() {

    if (texi == null) {
      texi = createImage(10, 10, RGB);
      for (int i=0; i<texi.width*texi.height; i++) 
        texi.pixels[i]=color(0, 0, 0, 255);
    }

    // _texi has the color of the stroke color c
    // and brightness values (inverse) are mapped to alpha

    float cred = red(col);
    float cgreen = green(col);
    float cblue = blue(col);

    _texi = createImage(texi.width, texi.height, ARGB);
    for (int i=0; i<texi.width*texi.height; i++) {
      float a = 255-brightness(texi.pixels[i]); 
      _texi.pixels[i]=color(cred, cgreen, cblue, a);
    }
  }

  //-------------------------------------------------------------

  public String toString() {
    String s = "Line [";
    for (int i = 1; i<plist.size(); i++) 
      s += plist.get(i).toString();
    s += "] ";
    return s;
  }

  //---------------------------------------------- 

  void movePerpendicuarToGradient(int steps, PImage inp) {
    plist.add(start);
    PVector current = start;
    color col = inp.get(round(current.x), round(current.y));


    for (int i = 0; i < steps; ++i) {
      PVector next = tracePosition(inp, current);

      // TODO: Handle no gradient

      color actC = inp.get(round(next.x), round(next.y));

      // TODO: Handle excessive color change
      if (sqrt(sq(red(col)-red(actC)) + sq(green(col)-green(actC)) + sq(blue(col)-blue(actC))) > 50) 
        break;

      // a ----- b 
      //         /
      //        /
      //       c
      //
      // Calculate angle between 
      // the vectors b -> a and b -> (using a -> b would result in a blunt angle!)
      // a - b <- > c - b

      if (plist.size() > 2) {
        // TODO: calculate the angle
        float angle = 90.0;
        if (angle < 45) {
          break;
        }
      }

      current = next;
      plist.add(next);
    }
  }

  //---------------------------------------------- 

  PVector tracePosition(PImage inp, PVector pos) {
    int actX = round(pos.x);
    int actY = round(pos.y);
    int w = inp.width;

    actX = constrain(actX, 1, inp.width-2);
    actY = constrain(actY, 1, inp.height-2);

    // Gradient 
    float gx =   (brightness(inp.pixels[actX+1 + (actY-1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
      2*(brightness(inp.pixels[actX+1 + (actY  )*w]) - brightness(inp.pixels[actX-1 + (actY  )*w])) +
      (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY+1)*w]));

    float gy =   (brightness(inp.pixels[actX-1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
      2*(brightness(inp.pixels[actX   + (actY+1)*w]) - brightness(inp.pixels[actX   + (actY-1)*w])) +
      (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX+1 + (actY-1)*w]));

    // Normalize 
    float len = sqrt(sq(gx) + sq(gy));    
    if (len == 0) {
      return new PVector(0, 0);
    }

    gx /= len;
    gy /= len;

    // find new postion
    float stepSize = wid / 2;
    float dx = -gy*stepSize;
    float dy =  gx*stepSize;
    return new PVector(actX+dx, actY+dy);
  }
}
