local EVENT = {}

JoelBotC = JoelBotC or {}

EVENT.Title = "JoelBotC"
EVENT.Description = ""
EVENT.id = "joelbotc"
EVENT.Categories = {"gamemode", "largeimpact", "rolechange"}

CreateConVar("randomat_joelbotc_enable_testing_mode", 0, FCVAR_NONE, "Whether testing mode is enabled", 0, 1)

util.AddNetworkString("rdmtJoelBotCSeatingOrder")
-- util.AddNetworkString("rdmtJoelBotCSendGrimRevealRoles")

JoelBotC.original_COLOR_DETECTIVE = JoelBotC.original_COLOR_DETECTIVE or {}
JoelBotC.original_COLOR_SPECIAL_INNOCENT = JoelBotC.original_COLOR_SPECIAL_INNOCENT or {}
JoelBotC.original_COLOR_SPECIAL_TRAITOR = JoelBotC.original_COLOR_SPECIAL_TRAITOR or {}
JoelBotC.original_COLOR_MONSTER = JoelBotC.original_COLOR_MONSTER or {}

JoelBotC.players = JoelBotC.players or {}
JoelBotC.isAlive = JoelBotC.isAlive or {}
JoelBotC.rolesInGame = JoelBotC.rolesInGame or {}
JoelBotC.rolePool = JoelBotC.rolePool or {}
JoelBotC.recentExecutee = JoelBotC.recentExecutee or nil
JoelBotC.deadPlayers = JoelBotC.deadPlayers or {}
JoelBotC.BotCEventRunning = JoelBotC.BotCEventRunning or nil
JoelBotC.testingMode = JoelBotC.testingMode or nil

-- local originalDetectiveCvar = nil

function EVENT:Begin()
    JoelBotC.testingMode = GetConVar("randomat_joelbotc_enable_testing_mode"):GetBool()

    JoelBotC.players = {}
    JoelBotC.isAlive = {}
    JoelBotC.deadPlayers = {}
    JoelBotC.rolePool = {}
    JoelBotC.townsfolkInBag = {}
    JoelBotC.outsidersInBag = {}
    JoelBotC.minionsInBag = {}
    JoelBotC.demonsInBag = {}

    JoelBotC.saintExecuted = nil

    JoelBotC.BotCEventRunning = true

    self:AddHook("TTTCanSearchCorpse", function(ply, rag)
        if rag.is_botc_body then
            return false
        end
    end)

    self:AddHook("EntityTakeDamage", function(target, _)
        if target:IsPlayer() then
            return true
        end
    end )

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not IsValid(wep) then return false end

        local class = WEPS.GetClass(wep)

        if class == "weapon_zm_improvised" or
        class == "weapon_ttt_unarmed" or
        class == "weapon_zm_carry" or
        class == "weapon_ttt_joelbotc_adminbook" or
        class == "weapon_ttt_signedbook" or
        class == "weapon_ttt_bookquill" then
            return true
        end

        return false
    end)

    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if IsPlayer(ent) then
            return true
        end
    end)

    local lastUpdate = nil
    self:AddHook("Think", function()
        local curTime = CurTime()
        if lastUpdate == nil or curTime >= lastUpdate then
            lastUpdate = curTime + 1
            -- Change the round time so it effectively never ends
            SetGlobalFloat("ttt_round_end", curTime + 90000)
            SetGlobalFloat("ttt_haste_end", curTime + 90000)
        end
    end)

    JoelBotC.ravenkeeperKilledByDemon = nil
    JoelBotC.monkPlayer = nil
    JoelBotC.monkProtectedPlayer = nil
    JoelBotC.isFirstNight = true
    JoelBotC.isCurrentlyNight = nil
    JoelBotC.grandmother = nil
    JoelBotC.grandchild  = nil
    JoelBotC.morningDeaths = {}

    JoelBotC:ChangeRoleColours()

    ----------------------------------------------------------------------------------------------
    -- Set up game
    ----------------------------------------------------------------------------------------------

    JoelBotC:BuildGameScript()

    JoelBotC:BuildGameBag()

    JoelBotC:DetermineRolesInGame()

    -- ~~~~~~~~~~~~~~ Add bag-changing function ~~~~~~~~~~~~~~

    JoelBotC:SelectDemonBluffs()

    JoelBotC:AssignRolesAndSeats()

    JoelBotC.FortuneTellerRedHerring()

    timer.Create("rdmtJoelBotC_gamestart_1", 1, 1, function()
        JoelBotC:GiveStartingBooks()
    end)

    if not JoelBotC.testingMode then
        timer.Create("rdmtJoelBotC_gamestart_2", 8.5, 1, function()
            Randomat:SmallNotify("Check your inventory for your notebook and information book!", 5)
        end)

        timer.Create("rdmtJoelBotC_gamestart_3", 13.5, 1, function()
            Randomat:SmallNotify("Night 1 will start in 5 seconds...", 5)
        end)

        timer.Create("rdmtJoelBotC_gamestart_4", 13.5, 1, function()
            JoelBotC.isFirstNight = true
            JoelBotC.currentNight = 0
            timer.Create("rdmtJoelBotCNominationsEnd", 5, 1, function()
                JoelBotC:SendMiddleMessage("Night " .. tostring(JoelBotC.currentNight + 1) .. " begins...", 5)
                net.Start("rdmtJoelBotCNightStarts")
                net.Broadcast()

                timer.Create("rdmtJoelBotCStartNightAfterNominations", 5, 1, function()
                    JoelBotC:StartNight()
                end)
            end)
        end)
    end

    -------------------------------------------------------------------------------------
    -- Win condition stuff
    -------------------------------------------------------------------------------------

    local pendingWinType
    local grimRevealOngoing
    local grimRevealComplete

    self:AddHook("TTTWinCheckBlocks", function(winBlocks)
        table.insert(winBlocks, function(win_type)
            if win_type == WIN_NONE then return win_type end

            if grimRevealComplete then
                return pendingWinType
            end

            if not grimRevealOngoing then
                grimRevealOngoing = true

                -- Backup in case nothing is received from clients?
                local maxRevealTime = 60

                JoelBotC:DoGrimReveal()

                timer.Create("JoelBotC_RevealBackup", maxRevealTime, 1, function()
                    grimRevealComplete = true
                end)
            end

            return WIN_NONE
        end)
    end)

    self:AddHook("TTTCheckForWin", function()
        if pendingWinType then
            return pendingWinType
        end

        if JoelBotC.isCurrentlyNight then return WIN_NONE end

        local demonAlive = false
        local livingCount = JoelBotC:AlivePlayerCount()

        for _, ply in ipairs(JoelBotC.demonPlayers) do
            if not ply.BotCDead then
                demonAlive = true
            end
        end

        if JoelBotC.saintExecuted then
            pendingWinType = WIN_TRAITOR
            return WIN_TRAITOR
        end

        if not demonAlive then
            pendingWinType = WIN_INNOCENT
            return WIN_INNOCENT
        end

        if livingCount <= 2 and demonAlive then
            pendingWinType = WIN_TRAITOR
            return WIN_TRAITOR
        end

        return WIN_NONE
    end)

    net.Receive("rdmtJoelBotCSendGrimRevealRoles", function(len, ply)
        grimRevealComplete = true

        timer.Remove("JoelBotC_RevealBackup")
    end)
end

function EVENT:End(isActive)
    -- Revert colours to default
    if isActive then
        COLOR_DETECTIVE = table.Copy(JoelBotC.original_COLOR_DETECTIVE)
        COLOR_SPECIAL_INNOCENT = table.Copy(JoelBotC.original_COLOR_SPECIAL_INNOCENT)
        COLOR_SPECIAL_TRAITOR = table.Copy(JoelBotC.original_COLOR_SPECIAL_TRAITOR)
        COLOR_MONSTER = table.Copy(JoelBotC.original_COLOR_MONSTER)
    end
    UpdateRoleColours()

    -- Remove books and give crowbar
    for i, ply in pairs(self:GetAlivePlayers()) do
        for _, wep in ipairs(ply:GetWeapons()) do
            if wep:GetClass() == "weapon_ttt_bookquill" or wep:GetClass() == "weapon_ttt_signedbook" or wep:GetClass() == "weapon_ttt_joelbotc_adminbook" then
                ply:StripWeapon(wep:GetClass())
            end
        end

        ply:Give("weapon_zm_improvised")
        ply:SelectWeapon("weapon_zm_improvised")
    end

    -- Revert players to original roles
    if isActive then
        for _, ply in ipairs(JoelBotC.players) do
            if ply.currentRole ~= nil and IsValid(ply) and not ply:IsSpec() then
                Randomat:SetRole(ply, ply.currentRole)
            end
        end
    end
    SendFullStateUpdate()

    -- Remove timers
    if isActive then
        local timerCount = #JoelBotC.players

        for timerNumber = 1, timerCount do
            local timerName = "rdmtJoelBotCMoveBigHand_" .. timerCount
                timer.Remove(timerName)
        end
    end

    timer.Remove("rdmtJoelBotC_gamestart_1")
    timer.Remove("rdmtJoelBotC_gamestart_2")
    timer.Remove("rdmtJoelBotC_gamestart_3")
    timer.Remove("rdmtJoelBotC_gamestart_4")

    timer.Remove("rdmtJoelBotC_nom_announcement_delay")
    timer.Remove("rdmtJoelBotC_discussion_timer")

    timer.Remove("rdmtJoelBotCNominationsEnd")
    timer.Remove("rdmtJoelBotCStartNightAfterNominations")
    timer.Remove("RdmtJoelBotCEndDayStartNominations")
    timer.Remove("rdmtJoelBotCStartDiscussionsAfterMorningDeaths")

    JoelBotC.rolesInGame = {}

    -- Misc stuff
    JoelBotC.rolePool = {}
    JoelBotC.deadPlayers = JoelBotC.deadPlayers or {}
    JoelBotC.unusedTownsfolk = {}
    JoelBotC.unusedOutsiders = {}
    JoelBotC.unusedMinions = {}
    JoelBotC.unusedDemons = {}

    --------------------------------------------------------------------------------
    -- Role function stuff
    --------------------------------------------------------------------------------
    -- Monk
    timer.Remove("rdmtJoelBotCMonk10")
    timer.Remove("rdmtJoelBotCMonk5")
    timer.Remove("rdmtJoelBotCMonk4")
    timer.Remove("rdmtJoelBotCMonk3")
    timer.Remove("rdmtJoelBotCMonk2")
    timer.Remove("rdmtJoelBotCMonk1")
    timer.Remove("rdmtJoelBotCMonk0")
    hook.Remove("Think", "rdmtJoelBotCMonkProtect")

    -- Assassin
    timer.Remove("rdmtJoelBotCAssassin10")
    timer.Remove("rdmtJoelBotCAssassin5")
    timer.Remove("rdmtJoelBotCAssassin4")
    timer.Remove("rdmtJoelBotCAssassin3")
    timer.Remove("rdmtJoelBotCAssassin2")
    timer.Remove("rdmtJoelBotCAssassin1")
    timer.Remove("rdmtJoelBotCAssassin0")
    hook.Remove("Think", "rdmtJoelBotCAssassinKill")

    JoelBotC.BotCEventRunning = false
end

Randomat:register(EVENT)