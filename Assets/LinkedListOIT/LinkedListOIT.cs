using UnityEngine;
using UnityEngine.Rendering;

public class LinkedListOIT : MonoBehaviour
{
	public Material sortMaterial;

	ComputeBuffer headPointerBuffer;
	ComputeBuffer nodeBuffer;
	

	private int[] headPointerBuffer_data;
	private void Start()
	{
		int screenSize = Screen.width * Screen.height;
		int screenOverdraw = 4;

		headPointerBuffer_data = new int[screenSize];
		for(int i = 0; i < headPointerBuffer_data.Length; i++)
			headPointerBuffer_data[i] = -1;

		headPointerBuffer = new ComputeBuffer(screenSize, sizeof(int));
		nodeBuffer = new ComputeBuffer(screenSize * screenOverdraw, sizeof(float) * 4 + sizeof(float) + sizeof(int), ComputeBufferType.Counter);

		Shader.SetGlobalBuffer("_HeadPointerBuffer", headPointerBuffer);
		Shader.SetGlobalBuffer("_NodeBuffer", nodeBuffer);
	}

	private void Update()
	{
		
	}

	void OnPreRender()
	{
		headPointerBuffer.SetData(headPointerBuffer_data);
		nodeBuffer.SetCounterValue(0);

		//Graphics.ClearRandomWriteTargets();
		Graphics.SetRandomWriteTarget(1, headPointerBuffer);
		Graphics.SetRandomWriteTarget(2, nodeBuffer);
	}

	void OnPostRender()
	{
		Graphics.ClearRandomWriteTargets();
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		Graphics.Blit(src, dest, sortMaterial);
	}

	private void OnDestroy()
	{
		if(headPointerBuffer != null)
			headPointerBuffer.Dispose();

		if(nodeBuffer != null)
			nodeBuffer.Dispose();
	}
}
