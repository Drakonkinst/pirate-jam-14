shader_type canvas_item;

render_mode blend_add;

global uniform vec2 player_world_pos;
uniform float radius = 175.0;
varying vec2 world_vertex;

void vertex() {
    // https://github.com/godotengine/godot-docs/issues/7860
    world_vertex = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    float min_dist = min(length(player_world_pos - world_vertex), radius);
    COLOR.a = clamp(radius - min_dist, 0.0, COLOR.a);
}
