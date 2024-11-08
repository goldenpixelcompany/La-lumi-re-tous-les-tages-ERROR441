shader_type canvas_item;

uniform float dither_size ;

void fragment() {
	if (int(FRAGCOORD.x / dither_size) % 2 == 0 )
	{
		COLOR.a = .0;
	}
	if (int(FRAGCOORD.y / dither_size) % 2 == 0 )
	{
		COLOR.a = .0;
	}

}
