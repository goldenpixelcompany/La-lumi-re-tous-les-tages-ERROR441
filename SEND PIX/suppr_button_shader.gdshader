shader_type canvas_item;

uniform vec3 theme_color;
uniform float line_thinckness;
uniform float cross_size;
uniform bool hovered;
uniform float alpha;
uniform float color_factor;

void fragment() {
	float r = distance(UV,vec2(.5,.5));

	if (r>.5)
	{
		COLOR.rgba = vec4(.0,.0,.0,.0);
	}
	else
	{
		COLOR.rgba = vec4(.0,.0,.0,alpha);
	}
	if (abs(r-(.5-line_thinckness/2.0))<line_thinckness/2.0)
	{
		COLOR.rgb = theme_color*color_factor;
	}
	if(distance(abs(UV.x-.5),abs(UV.y-.5))<line_thinckness/2.0 && abs(UV.x-.5)< cross_size && abs(UV.y-.5)< cross_size)
	{
		COLOR.rgb = theme_color*color_factor;
	}
	if (hovered)
	{
		if (COLOR.rgb == theme_color && !(abs(r-(.5-line_thinckness/2.0))<line_thinckness/2.0))
		{
			COLOR.rgb = vec3(.0,.0,.0);
		}
		else if(COLOR.rgb == vec3(.0,.0,.0) || (abs(r-(.5-line_thinckness/2.0))<line_thinckness/2.0))
		{
			COLOR.rgb = theme_color;
		}
	}
}
