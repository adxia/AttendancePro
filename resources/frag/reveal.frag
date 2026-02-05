
#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 center;
    float radius;
    float aspect;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 uv = qt_TexCoord0;

    vec2 distVec = (uv - center) * vec2(aspect, 1.0);
    float dist = length(distVec);

    // 计算 alpha
    float alpha = smoothstep(radius-0.05, radius, dist);

    fragColor = texture(source, uv) * alpha * qt_Opacity;
}
