using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public class Golden1Editor : ShaderGUI {
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material targetMat = materialEditor.target as Material;

        bool effectsLayer1Enabled = Array.IndexOf(targetMat.shaderKeywords, "EFFECTS_LAYER_1_ON") != -1;
        bool effectsLayer2Enabled = Array.IndexOf(targetMat.shaderKeywords, "EFFECTS_LAYER_2_ON") != -1;
        bool effectsLayer3Enabled = Array.IndexOf(targetMat.shaderKeywords, "EFFECTS_LAYER_3_ON") != -1;

        EditorGUI.BeginChangeCheck();

        for (int i = 0; i < 3; i++)
            materialEditor.TexturePropertySingleLine(new GUIContent(properties[i].displayName), properties[i]);

        effectsLayer1Enabled = EditorGUILayout.Toggle("效果1",effectsLayer1Enabled);

        if (effectsLayer1Enabled)
        {
            DrawEffect(materialEditor, properties, 1);
        }

        effectsLayer2Enabled = EditorGUILayout.Toggle("效果2", effectsLayer2Enabled);

        if (effectsLayer2Enabled)
        {
            DrawEffect(materialEditor, properties, 2);
        }

        effectsLayer3Enabled = EditorGUILayout.Toggle("效果3", effectsLayer3Enabled);

        if (effectsLayer3Enabled)
        {
            DrawEffect(materialEditor, properties, 3);
        }

        if (EditorGUI.EndChangeCheck())
        {
            string[] newKeys = new string[] {
                effectsLayer1Enabled ? "EFFECTS_LAYER_1_ON" : "EFFECTS_LAYER_1_OFF",
                effectsLayer2Enabled ? "EFFECTS_LAYER_2_ON" : "EFFECTS_LAYER_2_OFF",
                effectsLayer3Enabled ? "EFFECTS_LAYER_3_ON" : "EFFECTS_LAYER_3_OFF",
            };
            targetMat.shaderKeywords = newKeys;
            EditorUtility.SetDirty(targetMat);
        }

    }


    void DrawEffect(MaterialEditor materialEditor, MaterialProperty[] property, int layer)
    {
        GUIStyle style = EditorStyles.helpBox;
        style.margin = new RectOffset(20, 20, 0, 0);

        EditorGUILayout.BeginVertical(style);
        materialEditor.TexturePropertySingleLine(new GUIContent("效果纹理"), property.GetByName(GetNameByLayer("EffectTexture", layer)));
        materialEditor.TexturePropertySingleLine(new GUIContent("移动纹理"), property.GetByName(GetNameByLayer("MotionTexture", layer)));

        materialEditor.ColorProperty(property.GetByName(GetNameByLayer("EffectColor", layer)), "效果颜色");

        materialEditor.FloatProperty(property.GetByName(GetNameByLayer("MotionSpeed", layer)), "移动速度");
        materialEditor.FloatProperty(property.GetByName(GetNameByLayer("RotationSpeed", layer)), "旋转速度");

        //materialEditor.VectorProperty(property.GetByName(GetNameByLayer("Pivot", layer)), "锚点");

        Vector4 translation = property.GetByName(GetNameByLayer("Position", layer)).vectorValue;
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.LabelField("位置");
            translation.x = EditorGUILayout.FloatField(translation.x);
            translation.y = EditorGUILayout.FloatField(translation.y);
        }
        EditorGUILayout.EndHorizontal();
        property.GetByName(GetNameByLayer("Position", layer)).vectorValue = translation;

        Vector4 pivot = property.GetByName(GetNameByLayer("Pivot", layer)).vectorValue;
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.LabelField("锚点");
            pivot.x = EditorGUILayout.FloatField(pivot.x);
            pivot.y = EditorGUILayout.FloatField(pivot.y);
        }
        EditorGUILayout.EndHorizontal();
        property.GetByName(GetNameByLayer("Pivot", layer)).vectorValue = pivot;

        Vector4 scale = property.GetByName(GetNameByLayer("Scale", layer)).vectorValue;
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.LabelField("缩放");
            scale.x = EditorGUILayout.FloatField(scale.x);
            scale.y = EditorGUILayout.FloatField(scale.y);
        }
        EditorGUILayout.EndHorizontal();
        property.GetByName(GetNameByLayer("Scale", layer)).vectorValue = scale;

        bool foreground = property.GetByName(GetNameByLayer("Foreground", layer)).floatValue == 1 ? true : false;
        foreground = EditorGUILayout.Toggle("前景？",foreground);
        property.GetByName(GetNameByLayer("Foreground", layer)).floatValue = foreground  ? 1 : 0;

       
        EditorGUILayout.EndVertical();
    }


    string  GetNameByLayer(string word, int layer)
    {
        return "_" + word + layer.ToString();
    }


}
