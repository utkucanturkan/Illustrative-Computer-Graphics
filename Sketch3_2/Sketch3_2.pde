// Sketch 3-1 
 
float [][] sourceImageArray, outputImageArray;
int imageHeight = 500;

// parameters for the canny edge detector
float clow = 2;
float chigh = 6;

PImage inputImage, outputImage, depthImage, normalMap;

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
          case 0: res.pixels[x+y*img.width] = color(r,r,r);
                  break;
          case 1: res.pixels[x+y*img.width] = color(g,g,g);
                  break;
          case 2: res.pixels[x+y*img.width] = color(b,b,b);
                  break;
        }
    }
  }
  
  res.updatePixels();
  
  return res;
}

///////////////////////////////////////////////////

PImage markDepth(PImage depth, int desiredDepth) {

  PImage res = createImage(depth.width,depth.height,RGB);
  depth.loadPixels();
  
  for (int y = 0; y < depth.height; ++y) {
    for (int x = 0; x < depth.width; ++x) {
        float d = brightness(depth.pixels[x+y*depth.width]);
        if(d == desiredDepth) {
          res.pixels[x+y*depth.width] = color(255,0,0);
        } else {
          res.pixels[x+y*depth.width] = color(0,0,0);
        }
    }
  }
  res.updatePixels();
  
  return res;
}

///////////////////////////////////////////////////

PImage modulateImage1(PImage img, PImage depth, PImage nmap) {
  PImage res = img.copy();  
  PImage blurred = depth.copy();
  PImage depthImage = depth.copy();
  
  blurred.filter(BLUR, 15);  
  depthImage.blend(blurred, 0, 0, res.width, res.height, 0, 0, res.width, res.height, SUBTRACT);
  
  depthImage.loadPixels();
  for (int i = 0; i < res.width*res.height; i++) {
    float br = brightness(depthImage.pixels[i]);
    if(depthImage.pixels[i] != color(0, 0, 0))
      depthImage.pixels[i] = color(br, br, br);
  }
  depthImage.updatePixels();
  res.blend(depthImage, 0, 0, img.width, img.height, 0, 0, depth.width, depth.height, SUBTRACT);
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
  inputImage = loadImage("data/venus.png");
  inputImage.resize(0,imageHeight); // proportional scale to height=500

  size(500,500); // size must always have fixed parameters...
  surface.setResizable(true);
  surface.setSize(inputImage.width, inputImage.height); // this is now the actual size
  frameRate(3);

  // depth = loadImg("Select depth Image");
  depthImage = loadImage("data/venus_depth.png");
  depthImage.resize(0,imageHeight); // proportional scale to height=500

  //nmap = loadImg("Select normal Image");
  normalMap = loadImage("data/venus_normal.png");
  normalMap.resize(0,imageHeight); // proportional scale to height=500

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
    outputImage = createEdgesCanny(inputImage,4,14);
  }
 
  if (key=='5') { 
    outputImage = createEdgesCanny(depthImage,4,14);
  }
 
  if (key=='6') {
     outputImage = modulateImage1(inputImage,depthImage,normalMap);
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
