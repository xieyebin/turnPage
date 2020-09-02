Shader "UI/Custom/Clip" {
	Properties {
	//_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_ATex ("A Texture", 2D) = "white" {}
	_BTex ("B Texture", 2D) = "white" {}
	_CTex ("C Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0

	_PosX ("pos_X", Float) = 0.8
	_PosY ("pos Y", Float) = 0.7

	_P0X ("P0X", Float) = 0.0
	_P0Y ("P0Y", Float) = 0.0
	_P1X ("P1X", Float) = 0.8
	_P1Y ("P1Y", Float) = 0.2
	_P2X ("P2X", Float) = 1.0
	_P2Y ("P2Y", Float) = 1.0
	
	// _MinX ("Min X", Float) = -1
	// _MaxX ("Max X", Float) = 1
	// _MinY ("Min Y", Float) = -1
	// _MaxY ("Max Y", Float) = 1
	}
 
	Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	AlphaTest Greater .01
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
		SubShader {
			Pass {
			
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_particles
	
				#include "UnityCG.cginc"

				float4x4 _mtStorage;
				float clipPosx, clipPosy;
	
				sampler2D _ATex;
				sampler2D _BTex;
				sampler2D _CTex;
				//fixed4 _TintColor;
				// float _MinX;
				// float _MaxX;
				// float _MinY;
				// float _MaxY;
				float _PosX;
				float _P0X;
				float _P0Y;
				float _P1X;
				float _P1Y;
				float _P2X;
				float _P2Y;

				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};
	
				struct v2f {
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD1;
					#endif
					float3 vpos : TEXCOORD2;
				};
				
				float4 _ATex_ST;
				float4 _BTex_ST;
				float4 _CTex_ST;
	
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vpos = v.vertex.xyz;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.vpos = ComputeScreenPos (o.vertex);
					#ifdef SOFTPARTICLES_ON
					o.projPos = ComputeScreenPos (o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_ATex);
					return o;
				}
	
				sampler2D_float _CameraDepthTexture;
				float _InvFade;

				float cal_bezier_y(float2 P0, float2 P1, float2 P2, float x){
					float a = P0.x - 2.0 * P1.x + P2.x, 
					b = (-2.0) * P0.x  + 2.0 * P1.x, 
					c = P0.x - x;

					float temp = (sqrt(b * b - 4.0 * a* c));
					float t1 = (-temp - b)/(2.0*a);
					float t2 = (temp - b)/(2.0*a);
					float t;
					if(0<t2 && t2<1)
						t = t2;
					if(0<t1 && t1<1)
						t = t1;  
					float bezier_y = (1.0-t)*(1.0-t) * P0.y + 2.0*t*(1.0-t) * P1.y + t*t*P2.y;
					return bezier_y;
				}

				float cal_line_y(float2 P0, float2 P1, float x){
					return (((P1.x-x) * P0.y + (x - P0.x) * P1.y )/(P1.x - P0.x));
				}


				
				fixed4 frag (v2f i) : SV_Target
				{
					// #ifdef SOFTPARTICLES_ON 
					// float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					// float partZ = i.projPos.z;
					// float fade = saturate (_InvFade * (sceneZ-partZ));
					// i.color.a *= fade;
					// #endif
					
					fixed4 color ;

					// float2 p0 = float2(_P0X, _P0Y);
					// float2 p1 = float2(_P1X, _P1Y);
					// float2 p2 = float2(_P2X, _P2Y);


					color = tex2D(_ATex, i.texcoord);
					
					//c.x~d.x
					if(_mtStorage[0][0] <i.texcoord.x && i.texcoord.x < _mtStorage[1][2])
					{
						float2 p0 = float2(_mtStorage[0][0], _mtStorage[0][1]);
						float2 p1 = float2(_mtStorage[0][2], _mtStorage[0][3]);
						float2 p2 = float2(_mtStorage[1][0], _mtStorage[1][1]);
						float bezier_y = cal_bezier_y(p0, p1, p2, i.texcoord.x);
						if( i.texcoord.y < bezier_y)
							color = tex2D(_CTex, i.texcoord);
						else
							color =  tex2D(_ATex, i.texcoord);
					}
					//i.x~j.x
					if(_mtStorage[3][2] <i.texcoord.x && i.texcoord.x < _mtStorage[3][0])
					{
						float2 p0 = float2(_mtStorage[2][0], _mtStorage[2][1]);
						float2 p1 = float2(_mtStorage[2][2], _mtStorage[2][3]);
						float2 p2 = float2(_mtStorage[3][0], _mtStorage[3][1]);
						float bezier_y = cal_bezier_y(p0, p1, p2, i.texcoord.x);
						if( i.texcoord.y < bezier_y)
							color = tex2D(_CTex, i.texcoord);
						else
							color =  tex2D(_ATex, i.texcoord);
					}

					//d.x~i.x
					if(_mtStorage[1][2] <i.texcoord.x && i.texcoord.x < _mtStorage[3][2]){
						
						float2 q0 = float2(_mtStorage[1][2], _mtStorage[1][3]);
						float2 q1 = float2(_mtStorage[3][2], _mtStorage[3][3]);
						float line_y = cal_line_y(q0, q1, i.texcoord.x);
						if( i.texcoord.y < line_y){
							color = tex2D(_CTex, i.texcoord);
						}
						else
						{
							//color = tex2D(_BTex, i.texcoord);

							//d.x~b.x
							if(_mtStorage[1][2] <=i.texcoord.x && i.texcoord.x < _mtStorage[1][0]){
								float2 c = float2(_mtStorage[0][0], _mtStorage[0][1]);
								float2 e = float2(_mtStorage[0][2], _mtStorage[0][3]);
								float2 b = float2(_mtStorage[1][0], _mtStorage[1][1]);
								float bezier_y = cal_bezier_y(c, e, b, i.texcoord.x);
								if( i.texcoord.y < bezier_y)
									color = tex2D(_BTex, i.texcoord);
								else
									color =  tex2D(_ATex, i.texcoord);
							}
							//b.x~a.x
							if(_mtStorage[1][0] <=i.texcoord.x && i.texcoord.x < clipPosx){
								//color = tex2D(_BTex, i.texcoord);
								float2 b0 = float2(_mtStorage[1][0], _mtStorage[1][1]);
								float2 a1 = float2(clipPosx, clipPosy);
								float line_y2 = cal_line_y(b0, a1, i.texcoord.x);
								if( i.texcoord.y < line_y2){
									color = tex2D(_BTex, i.texcoord);
								}
								else
									color =  tex2D(_ATex, i.texcoord);
							}
							//a.x~k.x
							if(clipPosx <=i.texcoord.x && i.texcoord.x < _mtStorage[2][0]){
								//color = tex2D(_BTex, i.texcoord);
								float2 a2 = float2(clipPosx, clipPosy);
								float2 k1 = float2(_mtStorage[2][0], _mtStorage[2][1]);
								float line_y2 = cal_line_y(a2, k1, i.texcoord.x);
								if( i.texcoord.y < line_y2)
									color = tex2D(_BTex, i.texcoord);
								else
									color = tex2D(_ATex, i.texcoord);
							}
							//k.x~i.x
							if(_mtStorage[2][0] <= i.texcoord.x && i.texcoord.x < _mtStorage[3][2]){
								float2 k = float2(_mtStorage[2][0], _mtStorage[2][1]);
								float2 h = float2(_mtStorage[2][2], _mtStorage[2][3]);
								float2 j = float2(_mtStorage[3][0], _mtStorage[3][1]);
								float bezier_y2 = cal_bezier_y(k, h, j, i.texcoord.x);
								if( i.texcoord.y < bezier_y2)
									color = tex2D(_BTex, i.texcoord);
								else
									color =  tex2D(_ATex, i.texcoord);
							}
						}
						
					}

					// //b.x~a.x
					// if(_mtStorage[1][0] < i.texcoord.x && i.texcoord.x < clipPosx)
					// {
					
					// 	float2 p0 = float2(_mtStorage[1][0], _mtStorage[1][1]);
					// 	float2 p1 = float2(clipPosx, clipPosy);
					// 	line_y = cal_line_y(p0, p1, i.texcoord.x);
					// 	if( i.texcoord.y < line_y){
					// 		color = tex2D(_CTex, i.texcoord);
					// 	}
					// 	else
					// 		color =  tex2D(_BTex, i.texcoord);
					// }
					// //a.x~k.x
					// if( clipPosx < i.texcoord.x && i.texcoord.x < _mtStorage[2][0] )
					// {
					// 	float2 p0 = float2(clipPosx, clipPosy);
					// 	float2 p1 = float2(_mtStorage[2][0], _mtStorage[2][1]);
					// 	line_y = cal_line_y(p0, p1, i.texcoord.x);
					// 	if( i.texcoord.y < line_y)
					// 		color = tex2D(_CTex, i.texcoord);
					// 	else
					// 		color = tex2D(_BTex, i.texcoord);
					// }
					
					// bezier_y = cal_bezier_y(p0, p1, p2, i.texcoord.x);

					// _mtStorage[1][1] = 1.0f;
					
					// {
						
					// }

					return color;
				}
				ENDCG 
			}
		}	
	}
 
}
