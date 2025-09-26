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
local E_MODEL_HUMBLER = smlua_model_util_get_id('humbler_geo')


-- Textures --
local TEX_FUMBLER = get_texture_info("fumbler_icon")
local TEX_JUMBLER = get_texture_info("jumbler_icon")
local TEX_HUMBLER = get_texture_info("humbler_icon")

local VOICETABLE_HUMBLER = {
    [CHAR_SOUND_OKEY_DOKEY] = 'humbler_herewego.ogg',
	[CHAR_SOUND_LETS_A_GO] = 'humbler_herewego.ogg',
	[CHAR_SOUND_PUNCH_YAH] = {'humbler_punch1.ogg', 'humbler_punch2.ogg'},
	[CHAR_SOUND_PUNCH_WAH] = {'humbler_punch1.ogg', 'humbler_punch2.ogg'},
    [CHAR_SOUND_WAH2] = 'humbler_raha.ogg',
	[CHAR_SOUND_PUNCH_HOO] = 'humbler_kick.ogg',
	[CHAR_SOUND_YAH_WAH_HOO] = {'humbler_ho.ogg', 'humbler_ha.ogg'},
	[CHAR_SOUND_HOOHOO] = {'humbler_yo.ogg', 'humbler_hua.ogg'},
	[CHAR_SOUND_YAHOO_WAHA_YIPPEE] = {'humbler_raha.ogg', 'humbler_blah.ogg'},
	[CHAR_SOUND_UH] = 'humbler_punch2.ogg',
	[CHAR_SOUND_UH2] = 'humbler_grab.ogg',
	[CHAR_SOUND_UH2_2] = nil,
	[CHAR_SOUND_HAHA] = 'humbler_yeah.ogg',
	[CHAR_SOUND_YAHOO] = 'humbler_raha.ogg',
	[CHAR_SOUND_DOH] = 'humbler_punch2.ogg',
	[CHAR_SOUND_WHOA] = 'humbler_wow.ogg',
	[CHAR_SOUND_EEUH] = 'humbler_eeuh.ogg',
	[CHAR_SOUND_WAAAOOOW] = 'humbler_falling.ogg',
	[CHAR_SOUND_TWIRL_BOUNCE] = 'humbler_blah.ogg',
	[CHAR_SOUND_GROUND_POUND_WAH] = 'humbler_raha.ogg',
	[CHAR_SOUND_HRMM] = 'humbler_grab.ogg',
	[CHAR_SOUND_HERE_WE_GO] = 'humbler_blah.ogg',
	[CHAR_SOUND_SO_LONGA_BOWSER] = {'humbler_raha.ogg', 'humbler_herewego.ogg'},
 	[CHAR_SOUND_OOOF] = 'humbler_hurt.ogg',
 	[CHAR_SOUND_OOOF2] = 'humbler_hurt.ogg',
	[CHAR_SOUND_ATTACKED] = 'humbler_hurt.ogg',
	[CHAR_SOUND_PANTING] = 'humbler_pant.ogg',
    [CHAR_SOUND_PANTING_COLD] = 'humbler_pant.ogg',
	[CHAR_SOUND_ON_FIRE] = {'humbler_falling.ogg', 'humbler_woah.ogg'},
	[CHAR_SOUND_SNORING1] = 'humbler_snore1.ogg',
	[CHAR_SOUND_SNORING2] = 'humbler_snore2.ogg',
	[CHAR_SOUND_COUGHING1] = 'humbler_cough.ogg',
	[CHAR_SOUND_COUGHING2] = 'humbler_cough.ogg',
	[CHAR_SOUND_COUGHING3] = 'humbler_cough.ogg',
	[CHAR_SOUND_DYING] = 'humbler_death.ogg',
	[CHAR_SOUND_DROWNING] = 'humbler_drown.ogg',
	[CHAR_SOUND_MAMA_MIA] = 'humbler_mamamia.ogg',
} 

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

local PALETTE_HUMBLER =  {
    [PANTS]  = "5C4176",
    [SHIRT]  = "FFC100",
    [GLOVES] = "333333",
    [SHOES]  = "E894FF",
    [HAIR]   = "8D6734",
    [SKIN]   = "fec179",
    [CAP]    = "AA01BC",
    [EMBLEM] = "FFC100",
}
local PALETTE_PIRATE = {
    [PANTS]  = "1e47c6",
    [SHIRT]  = "ddaa00",
    [GLOVES] = "7f3900",
    [SHOES]  = "ff0000",
    [HAIR]   = "000000",
    [SKIN]   = "fec179",
    [CAP]    = "1e47c6",
    [EMBLEM] = "ddaa00",
}
local PALETTE_BIKER =  {
    [PANTS]  = "ff8590",
    [SHIRT]  = "4a93ff",
    [GLOVES] = "ffff00",
    [SHOES]  = "004779",
    [HAIR]   = "8D6734",
    [SKIN]   = "fec179",
    [CAP]    = "ffff00",
    [EMBLEM] = "0059ff",
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
local ANIMTABLE_HUMBLER = {
    [CHAR_ANIM_RUNNING] = "humbler_run",
    [CHAR_ANIM_START_TWIRL] = "humbler_start_twirl",
    [CHAR_ANIM_TWIRL] = "humbler_twirl",
    [_G.charSelect.CS_ANIM_MENU] = "wario_anim_cs_menu",
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
local HEALTH_METER_WARIO = {
    label = {
        left = get_texture_info("char-select-wario-meter-left"),
        right = get_texture_info("char-select-wario-meter-right"),
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
    CT_HUMBLER = _G.charSelect.character_add("Humbler", { "A real humble guy. Hungry for coins to donate to charities.",
        ""}, "JerThePear", {r = 255, g = 255, b = 000}, E_MODEL_HUMBLER, CT_WARIO, TEX_HUMBLER)
end

local CSloaded = false
local function on_character_select_load()
    _G.charSelect.character_add_palette_preset(E_MODEL_FUMBLER, PALETTE_FUMBLER, "Default")
    _G.charSelect.character_add_palette_preset(E_MODEL_FUMBLER, PALETTE_CHARITY, "Crazy Kicker")
    _G.charSelect.character_add_animations(E_MODEL_FUMBLER, ANIMTABLE_FUMBLER)
    --_G.charSelect.character_add_caps(E_MODEL_FUMBLER, CAP_FUMBLER)
    _G.charSelect.character_add_health_meter(CT_FUMBLER, HEALTH_METER_MARIO)

    _G.charSelect.character_add_palette_preset(E_MODEL_JUMBLER, PALETTE_JUMBLER, "Default")
    _G.charSelect.character_add_animations(E_MODEL_JUMBLER, ANIMTABLE_JUMBLER)
    _G.charSelect.character_add_health_meter(CT_JUMBLER, HEALTH_METER_LUIGI)

    _G.charSelect.character_add_palette_preset(E_MODEL_HUMBLER, PALETTE_HUMBLER, "Default")
    _G.charSelect.character_add_palette_preset(E_MODEL_HUMBLER, PALETTE_PIRATE, "Sailor")
    _G.charSelect.character_add_palette_preset(E_MODEL_HUMBLER, PALETTE_BIKER, "Biker")
    _G.charSelect.character_add_animations(E_MODEL_HUMBLER, ANIMTABLE_HUMBLER)
    _G.charSelect.character_add_health_meter(CT_HUMBLER, HEALTH_METER_WARIO)
    _G.charSelect.character_add_voice(E_MODEL_HUMBLER, VOICETABLE_HUMBLER)


    CSloaded = true
end

local function on_character_sound(m, sound)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_HUMBLER then return _G.charSelect.voice.sound(m, sound) end
end

local function on_character_snore(m)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_HUMBLER then return _G.charSelect.voice.snore(m) end
end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)
hook_event(HOOK_CHARACTER_SOUND, on_character_sound)
hook_event(HOOK_MARIO_UPDATE, on_character_snore)