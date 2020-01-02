PImage inp, blurred, texture;
ArrayList<Stroke> strokes;
int mode = 0;
float lineWidth = 15;
float drawAlpha = 30;

boolean strokeDebug = false;
boolean startOnWhite = true;

float computeColorImpact(Stroke s, PImage ref) {
  ArrayList<PVector> points = s.getPoints();
    
  float errorSum = 0.0;
    
  for (PVector point : points) {
    // TODO: Calculate a usable difference between 
    // corresponding points on the canvas and the input image
  }
  return 100;
}

////////////////////////////////////////////////////////

void createACoupleOfStrokes(int noStrokes) {
  int strokesPainted = 0;
  while (strokesPainted < noStrokes) {
    int px = (int)random(0, inp.width-1);
    int py = (int)random(0, inp.height-2);
    color col = inp.pixels[px + py*inp.width];
    
    // TODO: Check for startOnWhite and if it's true assure your start position is white on the canvas
    
    Stroke s = new Stroke(new PVector(px, py), lineWidth, col, texture);
    s.movePerpendicuarToGradient(20, blurred); 

    if (s.getSize() > 3) {
      float strokeError = computeColorImpact(s, inp);
      
      if (strokeError > 50) {
        strokes.add(s);
        s.draw();
        ++strokesPainted;
      }
    }
  }
}

/////////////////////////////////////////////////////////
// draw the stroke at the position of the mouse
// for debugging, color is inverse to image
/////////////////////////////////////////////////////////

void createStrokeAtMousePosition() { 
  background(inp);
  int px = (int)mouseX;
  int py = (int)mouseY;
  color col = inp.pixels[px + py*inp.width];
  Stroke s = new Stroke(new PVector(px, py), lineWidth, 
                   color(255-red(col), 255-green(col), 255-blue(col)),texture);
  s.movePerpendicuarToGradient(20, blurred); 
  s.draw();
}

void createDebugStroke() {
  background(255);
  Stroke s = new Stroke(new PVector(100, 100), 30, color(255, 0, 0), texture);
  s.addPoint(100, 100);
  s.addPoint(600, 300);
  s.addPoint(100, 200);
  
  s.draw();
}

/////////////////////////////////////////////////////////

void settings() {
  // inp = loadImage("rampe.png");
  inp = loadImage("flower2.jpg");
  inp.resize(1000,0);
  size(inp.width, inp.height, P3D);
}

void setup() {
  surface.setResizable(false);
  texture = loadImage("data/brush.png");

  strokes = new ArrayList<Stroke>(1000);
  
  blurred = inp.copy();
  blurred.filter(BLUR, lineWidth / 2);
  
  background(255);
  noFill();
  noStroke();
  textureMode(IMAGE);  
}

////////////////////////////////////////////////////////

void draw() {
  if (mode == 0) createACoupleOfStrokes(100);
  if (mode == 1) createStrokeAtMousePosition();
  if (mode == 2) createDebugStroke();
}

////////////////////////////////////////////////////////

void keyPressed() {
  if (key == '0') mode = 0; 
  if (key == '1') mode = 1;
  if (key == '2') mode = 2;
  if (key == 'd') { 
    strokeDebug = !strokeDebug;
    if (strokeDebug) {
      stroke(0);
    } else {
      noStroke();
    }
  }
  if (key == 's') {
    save("painting.png");
  }
  if (key == 'w') {
    startOnWhite = !startOnWhite;
  }
  if (key == '-') lineWidth /= 1.5;
  if (key == '+') lineWidth *= 1.5;
}
