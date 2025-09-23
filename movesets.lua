local gExtraStates = {}
for i = 0, MAX_PLAYERS - 1 do
    gExtraStates[i] = {}
    local e = gExtraStates[i]
    e.stepTimer = 0
    e.prevActionTimer = 0
    e.canGPCancel = true
    e.extActionArg = 0
    e.particleArg = 0
    e.gfxY = 0
end

local ACT_MOVING_GP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_GP_CANCEL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_SH_BASH = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)
local ACT_SH_BASH_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_CONTROL_JUMP_HEIGHT)
local ACT_HUMBLE_GP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
local ACT_HUMBLE_GP_LAND = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_MOVING)
local ACT_HUMBLE_GP_CANCEL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_CORKSCREW = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

local stepMax = 4
local E_MODEL_ICE_SPARKLES = smlua_model_util_get_id('ice_sparkle_geo')
local E_MODEL_HUMBLE_PARTICLE = smlua_model_util_get_id('humbler_particle_geo')
local E_MODEL_HUMBLE_RING = smlua_model_util_get_id('particle_ring_geo')
local SOUND_HUMBLE_SH_BASH = audio_sample_load("humble_sh_bash.ogg")
local SOUND_HUMBLE_LEAP = audio_sample_load("humble_leap.ogg")
local SOUND_HUMBLE_CORKSCREW = audio_sample_load("humble_corkscrew.ogg")
local SOUND_HUMBLE_FLOP = audio_sample_load("humble_slap.ogg")

local PARTICLE_TIMER = 10

-- BEHAVIOURS --

local function convert_s16(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

function dash_attacks(m, o, intee)
    if obj_has_behavior_id(o, id_bhvKingBobomb) ~= 0 and o.oAction ~= 0 then
        o.oMoveAngleYaw = m.faceAngle.y
        o.oAction = 4
        o.oVelY = 50
        o.oForwardVel = 20
    end

    if obj_has_behavior_id(o, id_bhvBobomb) ~= 0 then
        o.oMoveAngleYaw = m.faceAngle.y
        o.oAction = BOBOMB_ACT_LAUNCHED
        o.oVelY = 30
        o.oForwardVel = 50
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
        o.oAction = MR_BLIZZARD_ACT_DEATH
    end

    if obj_has_behavior_id(o, id_bhvHeaveHo) ~= 0 then
        obj_mark_for_deletion(o)
        play_sound(SOUND_GENERAL_BREAK_BOX, m.marioObj.header.gfx.cameraToObject)
        spawn_triangle_break_particles(30, 138, 3.0, 4)
        spawn_non_sync_object(
            id_bhvBlueCoinJumping,
            E_MODEL_BLUE_COIN,
            o.oPosX, o.oPosY, o.oPosZ,
            function (coin)
                coin.oVelY = math.random(20, 40)
                coin.oForwardVel = 0
            end)
    end
    
    if (intee & INTERACT_BULLY) ~= 0 then
        o.oVelY = 30
        o.oForwardVel = 50
    end

    if obj_has_behavior_id(o, id_bhvBreakableBox) ~= 0 then
        obj_mark_for_deletion(o)
        play_sound(SOUND_GENERAL_BREAK_BOX, m.marioObj.header.gfx.cameraToObject)
        spawn_triangle_break_particles(30, 138, 3.0, 4)
        spawn_non_sync_object(
            id_bhvThreeCoinsSpawn,
            E_MODEL_YELLOW_COIN,
            o.oPosX, o.oPosY, o.oPosZ,
            function (coin)
                coin.oVelY = math.random(20, 40)
                coin.oForwardVel = 0
            end)
    end

    --if obj_has_behavior_id(o, id_bhvBigBoulder) ~= 0 then
    --    obj_mark_for_deletion(o)
    --    play_sound(SOUND_GENERAL_BREAK_BOX, m.marioObj.header.gfx.cameraToObject)
    --    spawn_triangle_break_particles(30, 138, 3.0, 4)
    --    spawn_non_sync_object(
    --        id_bhvThreeCoinsSpawn,
    --        E_MODEL_YELLOW_COIN,
    --        o.oPosX, o.oPosY, o.oPosZ,
    --        function (coin)
    --            coin.oVelY = math.random(20, 40)
    --            coin.oForwardVel = 0
    --        end)
    --end
end

function humble_bump(m, x, y)
    m.forwardVel = x
    m.vel.y = y
    set_mario_action(m, ACT_SH_BASH_JUMP, 0)
    m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
    play_sound(SOUND_ACTION_BOUNCE_OFF_OBJECT, m.marioObj.header.gfx.cameraToObject)
    return 0
end

function particle_clone_init(o)
  local index = network_local_index_from_global(o.globalPlayerIndex) or 255
  if index == 255 then
    obj_mark_for_deletion(o)
    return
  end
  local m = gMarioStates[index]
  o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
  --o.oOpacity = 0

  o.oPosX = m.marioObj.header.gfx.pos.x
  o.oPosY = m.marioObj.header.gfx.pos.y
  o.oPosZ = m.marioObj.header.gfx.pos.z
  o.oFaceAnglePitch = m.marioObj.header.gfx.angle.x
  o.oFaceAngleYaw = m.marioObj.header.gfx.angle.y
  o.oFaceAngleRoll = m.marioObj.header.gfx.angle.z
  o.header.gfx.animInfo.animID = m.marioObj.header.gfx.animInfo.animID
  o.header.gfx.animInfo.curAnim = m.marioObj.header.gfx.animInfo.curAnim
  o.header.gfx.animInfo.animYTrans = m.unkB0
  o.header.gfx.animInfo.animAccel = 0            --m.marioObj.header.gfx.animInfo.animAccel
  o.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame
  o.header.gfx.animInfo.animTimer = 0            --m.marioObj.header.gfx.animInfo.animTimer
  o.header.gfx.animInfo.animFrameAccelAssist = 0 --m.marioObj.header.gfx.animInfo.animFrameAccelAssist
  o.header.gfx.scale.x = m.marioObj.header.gfx.scale.x
  o.header.gfx.scale.y = m.marioObj.header.gfx.scale.y
  o.header.gfx.scale.z = m.marioObj.header.gfx.scale.z
end

function particle_clone_loop(o)
  --o.oOpacity = 200 - (o.oTimer * 200) // PARTICLE_TIMER
  o.header.gfx.animInfo.animFrame = o.header.gfx.animInfo.animFrame - 1
  if o.oTimer >= PARTICLE_TIMER then
    obj_mark_for_deletion(o)
  end
end

id_bhvParticleClone = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, true, particle_clone_init, particle_clone_loop,
  "bhvParticleClone")


function particle_ring_init(o)
    local index = network_local_index_from_global(o.globalPlayerIndex) or 255
    if index == 255 then
        obj_mark_for_deletion(o)
        return
    end
    local m = gMarioStates[index]
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oFaceAngleRoll = 0 - degrees_to_sm64(90)
    o.header.gfx.scale.x = 0
    o.header.gfx.scale.y = 0
    o.header.gfx.scale.z = 0
end

function particle_ring_loop(o)
    local index = network_local_index_from_global(o.globalPlayerIndex) or 255
    if index == 255 then
        obj_mark_for_deletion(o)
        return
    end
    local m = gMarioStates[index]
    local rot = (((m.forwardVel - 55)/3)*1000)
    o.oPosX = m.marioObj.header.gfx.pos.x
    o.oPosY = m.marioObj.header.gfx.pos.y + 100
    o.oPosZ = m.marioObj.header.gfx.pos.z
    o.oFaceAnglePitch = o.oFaceAnglePitch + rot
    o.oFaceAngleYaw = m.marioObj.header.gfx.angle.y - degrees_to_sm64(90)
    if m.action == ACT_SH_BASH then
        if m.forwardVel > 60 then
            o.header.gfx.scale.x = 1
            o.header.gfx.scale.y = 1
            o.header.gfx.scale.z = 1
        else
            o.header.gfx.scale.x = 0
            o.header.gfx.scale.y = 0
            o.header.gfx.scale.z = 0
        end
    else
        obj_mark_for_deletion(o)
    end
end

id_bhvParticleRing = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, true, particle_ring_init, particle_ring_loop,
  "bhvRingParticle")


-- CUSTOM ACTIONS --

local function act_moving_gp(m)
    local e = gExtraStates[m.playerIndex]

    if m.actionTimer == 0 then
        m.vel.y = 40
        m.forwardVel = m.forwardVel + 4
        play_character_sound(m, CHAR_SOUND_WAH2)
    end

    local range = math.random(-30, 30)
    spawn_non_sync_object(id_bhvCoinSparkles, e.particleArg, m.pos.x + range, m.pos.y + range, m.pos.z + range,
            --- @param o Object
            function(o)
                obj_scale(o, 2)
            end)

    if m.actionTimer == 5 then -- spin sound
        play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end

    local stepResult = common_air_action_step(m, ACT_GROUND_POUND_LAND, MARIO_ANIM_TRIPLE_JUMP_GROUND_POUND, AIR_STEP_NONE)
    if stepResult == AIR_STEP_LANDED then
        if should_get_stuck_in_ground(m) ~= 0 then
            queue_rumble_data_mario(m, 5, 80)
            play_character_sound(m, CHAR_SOUND_OOOF2)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0)
        else
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
            set_mario_action(m, ACT_GROUND_POUND_LAND, 0)
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
        local range = math.random(-15, 15)
        spawn_sync_object(id_bhvCoinSparkles, e.particleArg, m.pos.x + range, m.pos.y + range, m.pos.z + range,
            --- @param o Object
            function(o)
                obj_scale(o, 2)
            end)
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

local function act_sh_bash(m)
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_RIGHT
    m.marioBodyState.punchState = 66
    m.particleFlags = m.particleFlags | PARTICLE_DUST

    if (m.actionTimer & 2 == 0) then
        audio_sample_play(SOUND_HUMBLE_SH_BASH, m.pos, 0.75)
    end

    if m.actionTimer < 2 then
        m.vel.y = 0
    end

    local stepResult = perform_ground_step(m)
    if stepResult == GROUND_STEP_HIT_WALL and m.wall ~= nil then
        if m.wall.object == nil or m.wall.object.oInteractType & (INTERACT_BREAKABLE) == 0 then
            return humble_bump(m, -40, 30)
        end
    elseif stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_SH_BASH_JUMP, 0)
    end
        
    set_mario_anim_with_accel(m, MARIO_ANIM_RUNNING_UNUSED, m.forwardVel / 6 * 0x10000)
    smlua_anim_util_set_animation(m.marioObj, "humbler_sh_bash")

    -- speed
    local speedCap = 50
    local accel = 1
    local speed = m.forwardVel
    if m.actionTimer > 80 then
        accel = 0.1
        speedCap = 65
    end
    if speed < 30 then
        speed = 30
    else
        speed = approach_f32(speed, speedCap, accel, 5)
    end
    mario_set_forward_vel(m, speed)

    if m.input & INPUT_A_PRESSED ~= 0 then
        audio_sample_play(SOUND_HUMBLE_LEAP, m.pos, 1.25)
        m.vel.y = 50
        set_mario_action(m, ACT_SH_BASH_JUMP, 0)
    elseif (m.input & INPUT_B_PRESSED ~= 0 and m.actionTimer > 5) or is_game_paused() then
        set_mario_action(m, ACT_BRAKING, 0)
    elseif m.input & INPUT_Z_PRESSED ~= 0 then
        set_mario_action(m, ACT_CROUCH_SLIDE, 0)
    --elseif m.floor.normal.y < 0.6 then set_mario_action(m, ACT_WALKING, 0)
    end

    m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x400, 0x400)

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_SH_BASH, act_sh_bash)

local function act_sh_bash_jump(m)
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_LEFT
    m.marioBodyState.punchState = 66
    smlua_anim_util_set_animation(m.marioObj, "humbler_sh_bash_jump")
    m.peakHeight = m.pos.y

    local stepResult = common_air_action_step(m, ACT_SH_BASH, MARIO_ANIM_RUNNING_UNUSED, AIR_STEP_NONE)
    if stepResult == AIR_STEP_HIT_WALL and m.wall ~= nil then
        if m.wall.object == nil or m.wall.object.oInteractType & (INTERACT_BREAKABLE) == 0 then
            return humble_bump(m, -40, 30)
        end
    elseif stepResult == AIR_STEP_LANDED and m.forwardVel < 30 then
        set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end

    if m.input & INPUT_Z_PRESSED ~= 0 then
        set_mario_action(m, ACT_HUMBLE_GP, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_SH_BASH_JUMP, act_sh_bash_jump)

local function act_humble_gp(m)
    local e = gExtraStates[m.playerIndex]

    if m.actionTimer == 1 then
        play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
        e.gfxY = 0x11000
    elseif m.actionTimer < 10 then
        m.vel.y = 0
    end
    local stepResult = common_air_action_step(m, ACT_GROUND_POUND_LAND, MARIO_ANIM_START_TWIRL, AIR_STEP_NONE)
    if stepResult == AIR_STEP_HIT_WALL then
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
    elseif stepResult == AIR_STEP_LANDED then
        if should_get_stuck_in_ground(m) ~= 0 then
            queue_rumble_data_mario(m, 5, 80)
            play_character_sound(m, CHAR_SOUND_OOOF2)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            set_mario_action(m, ACT_HEAD_STUCK_IN_GROUND, 0)
        else
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
            set_mario_action(m, ACT_HUMBLE_GP_LAND, 0)
        end
        set_camera_shake_from_hit(SHAKE_GROUND_POUND)
    end

    --m.forwardVel = m.forwardVel*0.95

    if m.input & INPUT_B_PRESSED ~= 0 then
        set_mario_action(m, ACT_HUMBLE_GP_CANCEL, 0)
    elseif m.input & INPUT_A_PRESSED ~= 0 then
        set_mario_action(m, ACT_CORKSCREW, 0)
    end

    m.peakHeight = m.pos.y
    e.gfxY = e.gfxY * 0.8
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfxY
    m.marioObj.header.gfx.pos.y = m.pos.y - 20

    if m.actionTimer < 15 then
        m.actionTimer = m.actionTimer + 1
    end
    return 0
end
hook_mario_action(ACT_HUMBLE_GP, act_humble_gp, INT_GROUND_POUND)

local function act_humble_gp_land(m)
    if m.actionTimer == 1 then
        m.vel.x = 0
        m.vel.z = 0
    end

    if (m.input & INPUT_OFF_FLOOR ~= 0) then
        return set_mario_action(m, ACT_FREEFALL, 0)
    elseif (m.input & INPUT_ABOVE_SLIDE ~= 0) then
        return set_mario_action(m, ACT_DIVE_SLIDE, 0)
    elseif m.actionTimer == 2 then
        return set_mario_action(m, ACT_STOMACH_SLIDE_STOP, 0)
    end



    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_HUMBLE_GP_LAND, act_humble_gp_land, INT_GROUND_POUND)

local function act_humble_gp_cancel(m)
    local e = gExtraStates[m.playerIndex]

    if m.actionTimer == 1 then
        m.vel.y = 30
        m.forwardVel = 35
        play_character_sound(m, CHAR_SOUND_HOOHOO)
        e.gfxY = 0 - 0x11000
        m.faceAngle.y = m.intendedYaw
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
    end
    local stepResult = common_air_action_step(m, ACT_BUTT_SLIDE, MARIO_ANIM_GROUND_POUND, AIR_STEP_CHECK_LEDGE_GRAB)
    if stepResult == AIR_STEP_HIT_WALL then
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
    end

    e.gfxY = e.gfxY * 0.8
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfxY

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_HUMBLE_GP_CANCEL, act_humble_gp_cancel)

local function act_corkscrew(m)
    local e = gExtraStates[m.playerIndex]

    smlua_anim_util_set_animation(m.marioObj, "humbler_corkscrew")
    m.marioBodyState.handState = MARIO_HAND_OPEN

    if m.actionTimer == 1 then
        play_character_sound(m, CHAR_SOUND_EEUH)
        audio_sample_play(SOUND_HUMBLE_CORKSCREW, m.pos, 0.7)
        m.faceAngle.y = m.intendedYaw
        e.gfxY = 0x20000
    elseif m.actionTimer > 1 then
        e.gfxY = e.gfxY * 0.9
        if m.actionTimer < 15 then
            m.vel.y = 25
            m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        elseif m.actionTimer < 30 then
            m.vel.y = m.vel.y + 2
        end
    end

    if m.forwardVel > 20 then
        m.forwardVel = 20
    end

    m.forwardVel = m.forwardVel*0.9

    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, MARIO_ANIM_GROUND_POUND, AIR_STEP_CHECK_LEDGE_GRAB)


    m.marioObj.header.gfx.angle.y = m.faceAngle.y + e.gfxY

    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_CORKSCREW, act_corkscrew)

-- UPDATES --

local function fumbler_update(m)
    local e = gExtraStates[m.playerIndex]
    
    e.particleArg = E_MODEL_RED_FLAME

    -- dust
        if m.action == ACT_WALKING and m.forwardVel > 20 and m.pos.y > m.waterLevel then
            e.stepTimer = e.stepTimer + 1

            if e.stepTimer > stepMax then
                e.stepTimer = 0
                m.particleFlags = m.particleFlags | PARTICLE_DUST
            end
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
            else
                spawn_mist_particles_variable(5, 0, 8)
                m.vel.y = 15
                play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
                set_mario_action(m, ACT_FORWARD_AIR_KB, 0)
            end
        end
        if m.pos.y == m.floorHeight then
            e.canGPCancel = true
        end
    -- lava boost particles
        if m.action == ACT_LAVA_BOOST and m.vel.y > 30 then
            local range = math.random(-30, 30)
            spawn_non_sync_object(id_bhvCoinSparkles, E_MODEL_RED_FLAME, m.pos.x + range, m.pos.y + range, m.pos.z + range,
                --- @param o Object
                function(o)
                    obj_scale(o, 2)
                end)
        end
end

local function fumbler_set_action(m)
    local e = gExtraStates[m.playerIndex]

    -- slide kick height
        if m.action == ACT_SLIDE_KICK then
            m.vel.y = m.forwardVel/2
        end
    -- zooted speed kick
        if m.action == ACT_JUMP_KICK and m.forwardVel > 40 then
            play_sound(SOUND_GENERAL_COIN_SPURT, m.marioObj.header.gfx.cameraToObject)
            m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
            m.forwardVel = m.forwardVel + 10
        elseif m.action == ACT_DIVE and m.input & INPUT_A_DOWN ~= 0 and m.input & INPUT_B_PRESSED ~= 0 and m.pos.y == m.floorHeight and m.intendedMag < 32 then
            set_mario_action(m, ACT_FORWARD_GROUND_KB, 0)
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
end

local function jumbler_update(m)
    local e = gExtraStates[m.playerIndex]

    e.particleArg = E_MODEL_ICE_SPARKLES

    -- dust
        if m.action == ACT_WALKING and m.forwardVel > 20 and m.pos.y > m.waterLevel then
            e.stepTimer = e.stepTimer + 1

            if e.stepTimer > stepMax then
                e.stepTimer = 0
                m.particleFlags = m.particleFlags | PARTICLE_DUST
            end
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

local function humbler_update(m)
    -- disable tilt
    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = m.forwardVel * 100
        m.marioBodyState.torsoAngle.z = 0
    end

      -- clone particles
    if (m.playerIndex == 0 or is_player_active(m) ~= 0) and m.marioObj.header.gfx.node.flags & GRAPH_RENDER_ACTIVE ~= 0 then
        if ((m.action == ACT_SH_BASH or m.action == ACT_SH_BASH_JUMP) and m.forwardVel > 49) or (m.action == ACT_CORKSCREW and m.vel.y > 20) then
            if (m.actionTimer) % 3 == 0 then
                spawn_non_sync_object(id_bhvParticleClone, E_MODEL_HUMBLE_PARTICLE, m.pos.x, m.pos.y, m.pos.z,
                function(o) o.globalPlayerIndex = network_global_index_from_local(m.playerIndex) end)
            end
        end
    end
end

local function humbler_set_action(m)
    local e = gExtraStates[m.playerIndex]

    -- shoulder bash
    if m.action == ACT_MOVE_PUNCHING then
        e.prevPosY = m.pos.y
        m.action = ACT_SH_BASH
    end
    -- water flop
    --if m.action == ACT_WATER_PLUNGE and m.prevAction == ACT_HUMBLE_GP then
        --audio_sample_play(SOUND_HUMBLE_FLOP, m.pos, 0.5)
    --end

        -- ring particles
    if (m.playerIndex == 0 or is_player_active(m) ~= 0) and m.marioObj.header.gfx.node.flags & GRAPH_RENDER_ACTIVE ~= 0 then
        if (m.action == ACT_SH_BASH) then
            spawn_non_sync_object(id_bhvParticleRing, E_MODEL_HUMBLE_RING, m.pos.x, m.pos.y, m.pos.z,
            function(o) o.globalPlayerIndex = network_global_index_from_local(m.playerIndex) end)
        end
    end
end

local function humbler_before_set_action(m, act)
    if act == ACT_GROUND_POUND then
        return ACT_HUMBLE_GP
    end
end

function humbler_interact(m, o, intee)
    local damagableTypes = (INTERACT_BOUNCE_TOP | INTERACT_BOUNCE_TOP2 | INTERACT_HIT_FROM_BELOW | 2097152 | INTERACT_KOOPA | INTERACT_BREAKABLE | INTERACT_GRABBABLE | INTERACT_BULLY)

    if m.action == ACT_SH_BASH and (intee & damagableTypes) ~= 0 then
        dash_attacks(m, o, intee)
        humble_bump(m, -40, 30)
        return false
    end

    if m.action == ACT_SH_BASH_JUMP and (intee & damagableTypes) ~= 0 then
        dash_attacks(m, o, intee)
        humble_bump(m, -40, 15)
        return false
    end
end

function humbler_attack(a, v)
    if a.action == ACT_SH_BASH or a.action == ACT_SH_BASH_AIR then
        humble_bump(a, -40, 30)
    end
end

_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_MARIO_UPDATE, fumbler_update)
_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_ON_SET_MARIO_ACTION, fumbler_set_action)

_G.charSelect.character_hook_moveset(CT_JUMBLER, HOOK_MARIO_UPDATE, jumbler_update)
_G.charSelect.character_hook_moveset(CT_JUMBLER, HOOK_ON_SET_MARIO_ACTION, jumbler_set_action)

_G.charSelect.character_hook_moveset(CT_HUMBLER, HOOK_MARIO_UPDATE, humbler_update)
_G.charSelect.character_hook_moveset(CT_HUMBLER, HOOK_ON_SET_MARIO_ACTION, humbler_set_action)
_G.charSelect.character_hook_moveset(CT_HUMBLER, HOOK_BEFORE_SET_MARIO_ACTION, humbler_before_set_action)
_G.charSelect.character_hook_moveset(CT_HUMBLER, HOOK_ON_INTERACT, humbler_interact)
_G.charSelect.character_hook_moveset(CT_HUMBLER, HOOK_ON_PVP_ATTACK, humbler_attack)

--local function debug_hud()
--        local m = gMarioStates[0]
--        local e = gExtraStates[m.playerIndex]
--        
--        djui_hud_set_color(0, 255, 0, 255)
--        djui_hud_set_resolution(RESOLUTION_DJUI)
--        djui_hud_set_font(FONT_ALIASED)


--        djui_hud_print_text(string.format("e.speedKickTimer:  "..e.speedKickTimer.." ") , 25, 150, 1)
--        djui_hud_print_text(string.format("m.actionTimer:  "..m.actionTimer.." ") , 25, 175, 1)
--        djui_hud_print_text(string.format("m.intendedMag:  "..m.intendedMag.." ") , 25, 200, 1)
--end
--hook_event(HOOK_ON_HUD_RENDER_BEHIND, debug_hud)