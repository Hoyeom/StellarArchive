Shader "Shader Graphs/SpinOutline"
    {
        Properties
        {
            [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
            [HDR]_OutlineColor("OutlineColor", Color) = (1, 1, 1, 1)
            _Count("Count", Float) = 5
            _Speed("Speed", Range(0, 5)) = 1
            _Length("Length", Range(0, 1)) = 0.5
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
            _StencilComp ("Stencil Comparison", Float) = 8
_Stencil ("Stencil ID", Float) = 0
_StencilOp ("Stencil Operation", Float) = 0
_StencilWriteMask ("Stencil Write Mask", Float) = 255
_StencilReadMask ("Stencil Read Mask", Float) = 255
_ColorMask ("Color Mask", Float) = 15
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Transparent"
                // DisableBatching: <None>
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalSpriteUnlitSubTarget"
            }
            Pass
            {
                Name "Sprite Unlit"
                Tags
                {
                    "LightMode" = "Universal2D"
                }
            
            // Render State
            Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest [unity_GUIZTestMode]
                ZWrite Off
            
                Stencil
   {
    Ref [_Stencil]
    Comp [_StencilComp]
    Pass [_StencilOp]
    ReadMask [_StencilReadMask]
    WriteMask [_StencilWriteMask]
   }
   ColorMask [_ColorMask]
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_TEXCOORD3
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD3
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SPRITEUNLIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                     float4 uv3 : TEXCOORD3;
                     float4 color : COLOR;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float4 texCoord0;
                     float4 texCoord1;
                     float4 texCoord2;
                     float4 texCoord3;
                     float4 color;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float4 uv0;
                     float4 uv1;
                     float4 uv2;
                     float4 uv3;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                     float4 texCoord1 : INTERP1;
                     float4 texCoord2 : INTERP2;
                     float4 texCoord3 : INTERP3;
                     float4 color : INTERP4;
                     float3 positionWS : INTERP5;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.texCoord1.xyzw = input.texCoord1;
                    output.texCoord2.xyzw = input.texCoord2;
                    output.texCoord3.xyzw = input.texCoord3;
                    output.color.xyzw = input.color;
                    output.positionWS.xyz = input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.texCoord1 = input.texCoord1.xyzw;
                    output.texCoord2 = input.texCoord2.xyzw;
                    output.texCoord3 = input.texCoord3.xyzw;
                    output.color = input.color.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _OutlineColor;
                float _Count;
                float _Speed;
                float _Length;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Round_float(float In, out float Out)
                {
                    Out = round(In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                Out = A * B;
                }
                
                void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float radius = length(delta) * 2 * RadialScale;
                    float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
                    Out = float2(radius, angle);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Fraction_float(float In, out float Out)
                {
                    Out = frac(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                struct Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float
                {
                half4 uv0;
                float3 TimeParameters;
                };
                
                void SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(float _Speed, float _Count, float _Length, Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float IN, out float OutVector1_1)
                {
                float _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float = _Speed;
                float _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float, _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float);
                float4 _UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4 = IN.uv0;
                float2 _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2;
                Unity_PolarCoordinates_float((_UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4.xy), float2 (0.5, 0.5), 0, 1, _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2);
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_R_1_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[0];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[1];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_B_3_Float = 0;
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_A_4_Float = 0;
                float _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float = _Count;
                float _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float;
                Unity_Multiply_float_float(_Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float, _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float);
                float _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float;
                Unity_Add_float(_Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float, _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float);
                float _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float;
                Unity_Fraction_float(_Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float, _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float);
                float _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float = _Length;
                float _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                Unity_Smoothstep_float(_Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float, 1, _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float, _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float);
                OutVector1_1 = _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                }
                
                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
                
                struct Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(UnityTexture2D _Texture2D, float2 _Offset, Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float IN, out float Out_Vector1_0)
                {
                UnityTexture2D _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D = _Texture2D;
                float4 _UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4 = IN.uv0;
                float2 _Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2 = _Offset;
                UnityTexture2D _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D = _Texture2D;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.z;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.w;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelWidth_3_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.x;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelHeight_4_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.y;
                float2 _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2 = float2(_TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float, _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float);
                float2 _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2;
                Unity_Divide_float2(_Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2, _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2, _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2);
                float2 _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2;
                Unity_Add_float2((_UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4.xy), _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2, _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2);
                float4 _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.tex, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.samplerstate, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.GetTransformedUV(_Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2) );
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_R_4_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.r;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_G_5_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.g;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_B_6_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.b;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.a;
                float _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                Unity_Step_float(0.01, _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float, _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float);
                Out_Vector1_0 = _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                struct Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(UnityTexture2D _MainTex, float _X, float _X_1, float _Y, float _Y_1, Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float IN, out float FullAlpha_2, out float OutlineAlpha_1)
                {
                UnityTexture2D _Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D = _MainTex;
                float _Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float = _X;
                float2 _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2 = float2(_Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv0 = IN.uv0;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv1 = IN.uv1;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv2 = IN.uv2;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv3 = IN.uv3;
                half _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float);
                float _Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float = _X_1;
                float _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float;
                Unity_Multiply_float_float(_Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float, -1, _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float);
                float2 _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2 = float2(_Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv0 = IN.uv0;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv1 = IN.uv1;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv2 = IN.uv2;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv3 = IN.uv3;
                half _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float);
                float _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float, _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float);
                float _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float = _Y;
                float2 _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2 = float2(0, _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv0 = IN.uv0;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv1 = IN.uv1;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv2 = IN.uv2;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv3 = IN.uv3;
                half _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float);
                float _Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float = _Y_1;
                float _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float;
                Unity_Multiply_float_float(_Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float, -1, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                float2 _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2 = float2(0, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv0 = IN.uv0;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv1 = IN.uv1;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv2 = IN.uv2;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv3 = IN.uv3;
                half _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float);
                float _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float);
                float _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float;
                Unity_Add_float(_Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float, _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float);
                float _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                Unity_Clamp_float(_Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float, 0, 1, _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float);
                UnityTexture2D _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D = _MainTex;
                float4 _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.tex, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.samplerstate, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_R_4_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.r;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_G_5_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.g;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_B_6_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.b;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.a;
                float _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                Unity_Subtract_float(_Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float, _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float, _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float);
                FullAlpha_2 = _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                OutlineAlpha_1 = _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                }
                
                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                struct Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float
                {
                };
                
                void SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(float4 _MainColor, Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float IN, out float4 Color_1)
                {
                float4 _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4 = _MainColor;
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_R_1_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[0];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_G_2_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[1];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_B_3_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[2];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[3];
                float _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float;
                Unity_OneMinus_float(_Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float, _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float);
                float4 _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4;
                Unity_Subtract_float4(_Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4, (_OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float.xxxx), _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4);
                float4 _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                Unity_Clamp_float4(_Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4);
                Color_1 = _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float = _Speed;
                    float _Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float = _Count;
                    float _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float;
                    Unity_Round_float(_Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float);
                    float _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float = _Length;
                    Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.uv0 = IN.uv0;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.TimeParameters = IN.TimeParameters;
                    float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float;
                    SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(_Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float, _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float);
                    float4 _Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor) : _OutlineColor;
                    UnityTexture2D _Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float _OutlineComponent_511518b8b2164464b514d039a9629a43;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv0 = IN.uv0;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv1 = IN.uv1;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv2 = IN.uv2;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv3 = IN.uv3;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float;
                    SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(_Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D, 1, 1, 1, 1, _OutlineComponent_511518b8b2164464b514d039a9629a43, _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float, _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float);
                    float4 _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4;
                    Unity_Multiply_float4_float4(_Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4, (_OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4);
                    float4 _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4;
                    Unity_Multiply_float4_float4((_FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4, _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4);
                    UnityTexture2D _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    float4 _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.tex, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.samplerstate, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_R_4_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_G_5_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_B_6_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_A_7_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.a;
                    Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d;
                    float4 _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4;
                    SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(_SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4);
                    float4 _Add_4298a45a24be47c389f7c7343a941856_Out_2_Vector4;
                    Unity_Add_float4(_Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4, _Add_4298a45a24be47c389f7c7343a941856_Out_2_Vector4);
                    float _Split_0187c19839e3457986c51354b0b5cba6_R_1_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[0];
                    float _Split_0187c19839e3457986c51354b0b5cba6_G_2_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[1];
                    float _Split_0187c19839e3457986c51354b0b5cba6_B_3_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[2];
                    float _Split_0187c19839e3457986c51354b0b5cba6_A_4_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[3];
                    float4 _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4;
                    Unity_Add_float4(_Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4, (_Split_0187c19839e3457986c51354b0b5cba6_A_4_Float.xxxx), _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4);
                    surface.BaseColor = (_Add_4298a45a24be47c389f7c7343a941856_Out_2_Vector4.xyz);
                    surface.Alpha = (_Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4).x;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                    output.uv1 = input.texCoord1;
                    output.uv2 = input.texCoord2;
                    output.uv3 = input.texCoord3;
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "SceneSelectionPass"
                Tags
                {
                    "LightMode" = "SceneSelectionPass"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_TEXCOORD3
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD3
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENESELECTIONPASS 1
                
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                     float4 uv3 : TEXCOORD3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0;
                     float4 texCoord1;
                     float4 texCoord2;
                     float4 texCoord3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float4 uv0;
                     float4 uv1;
                     float4 uv2;
                     float4 uv3;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                     float4 texCoord1 : INTERP1;
                     float4 texCoord2 : INTERP2;
                     float4 texCoord3 : INTERP3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.texCoord1.xyzw = input.texCoord1;
                    output.texCoord2.xyzw = input.texCoord2;
                    output.texCoord3.xyzw = input.texCoord3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.texCoord1 = input.texCoord1.xyzw;
                    output.texCoord2 = input.texCoord2.xyzw;
                    output.texCoord3 = input.texCoord3.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _OutlineColor;
                float _Count;
                float _Speed;
                float _Length;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Round_float(float In, out float Out)
                {
                    Out = round(In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                Out = A * B;
                }
                
                void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float radius = length(delta) * 2 * RadialScale;
                    float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
                    Out = float2(radius, angle);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Fraction_float(float In, out float Out)
                {
                    Out = frac(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                struct Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float
                {
                half4 uv0;
                float3 TimeParameters;
                };
                
                void SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(float _Speed, float _Count, float _Length, Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float IN, out float OutVector1_1)
                {
                float _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float = _Speed;
                float _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float, _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float);
                float4 _UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4 = IN.uv0;
                float2 _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2;
                Unity_PolarCoordinates_float((_UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4.xy), float2 (0.5, 0.5), 0, 1, _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2);
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_R_1_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[0];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[1];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_B_3_Float = 0;
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_A_4_Float = 0;
                float _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float = _Count;
                float _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float;
                Unity_Multiply_float_float(_Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float, _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float);
                float _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float;
                Unity_Add_float(_Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float, _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float);
                float _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float;
                Unity_Fraction_float(_Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float, _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float);
                float _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float = _Length;
                float _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                Unity_Smoothstep_float(_Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float, 1, _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float, _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float);
                OutVector1_1 = _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                }
                
                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
                
                struct Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(UnityTexture2D _Texture2D, float2 _Offset, Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float IN, out float Out_Vector1_0)
                {
                UnityTexture2D _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D = _Texture2D;
                float4 _UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4 = IN.uv0;
                float2 _Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2 = _Offset;
                UnityTexture2D _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D = _Texture2D;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.z;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.w;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelWidth_3_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.x;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelHeight_4_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.y;
                float2 _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2 = float2(_TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float, _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float);
                float2 _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2;
                Unity_Divide_float2(_Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2, _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2, _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2);
                float2 _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2;
                Unity_Add_float2((_UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4.xy), _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2, _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2);
                float4 _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.tex, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.samplerstate, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.GetTransformedUV(_Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2) );
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_R_4_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.r;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_G_5_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.g;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_B_6_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.b;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.a;
                float _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                Unity_Step_float(0.01, _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float, _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float);
                Out_Vector1_0 = _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                struct Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(UnityTexture2D _MainTex, float _X, float _X_1, float _Y, float _Y_1, Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float IN, out float FullAlpha_2, out float OutlineAlpha_1)
                {
                UnityTexture2D _Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D = _MainTex;
                float _Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float = _X;
                float2 _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2 = float2(_Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv0 = IN.uv0;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv1 = IN.uv1;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv2 = IN.uv2;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv3 = IN.uv3;
                half _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float);
                float _Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float = _X_1;
                float _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float;
                Unity_Multiply_float_float(_Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float, -1, _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float);
                float2 _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2 = float2(_Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv0 = IN.uv0;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv1 = IN.uv1;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv2 = IN.uv2;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv3 = IN.uv3;
                half _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float);
                float _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float, _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float);
                float _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float = _Y;
                float2 _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2 = float2(0, _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv0 = IN.uv0;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv1 = IN.uv1;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv2 = IN.uv2;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv3 = IN.uv3;
                half _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float);
                float _Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float = _Y_1;
                float _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float;
                Unity_Multiply_float_float(_Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float, -1, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                float2 _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2 = float2(0, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv0 = IN.uv0;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv1 = IN.uv1;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv2 = IN.uv2;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv3 = IN.uv3;
                half _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float);
                float _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float);
                float _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float;
                Unity_Add_float(_Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float, _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float);
                float _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                Unity_Clamp_float(_Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float, 0, 1, _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float);
                UnityTexture2D _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D = _MainTex;
                float4 _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.tex, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.samplerstate, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_R_4_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.r;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_G_5_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.g;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_B_6_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.b;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.a;
                float _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                Unity_Subtract_float(_Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float, _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float, _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float);
                FullAlpha_2 = _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                OutlineAlpha_1 = _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                }
                
                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                struct Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float
                {
                };
                
                void SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(float4 _MainColor, Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float IN, out float4 Color_1)
                {
                float4 _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4 = _MainColor;
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_R_1_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[0];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_G_2_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[1];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_B_3_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[2];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[3];
                float _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float;
                Unity_OneMinus_float(_Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float, _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float);
                float4 _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4;
                Unity_Subtract_float4(_Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4, (_OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float.xxxx), _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4);
                float4 _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                Unity_Clamp_float4(_Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4);
                Color_1 = _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float = _Speed;
                    float _Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float = _Count;
                    float _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float;
                    Unity_Round_float(_Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float);
                    float _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float = _Length;
                    Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.uv0 = IN.uv0;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.TimeParameters = IN.TimeParameters;
                    float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float;
                    SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(_Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float, _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float);
                    float4 _Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor) : _OutlineColor;
                    UnityTexture2D _Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float _OutlineComponent_511518b8b2164464b514d039a9629a43;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv0 = IN.uv0;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv1 = IN.uv1;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv2 = IN.uv2;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv3 = IN.uv3;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float;
                    SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(_Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D, 1, 1, 1, 1, _OutlineComponent_511518b8b2164464b514d039a9629a43, _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float, _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float);
                    float4 _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4;
                    Unity_Multiply_float4_float4(_Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4, (_OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4);
                    float4 _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4;
                    Unity_Multiply_float4_float4((_FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4, _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4);
                    UnityTexture2D _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    float4 _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.tex, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.samplerstate, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_R_4_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_G_5_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_B_6_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_A_7_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.a;
                    Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d;
                    float4 _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4;
                    SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(_SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4);
                    float _Split_0187c19839e3457986c51354b0b5cba6_R_1_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[0];
                    float _Split_0187c19839e3457986c51354b0b5cba6_G_2_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[1];
                    float _Split_0187c19839e3457986c51354b0b5cba6_B_3_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[2];
                    float _Split_0187c19839e3457986c51354b0b5cba6_A_4_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[3];
                    float4 _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4;
                    Unity_Add_float4(_Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4, (_Split_0187c19839e3457986c51354b0b5cba6_A_4_Float.xxxx), _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4);
                    surface.Alpha = (_Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4).x;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                    output.uv1 = input.texCoord1;
                    output.uv2 = input.texCoord2;
                    output.uv3 = input.texCoord3;
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ScenePickingPass"
                Tags
                {
                    "LightMode" = "Picking"
                }
            
            // Render State
            Cull Back
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_TEXCOORD3
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD3
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
                
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                     float4 uv3 : TEXCOORD3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0;
                     float4 texCoord1;
                     float4 texCoord2;
                     float4 texCoord3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float4 uv0;
                     float4 uv1;
                     float4 uv2;
                     float4 uv3;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                     float4 texCoord1 : INTERP1;
                     float4 texCoord2 : INTERP2;
                     float4 texCoord3 : INTERP3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.texCoord1.xyzw = input.texCoord1;
                    output.texCoord2.xyzw = input.texCoord2;
                    output.texCoord3.xyzw = input.texCoord3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.texCoord1 = input.texCoord1.xyzw;
                    output.texCoord2 = input.texCoord2.xyzw;
                    output.texCoord3 = input.texCoord3.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _OutlineColor;
                float _Count;
                float _Speed;
                float _Length;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Round_float(float In, out float Out)
                {
                    Out = round(In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                Out = A * B;
                }
                
                void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float radius = length(delta) * 2 * RadialScale;
                    float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
                    Out = float2(radius, angle);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Fraction_float(float In, out float Out)
                {
                    Out = frac(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                struct Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float
                {
                half4 uv0;
                float3 TimeParameters;
                };
                
                void SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(float _Speed, float _Count, float _Length, Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float IN, out float OutVector1_1)
                {
                float _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float = _Speed;
                float _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float, _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float);
                float4 _UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4 = IN.uv0;
                float2 _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2;
                Unity_PolarCoordinates_float((_UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4.xy), float2 (0.5, 0.5), 0, 1, _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2);
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_R_1_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[0];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[1];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_B_3_Float = 0;
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_A_4_Float = 0;
                float _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float = _Count;
                float _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float;
                Unity_Multiply_float_float(_Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float, _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float);
                float _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float;
                Unity_Add_float(_Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float, _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float);
                float _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float;
                Unity_Fraction_float(_Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float, _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float);
                float _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float = _Length;
                float _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                Unity_Smoothstep_float(_Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float, 1, _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float, _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float);
                OutVector1_1 = _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                }
                
                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
                
                struct Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(UnityTexture2D _Texture2D, float2 _Offset, Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float IN, out float Out_Vector1_0)
                {
                UnityTexture2D _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D = _Texture2D;
                float4 _UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4 = IN.uv0;
                float2 _Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2 = _Offset;
                UnityTexture2D _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D = _Texture2D;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.z;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.w;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelWidth_3_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.x;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelHeight_4_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.y;
                float2 _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2 = float2(_TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float, _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float);
                float2 _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2;
                Unity_Divide_float2(_Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2, _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2, _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2);
                float2 _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2;
                Unity_Add_float2((_UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4.xy), _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2, _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2);
                float4 _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.tex, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.samplerstate, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.GetTransformedUV(_Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2) );
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_R_4_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.r;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_G_5_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.g;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_B_6_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.b;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.a;
                float _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                Unity_Step_float(0.01, _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float, _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float);
                Out_Vector1_0 = _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                struct Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(UnityTexture2D _MainTex, float _X, float _X_1, float _Y, float _Y_1, Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float IN, out float FullAlpha_2, out float OutlineAlpha_1)
                {
                UnityTexture2D _Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D = _MainTex;
                float _Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float = _X;
                float2 _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2 = float2(_Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv0 = IN.uv0;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv1 = IN.uv1;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv2 = IN.uv2;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv3 = IN.uv3;
                half _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float);
                float _Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float = _X_1;
                float _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float;
                Unity_Multiply_float_float(_Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float, -1, _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float);
                float2 _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2 = float2(_Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv0 = IN.uv0;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv1 = IN.uv1;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv2 = IN.uv2;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv3 = IN.uv3;
                half _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float);
                float _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float, _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float);
                float _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float = _Y;
                float2 _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2 = float2(0, _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv0 = IN.uv0;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv1 = IN.uv1;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv2 = IN.uv2;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv3 = IN.uv3;
                half _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float);
                float _Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float = _Y_1;
                float _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float;
                Unity_Multiply_float_float(_Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float, -1, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                float2 _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2 = float2(0, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv0 = IN.uv0;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv1 = IN.uv1;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv2 = IN.uv2;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv3 = IN.uv3;
                half _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float);
                float _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float);
                float _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float;
                Unity_Add_float(_Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float, _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float);
                float _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                Unity_Clamp_float(_Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float, 0, 1, _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float);
                UnityTexture2D _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D = _MainTex;
                float4 _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.tex, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.samplerstate, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_R_4_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.r;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_G_5_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.g;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_B_6_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.b;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.a;
                float _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                Unity_Subtract_float(_Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float, _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float, _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float);
                FullAlpha_2 = _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                OutlineAlpha_1 = _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                }
                
                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                struct Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float
                {
                };
                
                void SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(float4 _MainColor, Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float IN, out float4 Color_1)
                {
                float4 _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4 = _MainColor;
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_R_1_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[0];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_G_2_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[1];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_B_3_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[2];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[3];
                float _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float;
                Unity_OneMinus_float(_Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float, _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float);
                float4 _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4;
                Unity_Subtract_float4(_Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4, (_OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float.xxxx), _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4);
                float4 _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                Unity_Clamp_float4(_Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4);
                Color_1 = _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float = _Speed;
                    float _Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float = _Count;
                    float _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float;
                    Unity_Round_float(_Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float);
                    float _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float = _Length;
                    Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.uv0 = IN.uv0;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.TimeParameters = IN.TimeParameters;
                    float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float;
                    SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(_Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float, _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float);
                    float4 _Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor) : _OutlineColor;
                    UnityTexture2D _Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float _OutlineComponent_511518b8b2164464b514d039a9629a43;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv0 = IN.uv0;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv1 = IN.uv1;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv2 = IN.uv2;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv3 = IN.uv3;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float;
                    SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(_Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D, 1, 1, 1, 1, _OutlineComponent_511518b8b2164464b514d039a9629a43, _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float, _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float);
                    float4 _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4;
                    Unity_Multiply_float4_float4(_Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4, (_OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4);
                    float4 _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4;
                    Unity_Multiply_float4_float4((_FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4, _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4);
                    UnityTexture2D _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    float4 _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.tex, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.samplerstate, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_R_4_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_G_5_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_B_6_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_A_7_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.a;
                    Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d;
                    float4 _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4;
                    SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(_SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4);
                    float _Split_0187c19839e3457986c51354b0b5cba6_R_1_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[0];
                    float _Split_0187c19839e3457986c51354b0b5cba6_G_2_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[1];
                    float _Split_0187c19839e3457986c51354b0b5cba6_B_3_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[2];
                    float _Split_0187c19839e3457986c51354b0b5cba6_A_4_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[3];
                    float4 _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4;
                    Unity_Add_float4(_Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4, (_Split_0187c19839e3457986c51354b0b5cba6_A_4_Float.xxxx), _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4);
                    surface.Alpha = (_Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4).x;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                    output.uv1 = input.texCoord1;
                    output.uv2 = input.texCoord2;
                    output.uv3 = input.texCoord3;
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "Sprite Unlit"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
            
            // Render State
            Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma exclude_renderers d3d11_9x
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_TEXCOORD3
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD3
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SPRITEFORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                     float4 uv3 : TEXCOORD3;
                     float4 color : COLOR;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float4 texCoord0;
                     float4 texCoord1;
                     float4 texCoord2;
                     float4 texCoord3;
                     float4 color;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float4 uv0;
                     float4 uv1;
                     float4 uv2;
                     float4 uv3;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                     float4 texCoord1 : INTERP1;
                     float4 texCoord2 : INTERP2;
                     float4 texCoord3 : INTERP3;
                     float4 color : INTERP4;
                     float3 positionWS : INTERP5;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.texCoord1.xyzw = input.texCoord1;
                    output.texCoord2.xyzw = input.texCoord2;
                    output.texCoord3.xyzw = input.texCoord3;
                    output.color.xyzw = input.color;
                    output.positionWS.xyz = input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.texCoord1 = input.texCoord1.xyzw;
                    output.texCoord2 = input.texCoord2.xyzw;
                    output.texCoord3 = input.texCoord3.xyzw;
                    output.color = input.color.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _OutlineColor;
                float _Count;
                float _Speed;
                float _Length;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Round_float(float In, out float Out)
                {
                    Out = round(In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                Out = A * B;
                }
                
                void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
                {
                    float2 delta = UV - Center;
                    float radius = length(delta) * 2 * RadialScale;
                    float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
                    Out = float2(radius, angle);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Fraction_float(float In, out float Out)
                {
                    Out = frac(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                struct Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float
                {
                half4 uv0;
                float3 TimeParameters;
                };
                
                void SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(float _Speed, float _Count, float _Length, Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float IN, out float OutVector1_1)
                {
                float _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float = _Speed;
                float _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_b7d59b362ada42dbb63cf4da67b28499_Out_0_Float, _Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float);
                float4 _UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4 = IN.uv0;
                float2 _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2;
                Unity_PolarCoordinates_float((_UV_92e6482964a34e73a495f2d8d96f27a1_Out_0_Vector4.xy), float2 (0.5, 0.5), 0, 1, _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2);
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_R_1_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[0];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float = _PolarCoordinates_0af8794048e649a783a78a567b222f37_Out_4_Vector2[1];
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_B_3_Float = 0;
                float _Split_cfbc908eb2154b88a26bb490fc9d5d41_A_4_Float = 0;
                float _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float = _Count;
                float _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float;
                Unity_Multiply_float_float(_Split_cfbc908eb2154b88a26bb490fc9d5d41_G_2_Float, _Property_aaf545ee278a46d29da9e7222acce820_Out_0_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float);
                float _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float;
                Unity_Add_float(_Multiply_17e886495acc41e791e4a7afd14971cd_Out_2_Float, _Multiply_8ffd1514c57e4914b4c15fef3e3798ac_Out_2_Float, _Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float);
                float _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float;
                Unity_Fraction_float(_Add_58aff2f86b91468997f9af4cc8f2ec3f_Out_2_Float, _Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float);
                float _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float = _Length;
                float _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                Unity_Smoothstep_float(_Fraction_b068dfd4986a4fb5810fed16d99a37f0_Out_1_Float, 1, _Property_be519b7c6ac64ed9a90fec03820809bd_Out_0_Float, _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float);
                OutVector1_1 = _Smoothstep_112d202de1184cee9eb29598fb8f5329_Out_3_Float;
                }
                
                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
                
                struct Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(UnityTexture2D _Texture2D, float2 _Offset, Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float IN, out float Out_Vector1_0)
                {
                UnityTexture2D _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D = _Texture2D;
                float4 _UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4 = IN.uv0;
                float2 _Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2 = _Offset;
                UnityTexture2D _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D = _Texture2D;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.z;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.w;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelWidth_3_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.x;
                float _TextureSize_686d5c7839a242af98d8041529e284b5_TexelHeight_4_Float = _Property_4a41055b1d7f40a5ad981b6322ac57ab_Out_0_Texture2D.texelSize.y;
                float2 _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2 = float2(_TextureSize_686d5c7839a242af98d8041529e284b5_Width_0_Float, _TextureSize_686d5c7839a242af98d8041529e284b5_Height_2_Float);
                float2 _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2;
                Unity_Divide_float2(_Property_27a049f3e55b43a9967a2557616f05da_Out_0_Vector2, _Vector2_54fa2f7a75da45a998d7f4b8a3daaa75_Out_0_Vector2, _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2);
                float2 _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2;
                Unity_Add_float2((_UV_12fa4d39920c449882a3d0b06e045a69_Out_0_Vector4.xy), _Divide_afef4de96b1a4163aea7361b3e82dd98_Out_2_Vector2, _Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2);
                float4 _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.tex, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.samplerstate, _Property_039a451d5cc64ff3a82ba02eb402568b_Out_0_Texture2D.GetTransformedUV(_Add_bb48c3432c624fb5836e2216f8efa490_Out_2_Vector2) );
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_R_4_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.r;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_G_5_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.g;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_B_6_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.b;
                float _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float = _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_RGBA_0_Vector4.a;
                float _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                Unity_Step_float(0.01, _SampleTexture2D_c181748b4cdb477486a040710b60ac4a_A_7_Float, _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float);
                Out_Vector1_0 = _Step_7d123b16595a4b5fbb05805457776efc_Out_2_Float;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                struct Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float
                {
                half4 uv0;
                half4 uv1;
                half4 uv2;
                half4 uv3;
                };
                
                void SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(UnityTexture2D _MainTex, float _X, float _X_1, float _Y, float _Y_1, Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float IN, out float FullAlpha_2, out float OutlineAlpha_1)
                {
                UnityTexture2D _Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D = _MainTex;
                float _Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float = _X;
                float2 _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2 = float2(_Property_eabf20d1db8e474e9467b6ea27cce631_Out_0_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv0 = IN.uv0;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv1 = IN.uv1;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv2 = IN.uv2;
                _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4.uv3 = IN.uv3;
                half _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_7ec61c479682482899aa1cad4f7078d9_Out_0_Vector2, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4, _OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float);
                float _Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float = _X_1;
                float _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float;
                Unity_Multiply_float_float(_Property_d28396cb635d41b8a71e0545e9f64ffe_Out_0_Float, -1, _Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float);
                float2 _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2 = float2(_Multiply_c56974eaa7834542a00692010c1d7069_Out_2_Float, 0);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv0 = IN.uv0;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv1 = IN.uv1;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv2 = IN.uv2;
                _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88.uv3 = IN.uv3;
                half _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_a6e10041670a4fba8562ccfcd1348674_Out_0_Vector2, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float);
                float _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_5020f19d1a9147a68b7d36b89605acc4_OutVector1_0_Float, _OutlineOffsetComponent_7f01cacb23bc46178266aabad39a7a88_OutVector1_0_Float, _Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float);
                float _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float = _Y;
                float2 _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2 = float2(0, _Property_67b2478e2bd84cc186114b95ae81e696_Out_0_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv0 = IN.uv0;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv1 = IN.uv1;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv2 = IN.uv2;
                _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb.uv3 = IN.uv3;
                half _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_803e2d9785114b0abdde1b43b3ef796d_Out_0_Vector2, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb, _OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float);
                float _Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float = _Y_1;
                float _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float;
                Unity_Multiply_float_float(_Property_fb7caef70d7a4937998cfb6d0da4ade7_Out_0_Float, -1, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                float2 _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2 = float2(0, _Multiply_820df595d3d24d09bacedcf608684738_Out_2_Float);
                Bindings_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv0 = IN.uv0;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv1 = IN.uv1;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv2 = IN.uv2;
                _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940.uv3 = IN.uv3;
                half _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float;
                SG_OutlineOffsetComponent_d8bf9850b07c1af47b140cc762ab66bb_float(_Property_76d114d813234ed1b740fcc126f1b73b_Out_0_Texture2D, _Vector2_1c4ead822e11413d8d3fe4b27146599a_Out_0_Vector2, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float);
                float _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float;
                Unity_Add_float(_OutlineOffsetComponent_8897ca1c53a8417ba095321ee4484acb_OutVector1_0_Float, _OutlineOffsetComponent_ad37a0eca7134fe6bbe73c7c2c69f940_OutVector1_0_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float);
                float _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float;
                Unity_Add_float(_Add_db694a8a38d64d30bb77820611f4b31d_Out_2_Float, _Add_a7bd58bb61454afaadd0a94e6f6bbe15_Out_2_Float, _Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float);
                float _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                Unity_Clamp_float(_Add_5e0a3ebc064e4182be71bdc239d1c565_Out_2_Float, 0, 1, _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float);
                UnityTexture2D _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D = _MainTex;
                float4 _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.tex, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.samplerstate, _Property_cc43b3114c7440f992721cccae1445f7_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_R_4_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.r;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_G_5_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.g;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_B_6_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.b;
                float _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float = _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_RGBA_0_Vector4.a;
                float _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                Unity_Subtract_float(_Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float, _SampleTexture2D_fb306aa4f9094eeb80f5c1e795b9ffe0_A_7_Float, _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float);
                FullAlpha_2 = _Clamp_31f4891f4fbc4e0685302c44be58b1b4_Out_3_Float;
                OutlineAlpha_1 = _Subtract_d853513b1dd14df4af1fe47c9f3b3fae_Out_2_Float;
                }
                
                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }
                
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float4(float4 In, float4 Min, float4 Max, out float4 Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                struct Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float
                {
                };
                
                void SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(float4 _MainColor, Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float IN, out float4 Color_1)
                {
                float4 _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4 = _MainColor;
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_R_1_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[0];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_G_2_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[1];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_B_3_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[2];
                float _Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float = _Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4[3];
                float _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float;
                Unity_OneMinus_float(_Split_a3c310fceba5448b98efcdcb7a6f8f3d_A_4_Float, _OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float);
                float4 _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4;
                Unity_Subtract_float4(_Property_6ee8a486c7254eda910794985e804ae0_Out_0_Vector4, (_OneMinus_65d93c546e1d4a3b9855157783b55bd8_Out_1_Float.xxxx), _Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4);
                float4 _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                Unity_Clamp_float4(_Subtract_e1b923f1233342309c01b7bae460ca72_Out_2_Vector4, float4(0, 0, 0, 0), float4(1, 1, 1, 1), _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4);
                Color_1 = _Clamp_dc1ece1026054a09b8538d85418885ed_Out_3_Vector4;
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float = _Speed;
                    float _Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float = _Count;
                    float _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float;
                    Unity_Round_float(_Property_179de5725b254f77b03e9cc0bb3af647_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float);
                    float _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float = _Length;
                    Bindings_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.uv0 = IN.uv0;
                    _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17.TimeParameters = IN.TimeParameters;
                    float _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float;
                    SG_FractionSpinComponent_7d99a9ee3c2c9a748b3445d061c68166_float(_Property_678c6d3b09314959ab62e23fcf5fa6a2_Out_0_Float, _Round_d76467b8bf7747d9967868e14be7a75f_Out_1_Float, _Property_a1d7675d68a44efeaac2f65f52b77291_Out_0_Float, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17, _FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float);
                    float4 _Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_OutlineColor) : _OutlineColor;
                    UnityTexture2D _Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    Bindings_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float _OutlineComponent_511518b8b2164464b514d039a9629a43;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv0 = IN.uv0;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv1 = IN.uv1;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv2 = IN.uv2;
                    _OutlineComponent_511518b8b2164464b514d039a9629a43.uv3 = IN.uv3;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float;
                    float _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float;
                    SG_OutlineComponent_5703f1fe7a0ed294fa7de2b022dcc231_float(_Property_8440c9a156704716a828ccec590987ba_Out_0_Texture2D, 1, 1, 1, 1, _OutlineComponent_511518b8b2164464b514d039a9629a43, _OutlineComponent_511518b8b2164464b514d039a9629a43_FullAlpha_2_Float, _OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float);
                    float4 _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4;
                    Unity_Multiply_float4_float4(_Property_9a0d09b8d12c4941b869083729859a2c_Out_0_Vector4, (_OutlineComponent_511518b8b2164464b514d039a9629a43_OutlineAlpha_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4);
                    float4 _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4;
                    Unity_Multiply_float4_float4((_FractionSpinComponent_99f9dac6aa424c22a68f30e9bf361e17_OutVector1_1_Float.xxxx), _Multiply_943aff2605e14141bae1717d2545cce9_Out_2_Vector4, _Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4);
                    UnityTexture2D _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                    float4 _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.tex, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.samplerstate, _Property_0a65de868e9547e5a138b1fc1738d9dc_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_R_4_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_G_5_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_B_6_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_A_7_Float = _SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4.a;
                    Bindings_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d;
                    float4 _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4;
                    SG_SanitzeColorComponent_c09426ebd7fb0cd4b8ff918ef88aac45_float(_SampleTexture2D_f455e0acffcd4e76be9cbf0e59965f47_RGBA_0_Vector4, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4);
                    float4 _Add_4298a45a24be47c389f7c7343a941856_Out_2_Vector4;
                    Unity_Add_float4(_Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4, _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4, _Add_4298a45a24be47c389f7c7343a941856_Out_2_Vector4);
                    float _Split_0187c19839e3457986c51354b0b5cba6_R_1_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[0];
                    float _Split_0187c19839e3457986c51354b0b5cba6_G_2_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[1];
                    float _Split_0187c19839e3457986c51354b0b5cba6_B_3_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[2];
                    float _Split_0187c19839e3457986c51354b0b5cba6_A_4_Float = _SanitzeColorComponent_56904d2c3e35477885b06f242fa2138d_Color_1_Vector4[3];
                    float4 _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4;
                    Unity_Add_float4(_Multiply_27a36dfad8ac45adb8778527a1175db0_Out_2_Vector4, (_Split_0187c19839e3457986c51354b0b5cba6_A_4_Float.xxxx), _Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4);
                    surface.BaseColor = (_Add_4298a45a24be47c389f7c7343a941856_Out_2_Vector4.xyz);
                    surface.Alpha = (_Add_d3119d25b1ab4ff093df3cbd350c5095_Out_2_Vector4).x;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                    output.uv1 = input.texCoord1;
                    output.uv2 = input.texCoord2;
                    output.uv3 = input.texCoord3;
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
        }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
    }