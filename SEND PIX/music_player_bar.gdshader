shader_type canvas_item;

uniform float base_line_thickness;
uniform vec3 color_theme;
uniform float line_ratio;
uniform float progress;
uniform float color_ratio;

bool is_at_line_range(vec2 UV_coord, vec2 line_start, vec2 line_stop, float line_thickness)
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
	if (is_at_line_range(UV,vec2(.0,.5),vec2(1.,.5),base_line_thickness))
	{
		COLOR.a = 1.;
		COLOR.rgb = color_theme*color_ratio/2.;
	}
	if (is_at_line_range(UV,vec2(.0,.5),vec2(progress,.5),base_line_thickness*line_ratio))
	{
		//correction de la ligne de progress
		if (UV.x < progress)
		{
			COLOR.a = 1.;
			COLOR.rgb = color_theme*color_ratio;
		}
		//a voir pour utiliser un frag coord pour faire un joli cercle pas deformé en bout de ligne


	}


}
