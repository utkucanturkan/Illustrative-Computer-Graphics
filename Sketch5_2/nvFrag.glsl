#version 410

uniform vec3 cameraPosition;

in vec4 vertPosition;
in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertLightDir;

in vec4 gl_FragCoord;


void main() {
  vec3 viewVector = normalize(vertLightDir); // TODO!
  float nv = dot(viewVector, vertNormal);  // TODO!
  vec4 color = vec4(nv, 0.0, 1.0-nv, 1.0); // TODO: Color from NV
  gl_FragColor = color * vertColor;
}