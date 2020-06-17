shader_type canvas_item;

uniform vec4 color : hint_color;
uniform float speed = 1.0;
uniform float density = 0.5;
uniform sampler2D noise_texture : hint_albedo;

void fragment() {
	vec2 uv = vec2(mod(UV.x + TIME * speed, 2.0), UV.y);
	float val = texture(noise_texture, uv / 2.0).r;
	vec4 overcolor = vec4(color.rgb, val * density);
	vec4 curr_color = texture(TEXTURE, UV);
	COLOR = vec4(mix(curr_color.rgb, color.rgb, val), curr_color.a);
}