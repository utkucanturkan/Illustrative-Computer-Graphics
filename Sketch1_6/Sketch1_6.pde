// Sketch 1-6 screening with characters 

float [][] sourceIntensity;
float [][] outputIntensity;

PImage inputImage;
PImage outputImage;
int maskX = 8;
int maskY = 14;

PFont font;
PImage ci[][];


/*
 * Converts an intensity array to a PImage (RGB)
 */
PImage convertIntensityToPImage(float [][] intensityArrayImg) {

  int w = intensityArrayImg.length;
  int h = intensityArrayImg[0].length;

  PImage convertedImage = createImage(w, h, RGB);
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < w; ++x) {
      float val = 255.0 * intensityArrayImg[x][y];
      convertedImage.pixels[x+y*w] = color(val, val, val);
    }

  return convertedImage;
}

/*
 * Initializes the passed float array with the corresponding intensity values of the source image.
 * intensityArray is passed BY REFERENCE so changes will be made to it.
 */

void createIntensityVal(PImage sourceImage, float[][] intensityArray) {
  // PImage.pixels is only filled with valid data after loadPixels() is called
  // After PImage pixels is changed, you must call updatePixels() for the changes
  // to have effect.
  sourceImage.loadPixels();
  for (int y = 0; y < sourceImage.height; ++y) {
    for (int x = 0; x < sourceImage.width; ++x) {
      intensityArray[x][y] = brightness(sourceImage.pixels[x + y*sourceImage.width]) / 255.0;
    }
  }
}

///////////////////////////////////////////////////

float getAvgIntensity(int x1, int y1, int x2, int y2, float [][] S) {

  int w = S.length;
  int h = S[0].length;
  x1 = max(0, min(w, x1));
  x2 = max(0, min(w, x2));
  y1 = max(0, min(h, y1));
  y2 = max(0, min(h, y2));
  float r = 0;

  for (int y=y1; y<y2; y++)
    for (int x = x1; x<x2; x++) 
      r += S[x][y];

  return r/((x2-x1)*(y2-y1));
}


/////////////////////////////////////////////////

void createFontImages() {

  PGraphics g = createGraphics(maskX, maskY); 
  ci = new PImage[10][26];
  font = loadFont("AbadiMT-CondensedExtraBold-20.vlw");

  g.beginDraw();
  for (int i=0; i<10; i++) {
    int mapSize = 5+2*i;
    print("+");
    for (int k=0; k<26; k++) {
      g.textFont(font, mapSize-2); 
      g.background(255);
      g.stroke(0); 
      g.fill(0);
      g.textAlign(CENTER, CENTER);
      g.text((char)('A'+k), maskX/2-1, maskY/2-2);
      ci[i][k]=g.get(0, 0, maskX, maskY);
      // print("+");
    }
  }
  g.endDraw();
}

void dither_screening_characters(float[][] S, float[][] O) {

  int w = S.length;
  int h = S[0].length;
  // TODO
  for (int sourceYAxis=0; sourceYAxis<h; sourceYAxis+=maskY) {
    for (int sourceXAxis=0; sourceXAxis<w; sourceXAxis+=maskX) {
      float blockAvgIntensity = getAvgIntensity(sourceXAxis, sourceYAxis, (sourceXAxis + maskX), (sourceYAxis + maskY), S);

      for (int letterRowIndex = 0; letterRowIndex<ci.length; letterRowIndex++) {
        for (int letterColIndex = 0; letterColIndex<ci[0].length; letterColIndex++) {
          PImage letterImage = ci[letterRowIndex][letterColIndex];

          float[][] letterImageIntensity = new float[letterImage.width][letterImage.height];
          createIntensityVal(letterImage, letterImageIntensity);

          float letterAvgIntensity = getAvgIntensity(0, 0, letterImage.width, letterImage.height, letterImageIntensity);
          if (round(blockAvgIntensity*100)/10f == round(letterAvgIntensity*100)/10f) {      
            int letterImageY = 0;
            for (int outputY=0; outputY<letterImage.height; outputY++) {               //<>//
              int letterImageX = 0;
              for (int outputX=0; outputX<letterImage.width; outputX++) {
                //if ((sourceXAxis+outputX)<1000 && (sourceYAxis+outputY) < 1000) {
                  O[sourceXAxis+outputX][sourceYAxis+outputY] = letterImageIntensity[letterImageX][letterImageY];
                  letterImageX++;
                //}
              }
              letterImageY++;
            }
          }
        }
      }
    }
  }
}


void settings() {
  inputImage = loadImage("data/blume.png");
  inputImage.resize(0, 1000);
  size(inputImage.width, inputImage.height); // this is now the actual size
}

void setup() { 
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  outputIntensity = new float [inputImage.width][inputImage.height];

  createIntensityVal(inputImage, sourceIntensity);

  outputImage = inputImage;   

  createFontImages();
}


void draw() {
  // Displays the image at its actual size at point (0,0)
  image(outputImage, 0, 0);
}

void keyPressed() {
  if (key=='1') {
    outputImage = inputImage;
  }
  if (key=='2') {
    createIntensityVal(inputImage, sourceIntensity);
    dither_screening_characters(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='s') {
    save("output.png");
  }
}
