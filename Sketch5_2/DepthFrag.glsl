#version 410

in float depth;

void main() {
  gl_FragColor = vec4(vec3(depth), 1.0);
  // gl_FragColor = vec4(vec3(gl_FragCoord.z), 1.0);
}