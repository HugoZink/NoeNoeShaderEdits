Shader "NoeNoe/NoeNoe Toon Shader/NoeNoe Toon Cutout" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main texture (RGB)", 2D) = "white" {}
        _StaticToonLight ("Static Toon Light", Vector) = (0,3,0,0)
		_WorldLightIntensity ("World Light Dir Multiplier", Range(0, 10)) = 1
		[Toggle(_)] _OverrideWorldLight ("Override World Light", Float) = 0
        [Toggle(_)] _BillboardStaticLight ("Billboard Static Light", Float ) = 0
        _Ramp ("Ramp", 2D) = "white" {}
        _ToonContrast ("Toon Contrast", Range(0, 1)) = 0.25
        _EmissionMap ("Emission Map", 2D) = "white" {}
        _Emission ("Emission", Range(0, 10)) = 0
        _Intensity ("Intensity", Range(0, 10)) = 0.8
        _Saturation ("Saturation", Range(0, 1)) = 0.65
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		[Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 0
		[NoScaleOffset]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Glossiness("Smoothness", Range( 0 , 1)) = 0
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
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
            uniform float _Emission;
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
            uniform float4 _Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _EmissionMap; uniform float4 _EmissionMap_ST;
            uniform float _Emission;
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
    FallBack "Diffuse"
}
