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
	[CHAR_SOUND_DROWNING] = 'humbler_drowning.ogg',
	[CHAR_SOUND_MAMA_MIA] = 'humbler_mamamia.ogg',
}

local PALETTES_FUMBLER = {
    {
        name = "Default",
        [PANTS]  = "ffffff",
        [SHIRT]  = "ff0000",
        [GLOVES] = "ffffff",
        [SHOES]  = "333333",
        [HAIR]   = "730600",
        [SKIN]   = "fec179",
        [CAP]    = "ffffff",
        [EMBLEM] = "ff0000",
    },{
        name = "Crazy Kicker",
        [PANTS]  = { r = 0xb2, g = 0x28, b = 0x18 },
        [SHIRT]  = { r = 0xff, g = 0xe0, b = 0xe0 },
        [GLOVES] = { r = 0xff, g = 0xff, b = 0xff },
        [SHOES]  = { r = 0x72, g = 0x1c, b = 0x0e },
        [HAIR]   = { r = 0x73, g = 0x06, b = 0x00 },
        [SKIN]   = { r = 0xfe, g = 0xc1, b = 0x79 },
        [CAP]    = { r = 0xff, g = 0xe0, b = 0xe0 },
        [EMBLEM] = { r = 0xff, g = 0x00, b = 0x00 },
    },{
        name = "Toothpaste",
        [PANTS]  = "9dffb8",
        [SHIRT]  = "242282",
        [GLOVES] = "ffffff",
        [SHOES]  = "864200",
        [HAIR]   = "730600",
        [SKIN]   = "fec179",
        [CAP]    = "9dffb8",
        [EMBLEM] = "242282",
    },{
        name = "Apple",
        [PANTS]  = "ff2000",
        [SHIRT]  = "408000",
        [GLOVES] = "a4ff72",
        [SHOES]  = "a4ff72",
        [HAIR]   = "9c0000",
        [SKIN]   = "fec179",
        [CAP]    = "ff2000",
        [EMBLEM] = "408000",
    },{
        name = "Coelco Adam",
        [PANTS]  = "bb4233",
        [SHIRT]  = "4020ff",
        [GLOVES] = "4020ff",
        [SHOES]  = "4020ff",
        [HAIR]   = "4020ff",
        [SKIN]   = "e7a184",
        [CAP]    = "bb4233",
        [EMBLEM] = "4020ff",
    },{
        name = "Jimbus",
        [PANTS]  = "ff0000",
        [SHIRT]  = "000000",
        [GLOVES] = "00ff00",
        [SHOES]  = "ffffff",
        [HAIR]   = "ffff00",
        [SKIN]   = "00ffff",
        [CAP]    = "ffffff",
        [EMBLEM] = "00ffff",
    },{
        name = "Anti-Fumbler",
        [PANTS]  = "111111",
        [SHIRT]  = "880000",
        [GLOVES] = "ff0000",
        [SHOES]  = "ff0000",
        [HAIR]   = "730600",
        [SKIN]   = "fec179",
        [CAP]    = "111111",
        [EMBLEM] = "ff0000",
    }
}

local PALETTES_JUMBLER =  {
    {
        name = "Default",
        [PANTS]  = "00ffff",
        [SHIRT]  = "00ff00",
        [GLOVES] = "2B3A59",
        [SHOES]  = "333333",
        [HAIR]   = "730600",
        [SKIN]   = "fec179",
        [CAP]    = "00ffff",
        [EMBLEM] = "00ff00",
    },{
        name = "Grim Gambler",
        [PANTS]  = "303030",
        [SHIRT]  = "bbbbbb",
        [GLOVES] = "303030",
        [SHOES]  = "721c0e ",
        [HAIR]   = "202020",
        [SKIN]   = "ffd3a2",
        [CAP]    = "bbbbbb",
        [EMBLEM] = "303030",
    },{
        name = "Forest",
        [PANTS]  = "b49320",
        [SHIRT]  = "004400",
        [GLOVES] = "ffff88",
        [SHOES]  = "4f240e",
        [HAIR]   = "730600",
        [SKIN]   = "fec179",
        [CAP]    = "004400",
        [EMBLEM] = "b49320",
    },{
        name = "Atlantic",
        [PANTS]  = "21203b",
        [SHIRT]  = "09c1ff",
        [GLOVES] = "21203b",
        [SHOES]  = "721c0e",
        [HAIR]   = "730600",
        [SKIN]   = "fec179",
        [CAP]    = "09c1ff",
        [EMBLEM] = "0044ff",
    },{
        name = "Retro",
        [PANTS]  = "ffffff",
        [SHIRT]  = "008000",
        [GLOVES] = "004000",
        [SHOES]  = "008000",
        [HAIR]   = "008000",
        [SKIN]   = "ffaa43",
        [CAP]    = "ffffff",
        [EMBLEM] = "008000",
    },{
        name = "Nimbus",
        [PANTS]  = "0000ff",
        [SHIRT]  = "000000",
        [GLOVES] = "00ff00",
        [SHOES]  = "ffffff",
        [HAIR]   = "00ffff",
        [SKIN]   = "ffff00",
        [CAP]    = "ffffff",
        [EMBLEM] = "ffff00",
    }
}

local PALETTES_HUMBLER =  {
    {
        name = "Default",
        [PANTS]  = "5C4176",
        [SHIRT]  = "FFC100",
        [GLOVES] = "333333",
        [SHOES]  = "E894FF",
        [HAIR]   = "8D6734",
        [SKIN]   = "fec179",
        [CAP]    = "AA01BC",
        [EMBLEM] = "FFC100",
    },{
        name = "Biker",
        [PANTS]  = "ff8590",
        [SHIRT]  = "4a93ff",
        [GLOVES] = "ffff00",
        [SHOES]  = "004779",
        [HAIR]   = "8D6734",
        [SKIN]   = "fec179",
        [CAP]    = "ffff00",
        [EMBLEM] = "0059ff",
    },{
        name = "Pirate",
        [PANTS]  = "1e47c6",
        [SHIRT]  = "ddaa00",
        [GLOVES] = "7f3900",
        [SHOES]  = "ff0000",
        [HAIR]   = "000000",
        [SKIN]   = "fec179",
        [CAP]    = "1e47c6",
        [EMBLEM] = "ddaa00",
    }
}

local ANIMTABLE_FUMBLER = {
    --[CHAR_ANIM_RUNNING] = "fumbler_run",
    [_G.charSelect.CS_ANIM_MENU]            = "mario_anim_cs_menu",
    [CHAR_ANIM_SINGLE_JUMP]                 = "fumbler_single_jump",
    [CHAR_ANIM_GROUND_POUND_LANDING]        = "fumbler_gp_end",
    [CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND]    = "fumbler_gp_start",
    [CHAR_ANIM_START_GROUND_POUND]          = "fumbler_gp_start",
    [CHAR_ANIM_GROUND_POUND]                = "fumbler_gp",
}
local ANIMTABLE_JUMBLER = {
    [_G.charSelect.CS_ANIM_MENU]            = "mario_anim_cs_menu",
    [CHAR_ANIM_SINGLE_JUMP]                 = "jumbler_single_jump",
}
local EYES_FUMBLER = {
    [_G.charSelect.CS_ANIM_MENU]            = MARIO_EYES_LOOK_RIGHT,
    [CHAR_ANIM_IDLE_HEAD_LEFT]              = MARIO_EYES_LOOK_RIGHT,
    [CHAR_ANIM_IDLE_HEAD_RIGHT]             = MARIO_EYES_LOOK_LEFT,
    [CHAR_ANIM_GROUND_POUND_LANDING]        = MARIO_EYES_DEAD,
    [CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND]    = MARIO_EYES_DEAD,
    [CHAR_ANIM_START_GROUND_POUND]          = MARIO_EYES_DEAD,
    [CHAR_ANIM_GROUND_POUND]                = MARIO_EYES_DEAD,
    [CHAR_ANIM_SOFT_BACK_KB]                = MARIO_EYES_DEAD,
    [CHAR_ANIM_SOFT_FRONT_KB]               = MARIO_EYES_DEAD,
    [CHAR_ANIM_BACKWARD_KB]                 = MARIO_EYES_DEAD,
    [CHAR_ANIM_FORWARD_KB]                  = MARIO_EYES_DEAD,
    [CHAR_ANIM_BACKWARDS_WATER_KB]          = MARIO_EYES_DEAD,
    [CHAR_ANIM_WATER_FORWARD_KB]            = MARIO_EYES_DEAD,
    [CHAR_ANIM_BACKWARD_AIR_KB]             = MARIO_EYES_DEAD,
    [CHAR_ANIM_AIR_FORWARD_KB]              = MARIO_EYES_DEAD,
    [CHAR_ANIM_FALL_OVER_BACKWARDS]         = MARIO_EYES_DEAD,
    [CHAR_ANIM_STAR_DANCE]                  = function(m, frame) if frame > 37 then return MARIO_EYES_LOOK_UP end end,
    [CHAR_ANIM_WATER_STAR_DANCE]            = function(m, frame) if frame > 68 then return MARIO_EYES_LOOK_UP end end,
}
local HANDS_FUMBLER = {
    [CHAR_ANIM_TRIPLE_JUMP_GROUND_POUND]    = function(m, frame) if frame < 7 then return MARIO_HAND_OPEN end end,
    [CHAR_ANIM_START_GROUND_POUND]          = function(m, frame) if frame < 7 then return MARIO_HAND_OPEN end end,
    [CHAR_ANIM_TWIRL]                       = MARIO_HAND_OPEN,
}

local HEALTH_METER_MARIO = {
    label = {
        left = get_texture_info("texture_power_meter_left_side"),
        right = get_texture_info("texture_power_meter_right_side"),
    },
    pie = {
        [1] = get_texture_info("texture_power_meter_one_segments"),
        [2] = get_texture_info("texture_power_meter_two_segments"),
        [3] = get_texture_info("texture_power_meter_three_segments"),
        [4] = get_texture_info("texture_power_meter_four_segments"),
        [5] = get_texture_info("texture_power_meter_five_segments"),
        [6] = get_texture_info("texture_power_meter_six_segments"),
        [7] = get_texture_info("texture_power_meter_seven_segments"),
        [8] = get_texture_info("texture_power_meter_full"),
    }
}
local HEALTH_METER_LUIGI = {
    label = {
        left = get_texture_info("char_select_luigi_meter_left"),
        right = get_texture_info("char_select_luigi_meter_right"),
    },
    pie = {
        [1] = get_texture_info("char_select_custom_meter_pie1"),
        [2] = get_texture_info("char_select_custom_meter_pie2"),
        [3] = get_texture_info("char_select_custom_meter_pie3"),
        [4] = get_texture_info("char_select_custom_meter_pie4"),
        [5] = get_texture_info("char_select_custom_meter_pie5"),
        [6] = get_texture_info("char_select_custom_meter_pie6"),
        [7] = get_texture_info("char_select_custom_meter_pie7"),
        [8] = get_texture_info("char_select_custom_meter_pie8"),
    }
}

--local CAP_FUMBLER = {
--    normal = smlua_model_util_get_id("cap_normal_geo"),
--    wing = smlua_model_util_get_id("cap_wing_geo"),
--    metal = smlua_model_util_get_id("cap_metal_geo"),
--    metalWing = smlua_model_util_get_id("cap_metal_wing_geo")
--}

if _G.charSelectExists then
    CT_FUMBLER = _G.charSelect.character_add("Fumbler", "What a fumble,,, that's embarassing.", "JerThePear", {r = 255, g = 255, b = 255}, E_MODEL_FUMBLER, CT_MARIO, TEX_FUMBLER)
    CT_JUMBLER = _G.charSelect.character_add("Jumbler", "The Fumbler's icy brother. Where's Jumble Jr?", "JerThePear", {r = 000, g = 255, b = 255}, E_MODEL_JUMBLER, CT_LUIGI, TEX_JUMBLER)
end

local CSloaded = false
local function on_character_select_load()
    for i = 1, #PALETTES_FUMBLER do
        _G.charSelect.character_add_palette_preset(E_MODEL_FUMBLER, PALETTES_FUMBLER[i], PALETTES_FUMBLER[i].name)
	end
    _G.charSelect.character_add_animations(E_MODEL_FUMBLER, ANIMTABLE_FUMBLER, EYES_FUMBLER, HANDS_FUMBLER)
    --_G.charSelect.character_add_voice(E_MODEL_FUMBLER, VOICETABLE_FUMBLER)
    --_G.charSelect.character_add_caps(E_MODEL_FUMBLER, CAP_FUMBLER)
    _G.charSelect.character_add_health_meter(CT_FUMBLER, HEALTH_METER_MARIO)

    for i = 1, #PALETTES_JUMBLER do
        _G.charSelect.character_add_palette_preset(E_MODEL_JUMBLER, PALETTES_JUMBLER[i], PALETTES_JUMBLER[i].name)
	end
    _G.charSelect.character_add_animations(E_MODEL_JUMBLER, ANIMTABLE_JUMBLER, EYES_FUMBLER)
    _G.charSelect.character_add_health_meter(CT_JUMBLER, HEALTH_METER_LUIGI)

    if CT_J_WARIO ~= nil then
        
    local ANIMTABLE_HUMBLER = {
        [CHAR_ANIM_RUNNING] = "humbler_run",
        [CHAR_ANIM_SINGLE_JUMP] = "JWAR_SINGLE_JUMP",
        [MARIO_ANIM_LAND_FROM_SINGLE_JUMP] = "JWAR_SINGLE_JUMP_LAND",
        [CHAR_ANIM_START_TWIRL] = "JWAR_START_TWIRL",
        [CHAR_ANIM_TWIRL] = "JWAR_TWIRL",
        [_G.charSelect.CS_ANIM_MENU] = "JWAR_MENU",
    }

    for i = 1, #PALETTES_HUMBLER do
        _G.charSelect.character_add_palette_preset(E_MODEL_HUMBLER, PALETTES_HUMBLER[i], PALETTES_HUMBLER[i].name)
	end
    _G.charSelect.character_add_animations(E_MODEL_HUMBLER, ANIMTABLE_HUMBLER)
    _G.charSelect.character_add_voice(E_MODEL_HUMBLER, VOICETABLE_HUMBLER)
    _G.charSelect.character_add_costume(CT_J_WARIO, "Humbler", { "A real humble guy. Hungry for coins to donate to charities.",
        ""}, "JerThePear", {r = 255, g = 255, b = 000}, E_MODEL_HUMBLER, CT_WARIO, TEX_HUMBLER)
    end

    CSloaded = true
end

local function on_character_sound(m, sound)
    if not CSloaded then return end
    --if _G.charSelect.character_get_voice(m) == VOICETABLE_FUMBLER then return _G.charSelect.voice.sound(m, sound) end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_HUMBLER then return _G.charSelect.voice.sound(m, sound) end
end

local function on_character_snore(m)
    if not CSloaded then return end
    --if _G.charSelect.character_get_voice(m) == VOICETABLE_FUMBLER then return _G.charSelect.voice.snore(m) end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_HUMBLER then return _G.charSelect.voice.snore(m) end
end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)
hook_event(HOOK_CHARACTER_SOUND, on_character_sound)
hook_event(HOOK_MARIO_UPDATE, on_character_snore)