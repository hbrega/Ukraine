//--------------------------------------------------------------------------------------
// File: terAlphaObject.fx
// Copyright (c) 2008 Third Wire Productions, Inc.
//--------------------------------------------------------------------------------------

struct DirLight
{
    float3	dir;
    float	___d4;		//float3 aligned to 4
    float3	color;	
    float	___c4;		//float3 aligned to 4
};

struct PointLight
{
    float3	color;		
    float	Range2;		//float3 aligned to 4
    float3	pos;
    float	invRange;
};

struct SpotLight
{
    float3	color;		
    float	___c4;		//float3 aligned to 4
    float3	pos;		
	float	___p4;		//float3 aligned to 4
    float3	dir;		
    float	Range2;		//float3 aligned to 4
    float	invRange;
    float3	angles;		// x = cos(Theta/2) (inner angle), y = cos(Phi/2) (outer angle), z = 1/(x - y)
};

//--------------------------------------------------------------------------------------
// Constant Buffers
//--------------------------------------------------------------------------------------
  
cbuffer cbGlobal
{
    float4x4	g_mWorldToView;
    float4x4	g_mViewProj;
    float		g_InvFarClip;
	float3		g_FogDistance;		// x = Start, y = End, z =  1 / (y - x)
    float3		g_FogColor;
    float3		g_FogLayer;			// x = amount, y = altitude (camera-relative), z = thickness
	float3		g_AmbientLight;
	DirLight	g_DirLight;
};

cbuffer cbPerMaterial
{
	float3		g_FadeDistance;	
};

cbuffer cbPerMesh
{
	float3		g_MeshOffsetPos;
	int			g_NumPointLights;
    PointLight	g_aPointLights[8];
	int			g_NumSpotLights;
    SpotLight	g_aSpotLights[2];
};

Texture2D g_MaterialTexture;

SamplerState g_LinearSampler
{
    Filter = ANISOTROPIC;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VS_INPUT
{
    float3	pos			: POSITION; 
    float3	norm		: NORMAL;
	float2	uv			: TEXCOORD;
};

struct VS_OUTPUT
{
  	float4 	pos_w		: COLOR;				//xyz = world space pos, w = fogdist
	float2 	uv			: TEXCOORD;

    float4	pos			: SV_POSITION;
};

struct PS_INPUT
{
  	float4 	pos_w		: COLOR;				//xyz = world space pos, w = fogdist
	float2 	uv			: TEXCOORD;
};

//--------------------------------------------------------------------------------------
		
float3 compute_per_pixel_ambient_diffuse(float3 P)
{
	float3 diffuse = g_AmbientLight + g_DirLight.color * max(0, -g_DirLight.dir.z);

	// do per-pixel light sourcing for point/spot lights
	for (int i = 0; i < g_NumPointLights; i++)
	{
		const float3 L = g_aPointLights[i].pos - P;
		const float L2 = dot(L, L);
		if (L2 < g_aPointLights[i].Range2)
		{
			const float lenL = sqrt(L2);
			const float Ln = lenL * g_aPointLights[i].invRange;
			float cp = 0;
			if (Ln < 0.5)
			{
				cp = 1.0-2.0*Ln*Ln;
			}
			else
			{
				cp = 2*(1.0-Ln)*(1.0-Ln);
			}
			cp /= lenL;
			diffuse += (g_aPointLights[i].color * cp);
		}
	}
	for (int j = 0; j < g_NumSpotLights; j++)
	{
		const float3 L = g_aSpotLights[j].pos - P;
		const float L2 = dot(L, L);
		if (L2 < g_aSpotLights[j].Range2)
		{
			const float lenL = sqrt(L2);
			const float inv_lenL = 1.0 / lenL;
			const float3 Lu = -L * inv_lenL;
			const float ca = dot(Lu, g_aSpotLights[j].dir);
			if (ca > g_aSpotLights[j].angles.y)
			{
				const float Ln = lenL * g_aSpotLights[j].invRange;
				float cp = 0;
				if (Ln < 0.5)
				{
					cp = 1.0-2.0*Ln*Ln;
				}
				else
				{
					cp = 2*(1.0-Ln)*(1.0-Ln);
				}
				if (ca < g_aSpotLights[j].angles.x)
				{
					cp *= (ca - g_aSpotLights[j].angles.y) * g_aSpotLights[j].angles.z;
				}						
				cp *= inv_lenL;
				diffuse += (g_aSpotLights[j].color * cp);
			}
		}
	}	
	
	return diffuse;	
}

//--------------------------------------------------------------------------------------

float4 add_fog_fade_alpha(float4 Color, float FogDist, float FogZ)
{
	float4 output = Color;

	float fog = 0.0f;	
	const float fd = FogDist - g_FogDistance.x;
	if (fd > 0.0)
	{
		fog = (fd * g_FogDistance.z);
	}
	if (g_FogLayer.x > 0.0)
	{
		const float fz = abs(FogZ - g_FogLayer.y);
		float depth = g_FogLayer.z - fz;
		if (depth > 0.0)
		{
			depth = min(FogDist, depth);
			
			fog += (g_FogLayer.x * (smoothstep(0.0, g_FogLayer.z, depth)));
		}
	}

	fog = clamp(0.0, 1.0, fog);
	output = lerp(output, float4(g_FogColor, 0.0f), fog);
	
	return (output);
}

//--------------------------------------------------------------------------------------

float fade_with_distance(float FadeDist)
{
	float fade_alpha = 1.0;	
	const float fd = FadeDist - g_FadeDistance.x;
	if (fd > 0.0)
	{
		fade_alpha = clamp(0.0, 1.0, 1.0 - (fd * g_FadeDistance.z));
	}

	return (fade_alpha);
}

//--------------------------------------------------------------------------------------

float precision_add_z( const float z1, const float z2, const float z3, const float z4 )
{   
	float z_sum = 0.0;
	float z_add = 0.0;
	float z_largest = 0.0;
	float z_temp = 0.0;
	float z_err = 0.0;

	if (z1 > z2)
	{
		z_sum = z2;
		if (z1 > z3)
		{
			z_largest = z1;
			z_add = z3;
		}
		else
		{
			z_largest = z3;
			z_add = z1;
		}
	}
	else
	{
		z_sum = z1;
		if (z2 > z3)
		{
			z_largest = z2;
			z_add = z3;
		}
		else
		{
			z_largest = z3;
			z_add = z2;
		}
	}
	
	// use Kahan summation
	z_temp = z_sum + z_add;				// if z_sum is big and z_add small, low-order digits can get lost...
	z_err = (z_temp - z_sum) - z_add;	// try to recover the lost digits...
	z_sum = z_temp; 

	z_add = z_largest - z_err;			// include the lost low part from prev add......
	z_temp = z_sum + z_add;
	z_err = (z_temp - z_sum) - z_add;
	z_sum = z_temp; 
	
	z_add = z4 - z_err;					// include the lost low part from prev add...

	return (z_sum + z_add);	
}

//--------------------------------------------------------------------------------------

float4 compute_pos( const float4 P  )
{    
	float4 pos;

	// try to compute z with minimal loss of precision ... 
	// TK TODO DX11/SM5.0 has double!

	pos.x = P.x * g_mViewProj[0][0] + P.y * g_mViewProj[1][0] + P.z * g_mViewProj[2][0];
	pos.y = P.x * g_mViewProj[0][1] + P.y * g_mViewProj[1][1] + P.z * g_mViewProj[2][1];

	pos.z = precision_add_z(P.x * g_mViewProj[0][2], P.y * g_mViewProj[1][2], P.z * g_mViewProj[2][2], g_mViewProj[3][2]);

	pos.w = P.x * g_mViewProj[0][3] + P.y * g_mViewProj[1][3] + P.z * g_mViewProj[2][3] + g_mViewProj[3][3];

	return (pos);
}

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------

VS_OUTPUT VS( VS_INPUT input )
{
    VS_OUTPUT output;
    
	const float4 P = float4((input.pos + g_MeshOffsetPos), 0.0);	// position, world-space
///Stary's note: const float4 P = float4((input.pos + g_MeshOffsetPos), 1.0);	// position, world-space		
	const float4 Pv = mul(P, g_mWorldToView);	// position in view-space

//	output.pos = mul(P, g_mViewProj);		
	output.pos = compute_pos(P);

	output.pos_w.xyz = P.xyz;
	output.pos_w.w = Pv.z;
	output.uv = input.uv;

    return output;    
 }

//--------------------------------------------------------------------------------------
// PixelShader
//--------------------------------------------------------------------------------------
float4 PS( PS_INPUT input ) : SV_TARGET
{ 
	float4 output = float4(0.0, 0.0, 0.0, 0.0);
	
	if (input.pos_w.w < g_FogDistance.y)
	{
		const float fade_alpha = fade_with_distance(input.pos_w.w);
		if (fade_alpha > 0.0)
		{
			output = g_MaterialTexture.Sample(g_LinearSampler, input.uv); 
			if (output.a > 0.0)
			{
				output.rgb *= compute_per_pixel_ambient_diffuse(input.pos_w.xyz);
				output = add_fog_fade_alpha(output, input.pos_w.w, input.pos_w.z);
				output.a *= (1.0 - smoothstep(0.0f, 22000.0f, input.pos_w.w));
				/////////////////////////////////////////////////////////////
				/// 16000.0f ok for detailmeshsize=10
				/// 12000.0f ok
				/// 18000.0f poping up noticeable
				///output.a *= fade_alpha;
			}
			output = saturate(output);
		}
	}
	return output;
}

//--------------------------------------------------------------------------------------
// Techniques
//--------------------------------------------------------------------------------------
technique10 Render
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}

//--------------------------------------------------------------------------------------
// File: terAlphaObject.fx
//--------------------------------------------------------------------------------------
    