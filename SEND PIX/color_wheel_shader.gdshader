shader_type canvas_item;

uniform vec2 center; 
uniform float line_thickness;
uniform float FSD; //Full saturation distance : Distance du centre a laquelle un angle est pleinement saturé
uniform float FSA; // Full saturation angle : Durée d'angle pendant laquelle une couleur reste au max avant de commencer le fondu
uniform vec3 theme_color;
uniform float color_factor;

float corrected(float value)
{
	if(floor(abs(value))==1.0)
	{
		return(1.0-fract(value))*FSA;
	}
	else if(floor(value)<.0 || floor(value)==2.0)
	{
		return .0;
	}
	else
	{
		return fract(value)*FSA;
	}
}

void fragment() 
{
//	float FSD = cos(TIME/5.0)*2.0; Pour jouer
//	float FSA = sin(TIME/5.0)*2.0; Pour jouer (passer aussi FSA en argument de corrected)
	vec2 opp_adj = (UV) - center; 
	float teta = atan(opp_adj.x,opp_adj.y)/PI;
	float r = 2.0*distance(UV,center);
	if(abs(1.0-(r+line_thickness))>=line_thickness)
	{
		float colorR = corrected(teta/0.666) ; //.0;
		float colorG = corrected((teta+0.666)/0.666); // .0;
		float colorB = corrected(-teta/0.666); // .0;
		COLOR.rgb = (floor(r/FSD)*(r-FSD)/(1.0-FSD))   +  vec3(colorR,colorG,colorB)*min(1.0,r/FSD);
		//    | Add reste beyond FSD (désat au W)|            Hue du pix      |  desat au B             
		//COLOR.rgb = vec3(colorR,colorG,colorB);

		if (r>1.0)
		{
			COLOR.a = .0;
		}
	}
	else 
	{
		COLOR.rgb = theme_color*color_factor;
	}
}
