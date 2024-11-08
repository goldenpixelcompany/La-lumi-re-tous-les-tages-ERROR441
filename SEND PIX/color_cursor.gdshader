shader_type canvas_item;

uniform float line_thickness ;

void fragment() {
	float r = 2.0*distance(UV,vec2(0.5,0.5));
	float dist = abs(1.0 - (r+line_thickness));
	if ( dist > line_thickness)
	{
		COLOR.a = .0;
	}
	else if (dist > line_thickness/1.5)
	{
		COLOR.rgb = vec3(1.0,1.0,1.0);
	}
}
