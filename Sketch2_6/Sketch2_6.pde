PImage inp, canvas;
ArrayList<Stroke> strokes;

int mode = 0;
float radius = 20;

////////////////////////////////////////////////////////

void createACoupleOfStrokes(int noStrokes) {

  for (int i=0; i<noStrokes; i++) {

    int px = (int)random(0, inp.width-1);
    int py = (int)random(0, inp.height-2);
    color col = inp.pixels[px + py*inp.width];
    
    Stroke s = new Stroke(new PVector(px, py), radius, col);
    s.movePerpendicuarToGradient(20, inp); 

    strokes.add(s);
   
    s.draw();
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
  Stroke s = new Stroke(new PVector(px, py), radius, color(255-red(col), 255-green(col), 255-blue(col)));
  s.movePerpendicuarToGradient(20, inp); 
  s.draw();
}

/////////////////////////////////////////////////////////

void setup() {

  inp = loadImage("flower.jpg");
  inp.resize(1000,0);
  size(10,10);
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);

  strokes = new ArrayList<Stroke>(1000);
  
  background(255);
  noFill();
  strokeCap(ROUND);
  strokeJoin(ROUND);
}

////////////////////////////////////////////////////////

void draw() {
  if (mode == 0) createACoupleOfStrokes(100);
  if (mode == 1) createStrokeAtMousePosition();
}

////////////////////////////////////////////////////////

void keyPressed() {
  if (key == '0') mode = 0; 
  if (key == '1') mode = 1; 
  if (key == '-') radius /= 1.5;
  if (key == '+') radius *= 1.5;
}
