Shader "Hidden/AsciiArtEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature _ _REVERSE_LUM
			#pragma shader_feature _ _MULTI_COL

			#include "UnityCG.cginc"
			#include "PhotoshopMath.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _RampTex;

			int _Level;
			int _DivNumX;
			int _DivNumY;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

#ifdef UNITY_COLORSPACE_GAMMA
				float lum = Luminance(col.rgb);
#else
				float lum = LinearRgbToLuminance(col.rgb);
#endif

#ifdef _REVERSE_LUM
				float lv = 1 - saturate(round(lum * (_Level-1)) / _Level);

#else
				float lv = saturate(round(lum * (_Level-1)) / _Level);
#endif

				float2 screenUV = i.uv;
				float2 fontUV = frac(screenUV * float2(_DivNumX, _DivNumY));

				fontUV.x = fontUV.x / _Level;
				fontUV += float2(lv, 0);

				fixed4 fontCol = tex2D(_RampTex, fontUV);
#ifdef _MULTI_COL
				fixed3 hsv = rgb2hsv(col.rgb);
				fixed3 rgb = hsv2rgb(fixed3(hsv.x, hsv.y, 1));
				fontCol *= fixed4(rgb, 1);
#endif

				return fontCol;
			}
			ENDCG
		}
	}
}
