local EVENT = {}

JoelBotC = JoelBotC or {}

EVENT.Title = "JoelBotC"
EVENT.Description = ""
EVENT.id = "joelbotc"
EVENT.Categories = {"gamemode", "largeimpact", "rolechange"}

util.AddNetworkString("rdmtJoelBotCSeatingOrder")

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

local originalDetectiveCvar = nil

function EVENT:Begin()

    JoelBotC.BotCEventRunning = true

    JoelBotC.ravenkeeperKilledByDemon = nil

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

    timer.Create("rdmtJoelBotC_gamestart_2", 2, 1, function()
        Randomat:SmallNotify("Check your inventory for your notebook and information book!", 5)
    end)

    timer.Create("rdmtJoelBotC_gamestart_3", 3, 1, function()
        Randomat:SmallNotify("Night 1 will start in 2 seconds...", 5)
    end)

    timer.Create("rdmtJoelBotC_gamestart_4", 5, 1, function()
        print("Ran Start Night")
        JoelBotC.isFirstNight = true
        JoelBotC:StartNight()
    end)

    self:AddHook("TTTCheckForWin", function()
        local demonAlive = false
        local livingCount = JoelBotC:AlivePlayerCount()

        for _, ply in ipairs(JoelBotC.demonPlayers) do
            if not ply.BotCDead then
                demonAlive = true
            end
        end

        -- If there isn't an alive Demon, the Good team wins
        if not demonAlive then return WIN_INNOCENT end

        -- Otherwise, if there are <= 2 players alive, one of which is the Demon, then the Evil team wins
        if livingCount <= 2 and demonAlive then
            return WIN_TRAITOR
        end

        -- Otherwise, keep on playing
        return WIN_NONE
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


    -- Clear active roles table (I think this is the right way to do it?)
    for role, _ in ipairs(JoelBotC.rolesInGame) do
        JoelBotC.rolesInGame[role] = false
    end

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