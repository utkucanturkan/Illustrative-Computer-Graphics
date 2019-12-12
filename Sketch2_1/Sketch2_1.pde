PImage inputImage, outputImage; //<>// //<>// //<>// //<>//

float [][] sourceIntensity;

float pointRadius = 2;
int numPoints = 50000; 
int numTrials = 1000000;

// The Point class provides basic storage of 2D points and 3D points with a radius  

class Point {
  float x, y, z, r; // R is used for the radius of a point

  Point(float px, float py) {
    x = px; 
    y = py; 
    z = 0; 
    r = 1; //2D case: Default radius to 1, so all are uniform
  }

  Point(float px, float py, float pz, float pr) {
    x = px; 
    y = py; 
    z = pz; 
    r = pr;
  }

  Point (Point p) {
    x = p.x; 
    y = p.y;
    z = p.z;
    r = p.r;
  }

  // Computes euclidian distance between this point and another coordinate pair in the XY plane
  float distXY(float px, float py) {
    return sqrt((x-px)*(x-px) + (y-py)*(y-py));
  }
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

  outputImage = createImage(w, h, RGB);
  for (int y=0; y<h; ++y)
    for (int x = 0; x < w; ++x) {
      float val = 255.0 * (1.0 - outputIntensity[x][y]);
      outputImage.pixels[x+y*w] = color(val, val, val);
    }

  return outputImage;
}


/*
 * Takes a PImage sourceImage and converts it to greyscale intensity array with values in [0.0 - 1.0]
 */
void createIntensityVal(PImage sourceImage, float[][] intensityArray) {
  sourceImage.loadPixels();
  for (int y=0; y<sourceImage.height; y++)
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
boolean insertPoint(float [][] intensityArray, ArrayList<Point> pointList, float x, float y) {
  // TODO: Fill in according to task in slides. Also return true if a point was placed and false if no point was placed

  int px=(int)round(x);
  int py=(int)round(y);

  float randomPointAvgIntensity = getAvgIntensity(int(px-1), int(py-1), int(px+1), int(py+1), intensityArray);
  if (randomPointAvgIntensity > intensityArray[px][py]) {
    pointList.add(new Point(px, py, 0, pointRadius));
    return true;
  } else {
    return false;
  }
}


/*
 * Attempts to place numPoints many points into the picture and adds them to pointList
 */
ArrayList<Point> createPoints() {
  int points = 0;
  int trials = 0;
  ArrayList<Point> pointList = new ArrayList<Point>(numPoints);

  //Fill point list with random points until you have numPoints many of them
  while (points <= numPoints) {
    float randomPositionX = random(1, width-1);
    float randomPositionY = random(1, height-1);
    println("Points Number: " + pointList.size());
    // Check each point with insertPoint
    if (insertPoint(sourceIntensity, pointList, randomPositionX, randomPositionY)) {      
      // Keep track of how many points you have and how many trials overall.
      points+=1;
    } else {
      trials+=1;
    }

    // Stop when you achieve the number of points or run out of trials.
    if (trials >= numTrials) {
      return pointList;
    }
  }
  return pointList;
}


/*
 * Gets a list of points and renders them into a PImage
 */
PImage createOutputImage(ArrayList<Point> pointList) {

  PGraphics pointGraphics = createGraphics(width, height);

  pointGraphics.beginDraw();
  pointGraphics.background(255);
  pointGraphics.fill(0);
  // TODO: Draw all points in pointList using pointGraphics.ellipse()
  for (Point p : pointList) {
    pointGraphics.ellipse(p.x, p.y, p.r, p.r);
  }
  pointGraphics.endDraw();

  return pointGraphics; // PGraphics is a PImage with extra drawing stuff tacked on.
}

void settings() {
  inputImage = loadImage("data/stone_figure.png");
  inputImage.resize(0, 1000);
  size(inputImage.width, inputImage.height); // this is now the actual size
}

void setup() {
  frameRate(3);
  sourceIntensity = new float [inputImage.width][inputImage.height];
  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
}

void draw() {
  image(outputImage, 0, 0);
}

void keyPressed() {
  if (key=='s') save("result.png");

  if (key=='1') {
    outputImage = inputImage;
  }
  if (key=='2') {  
    ArrayList pointList = createPoints();
    outputImage = createOutputImage(pointList);
  }  

  if (key=='+') {
    numPoints *= 1.3;
    ArrayList<Point> pointList = createPoints();
    outputImage = createOutputImage(pointList);
  } 
  if (key=='-') {
    numPoints /= 1.3;
    ArrayList<Point> pointList = createPoints();
    outputImage = createOutputImage(pointList);
  }
}
