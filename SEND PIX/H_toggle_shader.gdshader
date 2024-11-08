shader_type canvas_item;

uniform vec3 theme_color;
uniform float border_size;
uniform bool on;

void fragment() {
	COLOR.rgb = theme_color;
	if (UV.x <= border_size)
	{
		COLOR.a = 1.;
	}
	else if (UV.x >= 1. - border_size)
	{
		COLOR.a = 1.;
	}
	else if (UV.y <= border_size)
	{
		COLOR.a = 1.;
	}
	else if (UV.y >= 1. - border_size)
	{
		COLOR.a = 1.;
	}
	else
	{
		if (!on)
		{
			COLOR.a = .0;
		}
		else
		{
			COLOR.rgb = COLOR.rgb;
		}

	}

}
