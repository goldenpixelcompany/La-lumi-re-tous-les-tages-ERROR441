shader_type canvas_item;

uniform vec3 theme_color;
uniform float line_thinckness;
uniform float aspect_ratio;
uniform float cross_size;
uniform float color_ratio;

void fragment() {
	if(UV.x*aspect_ratio < line_thinckness|| (1.0-UV.x)*aspect_ratio  < line_thinckness)
	{
		COLOR.rgb = theme_color*color_ratio;
		COLOR.a = 1.0;
	}
	else if (UV.y < line_thinckness || (1.0-UV.y)< line_thinckness)
	{
		COLOR.rgb = theme_color*color_ratio;
		COLOR.a = 1.0;
	}
	else if(abs(UV.x * aspect_ratio -.5) < line_thinckness/2.0 && abs(UV.y -.5) < cross_size)
	{
		COLOR.rgb = theme_color*color_ratio;
		COLOR.a = 1.0;
	}
	else if(abs(UV.y * aspect_ratio -.5) < line_thinckness/2.0 && abs(UV.x -.5) < cross_size)
	{
		COLOR.rgb = theme_color*color_ratio;
		COLOR.a = 1.0;
	}
	else
	{
		COLOR.a = .0;
	}
}
