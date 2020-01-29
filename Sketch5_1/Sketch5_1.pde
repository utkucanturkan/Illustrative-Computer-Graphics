// Sketch 5-1 

float [][] sourceImageArray, outputImageArray;
int imageHeight = 500;

// parameters for the canny edge detector
float clow = 2;
float chigh = 6;

PImage inputImage, outputImage, depthImage, normalMap;

float epsilon = 0.5;

///////////////////////////////////////////////////
//
// some help routines for reading an image and outputting
//
//////////////////////////////////////////////////

///////////////////////////////////////////////////

PImage selectChannel(PImage img, int channelNumber) {

  PImage res = createImage(img.width, img.height, RGB);
  img.loadPixels();

  for (int y = 0; y < img.height; ++y) {
    for (int x = 0; x < img.width; ++x) {
      float r = red(img.pixels[x+y*img.width]);
      float g = green(img.pixels[x+y*img.width]);
      float b = blue(img.pixels[x+y*img.width]);
      switch (channelNumber) {
      case 0: 
        res.pixels[x+y*img.width] = color(r, r, r);
        break;
      case 1: 
        res.pixels[x+y*img.width] = color(g, g, g);
        break;
      case 2: 
        res.pixels[x+y*img.width] = color(b, b, b);
        break;
      }
    }
  }

  res.updatePixels();

  return res;
}

///////////////////////////////////////////////////

PImage markDepth(PImage depth, int desiredDepth) {

  PImage res = createImage(depth.width, depth.height, RGB);
  depth.loadPixels();

  for (int y = 0; y < depth.height; ++y) {
    for (int x = 0; x < depth.width; ++x) {
      float d = brightness(depth.pixels[x+y*depth.width]);
      if (d == desiredDepth) {
        res.pixels[x+y*depth.width] = color(255, 0, 0);
      } else {
        res.pixels[x+y*depth.width] = color(0, 0, 0);
      }
    }
  }
  res.updatePixels();

  return res;
}

///////////////////////////////////////////////////
PImage modulateImage1(PImage img, PImage depth, PImage nmap) {
  PImage res = createImage(depth.width, depth.height, RGB);  
  PImage e = createEdgesCanny(img, clow, chigh);
  PImage red = createEdgesCanny(selectChannel(depth, 0), clow, chigh);  
  // different components of the normal edges
  PImage normalRedEdges = createEdgesCanny(selectChannel(nmap, 0), clow, chigh);
  PImage normalGreenEdges = createEdgesCanny(selectChannel(nmap, 1), clow, chigh);
  PImage normalBlueEdges = createEdgesCanny(selectChannel(nmap, 2), clow, chigh);

  // Blending red, green and blue edges 
  normalRedEdges.blend(normalGreenEdges, 0, 0, res.width, res.height, 0, 0, res.width, res.height, DARKEST);
  normalRedEdges.blend(normalBlueEdges, 0, 0, res.width, res.height, 0, 0, res.width, res.height, DARKEST);

  for (int i=0; i<res.width*res.height; i++) {
    res.pixels[i] = white;

    // Mark corresponding pixels in the image
    if (red.pixels[i] == black) {
      res.pixels[i] = color(255, 0, 0);
    }

    if (normalRedEdges.pixels[i] == black) {
      res.pixels[i] = color(0, 0, 255);
    }

    if (e.pixels[i] == black) {
      res.pixels[i] = black;
    }
  }
  res.updatePixels(); 
  return res;
}


PImage modulateImage2(PImage img, PImage nmap) {
  PImage res = new PImage(img.width,img.height);
  PVector viewVector = new PVector(0, 0, 1);
  int w = img.width;
  int h = img.height;

  for (int y=0; y<h; y++) {
    for (int x=0; x<w; x++) {
      
      // set all pixels of the new image
      res.pixels[x+y*w] = color(255, 255, 255);
      
      // get the pixel with indices(x,y) of normalMap picture
      color pixelOfNormalMap = nmap.get(int(x),int(y));
      
      // calculate normalVector of pixel by RGB components
      PVector normalVector = new PVector(red(pixelOfNormalMap)/255, green(pixelOfNormalMap)/255, blue(pixelOfNormalMap)/255);
      float nv = viewVector.dot(normalVector);
      
      // if epsilon is bigger than dot production of viewVector and normalVector
      // set the pixel black
      if (abs(nv)<epsilon) {
        res.pixels[x+y*w] = color(0,0,0);
      }
    }
  }
  
  return res;
}

/////////////////////////////////////////////////////////////////////////////

PImage createEdgesCanny(PImage img, float low, float high) {

  //create the detector CannyEdgeDetector 
  CannyEdgeDetector detector = new CannyEdgeDetector();

  //adjust its parameters as desired 
  detector.setLowThreshold(low); 
  detector.setHighThreshold(high); 

  //apply it to an image 
  detector.setSourceImage(img);
  detector.process(); 
  return detector.getEdgesImage();
}

///////////////////////////////////////////////////  
//
// this is executed only once at the start of the program
//
///////////////////////////////////////////////////

void setup() { 

  //inp = loadImg("Select Input image");
  inputImage = loadImage("data/dragon.png");
  inputImage.resize(0, imageHeight); // proportional scale to height=500

  size(500, 500); // size must always have fixed parameters...
  surface.setResizable(true);
  surface.setSize(inputImage.width, inputImage.height); // this is now the actual size
  frameRate(3);

  // depth = loadImg("Select depth Image");
  depthImage = loadImage("data/dragon_depth.png");
  depthImage.resize(0, imageHeight); // proportional scale to height=500

  //nmap = loadImg("Select normal Image");
  normalMap = loadImage("data/dragon_normal.png");
  normalMap.resize(0, imageHeight); // proportional scale to height=500

  outputImage = inputImage;
}

/////////////////////////////////////////////////////
//
// this is automatically executed frameRate()-times
// per second
//
/////////////////////////////////////////////////////

void draw() {

  // Displays the image at its actual size at point (0,0)
  image(outputImage, 0, 0);
}

//////////////////////////////////////////////////////////////
void mouseMoved() {
  epsilon = (float)mouseX / (float)width;
  println("Epsilon ; " + epsilon);
}

void keyPressed() {
  if (key=='1') {
    outputImage = inputImage;
  }
  if (key=='2') {
    outputImage = depthImage;
  }
  if (key=='3') {
    outputImage = normalMap;
  }

  if (key=='4') { 
    outputImage = createEdgesCanny(inputImage, 4, 14);
  }

  if (key=='5') { 
    outputImage = createEdgesCanny(depthImage, 4, 14);
    outputImage.filter(ERODE);
  }

  if (key=='6') {
    outputImage = modulateImage2(inputImage, normalMap);
  }

  if (key=='a') {
    chigh -= 0.2;
    outputImage = modulateImage1(inputImage, depthImage, normalMap);
  }
  if (key=='s') {
    chigh += 0.2;
    outputImage = modulateImage1(inputImage, depthImage, normalMap);
  }
  if (key=='q') {
    clow -= 0.1;
    outputImage = modulateImage1(inputImage, depthImage, normalMap);
  }
  if (key=='w') {
    clow += 0.1;
    outputImage = modulateImage1(inputImage, depthImage, normalMap);
  }
  println("Low: " + clow + " High: " + chigh);
}
