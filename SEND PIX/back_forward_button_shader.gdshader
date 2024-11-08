shader_type canvas_item;

uniform float line_thickness;
uniform vec3 line_color;
uniform vec2 margin_size;
uniform float scndTriangle_translation_coef;
uniform bool forward;
uniform bool doubled; // Pour doubler le triangle
uniform bool hovered;
uniform float color_factor;
uniform bool stop;
uniform vec2 stop_margin;

uniform float teta;

vec2 rotate_UV(vec2 UV_coord)
{
	vec2 temp_UV = UV_coord; //- vec2(-.5,-.5);
	UV_coord.x = cos(teta)*temp_UV.x - sin(teta)*temp_UV.y;
	UV_coord.y = sin(teta)*temp_UV.x + cos(teta)*temp_UV.y;
	return UV_coord; //+ vec2(.5,.5);
}


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

bool is_at_triangle_range(vec2 UV_coord,vec2 p1, vec2 p2, vec2 p3)
{
	if (is_at_line_range(UV_coord,p1,p2) || is_at_line_range(UV_coord,p2,p3) || is_at_line_range(UV_coord,p1,p3))
	{
		return true;
	}
	else
	{
		return false;
	}
}

void fragment() {
	vec2 rotated_UV = rotate_UV(UV) + vec2(.0,-.0);
	if (hovered)
	{
		COLOR.a = 1.;
		COLOR.rgb = line_color*color_factor;
	}
	else
	{
		COLOR.a = 0.;
	}

	//Dessin du cadre
	if(is_at_line_range(UV,vec2(.0,line_thickness/2.0),vec2(1.,line_thickness/2.0)))
	{
		COLOR.rgb = line_color*color_factor;
		COLOR.a = 1.;
	}
	else if(is_at_line_range(UV,vec2(line_thickness/2.0, .0),vec2(line_thickness/2.0,1.0)))
	{
		COLOR.rgb = line_color*color_factor;
		COLOR.a = 1.;
	}
	else if(is_at_line_range(UV,vec2(.0, 1.-line_thickness/2.0),vec2(1.,1.-line_thickness/2.0)))
	{
		COLOR.rgb = line_color*color_factor;
		COLOR.a = 1.;
	}
	else if(is_at_line_range(UV,vec2(1.-line_thickness/2.0,.0),vec2(1.-line_thickness/2.0,1.)))
	{
		COLOR.rgb = line_color*color_factor;
		COLOR.a = 1.;
	}

	//Dessin du triangle
	float translation = scndTriangle_translation_coef*(.5-margin_size.x);

	if (forward)
	{
		if (doubled)
		{
			if (is_at_triangle_range(UV,vec2(1.-margin_size.x,.5),vec2(.5,margin_size.y),vec2(.5,1.-margin_size.y)))
			{
				COLOR.rgb = line_color*color_factor;
				if (hovered)
				{
					COLOR.a = 0.;
				}
				else
				{
					COLOR.a = 1.;
				}
			}
		}
		if (is_at_triangle_range(rotated_UV,vec2(1.-margin_size.x - translation,.5),vec2(.5-translation,margin_size.y),vec2(.5 - translation,1.-margin_size.y)))
		{
			COLOR.rgb = line_color*color_factor;
			if (hovered)
				{
					COLOR.a = 0.;
				}
				else
				{
					COLOR.a = 1.;
				}
		}

	}
	else if(stop)
	{
		if (is_at_line_range(rotated_UV,vec2(margin_size.x*stop_margin.x,margin_size.y*stop_margin.y),vec2(margin_size.x*stop_margin.x,1.-margin_size.y*stop_margin.y)))
		{
			COLOR.rgb = line_color*color_factor;

				if (hovered)
				{
					COLOR.a = 0.;
				}
				else
				{
					COLOR.a = 1.;
				}
		}
		else if (is_at_line_range(rotated_UV,vec2(1.-margin_size.x*stop_margin.x,margin_size.y*stop_margin.y),vec2(1.-margin_size.x*stop_margin.x,1.-margin_size.y*stop_margin.y)))
		{
			COLOR.rgb = line_color*color_factor;

				if (hovered)
				{
					COLOR.a = 0.;
				}
				else
				{
					COLOR.a = 1.;
				}
		}
	}
	else
	{
		if (doubled)
		{
			if (is_at_triangle_range(UV,vec2(margin_size.x,.5),vec2(.5,margin_size.y),vec2(.5,1.-margin_size.y)))
			{
				if (hovered)
				{
					COLOR.a = 0.;
				}
				else
				{
					COLOR.a = 1.;
				}
				COLOR.rgb = line_color*color_factor;

			}
		}

		if (is_at_triangle_range(UV,vec2(margin_size.x + translation,.5),vec2(.5+translation,margin_size.y),vec2(.5+translation,1.-margin_size.y)))
		{
			COLOR.rgb = line_color*color_factor;

				if (hovered)
				{
					COLOR.a = 0.;
				}
				else
				{
					COLOR.a = 1.;
				}
		}
	}

}

