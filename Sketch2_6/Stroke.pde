class Stroke {
  ArrayList<PVector> plist;
  float wid;
  color col;

  Stroke() {
    col = color(255);
    wid = 3;
    plist = new ArrayList<PVector>();
  }

  Stroke(PVector pp, float pwid, color pcol) {
    col = pcol; 
    wid = pwid;
    plist = new ArrayList<PVector>();
    plist.add(pp);
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

  //-------------------------------------------------------------

  void draw() {
    stroke(col);
    strokeWeight(wid); 
    for (int i=1; i<plist.size(); i++) {
      // TODO: Use line() to paint the stroke

      PVector startPoint = plist.get(i-1);
      PVector endPoint = plist.get(i);
      line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
    }
  }

  //---------------------------------------------- 

  void movePerpendicuarToGradient(int steps, PImage inp) {
    int actX = (int)round(plist.get(plist.size()-1).x);
    int actY = (int)round(plist.get(plist.size()-1).y);
    color col1 = inp.get(actX, actY);

    for (int i=0; i<steps; i++) {
      tracePosition(inp);

      actX = (int)round(plist.get(plist.size()-1).x);
      actY = (int)round(plist.get(plist.size()-1).y);
      color col2 = inp.get(actX, actY);

      // TODO: if color changes too much along the stroke, stop
      // Get the current loaction and color and compare them to the strokes origin point. 

      float col1Red = red(col1);     
      float col2Red = red(col2);
      float col1Green = green(col1); 
      float col2Green = green(col2);
      float col1Blue = blue(col1);   
      float col2Blue = blue(col2);

      //if (sqrt((col1Red - col2Red) * (col1Red - col2Red) + (col1Green - col2Green) * (col1Green - col2Green) + (col1Blue - col2Blue) * (col1Blue - col2Blue))) 
      //break;
    }
  }

  //---------------------------------------------- 

  void tracePosition(PImage inp) {
    int actX = (int)round(plist.get(plist.size()-1).x);
    int actY = (int)round(plist.get(plist.size()-1).y);
    int w = inp.width;

    if (inp == null) return;
    actX = constrain(actX, 1, inp.width-2);
    actY = constrain(actY, 1, inp.height-2);

    // Gradient 
    // TODO: use inp.pixels[x + y*w] to access pixel data and implement a sobel operate for x and y using this information
    // for this, replace 0.0 with the computation.

    float gx = (brightness(inp.pixels[actX+1 + (actY-1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
      2*(brightness(inp.pixels[actX+1 + (actY  )*w]) - brightness(inp.pixels[actX-1 + (actY  )*w])) +
      (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY+1)*w]));

    float gy = (brightness(inp.pixels[actX-1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
      2*(brightness(inp.pixels[actX   + (actY+1)*w]) - brightness(inp.pixels[actX   + (actY-1)*w])) +
      (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX+1 + (actY-1)*w]));
    
    // Normalization
    float lenghtOfVector = sqrt((gx*gx) + (gy*gy));     
    
    // TODO: Use the gradient to move further. replace PVector(0, 0) with the next location the stroke goes to, according to the gradient.
    plist.add(new PVector(actX-(gy/lenghtOfVector),actY+(gx/lenghtOfVector)));
  }
}
