shader_type canvas_item;

uniform float radius_frac : hint_range(0.0, 1.0) = 0.5;
// radius_frac es el radio del círculo como fracción de la mitad del tamaño mínimo del Control

void fragment() {
    // UV va de 0..1 en X e Y en el Control
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    // si estamos fuera del círculo de radio radius_frac, tiramos el fragmento
    if (dist > radius_frac) {
        discard;
    }
    // De lo contrario, pasamos al dibujo normal
}
