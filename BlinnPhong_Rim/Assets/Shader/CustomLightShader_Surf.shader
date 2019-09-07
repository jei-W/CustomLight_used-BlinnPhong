Shader "Custom/SurfaceShader/CustomLightShader_Surf"
{
    Properties
    {
		_MainTex ("Albedo", 2D) = "white" {}
		_BumpMap ("Normal", 2D) = "bump" {}
		_SpecMap ("Specular", 2D) = "white" {}
		_RimColor ("RimLight Color", Color) = (1,1,1,1)
		_RimPow ("RimLight Strenght", Range(0, 1)) = 0.3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf BlinnPhongWithRim

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _SpecMap;

		fixed4 _RimColor;
		half _RimPow;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal( tex2D(_BumpMap, IN.uv_BumpMap) );
			o.Specular = tex2D(_SpecMap, IN.uv_MainTex);
        }

		fixed4 LightingBlinnPhongWithRim (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
		{
			// Half Lambert Lighting
			float ndotl = dot(s.Normal, lightDir) * 0.5 + 0.5;
			ndotl = pow(ndotl, 3);
			fixed3 diffuse = s.Albedo * ndotl * _LightColor0 * atten;

			// Specular _Blinn Phong
			float3 H = normalize(lightDir + viewDir); // half-vector
			float spec = dot(H, s.Normal) * 0.5 + 0.5;
			spec = pow(spec, 80); // specular 범위가 너무 넓으므로 줄여준다
			// Specular _Rim
			fixed rim = abs( dot(viewDir, s.Normal) );
			spec += pow(rim, 200) * 0.3;

			// Rim Lighting
			rim = pow(1 - rim, 3);	// 너무 완만한 RimLight의 범위를 조절해준다

			fixed4 result;
			result.rgb = diffuse.rgb + (spec * _LightColor0.rgb * s.Specular) + (rim * _RimColor.rgb * _RimPow);
			result.a = s.Alpha;

			return result;
		}

        ENDCG
    }
    FallBack "Diffuse"
}
