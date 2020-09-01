using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ClipController : MonoBehaviour {

	// Use this for initialization
	public GameObject effObj;

	private Matrix4x4 mtStorage;

	public float clipPos = 0.6f;

	void Start () {
		float Xa = 0.8f, Ya = 0.7f;
		float Xg = (1.0f+Xa)/2.0f , Yg = Ya/2.0f;
		float Xe = Ya*Ya/(2.0f*(Xa-1.0f)), Ye = .0f;
		float Xh = 1.0f, Yh = (1.0f-Xa)*Xa/Ya - (1.0f-Xa) * (1.0f-Xa)/(2 * Ya) + Ya/2.0f;
		float Xb = (Xa+Xe)/2.0f, Yb = (Ya+Ye)/2.0f;
		float Xk = (Xa+Xh)/2.0f, Yk = (Ya+Yh)/2.0f;
		float Xc = 1.0f - (1.0f - Xe) * 3.0f/2.0f, Yc = 0.0f;
		float Xj = 1.0f, Yj = Yh * 3.0f/2.0f;
		// float Xp = (Xb+Xc)/2.0f, Yp = (Yb+Yc)/2.0f;
		// float Xq = (Xk+Xj)/2.0f, Yq = (Yk+Yj)/2.0f;
		// float Xd = (Xp+Xe)/2.0f, Yd = (Yp+Ye)/2.0f;
		// float Xi = (Xq+Xh)/2.0f, Yi = (Yq+Yh)/2.0f;
		mtStorage.SetRow(0, new Vector4(Xc, Yc, Xe, Ye));
		mtStorage.SetRow(1, new Vector4(Xb, Yb, Xa, Ya));
		mtStorage.SetRow(2, new Vector4(Xk, Yk, Xh, Yh));
		mtStorage.SetRow(3, new Vector4(Xj, Yj, Xe, Ye));

		//c e b a k h j
	}
	
	// Update is called once per frame
	void Update () {
		// effObj.GetComponent<Image>().material.SetFloat("_PosX", clipPos);
		
		
		effObj.GetComponent<Image>().material.SetMatrix("_mtStorage", mtStorage);
	}
}
