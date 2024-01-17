shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
const float DEFAULT_WIDTH = 720.0;  // Used to apply proper scaling

uniform vec3 tint;
global uniform vec2 player_pos;
global uniform float screen_width;
global uniform float screen_height;
uniform float scale = 0.5;
uniform float min_radius = 0.0;
uniform float max_radius = 0.5;

void fragment() {
    // Get the current color
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
    // Average the color
    COLOR.rgb = vec3(COLOR.r + COLOR.g + COLOR.b) / 3.0;
    // Add our tint to the color by averaging them together
    COLOR.rgb = (COLOR.rgb + tint.rgb) * 0.5;
    
    // Create a clear circle around the player
    float aspect_ratio = screen_height / screen_width;
    float val = distance(vec2(UV.x , UV.y * aspect_ratio), vec2(player_pos.x , player_pos.y * aspect_ratio));
	val = val / scale * (screen_width / DEFAULT_WIDTH);
	COLOR.a = smoothstep(min_radius, max_radius, val);
}