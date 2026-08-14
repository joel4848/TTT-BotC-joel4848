local EVENT = {}
EVENT.id = "joelbotc"

JoelBotC = JoelBotC or {}

local original_COLOR_DETECTIVE = {}
local original_COLOR_SPECIAL_INNOCENT = {}
local original_COLOR_SPECIAL_TRAITOR = {}
local original_COLOR_MONSTER = {}

JoelBotC.eventActiveClient = JoelBotC.eventActiveClient or nil
JoelBotC.isAliveClient = JoelBotC.isAliveClient or {}
JoelBotC.seatingOrderClient = JoelBotC.seatingOrderClient or {}

function EVENT:Begin()

    JoelBotC.eventActiveClient = true
    hook.Run("RdmtJoelBotC_Client_EventStarted")
    hook.Run("RdmtJoelBotC_Client_EventEnded")

    JoelBotC:MessageOverlayCreate()

    self:AddHook("TTTTargetIDPlayerRing", function(ent, client, ring_visible)
        return false
    end)

    self:AddHook("TTTTargetIDPlayerText", function(ent, client, text, col)
        return false
    end)

    self:AddHook("TTTTargetIDPlayerRoleIcon", function(v, client, role, noz, color_role)
        return false
    end)

    self:AddHook("TTTTargetIDPlayerTargetIcon", function(v, client, showJester)
        return false
    end)

    self:AddHook("TTTScoreboardPlayerRole", function(ply, client, color, roleText)
        return false, false
    end)

    hook.Add("ScoreboardShow", "JoelBotC_BlockScoreboardShow", function()
        if JoelBotC.clientGUIOpen then
            return true
        end
    end)

    hook.Add("ScoreboardHide", "JoelBotC_BlockScoreboardHide", function()
        if JoelBotC.clientGUIOpen then
            return true
        end
    end)

    hook.Add("PlayerButtonDown", "JoelBotC_EnableMouseInGUI", function(_, button)
        if button ~= KEY_TAB then return end
        if not JoelBotC.clientGUIOpen then return end

        if not gui.EnableScreenClicker() then
            gui.EnableScreenClicker(true)
        end
    end)

    hook.Add("PlayerButtonUp", "JoelBotC_DisableMouseInGUI", function(_, button)
        if button ~= KEY_TAB then return end

        if gui.EnableScreenClicker() then
            gui.EnableScreenClicker(false)
        end
    end)

    for _, ply in ipairs(player.GetAll()) do
        ply.originalColour = ply:GetColor()
        ply.originalRenderMode = ply:GetRenderMode()
    end

    local oldIsAliveClient = {}

    net.Receive("rdmtJoelBotCAliveDeadUpdate", function()
        JoelBotC.isAliveClient = net.ReadTable()
        oldIsAliveClient = oldIsAliveClient or JoelBotC.isAliveClient

        for _, ply in ipairs(JoelBotC.seatingOrderClient) do
            if JoelBotC.isAliveClient[ply] == false and oldIsAliveClient[ply] ~= false then
                ply:SetRenderMode(RENDERMODE_TRANSALPHA)
                ply:SetColor(Color(255,255,255,0))

                -- Fade the ghost in
                local fadeTimer = "JoelBotC_GhostFade_" .. ply:EntIndex()
                local alpha = 0

                timer.Create(fadeTimer, 0.05, 100, function()
                    if not IsValid(ply) then
                        timer.Remove(fadeTimer)
                        return
                    end

                    alpha = alpha + 1
                    ply:SetColor(Color(255,255,255,alpha))
                end)

            elseif JoelBotC.isAliveClient[ply] == false then
                ply:SetRenderMode(RENDERMODE_TRANSALPHA)
                ply:SetColor(Color(255,255,255,100))
            else
                ply:SetColor(Color(255, 255, 255, 255))
                ply:SetRenderMode(RENDERMODE_NORMAL)
            end
        end

        oldIsAliveClient = JoelBotC.isAliveClient
    end)

    -- Opening splash screen
    JoelBotC:BotCTitleCreate()
    surface.PlaySound("intro_loudest_8_5.wav")
    timer.Simple(5, function()
        JoelBotC:BotCTitleDestroy(3.5)
    end)

    -- JoelBotC:SeatingGUICreate()

    -------------------------------------------------------------------------------------
    -- Custom role colours
    -------------------------------------------------------------------------------------
    original_COLOR_DETECTIVE = table.Copy(COLOR_DETECTIVE)
    original_COLOR_SPECIAL_INNOCENT = table.Copy(COLOR_SPECIAL_INNOCENT)
    original_COLOR_SPECIAL_TRAITOR = table.Copy(COLOR_SPECIAL_TRAITOR)
    original_COLOR_MONSTER = table.Copy(COLOR_MONSTER)

    COLOR_DETECTIVE = {
        ["default"] = Color(31, 101, 255, 255),
        ["simple"] = Color(31, 101, 255, 255),
        ["protan"] = Color(31, 101, 255, 255),
        ["deutan"] = Color(31, 101, 255, 255),
        ["tritan"] = Color(31, 101, 255, 255)
    }

    COLOR_SPECIAL_INNOCENT = {
        ["default"] = Color(70, 213, 255, 255),
        ["simple"] = Color(70, 213, 255, 255),
        ["protan"] = Color(70, 213, 255, 255),
        ["deutan"] = Color(70, 213, 255, 255),
        ["tritan"] = Color(70, 213, 255, 255)
    }

    COLOR_SPECIAL_TRAITOR = {
        ["default"] = Color(255, 105, 0, 255),
        ["simple"] = Color(255, 105, 0, 255),
        ["protan"] = Color(255, 105, 0, 255),
        ["deutan"] = Color(255, 105, 0, 255),
        ["tritan"] = Color(255, 105, 0, 255)
    }

    COLOR_MONSTER = {
        ["default"] = Color(206, 1, 0, 255),
        ["simple"] = Color(206, 1, 0, 255),
        ["protan"] = Color(206, 1, 0, 255),
        ["deutan"] = Color(206, 1, 0, 255),
        ["tritan"] = Color(206, 1, 0, 255)
    }

    UpdateRoleColours()

    net.Receive("rdmtJoelBotCOpenSeatingGUI", function()
        JoelBotC:SeatingGUICreate()
    end)

    -- Win condition stuff
    LANG.AddToLanguage("english", "win_joelbotc_good", string.upper("The Good team wins!"))
    LANG.AddToLanguage("english", "win_joelbotc_evil", string.upper("The Evil team wins!"))

    hook.Add("TTTScoringWinTitleOverride", "JoelBotCWinTitle", function(wintype)
        local newTitle = {}

        if wintype == WIN_INNOCENT then
            newTitle.txt = "win_joelbotc_good"
            newTitle.c = Color(70, 213, 255, 255)
        else
            newTitle.txt = "win_joelbotc_evil"
            newTitle.c = Color(206, 1, 0, 255)
        end

        return newTitle
    end)

    hook.Add("TTTPrepareRound", "JoelBotCWinTitle", function()
        hook.Remove("TTTScoringWinTitleOverride", "JoelBotCWinTitle")
    end)

    local iconNames = {
        [ROLE_TEAM_DETECTIVE] = "botctwn",
        [ROLE_TEAM_INNOCENT]  = "botcots",
        [ROLE_TEAM_TRAITOR]   = "botcmin",
        [ROLE_TEAM_MONSTER]   = "botcdmn"
    }

    self:AddHook("TTTScoringSummaryRender", function(_, _, _, _, _, _, finalRole)
        local roleData = ROLE_DATA_EXTERNAL and ROLE_DATA_EXTERNAL[finalRole]

        if roleData and roleData.isBotC then
            local iconFileName = iconNames[roleData.team]

            if iconFileName then
                return iconFileName
            end
        end
    end)
end

function EVENT:End()
    -- Remove any overlays etc.
    JoelBotC:SeatingGUIDestroy()
    JoelBotC:BotCTitleDestroy(2)
    JoelBotC:MessageOverlayDestroy()
    JoelBotC:DestroyEndDayEarlyButton()

    JoelBotC.bossBarData = nil

    -- Remove hooks
    hook.Remove("ScoreboardShow", "JoelBotC_BlockScoreboardShow")
    hook.Remove("ScoreboardHide", "JoelBotC_BlockScoreboardHide")
    hook.Remove("PlayerButtonDown", "JoelBotC_EnableMouseInGUI")
    hook.Remove("PlayerButtonUp", "JoelBotC_DisableMouseInGUI")

    hook.Remove("RenderScreenspaceEffects", "JoelBOTC_NightEffect")
    hook.Remove("SetupWorldFog", "NightFog")
    hook.Remove("PostDrawSkyBox", "DarkSky")

    hook.Remove("RenderScreenspaceEffects", "RdmtJoelBotC_Night_RenderScreenspaceEffects")
    hook.Remove("SetupSkyboxFog", "RdmtJoelBotC_Night_SetupSkyboxFog")
    hook.Remove("SetupWorldFog", "RdmtJoelBotC_Night_SetupWorldFog")

    hook.Remove("OnPauseMenuShow", "RdmtJoelBotC_BookQuill_MenuSuppress")
    hook.Remove("OnPauseMenuShow", "RdmtJoelBotC_SignedBook_MenuSuppress")
    hook.Remove("OnPauseMenuShow", "RdmtJoelBotC_AdminBook_MenuSuppress")

    -- Remove timers
    timer.Remove("rdmtJoelBotCMoveBigHand")
    timer.Remove("rdmtJoelBotCLockInVote")
    timer.Remove("rdmtJoelBotCReopenNominations")

    -- Reset team colours
    if JoelBotC.eventActiveClient then
        COLOR_DETECTIVE = table.Copy(original_COLOR_DETECTIVE)
        COLOR_SPECIAL_INNOCENT = table.Copy(original_COLOR_SPECIAL_INNOCENT)
        COLOR_SPECIAL_TRAITOR = table.Copy(original_COLOR_SPECIAL_TRAITOR)
        COLOR_MONSTER = table.Copy(original_COLOR_MONSTER)
    end
    UpdateRoleColours()

    if JoelBotC.eventActiveClient then
        for _, ply in ipairs(player.GetAll()) do
            if ply.originalColour then
                ply:SetColor(ply.originalColour)
            end
            if ply.originalRenderMode then
                ply:SetRenderMode(ply.originalRenderMode)
            end
        end
    end

    JoelBotC.eventActiveClient = nil
end

Randomat:register(EVENT)