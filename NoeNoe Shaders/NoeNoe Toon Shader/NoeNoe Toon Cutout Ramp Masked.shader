Shader "NoeNoe/NoeNoe Toon Shader/NoeNoe Toon Cutout Ramp Masked" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main texture (RGB)", 2D) = "white" {}
        _StaticToonLight ("Static Toon Light", Vector) = (0,3,0,0)
		_WorldLightIntensity ("World Light Dir Multiplier", Range(0, 10)) = 1
		[Toggle(_)] _OverrideWorldLight ("Override World Light", Float) = 0
        [Toggle(_)] _BillboardStaticLight ("Billboard Static Light", Float ) = 0
        _RealRamp ("Default Ramp", 2D) = "white" {}
		_RampTint ("Ramp Tint", Range(0,1)) = 0
        _ToonContrast ("Default Toon Contrast", Range(0, 1)) = 0.25
        _EmissionMap ("Emission Map", 2D) = "white" {}
        _EmissionColor ("Emission", Color) = (0,0,0)
        _Intensity ("Default Intensity", Range(0, 10)) = 0.8
        _Saturation ("Default Saturation", Range(0, 1)) = 0.65
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		[Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 2
		[NoScaleOffset]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Glossiness("Smoothness", Range( 0 , 1)) = 0
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
		_Ramp ("Fallback Ramp", 2D) = "white" {}
		[Toggle(_)] _ReceiveShadows ("Receive Shadows", Float) = 0
    }
    SubShader {
        Tags {
            "RenderType"="TransparentCutout" "Queue"="AlphaTest"
        }
        Pass {
            Name "FORWARD"
            Tags { "LightMode"="ForwardBase" }
            
			Cull [_Cull]            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
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

            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform float _Intensity;
			
			float _Cutoff;
			
			float _OverrideWorldLight;
            
            uniform float4 _StaticToonLight;
            uniform sampler2D _RealRamp; uniform float4 _RealRamp_ST;
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
			
			#define NOENOETOON_RAMP_MASKING

			#include "NoeNoeToonEdits.cginc"
            
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
            #define UNITY_PASS_FORWARDADD
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

            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform float _Intensity;
			
			float _Cutoff;
			
			float _OverrideWorldLight;
            
            uniform float4 _StaticToonLight;
            uniform sampler2D _RealRamp; uniform float4 _RealRamp_ST;
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
			
			#define NOENOETOON_RAMP_MASKING
			
			#include "NoeNoeToonEdits.cginc"
			
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
			Cull [_Cull]
            
            CGPROGRAM
            #pragma vertex vertShadow
            #pragma fragment fragShadow
            #define UNITY_PASS_SHADOWCASTER
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

			#include "NoeNoeShadowCaster.cginc"

            ENDCG
        }
    }
	CustomEditor "NoeNoeToonEditorGUI"
}
