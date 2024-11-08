shader_type canvas_item;

uniform bool hovered;
uniform vec3 theme_color;
uniform float color_factor;
uniform float seuil_alpha;
uniform float line_thickness;
uniform bool line_as_fill;

uniform float scale;


bool is_at_line_range(vec2 UV_coord, vec2 line_start, vec2 line_stop)
{
	float min_x = min(line_start.x,line_stop.x)-line_thickness/2.;
	float max_x = max(line_start.x,line_stop.x)+line_thickness/2.;
	float min_y = min(line_start.y,line_stop.y)-line_thickness/2.;
	float max_y = max(line_start.y,line_stop.y)+line_thickness/2.;
	if (UV_coord.x > min_x && UV_coord.x < max_x && UV_coord.y > min_y && UV_coord.y < max_y)
	{
		vec2 v_dir = normalize(line_stop - line_start);
		vec2 orthogonal_proj = line_start + dot((UV_coord-line_start),v_dir)*v_dir;
		if (dot((UV_coord-line_start),v_dir) < .0 )
		{
			orthogonal_proj =line_start;
		}
		else if ( dot((UV_coord-line_start),v_dir) > length(line_stop - line_start))
		{
			orthogonal_proj = line_stop;
		}
		if (distance(UV_coord,orthogonal_proj)<line_thickness/2.0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}

}

void fragment() {

	// Dissociation du line/fill/alpha
	if (COLOR.a < seuil_alpha) // if alpha
	{
		if (hovered)
		{
			COLOR.rgb = theme_color*color_factor;;
			COLOR.a = 1.;
		}
		else
		{
			COLOR.a = 0.;
		}
	}
	else if (COLOR.b > 1. - seuil_alpha && COLOR.r < seuil_alpha) // elif fill
	{
		if (hovered)
		{
			COLOR.a = 0.;
		}
		else
		{
			COLOR.rgb = theme_color*color_factor;;
			COLOR.a = 1.;
		}
	}
	else //if line
	{
		if (hovered)
		{
			if (line_as_fill)
			{
				COLOR.a = 0.;
			}
			else
			{
				COLOR.rgb = theme_color*color_factor;;
				COLOR.a = 1.;
			}

		}
		else
		{
			if (line_as_fill)
			{
				COLOR.rgb = theme_color*color_factor;;
				COLOR.a = 1.;
			}
			else
			{
				COLOR.a = .0;
			}

		}
	}

	float line_thicknesse = line_thickness;
	if (hovered)
	{
		line_thicknesse = line_thickness *2.;
	}
	if (is_at_line_range(UV,vec2(.0,line_thicknesse*.5),vec2(1.,line_thicknesse*.5)))
	{
		COLOR.a = 1.;
		COLOR.rgb = theme_color*color_factor;
	}
	if (is_at_line_range(UV,vec2(line_thicknesse*.5,.0),vec2(line_thicknesse*.5,1.)))
	{
		COLOR.a = 1.;
		COLOR.rgb = theme_color*color_factor;
	}
	if (is_at_line_range(UV,vec2(1.-line_thicknesse*.5,.0),vec2(1.-line_thicknesse*.5,1.)))
	{
		COLOR.a = 1.;
		COLOR.rgb = theme_color*color_factor;
	}
	if (is_at_line_range(UV,vec2(.0,1.-line_thicknesse*.5),vec2(1.,1.-line_thicknesse*.5)))
	{
		COLOR.a = 1.;
		COLOR.rgb = theme_color*color_factor;
	}


}
