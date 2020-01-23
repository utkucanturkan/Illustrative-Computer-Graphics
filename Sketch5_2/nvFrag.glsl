#version 410

uniform vec3 cameraPosition;

in vec4 vertPosition;
in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertLightDir;

in vec4 gl_FragCoord;


void main() {
  vec3 viewVector; // TODO!
  float nv ;  // TODO!
  vec4 color = vec4(1.0, 1.0, 1.0, 1.0); // TODO: Color from NV
  gl_FragColor = color * vertColor;
}