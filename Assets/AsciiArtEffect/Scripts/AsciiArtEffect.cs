using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class AsciiArtEffect : CustomImageEffectBase {

    public Texture2D asciiRampTexture;
    public int level = 70;
    public int fontWidth = 7;
    public int fontHeight = 16;
    /// <summary>
    /// 輝度の順番を反転する
    /// </summary>
    public bool reverseLuminance = false;

    /// <summary>
    /// 元の色を乗算する
    /// </summary>
    public bool multipleColor = false;

    public override string ShaderName
    {
        get
        {
            return "Hidden/AsciiArtEffect";
        }
    }

    protected override void UpdateMaterial()
    {
        material.SetTexture("_RampTex", asciiRampTexture);
        material.SetInt("_Level", level);
        material.SetInt("_DivNumX", Screen.width / fontWidth);
        material.SetInt("_DivNumY", Screen.height / fontHeight);
    }

    private void OnValidate()
    {
        if (reverseLuminance)
        {
            material.EnableKeyword("_REVERSE_LUM");
        }
        else
        {
            material.DisableKeyword("_REVERSE_LUM");
        }

        if (multipleColor)
        {
            material.EnableKeyword("_MULTI_COL");
        }
        else
        {
            material.DisableKeyword("_MULTI_COL");
        }
        
    }

    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        UpdateMaterial();

        // 縮小
        var smallTex = RenderTexture.GetTemporary(Screen.width / fontWidth, Screen.height / fontHeight);
        smallTex.filterMode = FilterMode.Point;

        Graphics.Blit(source, smallTex);

        // Ascii Art化
        Graphics.Blit(smallTex, destination, material, 0);

        RenderTexture.ReleaseTemporary(smallTex);
    }
}
