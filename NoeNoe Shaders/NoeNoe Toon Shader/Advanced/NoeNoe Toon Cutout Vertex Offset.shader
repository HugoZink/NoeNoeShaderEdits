Shader "NoeNoe/NoeNoe Toon Shader/Advanced/NoeNoe Toon Cutout Vertex Offset" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main texture (RGB)", 2D) = "white" {}
        _StaticToonLight ("Static Toon Light", Vector) = (0,3,0,0)
		_WorldLightIntensity ("World Light Dir Multiplier", Range(0, 10)) = 1
		[Toggle(_OVERRIDE_WORLD_LIGHT_DIR_ON)] _OverrideWorldLight ("Override World Light", Float) = 0
        [Toggle(_)] _BillboardStaticLight ("Billboard Static Light", Float ) = 0
        _Ramp ("Ramp", 2D) = "white" {}
        _ToonContrast ("Toon Contrast", Range(0, 1)) = 0.25
        _EmissionMap ("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor ("Emission", Color) = (0,0,0,1)
        _Intensity ("Intensity", Range(0, 10)) = 0.8
        _Saturation ("Saturation", Range(0, 1)) = 0.65
        _NormalMap ("Normal Map", 2D) = "bump" {}
		[Enum(None,0,Metallic,1,Specular,2)] _MetallicMode("Metallic Mode", Float) = 0
		[NoScaleOffset] _MetallicGlossMap("Metallic Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Glossiness("Smoothness", Range( 0 , 1)) = 0
        _SpecColor("Specular Color", Color) = (0,0,0,0)
        _SpecGlossMap("Specular Map", 2D) = "white" {}
        _OutlineWidth ("Outline Width", Float ) = 0
        _OutlineColor ("Outline Tint", Color) = (0,0,0,1)
		_OutlineTex ("Outline Texture", 2D) = "white" {}
        [Toggle(_)] _ScreenSpaceOutline ("Screen-Space Outline", Float ) = 0
		[Enum(Normal,8,Outer Only,6)] _OutlineStencilComp ("Outline Mode", Float) = 8
		[Toggle(_)] _OutlineCutout ("Cutout Outlines", Float) = 1
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		_VertexOffset ("Vertex Offset", Vector) = (0,0,0,0)
		_VertexRotation ("Local Rotation", Vector) = (0,0,0,0)
		_VertexScale ("Scale", Vector) = (1,1,1,1)
		[NoScaleOffset] _RampMaskTex ("Ramp Mask", 2D) = "black"
		[NoScaleOffset] _RampR ("Ramp (R)", 2D) = "white" {}
		_RampTintR ("Ramp Tint (R)", Range(0,1)) = 0
		_ToonContrastR ("Toon Contrast (R)", Range(0, 1)) = 0.25
        _IntensityR ("Intensity (R)", Range(0, 10)) = 0.8
        _SaturationR ("Saturation (R)", Range(0, 1)) = 0.65
		[NoScaleOffset] _RampG ("Ramp (G)", 2D) = "white" {}
		_RampTintG ("Ramp Tint (G)", Range(0,1)) = 0
		_ToonContrastG ("Toon Contrast (G)", Range(0, 1)) = 0.25
        _IntensityG ("Intensity (G)", Range(0, 10)) = 0.8
        _SaturationG ("Saturation (G)", Range(0, 1)) = 0.65
		[NoScaleOffset] _RampB ("Ramp (B)", 2D) = "white" {}
		_RampTintB ("Ramp Tint (B)", Range(0,1)) = 0
		_ToonContrastB ("Toon Contrast (B)", Range(0, 1)) = 0.25
        _IntensityB ("Intensity (B)", Range(0, 10)) = 0.8
        _SaturationB ("Saturation (B)", Range(0, 1)) = 0.65
		[Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 2
		[Toggle(_SHADOW_RECEIVE_ON)] _ReceiveShadows ("Receive Shadows", Float) = 0
		_MatCap ("Matcap Texture", 2D) = "white" {}
		[Enum(Off,0,Additive (spa),1,Multiply (sph),2)] _MatCapMode ("Matcap Mode", Float) = 0
		_MatCapStrength ("Matcap Strength", Range(0, 1)) = 1
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout"
        }
		
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull [_Cull]
			
			Stencil {
				Ref 8
				Comp Always
				Pass Replace
			}
            
            CGPROGRAM
            #pragma vertex vertOffset
            #pragma fragment frag
			
			#ifndef UNITY_PASS_FORWARDBASE
				#define UNITY_PASS_FORWARDBASE
			#endif
			
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _SPECGLOSSMAP
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature_local _OVERRIDE_WORLD_LIGHT_DIR_ON
			#pragma shader_feature_local _SHADOW_RECEIVE_ON
			#pragma shader_feature_local _EMISSION
			#pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
			
			#define NOENOETOON_RAMP_MASKING
			
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform float _Intensity;
			
			float _Cutoff;
			
			float _OverrideWorldLight;
            
            uniform float4 _StaticToonLight;
            uniform sampler2D _Ramp; uniform float4 _Ramp_ST;
            float3 VRViewPosition(){
            #if defined(USING_STEREO_MATRICES)
            float3 leftEye = unity_StereoWorldSpaceCameraPos[0];
            float3 rightEye = unity_StereoWorldSpaceCameraPos[1];
            
            float3 centerEye = lerp(leftEye, rightEye, 0.5);
            #endif
            #if !defined(USING_STEREO_MATRICES)
            float3 centerEye = _WorldSpaceCameraPos;
            #endif
            return centerEye;
            }
            
            uniform float _Saturation;
            uniform fixed _BillboardStaticLight;
            uniform float _ToonContrast;
			
			#include "../NoeNoeToonEdits.cginc"
			#include "VertOffset.cginc"
			
            ENDCG
        }
		
        Pass {
            Name "Outline"
            Tags {
				"LightMode"="ForwardBase"
            }
            Cull Front
			
			Stencil {
				Ref 8
				Comp [_OutlineStencilComp]
				Pass Keep
			}
            
            CGPROGRAM
            #pragma vertex vertOutlineOffset
            #pragma fragment frag
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            //#pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _SPECGLOSSMAP
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature_local _OVERRIDE_WORLD_LIGHT_DIR_ON
			#pragma shader_feature_local _SHADOW_RECEIVE_ON
			#pragma shader_feature_local _EMISSION
			#pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
			
			#define NOENOETOON_OUTLINE_PASS
			
            uniform sampler2D _OutlineTex; uniform float4 _OutlineTex_ST;
			uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
            uniform float _OutlineWidth;
            uniform fixed _ScreenSpaceOutline;
            uniform float4 _OutlineColor;
			
			float3 VRViewPosition(){
            #if defined(USING_STEREO_MATRICES)
            float3 leftEye = unity_StereoWorldSpaceCameraPos[0];
            float3 rightEye = unity_StereoWorldSpaceCameraPos[1];
            
            float3 centerEye = lerp(leftEye, rightEye, 0.5);
            #endif
            #if !defined(USING_STEREO_MATRICES)
            float3 centerEye = _WorldSpaceCameraPos;
            #endif
            return centerEye;
            }
			
			float _OutlineCutout;
			float _Cutoff;
			
			float _OverrideWorldLight;
            
            uniform float4 _StaticToonLight;
            uniform sampler2D _Ramp; uniform float4 _Ramp_ST;
			
			uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
			
            uniform float _Saturation;
            uniform float _Intensity;
            uniform fixed _BillboardStaticLight;
            uniform float _ToonContrast;
			
			#include "../NoeNoeToonEdits.cginc"
			#include "VertOffset.cginc"

			VertexOutput vertOutlineOffset (VertexInput v) {

				//Apply scale
				v.vertex *= _VertexScale;

				// Apply rotation
				float3 vertexPos = v.vertex.xyz;
				vertexPos = mul(xRotation3dRadians(radians(_VertexRotation.x)), vertexPos);
				vertexPos = mul(yRotation3dRadians(radians(_VertexRotation.y)), vertexPos);
				vertexPos = mul(zRotation3dRadians(radians(_VertexRotation.z)), vertexPos);
				v.vertex = float4(vertexPos, v.vertex.w);

				//Apply offset
				v.vertex += _VertexOffset;

				VertexOutput o = (VertexOutput)0;
				o.uv0 = v.texcoord0;
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
				o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
				
				float3 lightColor = _LightColor0.rgb;
				
                float outlineWidth = (_OutlineWidth*0.001);
				// Scale outline by outline tex alpha
				float4 outlineTex = tex2Dlod(_OutlineTex, float4(v.texcoord0, 0, 0));
				outlineTex *= _OutlineColor;
				outlineWidth *= outlineTex.a;
				
                float OutlineScale = lerp( outlineWidth, (distance(_WorldSpaceCameraPos,mul(unity_ObjectToWorld, v.vertex).rgb)*outlineWidth), _ScreenSpaceOutline);
                o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal*OutlineScale,1));
				o.posWorld = mul(unity_ObjectToWorld, float4(v.vertex.xyz + v.normal*OutlineScale,1));
				TRANSFER_VERTEX_TO_FRAGMENT(o)
				return o;
			}
			
            ENDCG
        }
		
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            Cull [_Cull]
            
            
            CGPROGRAM
            #pragma vertex vertOffset
            #pragma fragment frag
			
			#ifndef UNITY_PASS_FORWARDADD
				#define UNITY_PASS_FORWARDADD
			#endif
			
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _SPECGLOSSMAP
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature_local _OVERRIDE_WORLD_LIGHT_DIR_ON
			#pragma shader_feature_local _SHADOW_RECEIVE_ON
			#pragma shader_feature_local _EMISSION
			#pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
			
			#define NOENOETOON_RAMP_MASKING
			
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform float _Intensity;
			
			float _Cutoff;
			
			float _OverrideWorldLight;
            
            uniform float4 _StaticToonLight;
            uniform sampler2D _Ramp; uniform float4 _Ramp_ST;
            float3 VRViewPosition(){
            #if defined(USING_STEREO_MATRICES)
            float3 leftEye = unity_StereoWorldSpaceCameraPos[0];
            float3 rightEye = unity_StereoWorldSpaceCameraPos[1];
            
            float3 centerEye = lerp(leftEye, rightEye, 0.5);
            #endif
            #if !defined(USING_STEREO_MATRICES)
            float3 centerEye = _WorldSpaceCameraPos;
            #endif
            return centerEye;
            }
            
            uniform float _Saturation;
            uniform fixed _BillboardStaticLight;
            uniform float _ToonContrast;
			
			#include "../NoeNoeToonEdits.cginc"
			#include "VertOffset.cginc"

            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vertShadowOffset
            #pragma fragment fragShadow
			
			#ifndef UNITY_PASS_SHADOWCASTER
				#define UNITY_PASS_SHADOWCASTER
			#endif

            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			
			float _Cutoff;
			
            #include "../NoeNoeShadowCaster.cginc"
			
			float4 _VertexOffset;
			float4 _VertexRotation;
			float4 _VertexScale;

			inline float3x3 xRotation3dRadians(float rad) {
				float s = sin(rad);
				float c = cos(rad);
				return float3x3(
					1, 0, 0,
					0, c, s,
					0, -s, c);
			}
			 
			inline float3x3 yRotation3dRadians(float rad) {
				float s = sin(rad);
				float c = cos(rad);
				return float3x3(
					c, 0, -s,
					0, 1, 0,
					s, 0, c);
			}
			 
			inline float3x3 zRotation3dRadians(float rad) {
				float s = sin(rad);
				float c = cos(rad);
				return float3x3(
					c, s, 0,
					-s, c, 0,
					0, 0, 1);
			}
			
			VertexOutputShadow vertShadowOffset (VertexInputShadow v) {

				//Apply scale
				v.vertex *= _VertexScale;

				// Apply rotation
				float3 vertexPos = v.vertex.xyz;
				vertexPos = mul(xRotation3dRadians(radians(_VertexRotation.x)), vertexPos);
				vertexPos = mul(yRotation3dRadians(radians(_VertexRotation.y)), vertexPos);
				vertexPos = mul(zRotation3dRadians(radians(_VertexRotation.z)), vertexPos);
				v.vertex = float4(vertexPos, v.vertex.w);
				
				//Apply offset
				v.vertex += _VertexOffset;

				VertexOutputShadow o = (VertexOutputShadow)0;
				o.uv0 = v.texcoord0;				
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}

            ENDCG
        }
    }
	CustomEditor "NoeNoeToonEditorGUI"
}