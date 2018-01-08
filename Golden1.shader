Shader "Hearthstone/Golden1"
{
	Properties
	{
		_Texture("MainTexture",2D) = "black"{}
		_DistortionTexture("Distortion Texture",2D) = "grey"{}
		_DistMask("Distortion Mask", 2D) = "black" {}

		_EffectTexture1("",2D) = "black"{}
		_MotionTexture1("",2D) = "black"{}
		_EffectColor1("",Color) = (1,1,1,1)
		_MotionSpeed1("",float) = 0
		_RotationSpeed1("",float) = 0
		_Position1("",Vector) = (1,1,0,0)
		_Pivot1("",Vector) = (1,1,0,0)
		_Scale1("",Vector) = (1,1,0,0)
		_Foreground1("",float) = 1

		_EffectTexture2("",2D) = "black"{}
		_MotionTexture2("",2D) = "black"{}
		_EffectColor2("",Color) = (1,1,1,1)
		_MotionSpeed2("",float) = 0
		_RotationSpeed2("",float) = 0
		_Position2("",Vector) = (1,1,0,0)
		_Pivot2("",Vector) = (1,1,0,0)
		_Scale2("",Vector) = (1,1,0,0)
		_Foreground2("",float) = 1

		_EffectTexture3("",2D) = "black"{}
		_MotionTexture3("",2D) = "black"{}
		_EffectColor3("",Color) = (1,1,1,1)
		_MotionSpeed3("",float) = 0
		_RotationSpeed3("",float) = 0
		_Position3("",Vector) = (0,0,0,0)
		_Pivot3("",Vector) = (0.5,0.5,0,0)
		_Scale3("",Vector) = (1,1,0,0)
		_Foreground3("",float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "PreviewType" = "Plane" }
		LOD 100
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature EFFECTS_LAYER_1_ON EFFECTS_LAYER_1_OFF
			#pragma shader_feature EFFECTS_LAYER_2_ON EFFECTS_LAYER_2_OFF
			#pragma shader_feature EFFECTS_LAYER_3_ON EFFECTS_LAYER_3_OFF

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 effect1uv : TEXCOORD1;
				float2 effect2uv : TEXCOORD2;
				float2 effect3uv : TEXCOORD3;
			};

			sampler2D _Texture;
			sampler2D _DistortionTexture;
			sampler2D _DistMask;

			sampler2D _EffectTexture1;
			sampler2D _MotionTexture1;
			half4 _EffectColor1;
			float _MotionSpeed1;
			float _RotationSpeed1;
			float _Foreground1;
			float2 _Position1;
			float2 _Pivot1;
			float2 _Scale1;

			sampler2D _EffectTexture2;
			sampler2D _MotionTexture2;
			half4 _EffectColor2;
			float _MotionSpeed2;
			float _RotationSpeed2;
			float _Foreground2;
			float2 _Position2;
			float2 _Pivot2;
			float2 _Scale2;

			sampler2D _EffectTexture3;
			sampler2D _MotionTexture3;
			half4 _EffectColor3;
			float _MotionSpeed3;
			float _RotationSpeed3;
			float _Foreground3;
			float2 _Position3;
			float2 _Pivot3;
			float2 _Scale3;
						
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				float cosdelta;
				float sindelta;
				float2x2 rotationMatrix;

				#if EFFECTS_LAYER_1_ON
				cosdelta = cos(_Time.x * _RotationSpeed1);
				sindelta = sin(_Time.x * _RotationSpeed1);
				rotationMatrix = float2x2(cosdelta, -sindelta, sindelta, cosdelta);
				o.effect1uv = o.uv - _Pivot1;
				o.effect1uv = (mul((o.effect1uv - _Position1) / _Scale1, rotationMatrix)) + _Pivot1;
				#endif

				#if EFFECTS_LAYER_2_ON
				cosdelta = cos(_Time.x * _RotationSpeed2);
				sindelta = sin(_Time.x * _RotationSpeed2);
				rotationMatrix = float2x2(cosdelta, -sindelta, sindelta, cosdelta);
				o.effect2uv = o.uv - _Pivot2;
				o.effect2uv = (mul((o.effect2uv - _Position2) / _Scale2, rotationMatrix)) + _Pivot2;
				#endif

				#if EFFECTS_LAYER_3_ON
				cosdelta = cos(_Time.x * _RotationSpeed3);
				sindelta = sin(_Time.x * _RotationSpeed3);
				rotationMatrix = float2x2(cosdelta, -sindelta, sindelta, cosdelta);
				o.effect3uv = o.uv - _Pivot3;
				o.effect3uv = (mul((o.effect3uv - _Position3) / _Scale3, rotationMatrix)) + _Pivot3;
				#endif

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			 	float2 disuv = float2(_Time.x, _Time.x);
			 	float2 distortion = (tex2D(_DistortionTexture,i.uv + disuv).rg - 0.5) * 2;
				float distortionMask = tex2D(_DistMask,i.uv + disuv).a;
				fixed4 col = tex2D(_Texture, i.uv + distortion * distortionMask * 0.025);
				float bg = col.a;

				# if EFFECTS_LAYER_1_ON
				fixed4 motion1 = tex2D(_MotionTexture1,i.uv);
				if(_MotionSpeed1)
					motion1.y -= _Time.x * _MotionSpeed1;
				else
					motion1 = fixed4(i.effect1uv.rg, motion1.b,motion1.a);
				fixed4 effectColor1 = tex2D(_EffectTexture1,motion1.rg) * motion1.a;
				effectColor1 *= _EffectColor1;
				col += effectColor1 * effectColor1.a * max(bg, _Foreground1);
				#endif

				# if EFFECTS_LAYER_2_ON
				fixed4 motion2 = tex2D(_MotionTexture2,i.uv);
				if(_MotionSpeed2)
					motion2.y -= _Time.x * _MotionSpeed2;
				else
					motion2 = fixed4(i.effect2uv, motion2.b,motion2.a);
				fixed4 effectColor2 = tex2D(_EffectTexture2,motion2) * motion2.a;
				effectColor2 *= _EffectColor2;
				col += effectColor2 * effectColor2.a * max(bg, _Foreground2);
				#endif

				# if EFFECTS_LAYER_3_ON
				fixed4 motion3 = tex2D(_MotionTexture3,i.uv);
				if(_MotionSpeed3)
					motion3.y -= _Time.x * _MotionSpeed3;
				else
					motion3 = fixed4(i.effect3uv, motion3.b,motion3.a);
				fixed4 effectColor3 = tex2D(_EffectTexture3,motion3) * motion3.a;
				effectColor3 *= _EffectColor3;
				col += effectColor3 * effectColor3.a * max(bg, _Foreground3);
				#endif
				return col;
			}
			ENDCG
		}
	}

	CustomEditor "Golden1Editor"
}
