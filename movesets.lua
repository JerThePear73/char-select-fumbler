local ACT_MOVING_GP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_GP_CANCEL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_GP_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
local ACT_CUSTOM_LONGJUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_FUMBLER_SPIN = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

local E_MODEL_ICE_SPARKLES = smlua_model_util_get_id('ice_sparkle_geo')
local TEX_FUMBLER_COMBO = get_texture_info("fumbler_combo")
local SOUND_FUMBLER_COMBO = audio_stream_load("fumbler_combo_1.ogg")
local SOUND_FUMBLER_COMBO_COMPLETE = audio_stream_load("fumbler_combo_2.ogg")

local stepFrame = 5
local ANGLE_QUEUE_SIZE = 9
local SPIN_TIMER_SUCCESSFUL_INPUT = 4

local gExtraStates = {}
for i = 0, MAX_PLAYERS - 1 do
    gExtraStates[i] = {
        prevActionTimer = 0,
        canGPCancel = true,
        canTwirl = true,
        extActionArg = 0,
        particleArg = 0,
        perfectTimer = 0,
        gpJumpType = 0,
        combo = 0,
        comboTimer = 0,
        opacity = 100,
        hudScaleX = 0,
        hudScaleY = 0,
        hudShakeX = 0,
        hudShakeY = 0,
        gfxX = 0,
        gfxY = 0,
        gfxZ = 0,
        stickLastAngle = 0,
        spinDirection = 0,
        spinBufferTimer = 0,
        spinInput = 0,
        lastStickMag = 0,
    }
    local e = gExtraStates[i]
    e.angleDeltaQueue = {}
    for j=0,(ANGLE_QUEUE_SIZE-1) do e.angleDeltaQueue[j] = 0 end
end

-- BEHAVIOURS --

local function convert_s16(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

local function pause_check()
    local m = gMarioStates[0]

    if m.action == ACT_START_SLEEPING or m.action == ACT_SLEEPING or m.actionTimer < 80 and
        (m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT or m.action == ACT_STAR_DANCE_WATER) then
        return 0.2
    end

    if is_game_paused() or _G.charSelect.is_menu_open() then
        return 0
    end

    return 1
end

local function spawn_fumbler_particles(m)
    local e = gExtraStates[m.playerIndex]
    local range = math.random(-30, 30)
    spawn_non_sync_object(id_bhvCoinSparkles, e.particleArg, m.pos.x + range, m.pos.y + range, m.pos.z + range,
            --- @param o Object
            function(o)
                obj_scale(o, 2)
            end)
end

local function do_fumbler_combo()
    local e = gExtraStates[0]
    e.combo = e.combo + 1
    e.comboTimer = 40
    e.opacity = 100
    e.hudScaleX = 0.5
    e.hudScaleY = -0.5

    if e.combo == 7 then
        audio_stream_play(SOUND_FUMBLER_COMBO_COMPLETE, true, pause_check())
    else
        local pitch = 1
        audio_stream_play(SOUND_FUMBLER_COMBO, true, pause_check())
        if e.combo > 7 then
            pitch = 1.4
        else
            pitch = 1 + ((e.combo - 1)/20)
        end
        audio_stream_set_frequency(SOUND_FUMBLER_COMBO, pitch)
    end
end

local function do_fumble()
    local m = gMarioStates[0]
    local e = gExtraStates[0]
    e.combo = -1
    e.opacity = 100
    e.comboTimer = 20
    e.hudScaleX = -0.5
    e.hudScaleY = 0.5

    play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
end

function mario_update_spin_input(m)
    local e = gExtraStates[m.playerIndex]
    local rawAngle = atan2s(-m.controller.stickY, m.controller.stickX)
    e.spinInput = 0

    -- prevent issues due to the frame going out of the dead zone registering the last angle as 0
    if e.lastStickMag > 60 and m.controller.stickMag > 60 then
        local angleOverFrames = 0
        local thisFrameDelta = 0
        local i = 0

        local newDirection = e.spinDirection
        local signedOverflow = 0

        if rawAngle < e.stickLastAngle then
            if e.stickLastAngle - rawAngle > 0x8000 then
                signedOverflow = 1
            end
            if signedOverflow ~= 0 then
                newDirection = 1
            else
                newDirection = -1
            end
        elseif rawAngle > e.stickLastAngle then
            if rawAngle - e.stickLastAngle > 0x8000 then
                signedOverflow = 1
            end
            if signedOverflow ~= 0 then
                newDirection = -1
            else
                newDirection = 1
            end
        end

        if e.spinDirection ~= newDirection then
            for i=0,(ANGLE_QUEUE_SIZE-1) do
                e.angleDeltaQueue[i] = 0
            end
            e.spinDirection = newDirection
        else
            for i=(ANGLE_QUEUE_SIZE-1),1,-1 do
                e.angleDeltaQueue[i] = e.angleDeltaQueue[i-1]
                angleOverFrames = angleOverFrames + e.angleDeltaQueue[i]
            end
        end

        if e.spinDirection < 0 then
            if signedOverflow ~= 0 then
                thisFrameDelta = math.floor((1.0*e.stickLastAngle + 0x10000) - rawAngle)
            else
                thisFrameDelta = e.stickLastAngle - rawAngle
            end
        elseif e.spinDirection > 0 then
            if signedOverflow ~= 0 then
                thisFrameDelta = math.floor(1.0*rawAngle + 0x10000 - e.stickLastAngle)
            else
                thisFrameDelta = rawAngle - e.stickLastAngle
            end
        end

        e.angleDeltaQueue[0] = thisFrameDelta
        angleOverFrames = angleOverFrames + thisFrameDelta

        if angleOverFrames >= 0xA000 then
            e.spinBufferTimer = SPIN_TIMER_SUCCESSFUL_INPUT
        end


        -- allow a buffer after a successful input so that you can switch directions
        if e.spinBufferTimer > 0 then
            e.spinInput = 1
            e.spinBufferTimer = e.spinBufferTimer - 1
        end
    else
        e.spinDirection = 0
        e.spinBufferTimer = 0
    end

    e.stickLastAngle = rawAngle
    e.lastStickMag = m.controller.stickMag
end

-- CUSTOM ACTIONS --

local function act_moving_gp(m)
    local e = gExtraStates[m.playerIndex]

    if m.actionTimer == 0 then
        m.vel.y = 40
        m.forwardVel = m.forwardVel + 4
        play_character_sound(m, CHAR_SOUND_WAH2)
    end

    spawn_fumbler_particles(m)

    if m.actionTimer == 5 then -- spin sound
        play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end

    local landingAction = ACT_BUTT_SLIDE
    if m.input & INPUT_Z_DOWN ~= 0 then
        landingAction = ACT_GROUND_POUND_LAND
    end

    local stepResult = common_air_action_step(m, landingAction, MARIO_ANIM_TRIPLE_JUMP_GROUND_POUND, AIR_STEP_NONE)
    if stepResult == AIR_STEP_LANDED then
        if should_get_stuck_in_ground(m) ~= 0 then
            queue_rumble_data_mario(m, 5, 80)
            play_character_sound(m, CHAR_SOUND_OOOF2)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0)
        else
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
            if e.particleArg == E_MODEL_RED_FLAME then
                check_fall_damage(m, ACT_HARD_BACKWARD_GROUND_KB)
            end
        end
        set_camera_shake_from_hit(SHAKE_GROUND_POUND)
    end
    
    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_MOVING_GP, act_moving_gp, INT_GROUND_POUND)

local function act_gp_cancel(m)
    local e = gExtraStates[m.playerIndex]
    local pitch = 90 - m.forwardVel*1.3

    if m.actionTimer == 0 then
        m.faceAngle.y = m.intendedYaw
        m.vel.y = (e.prevActionTimer*3) + 15
        m.forwardVel = (16 - e.prevActionTimer)*4
        if e.prevActionTimer < 10 then
            e.extActionArg = 0
            play_character_sound(m, CHAR_SOUND_HOOHOO)
        else
            e.extActionArg = 1
            play_character_sound(m, CHAR_SOUND_TWIRL_BOUNCE)
            play_sound(SOUND_GENERAL_BOING1, m.marioObj.header.gfx.cameraToObject)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        end
    end
    if m.actionTimer > 0 then
        local stepResult = common_air_action_step(m, ACT_DIVE_SLIDE, MARIO_ANIM_DIVE, AIR_STEP_NONE)
    end

    if stepResult == AIR_STEP_HIT_WALL then
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
    end

    if e.extActionArg == 1 then
        spawn_fumbler_particles(m)
        if m.input & INPUT_A_PRESSED ~= 0 and m.vel.y < 0 then
            if m.vel.y < -40 then
                play_sound(SOUND_GENERAL_BOING2, m.marioObj.header.gfx.cameraToObject)
            end
            m.action = ACT_BACKFLIP
            m.vel.y = m.vel.y/-1.5
        end
    end

    if m.vel.y > ((0 - pitch)/1.5) then
        pitch = 0 - m.vel.y * 1.5
    end
    m.marioObj.header.gfx.angle.x = degrees_to_sm64(pitch)
    
    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_GP_CANCEL, act_gp_cancel)

local function act_gp_jump(m)
    local e = gExtraStates[0]

    if m.actionTimer == 0 then
        m.vel.y = 60
        play_character_sound(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE)
        e.gfxY = 0 - 0x11000
    else
        common_air_action_step(m, ACT_JUMP_LAND, MARIO_ANIM_SINGLE_JUMP, AIR_STEP_CHECK_LEDGE_GRAB)
        if m.vel.y > 10 then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
        end
        
        if m.input & INPUT_B_PRESSED ~= 0 then
            if m.forwardVel < 30 then
                set_mario_action(m, ACT_JUMP_KICK, 0)
            else
                set_mario_action(m, ACT_DIVE, 0)
            end
        elseif m.input & INPUT_Z_PRESSED ~= 0 then
            set_mario_action(m, ACT_GROUND_POUND, 0)
        end
    end

    e.gfxY = e.gfxY * 0.85
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfxY
    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_GP_JUMP, act_gp_jump)

local function act_custom_longjump(m)
    local e = gExtraStates[0]

    if m.actionTimer == 0 then
        play_character_sound(m, CHAR_SOUND_YAHOO)
        if m.forwardVel < 35 then
            m.forwardVel = approach_f32(m.forwardVel, 0.0, 0.35, 0.35)
        end
    end

    m.vel.y = m.vel.y + 2
    --m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x100, 0x100)

    common_air_action_step(m, ACT_LONG_JUMP_LAND, CHAR_ANIM_SLOW_LONGJUMP, AIR_STEP_CHECK_LEDGE_GRAB)

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_CUSTOM_LONGJUMP, act_custom_longjump)

local function act_fumbler_spin(m)
    local e = gExtraStates[0]

    if m.actionTimer == 0 then
        play_character_sound(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE)
        m.vel.y = 10
        e.gfxY = 0
        e.gfxZ = 0.5
    end

    m.vel.y = m.vel.y + 2.5
    --m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x100, 0x100)

    common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_TWIRL, AIR_STEP_CHECK_LEDGE_GRAB)
    if e.canGPCancel and m.input & INPUT_B_PRESSED ~= 0 then
        set_mario_action(m, ACT_DIVE, 0)
        m.faceAngle.y = m.intendedYaw
        m.forwardVel = 20
        e.canGPCancel = false
    elseif m.actionTimer >= 30 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end

    if (m.actionTimer % 3) == 0 and m.actionTimer > 0 then
        play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end

    e.gfxY = e.gfxY + 0x3000
    e.gfxZ = e.gfxZ * 0.8
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfxY
    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_FUMBLER_SPIN, act_fumbler_spin)

-- UPDATES --

local fumblerSpinTable = {
    [ACT_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_CUSTOM_LONGJUMP] = true,
    [ACT_FREEFALL] = true,
    [ACT_DIVE] = true,
    [ACT_JUMP_KICK] = true,
    [ACT_GROUND_POUND] = true,
    [ACT_GP_JUMP] = true,
    [ACT_WALL_KICK_AIR] = true,
    [ACT_FORWARD_ROLLOUT] = true,
}

local perfectActions = {
    [ACT_LEDGE_GRAB] = true,
    [ACT_JUMP_LAND] = true,
    [ACT_FREEFALL_LAND] = true,
}

local comboEndActions = {
    [ACT_WATER_ACTION_END] = true,
    [ACT_WATER_DEATH] = true,
    [ACT_WATER_IDLE] = true,
    [ACT_WATER_JUMP] = true,
    [ACT_WATER_PLUNGE] = true,
    [ACT_WATER_PUNCH] = true,
    [ACT_WATER_SHELL_SWIMMING] = true,
    [ACT_WATER_SHOCKED] = true,
    [ACT_WATER_THROW] = true,
    [ACT_METAL_WATER_FALLING] = true,
    [ACT_METAL_WATER_FALL_LAND] = true,
    [ACT_METAL_WATER_JUMP] = true,
    [ACT_METAL_WATER_JUMP_LAND] = true,
    [ACT_METAL_WATER_STANDING] = true,
    [ACT_METAL_WATER_WALKING] = true,
}

local function fumbler_update(m)
    local e = gExtraStates[m.playerIndex]
    
    e.particleArg = E_MODEL_RED_FLAME
    mario_update_spin_input(m)

    if m.pos.y == m.floorHeight then
        e.canGPCancel = true
        e.canTwirl = true
    end

    -- dust
        if get_global_timer() % stepFrame == 0 and m.forwardVel > 29 and m.action == ACT_WALKING then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
        end
    -- sprungflip (moving gp)
        if m.action == ACT_DIVE_SLIDE and m.input & INPUT_Z_PRESSED ~= 0 then
            set_mario_action(m, ACT_MOVING_GP, 0)
        end
    -- GP cancel
        if m.action == ACT_GROUND_POUND and m.input & INPUT_B_PRESSED ~= 0 then
            if e.canGPCancel then
                m.faceAngle.y = m.intendedYaw
                m.forwardVel = 20
                m.vel.y = 20
                set_mario_action(m, ACT_DIVE, 0)
                play_sound(SOUND_GENERAL_SWISH_WATER, m.marioObj.header.gfx.cameraToObject)
                e.canGPCancel = false
            else
                spawn_mist_particles_variable(5, 0, 8)
                m.vel.y = 15
                set_mario_action(m, ACT_FORWARD_AIR_KB, 0)
                do_fumble()
            end
        end
    -- GP jump
        if m.action == ACT_GROUND_POUND_LAND and m.input & INPUT_A_PRESSED ~= 0 then
            if e.gpJumpType == 1 then
                set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
                m.forwardVel = 50
                m.vel.y = 35
                m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
            else
                m.pos.y = m.pos.y + 20
                set_mario_action(m, ACT_GP_JUMP, 0)
                --m.faceAngle.y = m.intendedYaw
            end
        end
    -- lava boost particles
        if m.action == ACT_LAVA_BOOST and m.vel.y > 30 then
            spawn_fumbler_particles(m)
        end
    -- sliding
        if  m.action == ACT_SLIDE_KICK_SLIDE or m.action == ACT_BUTT_SLIDE then
            m.slideVelX = m.slideVelX * 1.02
            m.slideVelZ = m.slideVelZ * 1.02
        end
        if m.action == ACT_GROUND_POUND_LAND and m.floor.normal.y < 0.9 then
            set_mario_action(m, ACT_BUTT_SLIDE, 0)
        end
        if m.action == ACT_BUTT_SLIDE and m.prevAction == ACT_GROUND_POUND_LAND and m.actionTimer < 2 and m.forwardVel < 100 then
            m.slideVelX = (m.slideVelX/m.floor.normal.y)*4
            m.slideVelZ = (m.slideVelZ/m.floor.normal.y)*4
        end
    --wing cap
        if m.action == ACT_DIVE and m.prevAction ~= ACT_GROUND_POUND and m.flags & MARIO_WING_CAP ~= 0 and m.vel.y < 0 and m.pos.y > (m.floorHeight + 100) then
            m.action = ACT_FLYING
            e.gfxZ = 0x10000
        end
        if m.action == ACT_FLYING then
            e.gfxZ = math.lerp(e.gfxZ, 0, 0.1)
            m.marioObj.header.gfx.angle.z = m.marioObj.header.gfx.angle.z + e.gfxZ
        end
    -- GP fix
        if m.action == ACT_GROUND_POUND then
            m.marioObj.header.gfx.angle.y = m.faceAngle.y
        end
    -- firsties
        if m.action == ACT_WALL_KICK_AIR and (m.prevAction == ACT_AIR_HIT_WALL or m.prevAction == ACT_WALL_KICK_AIR) then
            if m.marioObj.header.gfx.animInfo.animFrame < 10 then
                m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
                if m.marioObj.header.gfx.animInfo.animFrame == -1 then
                    e.gfxY = 0 - 0x11000
                    do_fumbler_combo()
                end
            end
            e.gfxY = e.gfxY * 0.85
            m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfxY
        end
    -- fast climb
        if m.action == ACT_LEDGE_GRAB then
            if e.perfectTimer < 1 and m.input & INPUT_A_PRESSED ~= 0 then
                set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
                do_fumbler_combo()
                m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
                m.forwardVel = 30
            end
        end
    -- double jump
        if m.action == ACT_DOUBLE_JUMP then
            if m.vel.y > 60 then
                m.actionArg = 2
                e.gfxY = 0x15000
            end
            if e.gfxY > 0x200 and m.actionArg == 2 then
                spawn_fumbler_particles(m)
                e.gfxY = e.gfxY * 0.8
                m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfxY

                if e.gfxY == 0x15000 * 0.8 and m.prevAction == ACT_FREEFALL_LAND then
                    do_fumbler_combo()
                end
            end
        end
    -- slide kick
        if m.action == ACT_SLIDE_KICK and m.actionArg == 2 then
            e.gfxX = e.gfxX * 0.8
            e.gfxY = e.gfxY * 0.8
            m.marioObj.header.gfx.angle.x = e.gfxX
            m.marioObj.header.gfx.pos.y = m.pos.y + e.gfxY
            m.marioObj.header.gfx.animInfo.animFrame = 7
            m.marioObj.header.gfx.animInfo.animAccel = 0
            spawn_fumbler_particles(m)
        end
    -- spin
        if e.spinInput ~= 0 and fumblerSpinTable[m.action] and e.canTwirl then
            set_mario_action(m, ACT_FUMBLER_SPIN, 0)
            e.canTwirl = false
        end
        if m.action == ACT_FUMBLER_SPIN then
            m.marioObj.header.gfx.scale.x = 1 + (e.gfxZ * 2)
            m.marioObj.header.gfx.scale.y = 1 - e.gfxZ
            m.marioObj.header.gfx.scale.z = 1 + (e.gfxZ * 2)
            m.marioObj.header.gfx.pos.y = m.pos.y + (e.gfxZ * 100)
        end



    -- perfect timer
        if perfectActions[m.action] then
            e.perfectTimer = e.perfectTimer + 1
        else
            e.perfectTimer = 0
        end
    -- hud calcs
        if e.comboTimer > 0 then
            if (m.pos.y == m.floorHeight) then
                e.comboTimer = e.comboTimer - 1
            end
            if comboEndActions[m.action] then
                e.comboTimer = 0
            end
        else
            if e.opacity > 5 then
                e.opacity = math.lerp(e.opacity, 0, 0.3)
            elseif e.opacity <= 5 then
                e.opacity = 0
                e.combo = 0
            end
        end
        e.hudScaleX = math.lerp(e.hudScaleX, 0, 0.3)
        e.hudScaleY = math.lerp(e.hudScaleY, 0, 0.3)
        if e.combo >= 7 then
            e.hudShakeX = math.random(6 - e.combo, -6 + e.combo)
            e.hudShakeY = math.random(6 - e.combo, -6 + e.combo)
        end
end

local function fumbler_set_action(m)
    local e = gExtraStates[m.playerIndex]

    e.perfectTimer = 0

    -- zooted speed kick
        if m.action == ACT_JUMP_KICK and m.forwardVel > 40 then
            play_sound(SOUND_GENERAL_COIN_SPURT, m.marioObj.header.gfx.cameraToObject)
            do_fumbler_combo()
            m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
            m.forwardVel = m.forwardVel + 10
        elseif m.action == ACT_DIVE and m.input & INPUT_A_DOWN ~= 0 and m.input & INPUT_B_PRESSED ~= 0 and m.pos.y == m.floorHeight and m.intendedMag < 32 then
            set_mario_action(m, ACT_FORWARD_GROUND_KB, 0)
            do_fumble()
        end
    -- zooted lava boost
        if m.action == ACT_LAVA_BOOST and m.prevAction == ACT_GROUND_POUND_LAND then
            play_sound(SOUND_GENERAL2_BOBOMB_EXPLOSION, m.marioObj.header.gfx.cameraToObject)
            m.vel.y = m.vel.y + 10
        end
    -- replace metal fall
        if m.action == ACT_WATER_PLUNGE and m.flags & MARIO_METAL_CAP ~= 0 then
            m.action = ACT_METAL_WATER_JUMP
            play_sound(SOUND_OBJ_DIVING_INTO_WATER, m.marioObj.header.gfx.cameraToObject)
            m.particleFlags = m.particleFlags | PARTICLE_WATER_SPLASH | PARTICLE_PLUNGE_BUBBLE
        end
    -- fizzle
        if m.action == ACT_WATER_PLUNGE and (m.prevAction == ACT_MOVING_GP or (m.prevAction == ACT_GP_CANCEL and e.extActionArg == 1)) then
            play_sound(SOUND_GENERAL_FLAME_OUT, m.marioObj.header.gfx.cameraToObject)
        end
    -- custom longjump
        if m.action == ACT_LONG_JUMP then
            set_mario_action(m, ACT_CUSTOM_LONGJUMP, 0)
        end
    -- fix repeated firsties
        if m.action == ACT_WALL_KICK_AIR then
            m.marioObj.header.gfx.animInfo.animID = -1
        end
    -- GP jump type set
        if m.action == ACT_GROUND_POUND then
            if m.pos.y < (m.floorHeight + 50) then
                e.gpJumpType = 1
            else
                e.gpJumpType = 0
            end
        end
    -- slide kick
        if m.action == ACT_SLIDE_KICK and m.forwardVel > 45 then
            play_sound(SOUND_GENERAL_SWISH_WATER, m.marioObj.header.gfx.cameraToObject)
            m.actionArg = 2
            m.vel.y = 20
            e.gfxX = -0x10000
            e.gfxY = 100
            do_fumbler_combo()
        end
end

local function fumbler_before_set_action(m, act)
    if act == ACT_BACKWARD_AIR_KB and m.action == ACT_DIVE then
        return ACT_AIR_HIT_WALL
    end
end

local function fumbler_hud()
    local m = gMarioStates[0]
    local e = gExtraStates[0]
    local comboSprite = 1
    local ScaleX = 2 + e.hudScaleX
    local ScaleY = 2 + e.hudScaleY
    local PosX = 64 * e.hudScaleX
    local PosY = 64 * e.hudScaleY

    if e.combo == -1 then
        comboSprite = 7
    elseif e.combo < 7 then
        comboSprite = e.combo - 1
    elseif e.combo >= 7 then
        comboSprite = 6
    end

    djui_hud_set_color(255, 255, 255, (e.opacity/100)*255)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    djui_hud_render_texture_tile(TEX_FUMBLER_COMBO, 80 - PosX + e.hudShakeX, 150 - PosY + e.hudShakeY, ScaleX, ScaleY, comboSprite*128, 0, 128, 128)

    local TimerWidth = 220
    local TimerHeight = 20
    local inset = 8

    djui_hud_set_color(0, 0, 0, (e.opacity/100)*255)
    djui_hud_render_rect(80, 410, TimerWidth, TimerHeight)

    djui_hud_set_color(255, (e.comboTimer/40)*255, (e.comboTimer/40)*255, (e.opacity/100)*255)
    if e.combo ~= -1 then
        djui_hud_render_rect(80 + inset, 410 + inset, (e.comboTimer/40)*(TimerWidth - (2*inset)), TimerHeight - (2*inset))
    end

    --djui_hud_set_color(255, 0, 0, 255)
    --djui_hud_print_text(string.format("opacity: "..e.opacity..""), 1600, 150, 1)
    --djui_hud_print_text(string.format("comboTimer: "..e.comboTimer..""), 1600, 175, 1)
    --djui_hud_print_text(string.format("comboSprite: "..comboSprite..""), 1600, 200, 1)
end

local function jumbler_update(m)
    local e = gExtraStates[m.playerIndex]

    e.particleArg = E_MODEL_ICE_SPARKLES

    -- dust
        if get_global_timer() % stepFrame == 0 and m.forwardVel > 29 and m.action == ACT_WALKING then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
        end
    -- sprungflip (moving gp)
        if m.action == ACT_DIVE_SLIDE and m.input & INPUT_Z_PRESSED ~= 0 then
            set_mario_action(m, ACT_MOVING_GP, 0)
        end
    -- GP cancel
        if m.action == ACT_GROUND_POUND and m.input & INPUT_B_PRESSED ~= 0 then
            if e.canGPCancel then
                e.prevActionTimer = m.actionTimer
                set_mario_action(m, ACT_GP_CANCEL, 0)
                e.canGPCancel = false
            end
        end
        if m.pos.y == m.floorHeight then
            e.canGPCancel = true
        end
    -- GP fix
        if m.action == ACT_GROUND_POUND then
            m.marioObj.header.gfx.angle.y = m.faceAngle.y
        end
    -- syrup special swimming
        if m.action == ACT_FLUTTER_KICK and m.marioObj.header.gfx.animInfo.animID == MARIO_ANIM_FLUTTERKICK then
            m.particleFlags = m.particleFlags | PARTICLE_PLUNGE_BUBBLE
        end
end

local jumblerJumpTable = {
    [ACT_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_SIDE_FLIP] = true
}

local function jumbler_set_action(m)
    local e = gExtraStates[m.playerIndex]

    -- slide kick height
        if m.action == ACT_SLIDE_KICK then
            m.vel.y = m.forwardVel/2
        end
    -- replace metal fall
        if m.action == ACT_WATER_PLUNGE and m.flags & MARIO_METAL_CAP ~= 0 then
            m.action = ACT_METAL_WATER_JUMP
            play_sound(SOUND_OBJ_DIVING_INTO_WATER, m.marioObj.header.gfx.cameraToObject)
            m.particleFlags = m.particleFlags | PARTICLE_WATER_SPLASH | PARTICLE_PLUNGE_BUBBLE
        end
    -- jump height
        if jumblerJumpTable[m.action] then
            m.vel.y = m.vel.y + 5
        end
end

local function jumbler_before_phys_step(m)
    -- faster swimming
    if m.action == ACT_FLUTTER_KICK and m.marioObj.header.gfx.animInfo.animID == MARIO_ANIM_FLUTTERKICK then
        m.vel.x = m.vel.x * 3
        m.vel.y = m.vel.y * 3
        m.vel.z = m.vel.z * 3
    end
end

_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_MARIO_UPDATE, fumbler_update)
_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_ON_SET_MARIO_ACTION, fumbler_set_action)
_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_BEFORE_SET_MARIO_ACTION, fumbler_before_set_action)
_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_ON_HUD_RENDER_BEHIND, fumbler_hud)

_G.charSelect.character_hook_moveset(CT_JUMBLER, HOOK_MARIO_UPDATE, jumbler_update)
_G.charSelect.character_hook_moveset(CT_JUMBLER, HOOK_ON_SET_MARIO_ACTION, jumbler_set_action)
_G.charSelect.character_hook_moveset(CT_JUMBLER, HOOK_BEFORE_PHYS_STEP, jumbler_before_phys_step)