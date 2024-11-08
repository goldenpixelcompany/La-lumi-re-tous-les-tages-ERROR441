shader_type canvas_item;

uniform float R;
uniform float G;
uniform float B;

uniform bool H_control;
uniform float H;
uniform float S;
uniform float V;

uniform bool effect1;
uniform bool effect2;
uniform bool effect3;

vec3 RGB_to_OKLAB(vec3 RGB)
{
	highp mat3 m1 = mat3(	vec3(.8189330101, .0329845436, .0482003018),
					vec3(.3618667424, .9293118715, .2643662691),
					vec3(-.1288597137, .0361456387, .6338517070));

	highp mat3 m2 = mat3(vec3(.2104542553, 1.9779984951, .0259040371),
					vec3(.7936177850, -2.4285922050, .7827717662),
					vec3(-.0040720468, .4505937099, -.8086757660));


	highp vec3 lms = m1 * RGB;

	lms.x = pow(lms.x,.3333333333);
	lms.y = pow(lms.y,.3333333333);
	lms.z = pow(lms.z,.3333333333);

	highp vec3 OKLAB = m2* lms;

	return OKLAB;
}



vec3 OKLAB_to_RGB(vec3 OKLAB)
{
	highp vec3 RGB;

	highp mat3 m1_ = mat3(	vec3(.8189330101, .0329845436, .0482003018),
					vec3(.3618667424, .9293118715, .2643662691),
					vec3(-.1288597137, .0361456387, .6338517070));

	highp mat3 m2_ = mat3(vec3(.2104542553, 1.9779984951, .0259040371),
					vec3(.7936177850, -2.4285922050, .7827717662),
					vec3(-.0040720468, .4505937099, -.8086757660));

	m1_ = inverse(m1_);
	m2_ = inverse(m2_);

	highp vec3 lms = m2_ * OKLAB;

	lms.x = pow(lms.x,3.);
	lms.y = pow(lms.y,3.);
	lms.z = pow(lms.z,3.);

	RGB = m1_*lms;


	return RGB;
}

highp vec3 OKLAB_to_OKLCH(vec3 OKLAB)
{
	highp vec3 OKLCH;
	OKLCH.x = OKLAB.x;
	OKLCH.y = length(OKLAB.yz);
	OKLCH.z = atan(OKLAB.z,OKLAB.y);

	return OKLCH;
}

highp vec3 OKLCH_to_OKLAB(vec3 OKLCH)
{
	highp vec3 OKLAB;
	OKLAB.x = OKLCH.x;
	OKLAB.y = OKLCH.y*cos(OKLCH.z);
	OKLAB.z = OKLCH.y*sin(OKLCH.z);

	return OKLAB;
}


void fragment() {
	//RGB modifications
	vec3 RGB_COLOR = COLOR.rgb;

	RGB_COLOR.r *= R;
	RGB_COLOR.g *= G;
	RGB_COLOR.b *= B;

	COLOR.rgb = RGB_COLOR;

	//HSL modifications (more like LCH)
	highp vec3 OKLAB = RGB_to_OKLAB(COLOR.rgb);
	highp vec3 OKLCH = OKLAB_to_OKLCH(OKLAB);

	OKLCH.y *= S;
	if (H_control)
	{
		OKLCH.z = H;
	}
	OKLCH.x *= V;


	OKLAB = OKLCH_to_OKLAB(OKLCH);
	COLOR.rgb = OKLAB_to_RGB(OKLAB);

}
