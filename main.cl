#bind layer !&dst

float2 get_fraction_v2 ( float2 x ) { return x - floor(x); }

float2 rand2d ( float2 p )
{
    float dot1 = dot(p, (float2)(127.1f, 311.7f));
    float dot2 = dot(p, (float2)(269.5f, 183.3f));
    
    float2 dots = (float2)(dot1, dot2);
    float2 sin_val = sin(dots) * 43758.5453f;
    
    return get_fraction_v2(sin_val);
}

float smin(float x, float y, float lambda)
{
    float sum = x + y;
    float sub = x - y;
    
    return sum - sqrt(sub * sub + lambda);
}

@KERNEL
{
    float2 uv = @P;
    float t = @Time;
    
    uv *= 2.0f;
    
    float m_d = 1.0f;
    float lambda = 1.0f;
    
    float2 i_uv = floor(uv);
    float2 f_uv = get_fraction_v2(uv);
    
    for (int y = -3; y <= 3; y++)
    {
        for (int x = -3; x <= 3; x++)
        {
            float2 nb = (float2)((float)(x), (float)(y));
            
            float2 pt = rand2d(i_uv + nb);
            pt = 0.5f + 0.5f * sin(t * 1.5f + 6.2345f * pt);

            float2 diff = nb + pt - f_uv;
            
            float b_d = length(diff);
            
            m_d = smin(m_d, b_d, lambda);
        }
    }
    
    float3 col1 = (float3)(0.58f, 0.56f, 0.13f);
    float3 col2 = (float3)(0.00f, 0.00f, 0.00f);
    
    float mask = smoothstep(0.1f, 0.4f, m_d);
    
    float3 final_col = mix(col1, col2, mask);
    
    @dst.set((float4)(final_col.x, final_col.y, final_col.z, 1.0f));
}
