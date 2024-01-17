shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec3 tint;

void fragment() {
    // Get the current color
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
    // Average the color
    COLOR.rgb = vec3(COLOR.r + COLOR.g + COLOR.b) / 3.0;
    // Add our tint to the color by averaging them together
    COLOR.rgb = (COLOR.rgb + tint.rgb) * 0.5;
}