
			  Shader"Cloud/cloud3D"{
	Properties{
		_MainTex("MainTex",Color) = (1,1,1,1)
		_Noise3D("Noise3D",3D) = ""{}
		_NoiseScale("NoiseScale",Range(0.0,200.0)) = 1
		_Speed("Speed",Range(0.0,20.0)) = 1
		_ColorTint("Color",Color) = (0.9,0.9,0.9,0.9)
		_Cutoff("AlphaClipping",Range(-1,1.0)) = 0.5
		_AlphaBlend("AlphaBlend",Range(0.0,1.0)) = 0.5
		_LargeWaves("LargeCloud",Range(0.0,1.0)) = 0.5
		_MiddleWaves("MiddleCloud",Range(0.0,1.0)) = 0.3
		_SmallWaves("SmallCloud",Range(0.0,1.0)) = 0.1
	}
		SubShader{
			Tags
				{
					"RenderPipeline" = "UniversalPipeline"
					"IgnoreProjector" = "True"
					"Queue" = "Transparent"
					"RenderType" = "Transparent"
			
					
				}
		HLSLINCLUDE

			  #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			   #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			//	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

			  uniform TEXTURE2D(_MainTex);
			  uniform SAMPLER(sampler_MainTex);
			  //TEXTURE3D(_Noise3D);
			  //SAMPLER(sampler_Noise3D);

			  //Define variable
			//  UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
				//UNITY_DEFINE_INSTANCED_PROP(float4,_ColorTint)

				//UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)


			 CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
				float4 _Noise_ST;
				float _NoiseScale;
				float _Speed;
				float4 _ColorTint;
				float _Cutoff;
				float _LargeWaves;
				float _MiddleWaves;
				float _SmallWaves;
				float alpha;
			   CBUFFER_END

			   ENDHLSL


				   Pass{
					   Tags{"LightMode" = "UniversalForward"}
					   Blend SrcAlpha OneMinusSrcAlpha
					   //Zwrite Off
						Cull Off
						HLSLPROGRAM
						#pragma vertex vert
						#pragma fragment frag


				   //GPU instance
					#pragma multi_compile_instancing
				   #pragma instancing_options procedural:setup

				   //SHADOW
					#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
					#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

					#pragma multi_compile _ _SHADOWS_SOFT//



				   //Instance Information;
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
				   struct CloudInfo {
				   float4x4 matrices;
				   float4 _BaseColor;
				   }
			   StructuredBuffer<CloudInfo>_CloudInfos;
#endif


				   sampler3D _Noise3D;

				   struct Attributes
					{
						float4 positionOS : POSITION;
						float3 normalOS:NORMAL;
						float2 uv : TEXCOORD0;
						half4 color:COLOR;
						uint instanceID : SV_InstanceID;
						//UNITY_VERTEX_INPUT_INSTANCE_ID


					};
					struct Varings
					{
						
						float4 positionCS : SV_POSITION;
						float2 uv : TEXCOORD0;
						float3 positionWS:TEXCOORD1;
						float3 viewDirWS:TEXCOORD2;
						float3 normalWS:TEXCOORD3;
						float3 uvw:TEXCOORD4;

 #ifdef SHADOWS_SHADOWMASK
						float4 shadowcoord:TEXCOORD4;
 #endif
					 };

					Varings vert(Attributes IN) {
						Varings OUT;
						//Sampler 3D noise and flow UV
						
						//UNITY_SETUP_INSTANCE_ID(IN);
						//UNITY_TRANSFER_INSTANCE_ID(IN,OUT);
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
						CloudInfo cloudInfo = _CloudInfos[instanceID];
#endif


						OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
						OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
 #ifdef SHADOWS_SHADOWMASK
						OUT.shadowcoord = TransformWorldToShadowCoord(OUT.positionWS);
 #endif
						//OUT.viewDirWS = GetCameraPositionWS() - OUT.positionWS;
						OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
						OUT.uvw = OUT.positionWS.xyz;

						//OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);


						return OUT;
					}

					float4 frag(Varings IN) :SV_Target
					{

						//UNITY_SETUP_INSTANCE_ID(IN);
						float3 FlowUVW = IN.uvw / _NoiseScale;//+ (_Time.xyz/3) * _Speed * half3(1, 1, 1);
						
						 float4 samplerColor = tex3D(_Noise3D, FlowUVW);
						 //Add noise to the uv
						 float4 samplerColorNoise = tex3D(_Noise3D, IN.uvw + samplerColor.b * 0.2);
						 //samplerColor = samplerColor + samplerColorNoise;
						 float MaxGB =1-(_MiddleWaves + _SmallWaves);
						 float AlphaTint = (_LargeWaves * samplerColor.r + _MiddleWaves * samplerColor.b + _SmallWaves * samplerColor.g);///MaxGB*1.5;
						 
						 clamp(AlphaTint, 0.0, 1.0);
						 clip(AlphaTint - _Cutoff);
						 
						 half4 ambient = UNITY_LIGHTMODEL_AMBIENT;
						 
						
						// Smooth the cloud
	

						 //mix RGB R for the main ,b for the middle waves , c for the small Waves
						
						 samplerColor.a = samplerColor.r + _MiddleWaves * samplerColor.b + _SmallWaves*samplerColor.g;
						 float SmoothedA = smoothstep(0, 1-_Cutoff , samplerColor.a);


						 //shadow the cloud
						 Light light = GetMainLight();

						//return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _ColorTint);
						 return _ColorTint;//* _ColorTint;// + ambient;

					 }


				ENDHLSL

			   }
 }


		}

