PShader defaultShader;
PShader toonShader;
PShader depthShader;
PShader nvShader;
PShader contourShader;

PShader currentShader;

PShape sceneObject;

PVector cameraPos;
PVector sceneCenter;
PVector up;

float clipNear = 1;
float clipFar = 2000;

boolean drawContours = false;
PImage contourTexture;
float contour_D_modifier = 0.1;
float contour_S_modifier = 0.5;

void setup() {
  size(1000, 1000, P3D);
  noStroke();
  fill(204);

  // override wierd processing defaults
  cameraPos = new PVector(0.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0));
  sceneCenter = new PVector(0.0, 0.0, 0.0);
  up = new PVector(0, 1, 0);
  camera(cameraPos.x, cameraPos.y, cameraPos.z, 
    sceneCenter.x, sceneCenter.y, sceneCenter.z, 
    up.x, up.y, up.z);

  perspective(PI/3.0, (float)width/height, clipNear, clipFar);

  println("Loading shape...");
  sceneObject = loadShape("Blob.obj");
  sceneObject.scale(10);
  //sceneObject.rotateZ(radians(180));
  sceneObject.rotateX(radians(-45));

  /*sceneObject = loadShape("David.obj");
   sceneObject.scale(0.5);
   sceneObject.translate(0, 300, -200);
   sceneObject.rotateZ(radians(0));
   sceneObject.rotateX(radians(90));
   sceneObject.rotateY(radians(180));*/
  println("Loaded shape");

  println("Loading shaders...");
  defaultShader = loadShader("DefaultFrag.glsl", "DefaultVert.glsl");
  defaultShader.set("cameraPosition", cameraPos);

  toonShader = loadShader("ToonFrag.glsl", "ToonVert.glsl");
  toonShader.set("cameraPosition", cameraPos);

  depthShader = loadShader("DepthFrag.glsl", "DepthVert.glsl");
  depthShader.set ("farplane", clipFar);

  nvShader = loadShader("nvFrag.glsl", "nvVert.glsl");
  nvShader.set("cameraPosition", cameraPos);

  contourShader = loadShader("SuggestiveFrag.glsl");
  contourShader.set("radius", 2);
  contourShader.set("d_modifier", contour_D_modifier);
  contourShader.set("s_modifier", contour_S_modifier);

  currentShader = defaultShader;

  println("Loaded shaders");
}

PGraphics render(PShader shader) {
  PGraphics graphics = createGraphics(width, height, P3D);
  graphics.beginDraw();
  graphics.camera(cameraPos.x, cameraPos.y, cameraPos.z, 
    sceneCenter.x, sceneCenter.y, sceneCenter.z, 
    up.x, up.y, up.z);
  graphics.perspective(PI/3.0, (float)width/height, clipNear, clipFar);
  graphics.shader(shader);
  graphics.background(255);
  graphics.shape(sceneObject);
  graphics.endDraw();
  return graphics;
}

void applyContourFilter() {
  PGraphics nv = render(nvShader);
  nv.filter(contourShader);
  blend(nv, 0, 0, nv.width, nv.height, 0, 0, width, height, BLEND);
}

void draw() {
  background(255);
  shader(currentShader);
  float dirY = (mouseY / float(height) - 0.5) * 2;
  float dirX = (mouseX / float(width) - 0.5) * 2;
  directionalLight(204, 204, 204, -dirX, -dirY, -1);
  shape(sceneObject);

  if (drawContours) {
    applyContourFilter();
  }
}

void keyPressed() {
  if (key == '1') {
    currentShader = defaultShader;
  }
  if (key == '2') {
    currentShader = toonShader;
  }
  if (key == '3') {
    currentShader = depthShader;
  }
  if (key == '4') {
    currentShader = nvShader;
  }
  if (key == 'a') {
    sceneObject.rotateY(radians(10));
  }
  if (key == 'd') {
    sceneObject.rotateY(radians(-10));
  }
  if (key == 'w') {
    sceneObject.rotateX(radians(10));
  }
  if (key == 's') {
    sceneObject.rotateX(radians(-10));
  }
  if (key == 'c') {
    drawContours = !drawContours;
  }
  if (key == 'j') {
    contour_D_modifier -= 0.01;
    println("D modifier = ", contour_D_modifier);
    contourShader.set("d_modifier", contour_D_modifier);
  }
  if (key == 'k') {
    contour_D_modifier += 0.01;
    println("D modifier = ", contour_D_modifier);
    contourShader.set("d_modifier", contour_D_modifier);
  }
  if (key == 'n') {
    contour_S_modifier -= 0.05;
    println("S modifier = ", contour_S_modifier);
    contourShader.set("s_modifier", contour_S_modifier);
  }
  if (key == 'm') {
    contour_S_modifier += 0.05;
    println("S modifier = ", contour_S_modifier);
    contourShader.set("s_modifier", contour_S_modifier);
  }
  if (key == 'x') {
    save("result.png");
  }
}
