Shader "Custom/NoiseSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_PositionTex("-", 2D) = "white" {}
	}

	CGINCLUDE
	
	half _Glossiness;
	half _Metallic;
	fixed4 _Color;
	sampler2D _PositionTex;

	struct Input {
        half color;	
		float size : PSIZE;
	};

	void vert(inout appdata_base v, out Input data)
	{
		UNITY_INITIALIZE_OUTPUT(Input, data);
		float2 uv = v.vertex.xy;
		float3 p = tex2Dlod(_PositionTex, float4(uv, 0, 0)).rgb;
		
 		v.vertex.xyz = p * 5.0;
		data.color = 1.0;
		//data.size = 10.0;
	}

	ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		
		#pragma surface surf Lambert vertex:vert nolightmap addshadow
		#pragma target 3.0

		void surf (Input IN, inout SurfaceOutput o) {
			
			o.Albedo = float3(IN.color, IN.color, IN.color);
			//o.Metallic = _Metallic;
			//o.Smoothness = _Glossiness;
			o.Alpha = 1.0;
			o.Emission = half3(1.0, 1.0, 1.0);
			
		}
		ENDCG
	}
	FallBack "Diffuse"
}
