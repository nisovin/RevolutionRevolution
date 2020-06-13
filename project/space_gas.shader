shader_type canvas_item;

uniform vec4 color : hint_color;
uniform float fade;
uniform sampler2D noise_texture;

void fragment() {
	float f = max(texture(noise_texture, UV).r - fade, 0);
	COLOR = vec4(color.rgb, f);
	//COLOR = vec4(1.0, 0, 0, 1.0);
}