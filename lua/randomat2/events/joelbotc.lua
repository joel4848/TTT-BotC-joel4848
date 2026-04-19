local EVENT = {}

JoelBotC = JoelBotC or {}

EVENT.Title = "JoelBotC"
EVENT.Description = "You know how this works!"
EVENT.id = "joelbotc"
EVENT.Categories = {"gamemode", "largeimpact", "rolechange"}

util.AddNetworkString("rdmtJoelBotCSeatingOrder")
util.AddNetworkString("rdmtJoelBotCAliveDeadUpdate")

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

local originalDetectiveCvar = nil

function EVENT:Begin()

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

    JoelBotC.isFirstNight = true

    timer.Simple(1, function()
        JoelBotC:GiveStartingBooks()
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
    hook.Remove("Think", "rdmtJoelBotcMonkProtect")

    -- Assassin
    timer.Remove("rdmtJoelBotCAssassin10")
    timer.Remove("rdmtJoelBotCAssassin5")
    timer.Remove("rdmtJoelBotCAssassin4")
    timer.Remove("rdmtJoelBotCAssassin3")
    timer.Remove("rdmtJoelBotCAssassin2")
    timer.Remove("rdmtJoelBotCAssassin1")
    timer.Remove("rdmtJoelBotCAssassin0")
    hook.Remove("Think", "rdmtJoelBotcAssassinKill")

end

Randomat:register(EVENT)