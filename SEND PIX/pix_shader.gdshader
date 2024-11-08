shader_type canvas_item;

uniform float line_thinckness;
uniform float aspect_ratio;
uniform float gray_value;

void fragment() 
{
	if(UV.x*aspect_ratio < line_thinckness|| (1.0-UV.x)*aspect_ratio  < line_thinckness)
	{
		//COLOR.a = .0;
		COLOR.rgb = vec3(gray_value,gray_value,gray_value);
	}
	else if (UV.y < line_thinckness || (1.0-UV.y)< line_thinckness)
	{
		//COLOR.a = .0;
		COLOR.rgb = vec3(gray_value,gray_value,gray_value);
	}
	
}
