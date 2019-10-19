Shader "NoeNoe/NoeNoe Toon Shader/Advanced/NoeNoe Toon Eye Tracking" {
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
        _EmissionColor ("Emission", Color) = (0,0,0)
        _Intensity ("Intensity", Range(0, 10)) = 0.8
        _Saturation ("Saturation", Range(0, 1)) = 0.65
        _NormalMap ("Normal Map", 2D) = "bump" {}
		[Toggle(_ALPHATEST_ON)] _Mode ("Cutout", Float) = 0
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		[Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 0
		[Enum(None,0,Metallic,1,Specular,2)] _MetallicMode("Metallic Mode", Float) = 0
		[NoScaleOffset] _MetallicGlossMap("Metallic Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Glossiness("Smoothness", Range( 0 , 1)) = 0
        _SpecColor("Specular Color", Color) = (0,0,0,0)
        _SpecGlossMap("Specular Map", 2D) = "white" {}
		[Toggle(_SHADOW_RECEIVE_ON)] _ReceiveShadows ("Receive Shadows", Float) = 0
		[Enum(Left,0,Center,1,Right,2)] _TargetEye("Target Eye", Float) = 0.5
		_MaxLookRange ("Max Look Range", Range(0,1)) = 0.4
		_EyeTrackingPatternTex ("Eye Tracking Pattern Texture", 2D) = "white" {}
		_EyeTrackingScrollSpeed ("Eye Tracking Pattern Speed", Range(-100, 100)) = 1
		_EyeTrackingBlur ("Eye Tracking Pattern Blur", Range(0,6)) = 0
		[Toggle(_)] _EyeTrackingRotationCorrection ("Blender Rotation Correction", Float) = 1
		_MatCap ("Matcap Texture", 2D) = "white" {}
		[Enum(Off,0,Additive (spa),1,Multiply (sph),2)] _MatCapMode ("Matcap Mode", Float) = 0
		_MatCapStrength ("Matcap Strength", Range(0, 1)) = 1
		_OverlayStrength ("Overlay Strength", Range(0, 1)) = 1
		[Enum(Replace,0,Multiply,1)] _OverlayMode ("Overlay Mode", Float) = 0
		[Toggle(_PANO_ON)] _PanoEnabled ("Panosphere Enabled", Float) = 0
        _TileOverlay ("Panosphere Texture", 2D) = "white" {}
        _TileSpeedX ("Pano Rotation Speed X", Range(-1, 1)) = 0
        _TileSpeedY ("Pano Rotation Speed Y", Range(-1, 1)) = 0
		[Toggle(_CUBEMAP_ON)] _CubemapEnabled ("Cubemap Enabled", Float) = 0
        _CubemapOverlay ("Cubemap Texture", Cube) = "_Skybox" {}
        _CubemapRotationSpeed ("Cubemap Rotation Speed", Vector) = (0,0,0,0)
        _CrossfadeTileCubemap ("Crossfade Pano / Cubemap", Range(0, 1)) = 0.5
		
		[Toggle(_)] _RimLightMode ("Rimlight Enabled", Float) = 0
		_RimLightColor ("Rimlight Tint", Color) = (1,1,1,0.4)
		_RimTex ("Rimlight Texture", 2D) = "white" {}
		_RimWidth ("Rimlight Width", Range(0,1)) = 0.75
		[Toggle(_)] _RimInvert ("Invert Rimlight", Float) = 0
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout" "Queue"="AlphaTest" "DisableBatching"="True"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
			Cull [_Cull]
            
            CGPROGRAM
            #pragma vertex vertEyeTracking
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
			#pragma shader_feature_local _ALPHATEST_ON
			#pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local _OVERRIDE_WORLD_LIGHT_DIR_ON
			#pragma shader_feature_local _SHADOW_RECEIVE_ON
			#pragma shader_feature_local _EMISSION
			#pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
			#pragma shader_feature_local _PANO_ON
			#pragma shader_feature_local _CUBEMAP_ON
			#pragma shader_feature_local _RIMLIGHT_ON

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
			
			#include "EyeTracking.cginc"
			
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
            #pragma vertex vert
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
			#pragma shader_feature_local _ALPHATEST_ON
			#pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local _OVERRIDE_WORLD_LIGHT_DIR_ON
			#pragma shader_feature_local _SHADOW_RECEIVE_ON
			#pragma shader_feature_local _EMISSION
			#pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
			#pragma shader_feature_local _PANO_ON
			#pragma shader_feature_local _CUBEMAP_ON
			#pragma shader_feature_local _RIMLIGHT_ON

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
            ENDCG
        }
    }
	CustomEditor "NoeNoeToonEditorGUI"
}
