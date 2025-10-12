shader_type spatial;
render_mode depth_draw_opaque;

uniform sampler2D albedo_tex : source_color;

uniform vec2 scroll_speed = vec2(0.0, -1.0); // UV/sec
uniform float drive = 0.0;                   // 0=stop, 1=scroll
uniform float brightness = 1.0;

uniform vec2 uv_scale = vec2(1.0, 1.0);      // per-axis scale
uniform vec2 uv_offset = vec2(0.0, 0.0);     // per-axis offset

void fragment() {
    vec2 uv = UV * uv_scale + uv_offset + scroll_speed * TIME * drive;
    vec4 c = texture(albedo_tex, uv);
    ALBEDO = c.rgb*brightness;
}