if CLIENT then
    local isNight = false

    ---------------
    -- NIGHT FOG --
    ---------------

    local nightIntensity = 0

    local function Night_SetupWorldFog()
        -- if not IsPlayer(client) then
        --     client = LocalPlayer()
        -- end

        if not isNight and nightIntensity == 0 then return end

        if isNight and nightIntensity < 1 then
            nightIntensity = nightIntensity + 0.01
            if nightIntensity > 1 then nightIntensity = 1 end
        elseif not isNight and nightIntensity > 0 then
            nightIntensity = nightIntensity - 0.01
            if nightIntensity < 0 then nightIntensity = 0 end
        end

        -- local night_visibility_mode = werewolf_night_visibility_mode:GetInt()
        -- if not client:IsActiveWerewolf() and night_visibility_mode == WEREWOLF_NIGHT_ONLY_SHOW_WEREWOLVES then return end

        -- local fog_visibility_mode = werewolf_fog_visibility_mode:GetInt()
        -- if fog_visibility_mode == WEREWOLF_FOG_NONE then return end
        -- if client:IsActiveWerewolf() and fog_visibility_mode == WEREWOLF_FOG_NONWEREWOLVES then return end

        local werewolfScale = 1
        -- if client:IsActiveWerewolf() then werewolfScale = 2 end

        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogMaxDensity(nightIntensity)
        render.FogColor(0, 0, 0)
        render.FogStart((50 + ((1 - nightIntensity) * 1000)) * werewolfScale)
        render.FogEnd((600 + ((1 - nightIntensity) * 1000)) * werewolfScale)
        return true
    end

    local function Night_SetupSkyboxFog(scale)
        -- if not IsPlayer(client) then
        --     client = LocalPlayer()
        -- end

        if not isNight and nightIntensity == 0 then return end

        -- local night_visibility_mode = werewolf_night_visibility_mode:GetInt()
        -- if not client:IsActiveWerewolf() and night_visibility_mode == WEREWOLF_NIGHT_ONLY_SHOW_WEREWOLVES then return end

        -- local fog_visibility_mode = werewolf_fog_visibility_mode:GetInt()
        -- if fog_visibility_mode == WEREWOLF_FOG_NONE then return end
        -- if client:IsActiveWerewolf() and fog_visibility_mode == WEREWOLF_FOG_NONWEREWOLVES then return end

        local werewolfScale = 1
        -- if client:IsActiveWerewolf() then werewolfScale = 2 end

        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogMaxDensity(nightIntensity)
        render.FogColor(0, 0, 0)
        render.FogStart((50 + ((1 - nightIntensity) * 1000)) * werewolfScale * scale)
        render.FogEnd((600 + ((1 - nightIntensity) * 1000)) * werewolfScale * scale)
        return true
    end

    ------------------
    -- SCREEN TINTS --
    ------------------


    local function Night_RenderScreenspaceEffects()
        if not isNight and nightIntensity == 0 then return end

        -- if not IsPlayer(client) then
        --     client = LocalPlayer()
        -- end

        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1 - (nightIntensity * 0.2),
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })

        DrawColorModify({
            ["$pp_colour_addr"] = nightIntensity * -0.5,
            ["$pp_colour_addg"] = nightIntensity * -0.2,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
    end

    net.Receive("rdmtJoelBotCNightStarts", function()
        isNight = true

        LocalPlayer():EmitSound("bell_night.wav")
    end)

    net.Receive("rdmtJoelBotCNightEnds", function()
        isNight = false

        LocalPlayer():EmitSound("bell_morning.wav")
    end)

    hook.Add("RdmtJoelBotC_Client_EventStarted", "RdmtJoelBotC_AddNightEffectHooks", function()
        hook.Add("RenderScreenspaceEffects", "RdmtJoelBotC_Night_RenderScreenspaceEffects", Night_RenderScreenspaceEffects)
        hook.Add("SetupSkyboxFog", "RdmtJoelBotC_Night_SetupSkyboxFog", Night_SetupSkyboxFog)
        hook.Add("SetupWorldFog", "RdmtJoelBotC_Night_SetupWorldFog", Night_SetupWorldFog)
    end)
    hook.Add("RdmtJoelBotC_Client_EventEnded", "RdmtJoelBotC_AddNightEffectHooks", function()
        isNight = false
    end)
end