Shader "Hidden/NoiseKernel"
{
    Properties
    {
       _PositionTex ("-", 2D) = ""{}
       _VelocityTex ("-", 2D) = ""{}
    }

    CGINCLUDE

    #pragma multi_compile CNOISE PNOISE SNOISE SNOISE_AGRAD SNOISE_NGRAD
    #pragma multi_compile _ THREED
    #pragma multi_compile _ ASVELOCITY

    #include "UnityCG.cginc"

    #if  defined(SNOISE) || defined(SNOISE_NGRAD)
        #if defined(THREED)
            #include "Noise/SimplexNoise3D.cginc"
        #else
            #include "Noise/SimplexNoise2D.cginc"
        #endif
    #elif defined(SNOISE_AGRAD)
        #if defined(THREED)
            #include "Noise/SimplexNoiseGrad3D.cginc"
        #else
            #include "Noise/SimplexNoiseGrad2D.cginc"
        #endif
    #else
        #if defined(THREED)
            #include "Noise/ClassicNoise3D.cginc"
        #else
            #include "Noise/ClassicNoise2D.cginc"
        #endif
    #endif

    sampler2D _PositionTex;
	sampler2D _VelocityTex;

	float nrand(float2 uv, float salt) {
        uv += float2(salt, 0);
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

	float4 frag_update_position(v2f_img i): SV_Target {	

		#if defined(ASVELOCITY)
            #if defined(SNOISE_AGRAD)
                #if defined(THREED)
                    float3 p = tex2D(_PositionTex, i.uv);
                    p += snoise_grad(p) * unity_DeltaTime.y * 0.005;
                    return float4(p, 1.0);
                #else
                    float2 p = tex2D(_PositionTex, i.uv);
                    p += snoise_grad(p) * unity_DeltaTime.y * 0.005;
                    return float4(p, 1.0, 1.0);
                #endif
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
		return float4(0,0,0,1.0);
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