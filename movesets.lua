local gExtraStates = {}
for i = 0, MAX_PLAYERS - 1 do
    gExtraStates[i] = {}
    local e = gExtraStates[i]
    e.stepTimer = 0
    e.prevActionTimer = 0
    e.canGPCancel = true
    e.extActionArg = 0
end

local stepMax = 4

-- CUSTOM ACTIONS --

local ACT_MOVING_GP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
local ACT_GP_CANCEL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

local function act_moving_gp(m)

    set_mario_animation(m, MARIO_ANIM_TRIPLE_JUMP_GROUND_POUND)

    if m.actionTimer == 0 then
        m.vel.y = 40
        m.forwardVel = m.forwardVel + 4
        play_character_sound(m, CHAR_SOUND_WAH2)
    end

    local range = math.random(-30, 30)
    spawn_non_sync_object(id_bhvCoinSparkles, E_MODEL_RED_FLAME, m.pos.x + range, m.pos.y + range, m.pos.z + range,
            --- @param o Object
            function(o)
                obj_scale(o, 2)
            end)

    local stepResult = common_air_action_step(m, ACT_GROUND_POUND_LAND, MARIO_ANIM_TRIPLE_JUMP_GROUND_POUND, AIR_STEP_NONE)

    if m.actionTimer == 5 then -- spin sound
        play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
    
    if stepResult == AIR_STEP_LANDED then
        if should_get_stuck_in_ground(m) ~= 0 then
            queue_rumble_data_mario(m, 5, 80)
            play_character_sound(m, CHAR_SOUND_OOOF2)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0)
        else
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
            if check_fall_damage(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
                m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
                set_mario_action(m, ACT_GROUND_POUND_LAND, 0)
            end
        end
        set_camera_shake_from_hit(SHAKE_GROUND_POUND)
    end
    
    m.actionTimer = m.actionTimer + 1
    return 0
end
hook_mario_action(ACT_MOVING_GP, act_moving_gp)

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
        spawn_non_sync_object(id_bhvCoinSparkles, E_MODEL_RED_FLAME, m.pos.x + range, m.pos.y + range, m.pos.z + range,
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

-- UPDATES --

local function fumbler_update(m)
    local e = gExtraStates[m.playerIndex]
    
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

--local function fumbler_before_set_action(m, act)

--end

_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_MARIO_UPDATE, fumbler_update)
_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_ON_SET_MARIO_ACTION, fumbler_set_action)
--_G.charSelect.character_hook_moveset(CT_FUMBLER, HOOK_BEFORE_SET_MARIO_ACTION, fumbler_before_set_action)