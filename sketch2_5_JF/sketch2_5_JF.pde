PImage inputImage;
PImage outputImage;

float [][] sourceIntensity;
ArrayList<Point> [][] grid;
int gridX=0, gridY=0;

float poissonDiscRadius = 5;
float pointRadius = 2;
int numPoints =5000; 
int numTrials = 1000000;
float accuracy = 0.01;

boolean computed = false;
ArrayList<Point> computedPoints;

// The Point class provides basic storage of 2D points and 3D points with a radius  

class Point {
  float x, y, z, r; // R is used for the radius of a point
  float tx, ty, n;
  color c;
  
  Point(float px, float py) {
    x = px; 
    y = py; 
    z = 0; 
    r = 1; //2D case: Default radius to 1, so all are uniform
     c = color(0,0,0);
  }
  
  Point(float px, float py, float pz, float pr) {
    x = px; 
    y = py; 
    z = pz; 
    r = pr; 
     c = color(0,0,0);
  }
  
  Point (Point p) {
    x = p.x; 
    y = p.y;
    z = p.z;
    r = p.r;  
    c = p.c;
  }
  
  // Computes euclidian distance between this point and another coordinate pair in the XY plane
  float distXY(float px, float py) {
     return sqrt((x-px)*(x-px) + (y-py)*(y-py));
  }
  
  void voronoiIni() { 
    tx = ty = n = 0;
  }
  void voronoiMove() { 
    x = tx/n; 
    y = ty/n;
    x = constrain(x, 20,width-20);
    y = constrain(y, 20,height-20);
  }
}

color intToColor(int i) {
  int r =  (i % 128);
  int g = ((i>>6) % 128);
  int b = ((i>>12) % 128);
  return color(r, g, b);
}

int colorToInt(color c) {
  int r = (int)(c>> 16 & 0xFF);
  int g = (int)(c>> 8  & 0xFF);
  int b = (int)(c      & 0xFF);
  return r + (g<<6) + (b<<12);
}

 
// Computes euclidian distance between two points in the XY plane
float dist(Point p1, Point p2) {
  return sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y));
}


/*
 * Creates an Pimage form a 2D array of float intensity values. 
 */
PImage createOutputImage(float [][] outputIntensity) {
  
    int w = outputIntensity.length;
    int h = outputIntensity[0].length;

    outputImage = createImage(w, h ,RGB);
    for (int y=0; y<h; ++y)
      for (int x = 0; x < w; ++x) {
        float val = 255.0 * (1.0 - outputIntensity[x][y]);
        outputImage.pixels[x+y*w] = color(val,val,val);
    }
    
    return outputImage;
}


/*
 * Takes a PImage sourceImage and converts it to greyscale intensity array with values in [0.0 - 1.0]
 */
void createIntensityVal(PImage sourceImage, float[][] intensityArray) {
  sourceImage.loadPixels();
  for (int y=0;y<sourceImage.height;y++)
    for (int x = 0; x < sourceImage.width; x++) 
       intensityArray[x][y] = brightness(sourceImage.pixels[x+y*sourceImage.width]) / 255.0;
}

/*
 * Computes the intensity in the rectangle given by (x1, y1) and (x2, y2), reading data from intensityArray
 * The average intensity is the sum of all intensity values, divided by the area visited
 */

float getAvgIntensity(int x1, int y1, int x2, int y2, float [][] intensityArray) {

  int w = intensityArray.length;
  int h = intensityArray[0].length;
  x1 = max(0, min(w, x1));
  x2 = max(0, min(w, x2));
  y1 = max(0, min(h, y1));
  y2 = max(0, min(h, y2));
  
  float intensitySum = 0;
  
  for (int y = y1; y < y2; ++y) {
    for (int x = x1; x < x2; ++x) { 
       intensitySum += intensityArray[x][y];
    }
  }

  return intensitySum / ((x2-x1)*(y2-y1));
}

/*
 * Insert a point into the point List, checking in the intensityArray if the average intensity around the selected area is ok 
 */
boolean insertPoint(float [][] intensityArray, ArrayList pointList, float x, float y) {
  
  int px = (int)round(x);
  int py = (int)round(y);
  
  float avgIntensity = getAvgIntensity(px-2, py-2, px+2, py+2, intensityArray);
  if (random(0,1) > avgIntensity) {
     pointList.add(new Point(x, y, random(0,1), pointRadius));
     return true;
  }
  
  return false;
}


/*
 * Attempts to place numPoints many points into the picture and adds them to pointList
 */
ArrayList createPoints() {
  
  ArrayList<Point> pointList = new ArrayList(numPoints);
  
  int points = 0;
  int trials = 0;
  do {
    float positionX = random(0, width-1);
    float positionY = random(0, height-1);
    boolean accepted = insertPoint(sourceIntensity, pointList, positionX, positionY);
    if (accepted) {
      points++;
    }
    trials++;
  } while ((points<numPoints) && (trials<numTrials));
    
    return pointList;
}

int nearestPoint(float x, float y, ArrayList<Point> pointList) {
  int ind = -1;
  float minD=width+height;

  int ix = (int)round(x/(gridX-1));
  int iy = (int)round(y/(gridY-1));

  for (int i=0; i<pointList.size(); i++) {
    Point p = pointList.get(i);
    float d = p.distXY(x, y);
    if (d < minD) {
      ind = i;
      minD = d;
    }
  }

  return ind;
}

PImage voronoiDiagram (ArrayList<Point> pointList) {
  PImage resultImage = createImage(width, height, RGB);
  for (int y = 0; y < height; y++ ) {
    for (int x = 0; x < width; x++) {
      int i = nearestPoint(x, y, pointList);
      resultImage.set(x, y, intToColor(i));
    }
  }
  return resultImage;
}

void movePointsUnweighted(ArrayList<Point> pointList) {

  float dx=3, dy=3;

  for (Point p : pointList) p.voronoiIni();


  for (float y=0; y<height; y+=dy) {
    for (float x=0; x<width; x+= dx) {
      Point p = pointList.get(nearestPoint(x, y, pointList));

      float it = 1-min(0.9, sourceIntensity[(int)round(p.x)][(int)round(p.y)]);
      p.tx += x;
      p.ty += y;
      p.n += 1;
    }
    print("+");
  }

  for (Point p : pointList) p.voronoiMove();

  println(" ... Moved");
}


void movePoints(ArrayList<Point> pointList) {

  float dx=3, dy=3;

  for (Point p : pointList) p.voronoiIni();


  for (float y=0; y<height; y+=dy) {
    for (float x=0; x<width; x+= dx) {
      Point p = pointList.get(nearestPoint(x, y, pointList));

      float it = 1-min(0.9, sourceIntensity[(int)round(p.x)][(int)round(p.y)]);
      p.tx += x*it;
      p.ty += y*it;
      p.n += it;
    }
    print("+");
  }

  for (Point p : pointList) p.voronoiMove();

  println(" ... Moved");
}

/*
 * Gets a list of points and renders them into a PImage
 */
PImage createOutputImage(ArrayList<Point> pointList) {
  
  PGraphics pointGraphics = createGraphics(width, height);
  
  pointGraphics.beginDraw();
  pointGraphics.background(255);
  pointGraphics.fill(0);
  for (int i=0;i < pointList.size();i++) {
    Point p = pointList.get(i);
    pointGraphics.ellipse(p.x, p.y, 2*p.r, 2*p.r); // Draw an ellipse with the major axes being twice the radius
  }
  pointGraphics.endDraw();

  return pointGraphics; // PGraphics is a PImage with extra drawing stuff tacked on.
}

PImage createOutputImageBetter(ArrayList<Point> pointList) {

  PGraphics pg = createGraphics(width, height);

  pg.beginDraw();
  pg.background(255);
  pg.fill(0);
  for (int i=0; i<pointList.size(); i++) {
    Point p = (Point)pointList.get(i);
    if (sourceIntensity[(int)p.x][(int)p.y] < 0.95)
    pg.ellipse(p.x, p.y, 2*p.r, 2*p.r);
  }
  pg.endDraw();

  return pg;
}

void settings() {
  inputImage = loadImage("data/stone_figure.png");
  inputImage.resize(0,1000);
  size(inputImage.width, inputImage.height); // this is now the actual size
}
  
void setup() {
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
  computedPoints = new ArrayList<Point>();
}

void draw() {
  image(outputImage,0,0);
}

void keyPressed() {
  if (key=='s') save("result.png");
  
  if (key=='1') {
     computedPoints.clear();
     outputImage = inputImage;
     computed = false;
  }
  if (key=='2') {
      if (!computed) {
        computedPoints = createPoints();
        computed = true;
      }
      outputImage = createOutputImage(computedPoints);
  }
  if (key=='3') {
    if (!computed) {
        computedPoints = createPoints();
        computed = true;
      }
      movePointsUnweighted(computedPoints);
      //outputImage = createOutputImage(computedPoints);
      outputImage = voronoiDiagram(computedPoints);
  }
  if (key=='4') {
    if (!computed) {
        computedPoints = createPoints();
        computed = true;
      }
      movePoints(computedPoints);
      //outputImage = createOutputImage(computedPoints);
      outputImage = voronoiDiagram(computedPoints);
  }
  
  /*
  if (key=='4') {
    movePoints(computedPoints);
    outputImage = createOutputImageBetter(computedPoints);
  }
  */

  if (key=='+') {
      numPoints *= 1.3;
      ArrayList pointList = createPoints();
      outputImage = createOutputImage(pointList);
  } 
  if (key=='-') {
      numPoints /= 1.3;
      ArrayList pointList = createPoints();
      outputImage = createOutputImage(pointList);
  } 
}
