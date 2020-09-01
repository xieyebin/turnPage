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
	
				sampler2D _ATex;
				sampler2D _BTex;
				sampler2D _CTex;
				//fixed4 _TintColor;
				// float _MinX;
				// float _MaxX;
				// float _MinY;
				// float _MaxY;
				

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
				
				fixed4 frag (v2f i) : SV_Target
				{
					// #ifdef SOFTPARTICLES_ON 
					// float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					// float partZ = i.projPos.z;
					// float fade = saturate (_InvFade * (sceneZ-partZ));
					// i.color.a *= fade;
					// #endif

					float _PosX;
					float _P0X;
					float _P0Y;
					float _P1X;
					float _P1Y;
					float _P2X;
					float _P2Y;
					
					fixed4 color ;

					// if(i.texcoord.x > i.texcoord.y)
					// 	color =  tex2D(_ATex, i.texcoord);//2.0f * i.color  *
					
					// else 
					// 	color = tex2D(_BTex, i.texcoord);
					

					// if(i.texcoord.x - _PosX > i.texcoord.y)
					// 	color =  tex2D(_CTex, i.texcoord);

					float a = _P0X - 2.0 * _P1X + _P2X, 
					b = (-2.0) * _P0X  + 2.0 * _P1X, 
					c = _P0X - i.texcoord.x;

					float temp = (sqrt(b * b - 4.0 * a* c));
					float t1 = (-temp - b)/(2.0*a);
					float t2 = (temp - b)/(2.0*a);
					float t;
					// if(0<t1 && t1<1)
					// 	t = t1;  
					// else 
					//	t = t2;
					if(0<t2 && t2<1)
						t = t2;
					if(0<t1 && t1<1)
						t = t1;  
					 
						
					
					float bezier_y = (1.0-t)*(1.0-t) * _P0Y + 2.0*t*(1.0-t) * _P1Y + t*t*_P2Y;
					//if( _P0X < i.texcoord.x && i.texcoord.x< _P2X )
					{
						if( i.texcoord.y < bezier_y)
							color = tex2D(_CTex, i.texcoord);
						else
							color =  tex2D(_BTex, i.texcoord);
						// if(  bezier_y - 0.05 < i.texcoord.y  && i.texcoord.y < bezier_y + 0.05)
						// 	color = tex2D(_CTex, i.texcoord);
						// else
						// 	color =  tex2D(_BTex, i.texcoord);
					}

					return color;
				}
				ENDCG 
			}
		}	
	}
 
}
