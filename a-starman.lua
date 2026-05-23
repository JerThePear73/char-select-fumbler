gStarmanStates = {}
for i = 0, (MAX_PLAYERS - 1) do
    gStarmanStates[i] = {
        hasStarman = false,
        starmanTimer = 0,
        playerR = 255,
        playerG = 0,
        playerB = 0,
    }
end

local MUSIC_STARMAN = audio_stream_load("starman.ogg")

--local E_MODEL_RAINBOW_STAR = smlua_model_util_get_id("rainbow_star_geo")

-- BEHAVIOURS --

function bhv_rainbow_star_init(o)
    local m = gMarioStates[0]

    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_play_sound_2(SOUND_GENERAL_COIN_SPURT)
    spawn_mist_particles()
    
    obj_scale(o, 0.7)
    o.hitboxRadius = 50
    o.hitboxHeight = 50
    o.oIntangibleTimer = 0
    o.oGravity = 2
    o.oFriction = 1

    o.oFaceAngleYaw = m.faceAngls.y
    o.oForwardVel = 15
    o.oVelY = 10

    o.oBuoyancy = 0.9
    o.hitboxDownOffset = 20
    o.oDrawingDistance = 4000
    o.oGraphYOffset = 0
end

function bhv_rainbow_star_loop(o)
    object_step()
    load_object_collision_model()
    local m = gMarioStates[0]
    local s = gStarmanStates[0]
    local range = math.random(-25, 25)

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x500
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0

    cur_obj_update_floor_and_walls()
    if o.oPosY < (o.oFloorHeight + 55) then
        o.oVelY = 30
    end

    spawn_non_sync_object(
        id_bhvSparkle, 
        E_MODEL_SPARKLES_ANIMATION, 
        (o.oPosX + range),
        (o.oPosY + range - 25),
        (o.oPosZ + range),
        nil)

    if obj_check_hitbox_overlap(m.marioObj, o) then 
        m.capTimer = 30*30
        obj_mark_for_deletion(o)
        cur_obj_play_sound_2(SOUND_MENU_STAR_SOUND)
        play_character_sound(m, CHAR_SOUND_HERE_WE_GO)
        s.hasStarman = true
        s.starmanTimer = 0
        --m.flags = m.flags & ~MARIO_WING_CAP
        --m.flags = m.flags & ~MARIO_VANISH_CAP
        --m.flags = m.flags & ~MARIO_METAL_CAP
        --play_cap_music(0)
    end
end

id_bhvRainbowStar = hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhv_rainbow_star_init, bhv_rainbow_star_loop)

-- FUNCTIONS --

local function get_cap_volume()
    local m = gMarioStates[0]
    local s = gStarmanStates[0]

    if _G.charSelectExists and _G.charSelect.is_menu_open() then
        return 0
    end

    if is_game_paused() or m.action == ACT_START_SLEEPING or m.action == ACT_SLEEPING or m.actionTimer < 80 and
        (m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT or m.action == ACT_STAR_DANCE_WATER) then
        if m.capTimer < (3 * 30) then
            return (m.capTimer / 90) * 0.2
        else
            return 0.2
        end
    end

    if s.hasStarman then
        if m.capTimer < (3 * 30) then
            return m.capTimer / 90
        end
    end

    return 1
end

local function reset_on_warp() 
    local s = gStarmanStates[0]
    local np = gNetworkPlayers[0]

    if s.hasStarman then
        network_player_reset_override_palette(np)

        s.hasStarman = false
        s.starmanTimer = 0
    end
end
hook_event(HOOK_ON_WARP, reset_on_warp)

-- UPDATES --

local function mario_update(m)
    local s = gStarmanStates[m.playerIndex]
    local np = gNetworkPlayers[m.playerIndex]
    --local rate = 20
    local offset1 = 128
    local E_MODEL_CLONE_PARTICLE = obj_get_model_id_extended(m.marioObj)

    --if m.controller.buttonPressed & Y_BUTTON ~= 0 then
    --    spawn_sync_object(id_bhvRainbowStar, E_MODEL_RAINBOW_STAR, m.pos.x, (m.pos.y + 250), m.pos.z, 
    --        function(o)
    --            obj_scale(o, 1)
    --        end)
    --end

    if m.capTimer < 2 and m.capTimer > 0 then
        s.hasStarman = false

        if m.action == ACT_WALKING then
            m.marioObj.header.gfx.animInfo.animID = -1
        end

        network_player_reset_override_palette(np)
    else
        if s.hasStarman then
            local rate = 85
            local max = 255 - rate
            local min = 0 + rate
            if s.playerR == 255 and s.playerG ~= 255 then
                if s.playerB >= min then
                    s.playerB = s.playerB - rate
                elseif s.playerG <= max then
                    s.playerG = s.playerG + rate
                end
            elseif s.playerG == 255 and s.playerB ~= 255 then
                if s.playerR >= min then
                    s.playerR = s.playerR - rate
                elseif s.playerB <= max then
                    s.playerB = s.playerB + rate
                end
            elseif s.playerB == 255 and s.playerR ~= 255 then
                if s.playerG >= min then
                    s.playerG = s.playerG - rate
                elseif s.playerR <= max then
                    s.playerR = s.playerR + rate
                end
            end
            network_player_set_override_palette_color(np, GLOVES,   {r = s.playerR, g = s.playerG, b = s.playerB})
            network_player_set_override_palette_color(np, EMBLEM,   {r = s.playerR, g = s.playerG, b = s.playerB})
            network_player_set_override_palette_color(np, CAP,      {r = s.playerR, g = s.playerG, b = s.playerB})
            network_player_set_override_palette_color(np, HAIR,     {r = s.playerR, g = s.playerG, b = s.playerB})
            network_player_set_override_palette_color(np, SKIN,     {r = s.playerR, g = s.playerG, b = s.playerB})
            network_player_set_override_palette_color(np, SHIRT,    {r = s.playerR, g = s.playerG, b = s.playerB})
            network_player_set_override_palette_color(np, PANTS,    {r = s.playerR, g = s.playerG, b = s.playerB})
            network_player_set_override_palette_color(np, SHOES,    {r = s.playerR, g = s.playerG, b = s.playerB})

            m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
            m.flags = m.flags | MARIO_METAL_CAP

            if m.action == ACT_WALKING then
                m.marioBodyState.torsoAngle.x = 0

                if m.forwardVel > 45 then
                    smlua_anim_util_set_animation(m.marioObj, "woke_run")
                    m.marioBodyState.handState = MARIO_HAND_OPEN
                elseif smlua_anim_util_get_current_animation_name(m.marioObj) == "woke_run" then
                    m.marioObj.header.gfx.animInfo.animID = -1
                end
            end

            m.peakHeight = m.pos.y

            if (m.action == ACT_WALKING or m.action == ACT_SPECIAL_TRIPLE_JUMP or m.action == ACT_METAL_WATER_WALKING) and m.forwardVel < 60 and m.forwardVel > 0 then
                m.forwardVel = m.forwardVel * 1.15
            end
        end
    end

end
hook_event(HOOK_MARIO_UPDATE, mario_update)

local function mario_set_action(m)
    local s = gStarmanStates[m.playerIndex]

    if s.hasStarman then
        if m.action == ACT_LONG_JUMP then
            set_mario_action(m, ACT_SPECIAL_TRIPLE_JUMP, 0)
            m.vel.y = 40
        end
    end
end
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_set_action)

function themes()
    local m = gMarioStates[0]
    local s = gStarmanStates[0]
   
    if s.starmanTimer > 0 then
        stop_cap_music()
        play_cap_music(0)
    elseif s.starmanTimer == 0 and (m.flags & MARIO_WING_CAP) == 0 and (m.flags & MARIO_VANISH_CAP) == 0 and (m.flags & MARIO_METAL_CAP) == 0 then
        stop_cap_music()
    end

    if s.hasStarman then
        s.starmanTimer = s.starmanTimer + 1
        audio_stream_play(MUSIC_STARMAN, false, get_cap_volume())
    else
        audio_stream_stop(MUSIC_STARMAN)
        s.starmanTimer = 0
    end
end
hook_event(HOOK_UPDATE, themes)

local function mario_int(m, o, type)
    local s = gStarmanStates[m.playerIndex]
    if not s.hasStarman then return end

    if obj_has_behavior_id(o, id_bhvBobomb) ~= 0 then
        play_sound(SOUND_ACTION_BOUNCE_OFF_OBJECT, m.marioObj.header.gfx.cameraToObject)
        o.oMoveAngleYaw = m.faceAngle.y
        o.oPosY = o.oPosY + 100
        o.oAction = BOBOMB_ACT_LAUNCHED
        o.oVelY = 40
        o.oForwardVel = 5
        o.oBobombFuseLit = false
    end

    if obj_has_behavior_id(o, id_bhvBreakableBoxSmall) ~= 0 then
        o.oMoveAngleYaw = m.faceAngle.y
        o.oVelY = 30
        o.oForwardVel = 40
    end

    if obj_has_behavior_id(o, id_bhvChuckya) ~= 0 then
        o.oMoveAngleYaw = m.faceAngle.y
        o.oAction = 2
        o.oVelY = 30
        o.oForwardVel = 40
    end

    if obj_has_behavior_id(o, id_bhvMrBlizzard) ~= 0 then
        o.oFaceAngleRoll = 0x3000
        o.oMrBlizzardHeldObj = nil
        o.prevObj = o.oMrBlizzardHeldObj
        obj_mark_for_deletion(o)
        play_sound(SOUND_OBJ_POKEY_DEATH, m.marioObj.header.gfx.cameraToObject)
        spawn_mist_particles()
    end

    if obj_has_behavior_id(o, id_bhvHeaveHo) ~= 0 then
        obj_mark_for_deletion(o)
        play_sound(SOUND_GENERAL_BREAK_BOX, m.marioObj.header.gfx.cameraToObject)
        spawn_triangle_break_particles(30, 138, 3.0, 4)
        spawn_mist_particles_variable(20, 50, 30)
        spawn_non_sync_object(
            id_bhvMrIBlueCoin,
            E_MODEL_BLUE_COIN,
            o.oPosX, o.oPosY, o.oPosZ,
            nil)
        m.action = ACT_IDLE
    end
    
    if (type & INTERACT_BULLY) ~= 0 then
        o.oVelY = 30
        o.oForwardVel = 50
    end

    if obj_has_behavior_id(o, id_bhvChainChomp) ~= 0 then
        obj_mark_for_deletion(o)
        play_sound(SOUND_GENERAL_BREAK_BOX, m.marioObj.header.gfx.cameraToObject)
        spawn_triangle_break_particles(30, 138, 5, 4)
        spawn_mist_particles_variable(50, 100, 30)
        spawn_non_sync_object(
            id_bhvTenCoinsSpawn,
            E_MODEL_NONE,
            o.oPosX, o.oPosY + 200, o.oPosZ,
            nil)
    end
end
hook_event(HOOK_ON_INTERACT, mario_int)