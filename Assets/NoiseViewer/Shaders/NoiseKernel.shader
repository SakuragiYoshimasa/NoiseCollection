Shader "Hidden/NoiseKernel"
{
    Properties
    {
       _PositionTex ("-", 2D) = ""{}
       _VelocityTex ("-", 2D) = ""{}
       _DefaultTex  ("-", 2D) = ""{}
    }

    CGINCLUDE

    #pragma multi_compile CNOISE PNOISE SNOISE SNOISE_AGRAD SNOISE_NGRAD
    #pragma multi_compile _ THREED
    #pragma multi_compile _ ASVELOCITY

    #include "UnityCG.cginc"

    #if  defined(SNOISE) || defined(SNOISE_NGRAD)
        #if defined(THREED)
            #include "./Noise/SimplexNoise3D.cginc"
        #else
            #include "./Noise/SimplexNoise2D.cginc"
        #endif
    #elif defined(SNOISE_AGRAD)
        #if defined(THREED)
            #include "./Noise/SimplexNoiseGrad3D.cginc"
        #else
            #include "./Noise/SimplexNoiseGrad2D.cginc"
        #endif
    #else
        #if defined(THREED)
            #include "./Noise/ClassicNoise3D.cginc"
        #else
            #include "./Noise/ClassicNoise2D.cginc"
        #endif
    #endif

    sampler2D _PositionTex;
	sampler2D _VelocityTex;
    sampler2D _DefaultTex;

	float nrand(float2 uv, float salt) {
        uv += float2(salt, 0);
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

	float4 frag_update_position(v2f_img i): SV_Target {	

		#if defined(ASVELOCITY)

            float delta = 0.001;

            #if defined(THREED)
                //velocity from curl cross noiseVectorField
                float3 p = tex2D(_PositionTex, i.uv - (i.uv - float2(0.5, 0.5)) * 0.01).xyz;
                if(p.x == 0 && p.y == 0 && p.z == 0){
                    float2 coord = i.uv - float2(0.5, 0.5);
                    float z = nrand(coord * float2(323.43, 13.343), 1.0) * 23.34242;
		
                    p = float3(coord * nrand(coord * 3.432432, _Time.y), z);
                }
                
                float3 dx = float3(delta + nrand(i.uv, _Time.x) * 0.0005, 0, 0);
                float3 dy = float3(0, delta + nrand(i.uv, _Time.x) * 0.0005, 0);
                float3 dz = float3(0, 0, delta + nrand(i.uv, _Time.x) * 0.0005);

                #if defined(CNOISE)
      
                    float3 p_x0 = cnoise( p - dx );
                    float3 p_x1 = cnoise( p + dx );
                    float3 p_y0 = cnoise( p - dy );
                    float3 p_y1 = cnoise( p + dy );
                    float3 p_z0 = cnoise( p - dz );
                    float3 p_z1 = cnoise( p + dz );

                #elif defined(PNOISE)
                    float3 rep = float3(2.0, 2.0, 2.0);
                    float3 p_x0 = pnoise( p - dx , rep);
                    float3 p_x1 = pnoise( p + dx , rep);
                    float3 p_y0 = pnoise( p - dy , rep);
                    float3 p_y1 = pnoise( p + dy , rep);
                    float3 p_z0 = pnoise( p - dz , rep);
                    float3 p_z1 = pnoise( p + dz , rep);

                #elif defined(SNOISE)
                    float3 p_x0 = snoise( p - dx );
                    float3 p_x1 = snoise( p + dx );
                    float3 p_y0 = snoise( p - dy );
                    float3 p_y1 = snoise( p + dy );
                    float3 p_z0 = snoise( p - dz );
                    float3 p_z1 = snoise( p + dz );

                #elif defined(SNOISE_AGRAD)
        
                    float3 p_x0 = snoise_grad( p - dx );
                    float3 p_x1 = snoise_grad( p + dx );
                    float3 p_y0 = snoise_grad( p - dy );
                    float3 p_y1 = snoise_grad( p + dy );
                    float3 p_z0 = snoise_grad( p - dz );
                    float3 p_z1 = snoise_grad( p + dz );

                #else
                    float3 p_x0 = snoise_grad( p - dx );
                    float3 p_x1 = snoise_grad( p + dx );
                    float3 p_y0 = snoise_grad( p - dy );
                    float3 p_y1 = snoise_grad( p + dy );
                    float3 p_z0 = snoise_grad( p - dz );
                    float3 p_z1 = snoise_grad( p + dz );
                #endif

                float vx = p_y1.z - p_y0.z - p_z1.y + p_z0.y;
                float vy = p_z1.x - p_z0.x - p_x1.z + p_x0.z;
                float vz = p_x1.y - p_x0.y - p_y1.x + p_y0.x;

                //float3 v = normalize(float3(vx, vy, vz));
                float3 v = float3(vx, vy, vz)/ delta;

                return float4((p + v * unity_DeltaTime.x) * 0.85 +  tex2D(_DefaultTex, i.uv).xyz * 0.15, 1.0);

            #else
                float2 p = tex2D(_PositionTex, i.uv).xy;
                float2 dx = float2(delta, 0);
                float2 dy = float2(0, delta);
            #endif

		#else 
            #if defined(THREED)
                float3 p = float3(0, 0, 0);
                float3 rep = float3(2.0, 2.0, 2.0);
                float3 coord = float3(i.uv * float2(10.0, 10.0), _Time.y);
            #else
                float2 p = float2(0, 0);
                float2 rep = float2(rep);
                float2 coord = float2(i.uv * float2(10.0, 10.0) + float2(_Time.y, _Time.y));
            #endif

            #if defined(CNOISE)
                p += cnoise(coord);
            #elif defined(PNOISE)
                p += pnoise(coord, rep); 
            #elif defined(SNOISE)
                p += snoise(coord);
            #elif defined(SNOISE_AGRAD)
                p += snoise_grad(coord);
            #else //#if defined(SNOISE_NGRAD)
                #if defined(THREED)
                    float epsilon = 0.0001;
                    float v0 = snoise(coord);
                    float vx = snoise(coord + float3(epsilon, 0, 0));
                    float vy = snoise(coord + float3(0, epsilon, 0));
                    float vz = snoise(coord + float3(0, 0, epsilon));
                    p += 0.5 * float3(vx - v0, vy - v0, vz - v0) / epsilon;     
                #else
                    float epsilon = 0.0001;
                    float v0 = snoise(coord);
                    float vx = snoise(coord + float2(epsilon, 0));
                    float vy = snoise(coord + float2(0, epsilon));
                    p += 0.5 * float2(vx - v0, vy - v0) / epsilon;      
                #endif
            #endif

            #if defined(THREED)
                return float4(p, 1.0);
            #else
                return float4(p, 1.0, 1.0);
            #endif
		#endif
        return float4(1.0, 1.0, 1.0, 1.0);
	}

    float4 frag_update_velocity(v2f_img i) : SV_Target {
		return float4(0, 0, 0, 0);
	}

	float4 frag_init_position(v2f_img i): SV_Target {
        float2 coord = i.uv - float2(0.5, 0.5);
        float z = nrand(coord * float2(323.43, 13.343), 1.0) * 23.34242;
		return normalize(float4(coord * 424.3423, z, 1.0));
        //return float4(0, 0, 0,1.0);
	}

	float4 frag_init_velocity(v2f_img i): SV_Target {		
		return float4(0,0,0,1.0);
	}
    ENDCG

    SubShader
    {
    	Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_init_position
            ENDCG
        }

		Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_update_position
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_init_velocity
            ENDCG
        }

        Pass
        {
        	CGPROGRAM
        	#pragma target 3.0
        	#pragma vertex vert_img
        	#pragma fragment frag_update_velocity
        	ENDCG
  
        }
    }
}