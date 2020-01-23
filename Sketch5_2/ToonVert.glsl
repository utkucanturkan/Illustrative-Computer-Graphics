#version 410

uniform mat4 transform;
uniform mat3 normalMatrix;
uniform vec3 lightNormal;

in vec4 position;
in vec4 color;
in vec3 normal;

out vec4 vertPosition;
out vec4 vertColor;
out vec3 vertNormal;
out vec3 vertLightDir;

void main() {
  gl_Position = transform * position;
  vertColor = color;
  vertNormal = normalize(normalMatrix * normal);
  vertLightDir = -lightNormal;
  vertPosition = gl_Position;
}