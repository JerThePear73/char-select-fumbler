Gfx ice_sparkle_sparkle_1_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 ice_sparkle_sparkle_1_rgba16[] = {
	#include "actors/ice_sparkle/sparkle-1.rgba16.inc.c"
};

Gfx ice_sparkle_sparkle_2_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 ice_sparkle_sparkle_2_rgba16[] = {
	#include "actors/ice_sparkle/sparkle-2.rgba16.inc.c"
};

Gfx ice_sparkle_sparkle_3_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 ice_sparkle_sparkle_3_rgba16[] = {
	#include "actors/ice_sparkle/sparkle-3.rgba16.inc.c"
};

Gfx ice_sparkle_sparkle_4_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 ice_sparkle_sparkle_4_rgba16[] = {
	#include "actors/ice_sparkle/sparkle-4.rgba16.inc.c"
};

Gfx ice_sparkle_sparkle_5_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 ice_sparkle_sparkle_5_rgba16[] = {
	#include "actors/ice_sparkle/sparkle-5.rgba16.inc.c"
};

Gfx ice_sparkle_sparkle_6_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 ice_sparkle_sparkle_6_rgba16[] = {
	#include "actors/ice_sparkle/sparkle-6.rgba16.inc.c"
};

Vtx ice_sparkle_000_displaylist_mesh_layer_5_vtx_0[4] = {
	{{ {-16, 0, 0}, 0, {-16, 976}, {255, 255, 255, 255} }},
	{{ {16, 0, 0}, 0, {976, 976}, {255, 255, 255, 255} }},
	{{ {16, 32, 0}, 0, {976, -16}, {255, 255, 255, 255} }},
	{{ {-16, 32, 0}, 0, {-16, -16}, {255, 255, 255, 255} }},
};

Gfx ice_sparkle_000_displaylist_mesh_layer_5_tri_0[] = {
	gsSPVertex(ice_sparkle_000_displaylist_mesh_layer_5_vtx_0 + 0, 4, 0),
	gsSP2Triangles(0, 1, 2, 0, 0, 2, 3, 0),
	gsSPEndDisplayList(),
};


Gfx mat_ice_sparkle_sparkle_1[] = {
	gsSPGeometryMode(G_LIGHTING | G_SHADING_SMOOTH, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ice_sparkle_sparkle_1_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_ice_sparkle_sparkle_1[] = {
	gsSPGeometryMode(0, G_LIGHTING | G_SHADING_SMOOTH),
	gsDPPipeSync(),
	gsSPEndDisplayList(),
};

Gfx mat_ice_sparkle_sparkle_2[] = {
	gsSPGeometryMode(G_LIGHTING | G_SHADING_SMOOTH, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ice_sparkle_sparkle_2_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_ice_sparkle_sparkle_2[] = {
	gsSPGeometryMode(0, G_LIGHTING | G_SHADING_SMOOTH),
	gsDPPipeSync(),
	gsSPEndDisplayList(),
};

Gfx mat_ice_sparkle_sparkle_3[] = {
	gsSPGeometryMode(G_LIGHTING | G_SHADING_SMOOTH, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ice_sparkle_sparkle_3_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_ice_sparkle_sparkle_3[] = {
	gsSPGeometryMode(0, G_LIGHTING | G_SHADING_SMOOTH),
	gsDPPipeSync(),
	gsSPEndDisplayList(),
};

Gfx mat_ice_sparkle_sparkle_4[] = {
	gsSPGeometryMode(G_LIGHTING | G_SHADING_SMOOTH, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ice_sparkle_sparkle_4_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_ice_sparkle_sparkle_4[] = {
	gsSPGeometryMode(0, G_LIGHTING | G_SHADING_SMOOTH),
	gsDPPipeSync(),
	gsSPEndDisplayList(),
};

Gfx mat_ice_sparkle_sparkle_5[] = {
	gsSPGeometryMode(G_LIGHTING | G_SHADING_SMOOTH, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ice_sparkle_sparkle_5_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_ice_sparkle_sparkle_5[] = {
	gsSPGeometryMode(0, G_LIGHTING | G_SHADING_SMOOTH),
	gsDPPipeSync(),
	gsSPEndDisplayList(),
};

Gfx mat_ice_sparkle_sparkle_6[] = {
	gsSPGeometryMode(G_LIGHTING | G_SHADING_SMOOTH, 0),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ice_sparkle_sparkle_6_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 1023, 256),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0, G_TX_CLAMP | G_TX_NOMIRROR, 5, 0),
	gsDPSetTileSize(0, 0, 0, 124, 124),
	gsSPEndDisplayList(),
};

Gfx mat_revert_ice_sparkle_sparkle_6[] = {
	gsSPGeometryMode(0, G_LIGHTING | G_SHADING_SMOOTH),
	gsDPPipeSync(),
	gsSPEndDisplayList(),
};

Gfx ice_sparkle_000_displaylist_mesh_layer_5[] = {
	gsSPDisplayList(mat_ice_sparkle_sparkle_1),
	gsSPDisplayList(ice_sparkle_000_displaylist_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_ice_sparkle_sparkle_1),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_2_0[] = {
	gsSPDisplayList(mat_ice_sparkle_sparkle_2),
	gsSPDisplayList(ice_sparkle_000_displaylist_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_ice_sparkle_sparkle_2),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_3_1[] = {
	gsSPDisplayList(mat_ice_sparkle_sparkle_3),
	gsSPDisplayList(ice_sparkle_000_displaylist_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_ice_sparkle_sparkle_3),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_4_2[] = {
	gsSPDisplayList(mat_ice_sparkle_sparkle_4),
	gsSPDisplayList(ice_sparkle_000_displaylist_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_ice_sparkle_sparkle_4),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_5_3[] = {
	gsSPDisplayList(mat_ice_sparkle_sparkle_5),
	gsSPDisplayList(ice_sparkle_000_displaylist_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_ice_sparkle_sparkle_5),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_6_4[] = {
	gsSPDisplayList(mat_ice_sparkle_sparkle_6),
	gsSPDisplayList(ice_sparkle_000_displaylist_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_ice_sparkle_sparkle_6),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

