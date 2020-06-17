shader_type canvas_item;

uniform vec4 color : hint_color;
uniform sampler2D noise_texture : hint_albedo;

void fragment() {
	vec2 uv = UV;
	uv.x += sin(uv.x * 5.0 * cos(TIME / 15.0));
	uv.y += cos(uv.y * 5.0 * sin(TIME / 15.0));
	//uv.y += cos(TIME) * 0.1;
	float a = max(texture(noise_texture, uv).r, 0.3) - 0.3;
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(mix(c.rgb, color.rgb, a), c.a);
}