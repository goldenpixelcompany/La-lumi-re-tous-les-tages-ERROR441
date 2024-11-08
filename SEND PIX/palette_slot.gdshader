shader_type canvas_item;

uniform float line_thickness;
uniform vec3 line_color;
uniform float color_factor;
uniform bool none;
uniform float none_margin;

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

	else if (none && is_at_line_range(UV,vec2(none_margin,1.-none_margin),vec2(1.-none_margin,none_margin)))
	{
		COLOR.rgb = line_color*color_factor;
		COLOR.a = 1.;
	}
	else if( none)
	{
		COLOR.a = .0;
	}

}