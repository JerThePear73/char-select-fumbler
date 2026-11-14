gWhite = {r = 255, g = 255, b = 255}

local imapctFrameActive = 0
local impactFrameShaderEffects = {
    [SHADER_FLAG_EXPOSURE] = 1,
    [SHADER_FLAG_CONTRAST] = 1,
    [SHADER_FLAG_SATURATION] = 0.5,
    [SHADER_FLAG_POSTERIZATION] = 0.01,
}

---@param m MarioState
---@param frame integer amount of impactFrames (recommended 5)
function doImpactFrame(m, frames)
    if m.playerIndex == 0 then
        imapctFrameActive = frames
    end
end

function processImpactFrame()
    if imapctFrameActive == -1 then return end
    local m = gMarioStates[0]
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex ~= 0 then return end

    if imapctFrameActive > 0 then
        set_shading_fullbright_enabled(true)
        set_skybox_color(0, 0)
        set_skybox_color(1, 0)
        set_skybox_color(2, 0)
        for i=0, PLAYER_PART_MAX do
            network_player_set_override_palette_color(np, i, gWhite)
        end
        for i=0, SHADER_FLAG_MAX do
            if impactFrameShaderEffects[i] then
                set_shader_flag_value(i, impactFrameShaderEffects[i])
                set_shader_flag_enabled(i, true)
            end
        end
        imapctFrameActive = imapctFrameActive - 1
    elseif imapctFrameActive == 0 then
        set_shading_fullbright_enabled(false)
        set_skybox_color(0, 255)
        set_skybox_color(1, 255)
        set_skybox_color(2, 255)
        network_player_reset_override_palette(np)
        for i=0, SHADER_FLAG_MAX do
            if impactFrameShaderEffects[i] then
                set_shader_flag_enabled(i, false)
            end
        end
        imapctFrameActive = -1
    end
end
hook_event(HOOK_UPDATE, processImpactFrame)