shader_type canvas_item;

uniform sampler2D blend_texture;
uniform float light_strength : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    vec4 blend = texture(blend_texture, UV);
    vec3 result;

    for (int i = 0; i < 3; i++) {
        if (blend[i] < 0.5) {
            result[i] = base[i] - (1.0 - 2.0 * blend[i]) * base[i] * (1.0 - base[i]);
        } else {
            result[i] = base[i] + (2.0 * blend[i] - 1.0) * (sqrt(base[i]) - base[i]);
        }
    }

    vec4 final_color = vec4(mix(base.rgb, result, light_strength), base.a);
    COLOR = final_color * COLOR;
}
