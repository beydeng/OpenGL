#version 300 core
precision mediump float;

in vec2 myTexCoord;

out vec4 color;
uniform sampler2D ourTexTure;

void main()
{
    color = texture(ourTexTure,myTexCoord);
}
