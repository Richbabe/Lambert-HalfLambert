﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DiffusePerPixel" {
	Properties {
		//材质的颜色
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}
	SubShader{
		Pass{
			Tags{ "RenderType" = "Opaque" }
			LOD 200

			//******开始CG着色器语言编写模块******
			CGPROGRAM
			//引入头文件
			#include "Lighting.cginc"

			//定义Properties中的变量
			fixed4 _Diffuse;

			//定义结构体：顶点着色器阶段输入的数据
			struct vertexShaderInput {
				float4 vertex : POSITION;//顶点坐标
				float3 normal : NORMAL;//法向量
			};

			//定义结构体: 顶点着色器阶段输出的内容
			struct vertexShaderOutput {
				float4 pos : SV_POSITION;//顶点视口坐标系的坐标
				float3 worldNormal : TEXCOORD0;//世界坐标系中的法向量
			};

			//定义顶点着色器
			vertexShaderOutput vertexShader(vertexShaderInput v) {
				vertexShaderOutput o;//顶点着色器的输出

				//把顶点从局部坐标系转到世界坐标系再转到视口坐标系
				o.pos = UnityObjectToClipPos(v.vertex);

				//把法线转换到世界空间
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				return o;
			}

			//定义片段着色器
			fixed4 fragmentShader(vertexShaderOutput i) : SV_Target{
				/* 归一化法线，不能在顶点着色器中归一化后传进来，
				因为从顶点着色器到片段着色器有差值处理，
				传入的归一化法线并不是从顶点着色器直接传出的 */
				fixed3 worldNormal = normalize(i.worldNormal);

				//把光照方向归一化
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//根据兰伯特模型计算顶点的光照信息,dot为负值时取0
				fixed3 lambert = max(0.0, dot(worldNormal, worldLightDir));

				//最终输出颜色为lambert光强 * 材质Diffuse颜色 * 光颜色
				fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz;
				return fixed4(diffuse, 1.0);

			}

			//使用vertexShader函数和fragmentShader函数
			#pragma vertex vertexShader
			#pragma fragment fragmentShader

			//*****结束CG着色器语言编写模块******
			ENDCG
		}
	}
	//前面的Shader失效的话，使用默认的Diffuse
	FallBack "Diffuse"
}
