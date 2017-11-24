Shader "Unlit/LinkedList_Blit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Layer("Layer", Range(0.0, 31.0)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			ZWrite Off
			ZTest Always

CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#pragma target 5.0
#include "UnityCG.cginc"


#define TMP_ARRAY_SIZE 16


struct FragmentNode
{
	float4 color;
	float  depth;
	uint   next;
};


Buffer<uint> _HeadPointerBuffer;
StructuredBuffer<FragmentNode> _NodeBuffer;
sampler2D _MainTex;
float4 _MainTex_ST;


fixed4 frag(v2f_img i) : SV_Target
{
	half4 background = tex2D(_MainTex, i.uv);

	uint pixelIndex = (_ScreenParams.y - (uint)i.pos.y) * _ScreenParams.x + (uint)i.pos.x;
	uint pointer = _HeadPointerBuffer[pixelIndex];
	if (pointer == 0xFFFFFFFF)
		return background;
	

	//Store linked list to a temporary buffer
	FragmentNode fragTmpArray[TMP_ARRAY_SIZE];
	uint numberOfLayers = 0;
	for (uint ix = 0; ix < TMP_ARRAY_SIZE; ix++)
	{
		FragmentNode fragNode = _NodeBuffer[pointer];
		fragTmpArray[ix] = fragNode;
		numberOfLayers++;

		pointer = fragNode.next;
		if (pointer == 0xFFFFFFFF) break;
	}


	//Sort temporary buffer //BubbleSort
	for (int ix = (numberOfLayers - 2); ix >= 0; ix--)
	{
		for (int jx = 0; jx <= ix; jx++)
		{
			if (fragTmpArray[jx].depth > fragTmpArray[jx + 1].depth)
			{
				FragmentNode temp = fragTmpArray[jx + 1];
				fragTmpArray[jx + 1] = fragTmpArray[jx];
				fragTmpArray[jx] = temp;
			}
		}
	}


	//Final blend
	float4 result = background;
	for (uint ix = 0; ix < numberOfLayers; ix++)
	{
		float4 color = fragTmpArray[ix].color;
		result = lerp(result, color, color.a);
	}


return result;
}
ENDCG
		}
	}
}