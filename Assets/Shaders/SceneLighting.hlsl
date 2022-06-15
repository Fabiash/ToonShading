#ifndef SCENE_LIGHTING_INCLUDED
#define SCENE_LIGHTING_INCLUDED

#ifndef SHADERGRAPH_PREVIEW
 #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
    #if (SHADERPASS != SHADERPASS_FORWARD)
        #undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
    #endif

struct Variables
{
    float3 normal;
};
float3 CalculateLights(Light l, Variables v)
{
    return (saturate(dot(v.normal, l.direction)) * l.color) * (l.distanceAttenuation * l.shadowAttenuation);
}
#endif

void SceneLighting_float(float3 WorldPos, float3 NormalVector, out half3 MainDirection, out half3 MainColor, out float MainDistanceAtten, out half MainShadowAtten, out float3 MainLight, out float3 AdditionalLights)
{
#ifdef SHADERGRAPH_PREVIEW
    MainDirection = half3(0.5,0.5,0.5);
    MainColor = half3(1,1,1);
    MainDistanceAtten = 1;
    MainShadowAtten = 1;
    AdditionalLights = (1,1,1);
    MainLight = (1,1,1);
#else
    Variables v;
    v.normal = NormalVector;
    
    //Main light
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    Light mainLight = GetMainLight(shadowCoord);
    
    MainLight = CalculateLights(mainLight, v);
    MainDirection = mainLight.direction;
    MainColor = mainLight.color;
    MainDistanceAtten = mainLight.distanceAttenuation;
    MainShadowAtten = mainLight.shadowAttenuation;
    
    //Additional lights
    int pixelLightCount = GetAdditionalLightsCount();
    for (int i = 0; i < pixelLightCount; i++)
    {
        Light currentAdditionalLight = GetAdditionalLight(i, WorldPos, 1);
        AdditionalLights += CalculateLights(currentAdditionalLight, v);
    }
        
#endif

}
#endif
