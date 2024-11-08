shader_type canvas_item;

uniform vec3 theme_color;
uniform float color_coef;

void fragment() {
	COLOR.rgb = theme_color*color_coef;
}
