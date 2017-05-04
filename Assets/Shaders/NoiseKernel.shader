Shader "Hidden/NoiseKernel"
{
    Properties
    {
       _PositionTex ("-", 2D) = ""{}
       _VelocityTex ("-", 2D) = ""{}
       
       //_DeltaTime   ("-", Float) = 0
	   _Z           ("-", Float) = 0
       //_PointNum    ("-", int) = 0
	   //_NoiseMode   ("-", int) = 0
	   _AsVelocity  ("-", int) = 0
    }

    CGINCLUDE

    #include "UnityCG.cginc"
	#include "Noise/SimplexNoiseGrad3D.cginc"
    //#include "Noise/ClassicPerlinNoise.cginc"
   
    sampler2D _PositionTex;
	sampler2D _VelocityTex;
	//float _DeltaTime;
	float _Z;
	//int _PointNum;
	//int _NoiseMode;
	int _AsVelocity;

	float nrand(float2 uv, float salt) {
        uv += float2(salt, 0);
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }


	float4 frag_init_position(v2f_img i): SV_Target {
		return float4(0,0,0,1.0);
	}

	float4 frag_update_position(v2f_img i): SV_Target {	
		if(_AsVelocity == 0){

			//float3 p = tex2D(_PositionTex, i.uv).xyz;
            //float3 p;
            //p.xy = i.uv;     
            //p.z = cnoise(float3(i.uv, 10.0));
            float3 p =snoise_grad(float3(i.uv * float2(10.0, 10.0), _Time.y));
            //TODO noise return 3d grad
			return float4(p, 1.0); 
		}else{

		}
		
		return float4(1.0,1.0,1.0,1.0);
	}

	float4 frag_init_velocity(v2f_img i): SV_Target {		
		return float4(0,0,0,1.0);
	}

	float4 frag_update_velocity(v2f_img i) : SV_Target {

		//float p = tex2D(_PhaseTex, i.uv).x;
		//float nf = tex2D(_NaturalFreqTex, i.uv).x;
		//float v = nf + _K * _ParamR * sin(_ParamTheta - p);

		return float4(0, 0, 0, 0);
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