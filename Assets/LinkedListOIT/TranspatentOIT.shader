Shader "Unlit/TranspatentOIT"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "DisableBatching" = "True" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			ZWrite Off
			Cull Off
			ColorMask 0
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 5.0
#include "UnityCG.cginc"


struct v2f
{
	float4 vertex  : SV_POSITION;
	float2 uv      : TEXCOORD0;
	float3 wPos    : TEXCOORD1;
	float3 wNormal : TEXCOORD2;
};


	struct FragmentNode
{
	float4 color;
	float  depth;
	uint   next;
};


RWBuffer<uint> _HeadPointerBuffer: register(u1);
RWStructuredBuffer<FragmentNode> _NodeBuffer: register(u2);

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


[earlydepthstencil]
fixed4 frag(v2f i, fixed facing : VFACE ) : SV_Target
{
	uint pixelIndex = (uint)i.vertex.y * _ScreenParams.x + (uint)i.vertex.x;

	uint pixelCounter = _NodeBuffer.IncrementCounter();
	uint prevPixelCounter;
	InterlockedExchange(_HeadPointerBuffer[pixelIndex], pixelCounter, prevPixelCounter);

	fixed4 col = tex2D(_MainTex, i.uv) * _Color;

	i.wNormal = normalize(i.wNormal);
	i.wNormal = facing > 0 ? -i.wNormal : i.wNormal;
	half3 wLightlDir = UnityWorldSpaceLightDir(i.wPos);
	half  halfLambet = -dot(wLightlDir.xyz, i.wNormal) * 0.5 + 0.5;

	FragmentNode fragNode;
	fragNode.color = col * halfLambet;
	fragNode.depth = i.vertex.z;
	fragNode.next  = prevPixelCounter;


	_NodeBuffer[pixelCounter] = fragNode;
return col;
}
ENDCG
		}
	}
}