#include "src/game/envfx_snow.h"

const GeoLayout ice_sparkle_000_switch_opt1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_2_0),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout ice_sparkle_000_switch_opt2[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_3_1),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout ice_sparkle_000_switch_opt3[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_4_2),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout ice_sparkle_000_switch_opt4[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_5_3),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout ice_sparkle_000_switch_opt5[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, ice_sparkle_000_displaylist_mesh_layer_5_mat_override_sparkle_6_4),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout ice_sparkle_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_SWITCH_CASE(9, geo_switch_anim_state),
		GEO_OPEN_NODE(),
			GEO_NODE_START(),
			GEO_OPEN_NODE(),
				GEO_DISPLAY_LIST(LAYER_TRANSPARENT, ice_sparkle_000_displaylist_mesh_layer_5),
			GEO_CLOSE_NODE(),
			GEO_BRANCH(1, ice_sparkle_000_switch_opt1),
			GEO_BRANCH(1, ice_sparkle_000_switch_opt2),
			GEO_BRANCH(1, ice_sparkle_000_switch_opt3),
			GEO_BRANCH(1, ice_sparkle_000_switch_opt4),
			GEO_BRANCH(1, ice_sparkle_000_switch_opt5),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
