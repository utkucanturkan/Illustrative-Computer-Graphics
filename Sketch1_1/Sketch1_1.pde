// Sketch 1-1 threshold and random dither //<>//

float [][] sourceIntensity;
float [][] outputIntensity;

PImage inputImage;  // Loaded input image, do not alter!
PImage outputImage; // Put your result image in here, so it gets displayed


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

void dither_treshold(float[][] S, float[][] O) {

  // TODO: Iterate all pixels in S. Compare the intensity to a threshold value (e.g. 0.5) and set the corresponding pixel
  // in O to 0.0 if the intensity if below the threshold. Set it to 1.0 if it is greater or equal.
  // Hint: Access is S[x][y]. So the length of S is the width of the image and the length of S[0] is the height.
  // Accessing S[0][1] accesses the pixel in the first column, in the second row.
  // . . .
  // x . .     <- S[0][1]
  // . . .   

  for (int x=0; x<S.length; x++) {
    for (int y=0; y<S[0].length; y++) {
      if (S[x][y] > 0.5) {
        O[x][y] = 1.0;
      } else {
        O[x][y] = 0.0;
      }
    }
  }
}

void dither_random(float[][] S, float[][] O) {
  // TODO: Do the same as in dither_threshold, but add or subtract a small value form the threshold.
  // Change the random value for each pixel.
  for (int y=0; y<S[0].length; y++) {
    for (int x=0; x<S.length; x++) {
      if (S[x][y] > random(0, 1)) {
        O[x][y] = 1.0;
      } else {
        O[x][y] = 0.0;
      }
    }
  }
} 

/*
 * Setup gets called ONCE at the beginning of the sketch. Load images here, size your window etc.
 * If you want to size your window according to the input image size, use settings().
 */

void settings() {
  inputImage = loadImage("data/rampe.png");
  size(inputImage.width, inputImage.height); // this is now the actual size
} 

void setup() {
  surface.setResizable(false);
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  outputIntensity = new float [inputImage.width][inputImage.height];

  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
}

/*
 * In this function, outputImage gets drawn to the window. Code in here gets executed EVERY FRAME
 * so be careful what you put here. You should only compute the dithering once, hence don't put
 * any calls to it here. 
 */
void draw() {

  // Displays the image at its actual size at point (0,0)
  image(outputImage, 0, 0);
}

/*
 * This function gets called when a key is pressed. Use it to control your program and change parameters
 * via key input. 
 */

void keyPressed() {
  if (key=='1') {
    outputImage = inputImage;
  }
  if (key=='2') {
    dither_treshold(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='3') {
    dither_random(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key == 's') save("output.png");
}
