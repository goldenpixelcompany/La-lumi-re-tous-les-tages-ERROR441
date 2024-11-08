shader_type canvas_item;

uniform highp float screen_size;
uniform highp float line_thickness;


bool is_at_line_range(float component)
{
	highp float fractional_part = fract(component*screen_size);
	return (fractional_part <= line_thickness || (1.0-fractional_part) <= line_thickness ) ;
}

void fragment() {

	if (is_at_line_range(UV.x) || is_at_line_range(UV.y))
	{
		COLOR.rgb = vec3(0.0,0.0,0.0);
	}
	else
	{
		COLOR.a = .0;
	}
}