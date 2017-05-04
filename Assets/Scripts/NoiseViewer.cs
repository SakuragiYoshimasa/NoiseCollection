using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ExperimentUtilities;


//1d->1d: Only graph
//2d->1d:
//3d->1d:
//3d->3d:
//4d->1d:
//4d->3d:
[RequireComponent(typeof(MeshRenderer))]
public class NoiseViewer : MonoBehaviour {

	#region Parameters
	[Header("BufferSize")]
	[SerializeField, Range(1, 2048)] int size_x = 2048;
	[Tooltip("User for Trailer")]
	[SerializeField, Range(1, 2048)] int size_y = 1; 
	[SerializeField] float Z;
	#endregion

	#region ShaderAndMat
	[Header("Shader")]
	[SerializeField] Shader _kernel;
	[SerializeField] Shader _surface;
	Material _kernelMat;
	Material _surfaceMat;
	[SerializeField] Material _testMat;
	Mesh _mesh;

	enum KernelPass {
		InitPosition, UpdatePosition,
		InitVelocity, UpdateVelocity
	}
	#endregion

	#region Buffer
	[SerializeField] RenderTexture positionBufferDist;
	[SerializeField] RenderTexture positionBufferSource;
	[SerializeField] RenderTexture velocityBufferDist;
	[SerializeField] RenderTexture velocityBufferSource;
	#endregion

	#region Status
	[Header("Status")]
	[SerializeField] bool _asVelocity;

	enum NoiseType {
		Parlin2D, Parlin3D, Parlin4D,
		Simplex2D, Simplex3D, Simplex4D, 
		Curl2D, Curl3D, Curl4D
	}

	[SerializeField] NoiseType _noise = NoiseType.Parlin2D;
	#endregion

	#region Update Buffer and Render
	void KernelUpdate(){
		//Set Params
		_kernelMat.SetFloat("_Z", Z);
		_kernelMat.SetInt("_AsVelocity", 0);
		_kernelMat.SetTexture("_PositionTex", positionBufferSource);
		//Update
		Graphics.Blit(null, positionBufferDist, _kernelMat, (int)KernelPass.UpdatePosition);
		if(_asVelocity && velocityBufferDist != null) {
			Graphics.Blit(null, velocityBufferDist, _kernelMat, (int)KernelPass.UpdateVelocity);
		}
		
		SwapBuffer();
	}

	void SwapBuffer(){
		RenderTexture temp = positionBufferDist;
		positionBufferDist = positionBufferSource;
		positionBufferSource = temp;
		temp = velocityBufferDist;
		velocityBufferDist = velocityBufferSource;
		velocityBufferSource = temp;
	}

	void RenderUpdate(){
		//Set Params
		_surfaceMat.SetTexture("_PositionTex", positionBufferSource);
		Graphics.DrawMesh (_mesh, transform.localToWorldMatrix, _surfaceMat, this.gameObject.layer);
		//Graphics.DrawMesh (_mesh, transform.localToWorldMatrix, _testMat, this.gameObject.layer);
	}
	#endregion

	#region Main Cycle
	void Awake () {
		InitMaterials();
		InitBuffers(_asVelocity);
		InitMesh();
	}

	void LateUpdate () {
		KernelUpdate();
		RenderUpdate();
	}
	#endregion

	#region Init
	void InitBuffers(bool asVelocity){
		positionBufferDist = Buffer.CreateSquereRTBuffer(size_x, size_y);
		positionBufferSource = Buffer.CreateSquereRTBuffer(size_x, size_y);
		if(!asVelocity) return;
		velocityBufferDist = Buffer.CreateSquereRTBuffer(size_x, size_y);
		velocityBufferSource = Buffer.CreateSquereRTBuffer(size_x, size_y);
	}

	void InitMaterials(){
		_kernelMat = MaterialFuncs.CreateMaterial(_kernel);
		_surfaceMat = MaterialFuncs.CreateMaterial(_surface);

		Graphics.Blit(null, positionBufferDist, _kernelMat, (int)KernelPass.InitPosition);
		Graphics.Blit(null, velocityBufferDist, _kernelMat, (int)KernelPass.InitVelocity);
	}

	void InitMesh(){

		_mesh = new Mesh();
		
		Vector3[] vertices = new Vector3[size_x * size_y];
		int[] indices = new int[size_x * size_y];
		for(int i = 0; i < size_x; i++){
			for(int j = 0; j < size_y; j++){
				vertices[i * size_y + j] = new Vector3((float)i / (float)size_x + 0.5f, (float)j / (float)size_y + 0.5f, 1.0f);
				indices[i * size_y + j] = i * size_y + j;
			}
		}

		_mesh.vertices = vertices;
		_mesh.SetIndices(indices, MeshTopology.Points, 0);
	}
	#endregion
}
