PImage inputImage; //<>// //<>// //<>// //<>//
PImage outputImage;

float [][] sourceIntensity;

float poissonDiscRadius = 15;
float pointRadius = 3;
int numPoints = 50000; 
int numTrials = 1000000;

ArrayList _pList = new ArrayList<Point>();

// The Point class provides basic storage of 2D points and 3D points with a radius  

class Point {
  float x, y, z, r; // R is used for the radius of a point
  float tx, ty, n;

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

  void voronoiInit() {
    tx = ty = n = 0;
  }

  void voronoiMove() {
    x = tx/n;
    y = ty/n;
    x = constrain(x, 20, width-20);
    y = constrain(y, 20, height-20);
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
  float rad = 1/(0.1+1-randomPointAvgIntensity);
  //
  poissonDiscRadius = rad;

  if (randomPointAvgIntensity > intensityArray[px][py] && isFarEnough(x, y, pointList)) {
    pointList.add(new Point(px, py, 0, pointRadius));
    return true;
  } else {
    return false;
  }
}

boolean isFarEnough(float x, float y, ArrayList<Point> points) {
  Point _p = new Point(x, y, 0, pointRadius);
  for (Point p : points) {
    if (dist(p, _p) < poissonDiscRadius) {
      return false;
    }
  }
  return true;
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
    float randomPositionX = int(random(1, width));
    float randomPositionY = int(random(1, height));
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
      break;
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
  pointGraphics.noStroke();
  // TODO: Draw all points in pointList using pointGraphics.ellipse()
  for (Point p : pointList) {
    pointGraphics.ellipse(p.x, p.y, p.r, p.r);
  }
  pointGraphics.endDraw();

  return pointGraphics; // PGraphics is a PImage with extra drawing stuff tacked on.
}

PImage voronoiDiagram(PImage img, ArrayList<Point> pointList) {
  PImage voronoiImage = createImage(img.width, img.height, RGB);

  for (int y=0; y<img.height; y++) {
    for (int x=0; x<img.width; x++) {

      Point referencePoint = new Point(x, y, 0, pointRadius);
      float min_distance = dist(referencePoint, pointList.get(0));

      for (Point point : pointList) {
        float distance = dist(referencePoint, point);
        if (distance <= min_distance) {
          voronoiImage.set(x, y, intToColor(pointList.indexOf(point)));
          min_distance = distance;
        }
      }
    }
  }

  return voronoiImage;
}

color intToColor(int i) {
  int r = (i % 64);
  int g = ((i>>6) % 64);
  int b = ((i>>12) % 64);
  return color(r, g, b);
}

int colorToInt(color c) {
  int r = (int)(c>> 16 & 0xFF);
  int g = (int)(c>> 8 & 0xFF);
  int b = (int)(c & 0xFF);
  return r + (g<<6) + (b<<12);
}

int nearestPoint(float x, float y, ArrayList<Point> pointList) {
  int ind = -1;
  float min0 = width * height;

  for (int i=0; i<pointList.size(); i++) {
    Point p = pointList.get(i);
    float d = p.distXY(x, y);
    if (d<min0) {
      ind = i;
      min0 = d;
    }
  }
  return ind;
}

void movePoints(ArrayList<Point> pointList) {

  float dx=3, dy=3;
  for (Point p : pointList) {
    p.voronoiInit();
  }
  for (int y = 0; y < height; y+=dy) {
    for (int x = 0; x < width; x+=dx) {
      Point p = pointList.get(nearestPoint(x, y, pointList));
      p.tx += x;
      p.ty += y;
      p.n += 1;
    }
  }
  for (Point p : pointList) {
    p.voronoiMove();
  }


  /*
  PImage vorImg = voronoiDiagram(inputImage, pointList); // image with the color coded cells
   if (vorImg == null) {
   return;
   }
   
   for (int i = 0; i < pointList.size(); i++) {
   Point tp = pointList.get(i);
   tp.tx = 0;
   tp.ty = 0;
   tp.n = 0;
   }
   
   for (int x = 0; x < width; x++) {
   println("column:"+ x);
   for (int y = 0; y < height; y++) {
   int ic = colorToInt(vorImg.get(x, y)); // index of the generating point
   pointList.get(ic).tx += x; // sum up pixel positions of that point
   pointList.get(ic).ty += y;
   pointList.get(ic).n += 1; // sum pixels that belong to that point
   }
   }
   
   for (int j = 0; j < pointList.size(); j++) {
   // compute center of gravity for each
   pointList.get(j).x = pointList.get(j).tx/pointList.get(j).n;
   pointList.get(j).y = pointList.get(j).ty/pointList.get(j).n;
   }
   */
}

void settings() {
  inputImage = loadImage("data/stone_figure.png");
  //inputImage = loadImage("data/rampe.png");
  inputImage.resize(0, 1000);
  size(inputImage.width, inputImage.height); // this is now the actual size
}

void setup() {
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
  for (int i=0; i<10; i++) {
    for (int j=0; j<10; j++) {
      _pList.add(new Point(int(random(width)), int(random(height)), 0, 5));
    }
  }
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
  if (key=='3') {
    movePoints(_pList);
    outputImage = createOutputImage(_pList);
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