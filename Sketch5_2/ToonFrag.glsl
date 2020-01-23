#version 410

uniform vec3 cameraPosition;

in vec4 vertPosition;
in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertLightDir;

void main() {
  
  float intensity = max(0.0, dot(vertLightDir, vertNormal));
	    
  vec4 color = vec4(1.0);

  gl_FragColor = color * vertColor;
}