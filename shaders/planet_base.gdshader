shader_type canvas_item;

uniform vec4 planet_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);

void fragment() {
    vec2 pos = (UV - vec2(0.5)) * 2.0; // Mapea de 0–1 a -1–1
    float radius = 1.0 - length(pos);
    float mask = smoothstep(0.0, 0.02, radius); // borde suave
    COLOR = vec4(planet_color.rgb, planet_color.a * mask);
}
