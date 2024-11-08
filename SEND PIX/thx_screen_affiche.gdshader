shader_type canvas_item;

uniform float start_degrade;

void fragment() {
	if(UV.y < start_degrade)
	{
		COLOR.a += - 3.*abs(UV.y -  start_degrade);
	}
	if(UV.x < start_degrade)
	{
		COLOR.a +=- 3.*abs(UV.x -  start_degrade);
	}
	if(1.-UV.y < start_degrade)
	{
		COLOR.a += - 3.*abs(1.-UV.y -  start_degrade);
	}
	if(1.-UV.x < start_degrade)
	{
		COLOR.a +=- 3.*abs(1.-UV.x -  start_degrade);
	}
}
