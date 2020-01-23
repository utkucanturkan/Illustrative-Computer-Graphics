#version 410

in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertLightDir;

in vec4 gl_FragCoord;

void main() {
  float intensity = max(0.0, dot(vertLightDir, vertNormal));
  vec4 color = vec4(vec3(intensity), 1.0);
  gl_FragColor = color * vertColor;
}