-- name: [CS] \\#ff5555\\The Fumbler
-- description: What a fumble,,, that's embarassing.\n\n\\#ff7777\\This Pack requires Character Select\nto use as a Library!

local TEXT_MOD_NAME = "The Fumbler"

-- Stops mod from loading if Character Select isn't on
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

-- Models --
local E_MODEL_FUMBLER = smlua_model_util_get_id('fumbler_geo')
local E_MODEL_JUMBLER = smlua_model_util_get_id('jumbler_geo')

-- Textures --
local TEX_FUMBLER = get_texture_info("fumbler_icon")
local TEX_JUMBLER = get_texture_info("jumbler_icon")

local PALETTE_FUMBLER =  {
    [PANTS]  = "ffffff",
    [SHIRT]  = "ff0000",
    [GLOVES] = "ffffff",
    [SHOES]  = "333333",
    [HAIR]   = "730600",
    [SKIN]   = "fec179",
    [CAP]    = "ffffff",
    [EMBLEM] = "ff0000",
}
local PALETTE_CHARITY = {
    [PANTS]  = { r = 0xb2, g = 0x28, b = 0x18 },
    [SHIRT]  = { r = 0xff, g = 0xe0, b = 0xe0 },
    [GLOVES] = { r = 0xff, g = 0xff, b = 0xff },
    [SHOES]  = { r = 0x72, g = 0x1c, b = 0x0e },
    [HAIR]   = { r = 0x73, g = 0x06, b = 0x00 },
    [SKIN]   = { r = 0xfe, g = 0xc1, b = 0x79 },
    [CAP]    = { r = 0xff, g = 0xe0, b = 0xe0 },
    [EMBLEM] = { r = 0xff, g = 0x00, b = 0x00 },
}

local PALETTE_JUMBLER =  {
    [PANTS]  = "00ffff",
    [SHIRT]  = "00ff00",
    [GLOVES] = "2B3A59",
    [SHOES]  = "333333",
    [HAIR]   = "730600",
    [SKIN]   = "fec179",
    [CAP]    = "00ffff",
    [EMBLEM] = "00ff00",
}

local ANIMTABLE_FUMBLER = {
    --[CHAR_ANIM_RUNNING] = "fumbler_run",
    [CHAR_ANIM_SINGLE_JUMP] = "fumbler_single_jump",
    [_G.charSelect.CS_ANIM_MENU] = "mario_anim_cs_menu",
}
local ANIMTABLE_JUMBLER = {
    [CHAR_ANIM_SINGLE_JUMP] = "jumbler_single_jump",
    [_G.charSelect.CS_ANIM_MENU] = "mario_anim_cs_menu",
}

local HEALTH_METER_MARIO = {
    label = {
        left = get_texture_info("mario-hp-left"),
        right = get_texture_info("mario-hp-right"),
    }
}
local HEALTH_METER_LUIGI = {
    label = {
        left = get_texture_info("char-select-luigi-meter-left"),
        right = get_texture_info("char-select-luigi-meter-right"),
    }
}

--local CAP_FUMBLER = {
--    normal = smlua_model_util_get_id("cap_normal_geo"),
--    wing = smlua_model_util_get_id("cap_wing_geo"),
--    metal = smlua_model_util_get_id("cap_metal_geo"),
--    metalWing = smlua_model_util_get_id("cap_metal_wing_geo")
--}

if _G.charSelectExists then
    CT_FUMBLER = _G.charSelect.character_add("Fumbler", { "What a fumble,,, that's embarassing.",
        ""}, "JerThePear", {r = 255, g = 255, b = 255}, E_MODEL_FUMBLER, CT_MARIO, TEX_FUMBLER)
    CT_JUMBLER = _G.charSelect.character_add("Jumbler", { "The fumbler's icy brother. Where's Jumble Jr?",
        ""}, "JerThePear", {r = 000, g = 255, b = 255}, E_MODEL_JUMBLER, CT_LUIGI, TEX_JUMBLER)
end

local CSloaded = false
local function on_character_select_load()
    _G.charSelect.character_add_palette_preset(E_MODEL_FUMBLER, PALETTE_FUMBLER, "Default")
    _G.charSelect.character_add_palette_preset(E_MODEL_FUMBLER, PALETTE_CHARITY, "Air Rider")
    _G.charSelect.character_add_animations(E_MODEL_FUMBLER, ANIMTABLE_FUMBLER)
    --_G.charSelect.character_add_caps(E_MODEL_FUMBLER, CAP_FUMBLER)
    _G.charSelect.character_add_health_meter(CT_FUMBLER, HEALTH_METER_MARIO)

    _G.charSelect.character_add_palette_preset(E_MODEL_JUMBLER, PALETTE_JUMBLER, "Default")
    _G.charSelect.character_add_animations(E_MODEL_JUMBLER, ANIMTABLE_JUMBLER)
    _G.charSelect.character_add_health_meter(CT_JUMBLER, HEALTH_METER_LUIGI)

    CSloaded = true
end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)