Shader "Unlit/TransparentSimple"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			ZWrite Off
			Cull Off
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

struct v2f
{
	float4 vertex  : SV_POSITION;
	float2 uv      : TEXCOORD0;
	float3 wPos    : TEXCOORD1;
	float3 wNormal : TEXCOORD2;
};

fixed4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;

v2f vert (appdata_base v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

	o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.wNormal = UnityObjectToWorldNormal(v.normal);
return o;
}

fixed4 frag (v2f i, fixed facing : VFACE ) : SV_Target
{
	i.wNormal = normalize(i.wNormal);
	i.wNormal = facing > 0.0 ? -i.wNormal : i.wNormal;
	half3 wLightlDir = UnityWorldSpaceLightDir(i.wPos);
	half  halfLambet = -dot(wLightlDir.xyz, i.wNormal) * 0.5 + 0.5;

	fixed4 col = tex2D(_MainTex, i.uv) * _Color * halfLambet;
return col;
}
ENDCG
		}
	}
}
