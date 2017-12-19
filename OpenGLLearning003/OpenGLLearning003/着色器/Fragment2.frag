#version 300 core
precision mediump float;

in vec3 ourColor;
in vec2 myTexCoord;

uniform sampler2D myTexTure;
uniform sampler2D myTexTure1;

out vec4 color;

void main()
{
    color = mix(texture(myTexTure, myTexCoord), texture(myTexTure1, myTexCoord), 0.2);
}
