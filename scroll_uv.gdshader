shader_type spatial;
render_mode depth_draw_opaque;


uniform sampler2D albedo_tex : source_color, filter_nearest;

uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);
uniform vec2 scroll_speed = vec2(0.0, -1.0);
uniform float phase = 0.0; // seconds accumulated

void fragment() {
    vec2 uv = UV * uv_scale + uv_offset + scroll_speed * phase;
    vec4 c = texture(albedo_tex, uv);
    ALBEDO = c.rgb;
    ALPHA  = c.a;
}
