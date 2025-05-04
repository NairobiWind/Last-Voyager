shader_type canvas_item;

uniform vec4 atmo_color : source_color = vec4(0.5, 0.7, 1.0, 0.3);
uniform float blend_strength : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    // Solo usamos la textura para forma y ruido
    vec4 tex = texture(TEXTURE, UV);
    vec3 blend_rgb = mix(tex.rgb, atmo_color.rgb, blend_strength);

    // Forzar transparencia por color definido
    float alpha = atmo_color.a * blend_strength;

    COLOR = vec4(blend_rgb, alpha);
}
