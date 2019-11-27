Shader "NoeNoe/NoeNoe Toon Shader/NoeNoe Toon Outline" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main texture (RGB)", 2D) = "white" {}
        _StaticToonLight ("Static Toon Light", Vector) = (0,2.5,0,0)
        _WorldLightIntensity ("World Light Dir Multiplier", Range(0, 10)) = 1
        [Toggle(_OVERRIDE_WORLD_LIGHT_DIR_ON)] _OverrideWorldLight ("Override World Light", Float) = 0
        [Toggle(_)] _BillboardStaticLight ("Billboard Static Light", Float ) = 0
        _Ramp ("Ramp", 2D) = "white" {}
        _ToonContrast ("Toon Contrast", Range(0, 1)) = 0.25
        _EmissionMap ("Emission Map", 2D) = "white" {}
        _EmissionColor ("Emission", Color) = (0,0,0)
        _Intensity ("Intensity", Range(0, 10)) = 0.8
        _Saturation ("Saturation", Range(0, 1)) = 0.65
        _Exposure ("Exposure", Range(0, 1)) = 0.7
        _ExposureContrast ("Exposure Toon Ramp Contrast", Range(0, 2)) = 1.15
        [Enum(Toon,0,PBR,1,Legacy Toon,2)] _LightingMode ("Lighting Mode", Float) = 0
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
        [Toggle(_OUTLINE_SCREENSPACE)] _ScreenSpaceOutline ("Screen-Space Outline", Float ) = 0
        _ScreenSpaceMinDist ("Minimum Outline Distance", Float ) = 0
        _ScreenSpaceMaxDist ("Maximum Outline Distance", Float ) = 100
        [Enum(Normal,8,Outer Only,6)] _OutlineStencilComp ("Outline Mode", Float) = 8
        [Toggle(_)] _OutlineCutout ("Cutout Outlines", Float) = 1
        [Toggle(_OUTLINE_ALPHA_WIDTH_ON)] _OutlineAlphaWidthEnabled ("Alpha Affects Width", Float) = 1
        [Toggle(_ALPHATEST_ON)] _Mode ("Cutout", Float) = 0
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        [Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 2
        [Toggle(_SHADOW_RECEIVE_ON)] _ReceiveShadows ("Receive Shadows", Float) = 0
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
        
        [Enum(Off,0,Add,1,Mix,2)] _RimLightMode ("Rimlight Mode", Float) = 0
        _RimLightColor ("Rimlight Tint", Color) = (1,1,1,0.4)
        _RimTex ("Rimlight Texture", 2D) = "white" {}
        _RimWidth ("Rimlight Width", Range(0,1)) = 0.75
        [Toggle(_)] _RimInvert ("Invert Rimlight", Float) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        
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
            #pragma vertex vert
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
            #pragma multi_compile _ VERTEXLIGHT_ON
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
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _LIGHTING_PBR_ON _LIGHTING_LEGACY_ON

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
            
            #include "NoeNoeToonEdits.cginc"
            
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
            #pragma vertex vertOutline
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
            #pragma multi_compile _ VERTEXLIGHT_ON
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
            #pragma shader_feature_local _OUTLINE_ALPHA_WIDTH_ON
            #pragma shader_feature_local _OUTLINE_SCREENSPACE
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _LIGHTING_PBR_ON _LIGHTING_LEGACY_ON
            
            #define NOENOETOON_OUTLINE_PASS
            
            uniform sampler2D _OutlineTex; uniform float4 _OutlineTex_ST;
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
            
            float _ScreenSpaceMinDist;
            float _ScreenSpaceMaxDist;
            
            float _OverrideWorldLight;
            
            uniform float4 _StaticToonLight;
            uniform sampler2D _Ramp; uniform float4 _Ramp_ST;
            
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            
            uniform float _Saturation;
            uniform float _Intensity;
            uniform fixed _BillboardStaticLight;
            uniform float _ToonContrast;
            
            #include "NoeNoeToonEdits.cginc"

            VertexOutput vertOutline (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                
                float3 lightColor = _LightColor0.rgb;
                
                float outlineWidth = (_OutlineWidth*0.001);
                
                #if defined(_OUTLINE_ALPHA_WIDTH_ON)
                    // Scale outline by outline tex alpha
                    float4 outlineTex = tex2Dlod(_OutlineTex, float4(v.texcoord0, 0, 0));
                    outlineTex *= _OutlineColor;
                    outlineWidth *= outlineTex.a;
                #endif
                
                #if defined(_OUTLINE_SCREENSPACE)
                    float dist = clamp(distance(_WorldSpaceCameraPos,mul(unity_ObjectToWorld, v.vertex).rgb), _ScreenSpaceMinDist, _ScreenSpaceMaxDist);
                    float OutlineScale = dist * outlineWidth;
                #else
                    float OutlineScale = outlineWidth;
                #endif
                
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
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _LIGHTING_PBR_ON _LIGHTING_LEGACY_ON

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
            
            #include "NoeNoeToonEdits.cginc"        

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
            #pragma vertex vertShadow
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
            #pragma shader_feature_local _ALPHATEST_ON
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            
            float _Cutoff;
            
            #include "NoeNoeShadowCaster.cginc"

            ENDCG
        }
    }
    CustomEditor "NoeNoeToonEditorGUI"
}
