shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ปรับความซ่าขาว-ดำพื้นฐาน
uniform float noise_opacity : hint_range(0.0, 1.0) = 0.12;
// ปรับความถี่ของเม็ดสีม่วง-น้ำเงิน (ลดลงให้น้อยและเนียนขึ้น)
uniform float color_sparkle_amount : hint_range(0.0, 1.0) = 0.02;
// ปรับความเร็วในการจางเข้า-ออกเป็นระลอก
uniform float wave_speed : hint_range(0.1, 10.0) = 2.0;

float random_val(vec2 uv, float t) {
    return fract(sin(dot(uv + vec2(t * 0.1, t * 0.3), vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // 1. ความซ่าแบบเม็ด ขาว-ดำ
    float r1 = random_val(SCREEN_UV, TIME);
    color.rgb = mix(color.rgb, vec3(r1), noise_opacity);

    // 2. คำนวณคลื่นจังหวะระลอก (ให้เกิดสีเป็นช่วงๆ แล้ววูบหายไป)
    float wave = sin(TIME * wave_speed) * 0.5 + 0.5; // ค่าจะวนจาก 0.0 ถึง 1.0
    wave = pow(wave, 3.0); // บีบจังหวะให้กวาดขึ้นมาแป๊บเดียวแล้วดับ

    // 3. สุ่มเม็ดสีม่วง-น้ำเงินเฉพาะช่วงที่ระลอกคลื่นมากระทบ
    float r2 = random_val(SCREEN_UV + vec2(1.0), TIME * 0.5);
    float r3 = random_val(SCREEN_UV + vec2(2.0), TIME * 0.8);

    if (r2 < color_sparkle_amount * wave) {
        vec3 purple_blue = mix(vec3(0.4, 0.05, 0.7), vec3(0.05, 0.2, 0.8), r3);
        color.rgb = mix(color.rgb, purple_blue, 0.4 * wave);
    }

    COLOR = color;
}