// Sketch 1-5 Hints //<>//

float [][] sourceIntensity;
float [][] outputIntensity;

float [][] maskIntensity;

PImage inputImage;  // Loaded input image, do not alter!
PImage outputImage; // Put your result image in here, so it gets displayed

PImage ditherKernel; //Digital Screening

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

void dither_floydSteinberg1D(float[][] S, float[][] O) {
  for (int y=0; y<S[0].length-1; y++) {
    for (int x=0; x<S.length-1; x++) {
      float K = (S[x][y] > 0.5) ? 1.0 : 0.0;
      O[x][y] = K;
      float error = S[x][y] -K;
      S[x+1][y] += error;
    }
  }
  createIntensityVal(inputImage, sourceIntensity);
}

void dither_floydSteinberg2D(float[][] S, float[][] O) {
  for (int y=0; y<S[0].length-1; y++) {
    for (int x=1; x<S.length-1; x++) {
      float K = (S[x][y] > 0.5) ? 1.0 : 0.0;
      O[x][y] = K;
      float error = S[x][y] - K;
      S[x+1][y] += 7f/16 * error;
      S[x-1][y+1] += 3f/16 * error;
      S[x][y+1] += 5f/16 * error; 
      S[x+1][y+1] += 1f/16 * error;
    }
  }
  createIntensityVal(inputImage, sourceIntensity);
}

void dither_lineErrorDiffusion(float[][] S, float[][] O) {
  int m = 3; //line pixel long

  for (int y=0; y<S[0].length-1; y++) {
    for (int x=1; x<S.length-1; x++) {
      float K = (S[x][y] > 0.5) ? 1.0 : 0.0;
      O[x][y] = K;
      float error = 0.0;
      if (K==0) {
        drawLine(O, x, y, m);
        error = S[x][y] - K + (m-1);
      } else {
        error = S[x][y] - K;
      }
      S[x+1][y] += 7f/16 * error;
      S[x-1][y+1] += 3f/16 * error;
      S[x][y+1] += 5f/16 * error; 
      S[x+1][y+1] += 1f/16 * error;
    }
  }
  createIntensityVal(inputImage, sourceIntensity);
}

void drawLine(float[][] O, int x, int y, int size) {
  // go minus left-top pixel from (x,y) on O coordinate and set the pixels as 0.0 (black)
  for (int i=1; i<=size; i++) {
    if (x-i>0 && y-i>0) {
      O[x-i][y-i] = 0.0;
    }
  }
}

void digitalScreening(float[][] S, float[][] M, float[][] O) {
  int m = M.length;
  int n = M[0].length;
  for (int x=0; x<S.length; x++) {
    for (int y=0; y<S[0].length; y++) {
      O[x][y] = (S[x][y] < M[x%m][y%n]) ? 0.0 : 1.0;
    }
  }  
  createIntensityVal(inputImage, sourceIntensity);
}

void rotate2D_fixed(float[] r, int w, int h, float radians) {
  float x = (float)r[0];
  float y = (float)r[1];

  float xr =x-w/2.0;
  float yr = y-h/2.0;

  float x_rot = (xr*cos(radians)-yr*sin(radians));
  float y_rot = (xr*sin(radians)-yr*sin(radians));

  x_rot += w/2.0;
  y_rot += h/2.0;

  r[0] = (int) x_rot;
  r[1] = (int) y_rot;
}

void rotatePos(float[] p, int w, int h, float radians) {
  rotate2D_fixed(p, w, h, radians);
  p[0] += w;
  p[1] += h;
}
/*
float[] mapping(int x, int y, int angle) {
  float kernelSize = 8f;
  float[] result = new float[2];
  //rotatePos(result, x, y, angle);
  
  result[0] = ((result[0]%kernelSize)/kernelSize);
  result[1] = ((result[1]%kernelSize)/kernelSize);
  return result;
}
*/

PVector mapping(int x, int y, int radians) {
  float kernelSize = 8f;
  PVector mapVector = new PVector(x,y);
  mapVector.rotate(radians);  
  mapVector.x += width;
  mapVector.y += height;
  mapVector.x = ((mapVector.x%kernelSize)/kernelSize);
  mapVector.y = ((mapVector.y%kernelSize)/kernelSize);
  return mapVector;
}

void draw_xyz_kernel(float[][] S, float[][] O, float k, int angle) {
  float i, s, t;
  for (int x=0; x<S.length; x++) {
    for (int y=0; y<S[0].length; y++) {
      /*
      float[] m = mapping(x, y, angle);
      s = m[0];
      t = m[1];
      */
      PVector m = mapping(x, y, angle);
      s = m.x;
      t = m.y;
      i = kernel_cross((float)s, (float)t, k);
      //i = dither_kernel((float)s);
      O[x][y] = (S[x][y]<i) ? 0.0 : 1.0;
    }
  }
}

float kernel_cross(float s, float t, float I) {
  if (s<=I) {
    return I * t;
  } else {
    return ((1.f - I) * s) + I;
  }
}

float dither_kernel(float s) {
  if (s <= 0.5) {
    return 2 * s;
  } else {
    return 2 - 2 * s;
  }
}
/*
 * Setup gets called ONCE at the beginning of the sketch. Load images here, size your window etc.
 * If you want to size your window according to the input image size, use settings().
 */

void settings() {
  inputImage = loadImage("data/rampe.png");
  ditherKernel = loadImage("data/dither/4.png");

  size(inputImage.width, inputImage.height); // this is now the actual size
} 

void setup() {
  surface.setResizable(false);
  frameRate(1);
  ditherKernel.resize(16, 16);
  sourceIntensity = new float [inputImage.width][inputImage.height];
  outputIntensity = new float [inputImage.width][inputImage.height];
  maskIntensity = new float [ditherKernel.width][ditherKernel.height];

  createIntensityVal(inputImage, sourceIntensity); 
  createIntensityVal(ditherKernel, maskIntensity);

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
    draw_xyz_kernel(sourceIntensity, outputIntensity, 0.3, 20);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  /*
  if (key=='2') {
   dither_treshold(sourceIntensity, outputIntensity);
   outputImage = convertIntensityToPImage(outputIntensity);
   }
   if (key=='3') {
   dither_random(sourceIntensity, outputIntensity);
   outputImage = convertIntensityToPImage(outputIntensity);
   }
   if (key=='4') {
   dither_floydSteinberg1D(sourceIntensity, outputIntensity);
   outputImage = convertIntensityToPImage(outputIntensity);
   }
   if (key=='5') {
   dither_floydSteinberg2D(sourceIntensity, outputIntensity);
   outputImage = convertIntensityToPImage(outputIntensity);
   }
   if (key=='6') {
   dither_lineErrorDiffusion(sourceIntensity, outputIntensity);
   outputImage = convertIntensityToPImage(outputIntensity);
   }
   if (key=='7') {
   digitalScreening(sourceIntensity, maskIntensity, outputIntensity);
   outputImage=convertIntensityToPImage(outputIntensity);
   }*/

  if (key == 's') save("output.png");
}
