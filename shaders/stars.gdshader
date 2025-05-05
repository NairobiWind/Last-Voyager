shader_type canvas_item;

uniform sampler2D texture_albedo;

void fragment() {
	COLOR = texture(texture_albedo, UV);
}
