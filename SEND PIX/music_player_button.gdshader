shader_type canvas_item;

uniform vec3 color_theme;
uniform float line_thickness;
uniform float color_factor;

uniform bool forth;
uniform bool play;

uniform vec2 marge;


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
	vec2 p1;
	vec2 p2;
	vec2 p3;

	vec2 l1;
	vec2 l2;

	if (forth)
	{
		p1 = vec2(1.-marge.x,.5);
		p2 = vec2(marge.x,marge.y);
		p3 = vec2(marge.x,1.-marge.y);

		l1 = vec2(1.-marge.x,marge.y);
		l2 = vec2(1.-marge.x,1.-marge.y);

	}
	else
	{
		p1 = vec2(marge.x,.5);
		p2 = vec2(1.-marge.x,marge.y);
		p3 = vec2(1.-marge.x,1.-marge.y);

		l1 = vec2(marge.x,marge.y);
		l2 = vec2(marge.x,1.-marge.y);
	}

	if (is_at_triangle_range(UV,p1,p2,p3))
	{
		COLOR.a = 1.;
		COLOR.rgb = color_theme*color_factor;
	}
	else if (is_at_line_range(UV,l1,l2) && !play)
	{
		COLOR.a = 1.;
		COLOR.rgb = color_theme*color_factor;
	}
	else
	{
		COLOR.a = 0.;
	}

}
