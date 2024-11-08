shader_type canvas_item;

uniform float line_thinckness;
uniform float line_alpha;
uniform float aspect_ratio;
uniform vec3 theme_color;
uniform float alpha;

uniform bool beat_mode;

void fragment()
{
	if(UV.x*aspect_ratio < line_thinckness|| (1.0-UV.x)*aspect_ratio  < line_thinckness)
	{
		if (beat_mode)
		{
			COLOR.rgb = 1.0-COLOR.rgb;
			COLOR.a = 1.0-line_alpha;
		}
		else
		{
			COLOR.rgb = theme_color;
			COLOR.a = 1.0-line_alpha;
		}
	}
	else if (UV.y < line_thinckness || (1.0-UV.y)< line_thinckness)
	{
		if (beat_mode)
		{
			COLOR.rgb = 1.0-COLOR.rgb;
			COLOR.a = 1.0-line_alpha;
		}
		else
		{
			COLOR.rgb = theme_color;
			COLOR.a = 1.0-line_alpha;
		}
	}
	else
	{
		if (!beat_mode)
		{
			COLOR.a = alpha;
		}

	}
}
