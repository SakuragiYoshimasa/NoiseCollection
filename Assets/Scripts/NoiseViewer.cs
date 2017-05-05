//using System.Collections;
//using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using ExperimentUtilities;

//1d->1d: Only graph
//2d->1d:
//3d->1d:
//3d->3d:
//4d->1d:
//4d->3d:

namespace NoiseCollection {
	[RequireComponent(typeof(MeshRenderer))]
	public class NoiseViewer : MonoBehaviour {

		#region Parameters
		[Header("BufferSize")]
		[SerializeField, Range(1, 2048)] int size_x = 2048;
		[Tooltip("User for Trailer")]
		[SerializeField, Range(1, 2048)] int size_y = 1; 
		#endregion

		#region ShaderAndMat
		[Header("Shader")]
		[SerializeField] Shader _kernel;
		[SerializeField] Shader _surface;
		Material _kernelMat;
		Material _surfaceMat;

		enum KernelPass {
			InitPosition, UpdatePosition,
			InitVelocity, UpdateVelocity
		}
		#endregion

		#region Render Resource
		Mesh _mesh;
		[SerializeField] RawImage _textureCanvas;
		#endregion

		#region Buffer
		RenderTexture positionBufferDist;
		RenderTexture positionBufferSource;
		RenderTexture velocityBufferDist;
		RenderTexture velocityBufferSource;
		#endregion

		#region Status
		[Header("Status")]
		[SerializeField] bool _asVelocity;
		[SerializeField] bool _threeD;

		enum NoiseType {
			ClassicPerlin, PeriodicPerlin, Simplex, SimplexGradN, SimplexGradA
		}

		[SerializeField] NoiseType _noise = NoiseType.ClassicPerlin;

		enum ViewType {
			Texture, Mesh
		}
		[SerializeField] ViewType _viewType = ViewType.Texture;
		#endregion

		#region Update Buffer and Render
		void KernelUpdate(){
			//Set Params
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
			if(_viewType == ViewType.Mesh){
				
				_textureCanvas.gameObject.SetActive(false);
				_surfaceMat.SetTexture("_PositionTex", positionBufferSource);
				Graphics.DrawMesh (_mesh, transform.localToWorldMatrix, _surfaceMat, this.gameObject.layer);
			}else if(_viewType == ViewType.Texture){
				_textureCanvas.gameObject.SetActive(true);
				_textureCanvas.texture = positionBufferSource;
			}
		}

		void UpdateShaderKeywords(){
			_kernelMat.shaderKeywords = null;

			switch(_noise){
				case NoiseType.ClassicPerlin:
					_kernelMat.EnableKeyword("CNOISE");
					break;
				case NoiseType.PeriodicPerlin:
					_kernelMat.EnableKeyword("PNOISE");
					break;
				case NoiseType.Simplex:
					_kernelMat.EnableKeyword("SNOISE");
					break;
				case NoiseType.SimplexGradN:
					_kernelMat.EnableKeyword("SNOISE_NGRAD");
					break;
				case NoiseType.SimplexGradA:
					_kernelMat.EnableKeyword("SNOISE_AGRAD");
					break;
				default: break;
			}

			if(_threeD) _kernelMat.EnableKeyword("THREED");
			if(_asVelocity) _kernelMat.EnableKeyword("ASVELOCITY");
		}

		#endregion

		#region Main Cycle
		void Awake () {
			InitMaterials();
			InitBuffers(_asVelocity);
			InitMesh();
		}

		void Update(){
			UpdateShaderKeywords();
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
}