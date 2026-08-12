JoelBotC = JoelBotC or {}

JoelBotC.monkProtectedPlayer = nil
JoelBotC.poisonerPoisonedPlayer = nil
JoelBotC.players = JoelBotC.players or {}
JoelBotC.assassinAbilityUsed = nil
JoelBotC.nightwatchmanAbilityUsed = nil
JoelBotC.seamstressAbilityUsed = nil
JoelBotC.ravenkeeperAbilityUsed = nil
JoelBotC.nightFunctions = JoelBotC.nightFunctions or {}
JoelBotC.recentExecutee = JoelBotC.recentExecutee or nil
JoelBotC.deadPlayers = JoelBotC.deadPlayers or {}
JoelBotC.enabledTownsfolk = JoelBotC.enabledTownsfolk or {}
JoelBotC.enabledMinions = JoelBotC.enabledMinions or {}
JoelBotC.enabledOutsiders = JoelBotC.enabledOutsiders or {}
JoelBotC.unusedTownsfolk = JoelBotC.unusedTownsfolk or {}
JoelBotC.unusedOutsiders = JoelBotC.unusedOutsiders or {}
JoelBotC.unusedMinions = JoelBotC.unusedMinions or {}
JoelBotC.unusedDemons = JoelBotC.unusedDemons or {}
JoelBotC.ravenkeeperKilledByDemon = JoelBotC.ravenkeeperKilledByDemon or nil
JoelBotC.townsfolkInBag = JoelBotC.townsfolkInBag or {}
JoelBotC.outsidersInBag = JoelBotC.outsidersInBag or {}
JoelBotC.minionsInBag = JoelBotC.minionsInBag or {}
JoelBotC.demonsInBag = JoelBotC.demonsInBag or {}
JoelBotC.ogreIsEvil = JoelBotC.ogreIsEvil or nil
JoelBotC.monkPlayer = JoelBotC.monkPlayer or nil

function JoelBotC:GetNightFunctions()
    JoelBotC.nightFunctions = {
        [ROLE_STEWARDJBC] = {fn = JoelBotC.StewardNight, name = "StewardNight"},
        [ROLE_KNIGHTJBC] = {fn = JoelBotC.KnightNight, name = "KnightNight"},
        [ROLE_ORACLEJBC] = {fn = JoelBotC.OracleNight, name = "OracleNight"},
        [ROLE_CHEFJBC] = {fn = JoelBotC.ChefNight, name = "ChefNight"},
        [ROLE_UNDERTAKERJBC] = {fn = JoelBotC.UndertakerNight, name = "UndertakerNight"},
        [ROLE_NOBLEJBC] = {fn = JoelBotC.NobleNight, name = "NobleNight"},
        [ROLE_INVESTIGATORJBC] = {fn = JoelBotC.InvestigatorNight, name = "InvestigatorNight"},
        [ROLE_MONKJBC] = {fn = JoelBotC.MonkNight, name = "MonkNight"},
        [ROLE_WASHERWOMANJBC] = {fn = JoelBotC.WasherwomanNight, name = "WasherwomanNight"},
        [ROLE_NIGHTWATCHMANJBC] = {fn = JoelBotC.NightwatchmanNight, name = "NightwatchmanNight"},
        [ROLE_GRANDMOTHERJBC] = {fn = JoelBotC.GrandmotherNight, name = "GrandmotherNight"},
        [ROLE_SEAMSTRESSJBC] = {fn = JoelBotC.SeamstressNight, name = "SeamstressNight"},
        [ROLE_LIBRARIANJBC] = {fn = JoelBotC.LibrarianNight, name = "LibrarianNight"},
        [ROLE_EMPATHJBC] = {fn = JoelBotC.EmpathNight, name = "EmpathNight"},
        [ROLE_RAVENKEEPERJBC] = {fn = JoelBotC.RavenkeeperNight, name = "RavenkeeperNight"},
        [ROLE_FORTUNETELLERJBC] = {fn = JoelBotC.FortuneTellerNight, name = "FortuneTellerNight"},
        [ROLE_OGREJBC] = {fn = JoelBotC.OgreNight, name = "OgreNight"},
        [ROLE_POISONERJBC] = {fn = JoelBotC.PoisonerNight, name = "PoisonerNight"},
        [ROLE_ORGANGRINDERJBC] = {fn = JoelBotC.OrganGrinderNight, name = "OrganGrinderNight"},
        [ROLE_ASSASSINJBC] = {fn = JoelBotC.AssassinNight, name = "AssassinNight"},
        [ROLE_PUKKAJBC] = {fn = JoelBotC.PukkaNight, name = "PukkaNight"},
        [ROLE_IMPJBC] = {fn = JoelBotC.ImpNight, name = "ImpNight"},
        [ROLE_POJBC] = {fn = JoelBotC.PoNight, name = "PoNight"}
    }
end

----------------------------------------------------------------------------------------------------------------------------
-- ROLE FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------

-- Is droisoned
function JoelBotC:IsDroisoned(ply)
    if not IsValid(ply) then return false end
    return ply.poisonerPoisoned or ply.pukkaPoisoned or ply.organgrinderDrunk or ply.botc_role == ROLE_DRUNKJBC
end

-- Registers as evil
function JoelBotC:RegistersEvil(ply)
    if not IsValid(ply) then return false end
    return ply.evilTeam or ply.botc_role == ROLE_RECLUSEJBC
end

function JoelBotC:IsRoleBotCAlive(role)
    for _, ply in ipairs(JoelBotC.players) do
        if ply:GetRole() == role and not ply.BotCDead then
            return true
        end
    end
end

-- steward
function JoelBotC:StewardNight()
    local stewardInfo = nil

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsSteward() and not ply.BotCDead then
            if JoelBotC:IsDroisoned(ply) then
                repeat
                    table.Shuffle(JoelBotC.evilPlayers)
                    stewardInfo = JoelBotC.evilPlayers[1]
                until (stewardInfo ~= ply)
            else
                repeat
                    table.Shuffle(JoelBotC.goodPlayers)
                    stewardInfo = JoelBotC.goodPlayers[1]
                until (stewardInfo ~= ply)
            end

            local infoLine = stewardInfo:Nick() .. " is good"
            Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end

-- knight
function JoelBotC:KnightNight()
    local knightInfo1 = nil
    local knightInfo2 = nil
    local knightInfoPool = {}

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsKnight() and not ply.BotCDead then
            if JoelBotC:IsDroisoned(ply) then
                repeat
                    table.Shuffle(JoelBotC.players)
                    table.Shuffle(JoelBotC.demonPlayers)
                    knightInfo1 = JoelBotC.players[1]
                    knightInfo2 = JoelBotC.demonPlayers[2]
                until not (knightInfo1 == ply or knightInfo2 == ply or knightInfo1 == knightInfo2)
            else
                table.Add(knightInfoPool, JoelBotC.goodPlayers)
                table.Add(knightInfoPool, JoelBotC.minionPlayers)

                repeat
                    table.Shuffle(knightInfoPool)
                    knightInfo1 = knightInfoPool[1]
                    knightInfo2 = knightInfoPool[2]
                until not (knightInfo1 == ply or knightInfo2 == ply or knightInfo1 == knightInfo2)
            end

            local infoLine = "Neither " .. knightInfo1:Nick() .. " nor " .. knightInfo2:Nick() .. " is the Demon"
            Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end

-- oracle
function JoelBotC:OracleNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsOracle() and not ply.BotCDead then
            local previousEvilDead = previousEvilDead or 0
            local previousDeadPlayerAmount = previousDeadPlayerAmount or 0

            local evilDead = 0
            local deadPlayerAmount = #JoelBotC.deadPlayers

            for _, p in ipairs(JoelBotC.players) do
                if JoelBotC:RegistersEvil(p) and p.BotCDead then
                    evilDead = evilDead + 1
                end
            end

            if not JoelBotC:IsDroisoned(ply) then
                evilDead = evilDead
            else
                if deadPlayerAmount == previousDeadPlayerAmount then
                    evilDead = evilDead
                elseif deadPlayerAmount > previousDeadPlayerAmount then
                    if evilDead > previousEvilDead then
                        evilDead = previousEvilDead
                    elseif evilDead == previousEvilDead and JoelBotC.recentExecutee then
                        evilDead = evilDead + 1
                    end
                elseif deadPlayerAmount < previousDeadPlayerAmount then
                    if evilDead < previousEvilDead then
                        evilDead = previousEvilDead
                    elseif evilDead == previousEvilDead then
                        evilDead = evilDead - 1
                    end
                end
            end

            local infoLine = evilDead .. " dead player(s) are evil"
            Randomat:SmallNotify("Your nightly information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night " .. JoelBotC.currentNight .. ":", infoLine)

            previousEvilDead = evilDead
            previousDeadPlayerAmount = deadPlayerAmount
        end
    end

    JoelBotC:NextNightStep()
end

-- chef
function JoelBotC:ChefNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsChef() and not ply.BotCDead then
            local evilPairs = 0
            local seatCount = #JoelBotC.seatingOrder

            for i = 1, seatCount do
                local current  = JoelBotC.seatingOrder[i]
                local nextSeat = JoelBotC.seatingOrder[i % seatCount + 1]
                if JoelBotC:RegistersEvil(current) and JoelBotC:RegistersEvil(nextSeat) then
                    evilPairs = evilPairs + 1
                end
            end

            if JoelBotC:IsDroisoned(ply) then
                local recluseAmount = 0
                local droisonedEvilPairs = nil
                for _, p in ipairs(JoelBotC.players) do
                    if p:IsRecluse() then recluseAmount = recluseAmount + 1 end
                end
                repeat
                    droisonedEvilPairs = math.random(0, #JoelBotC.evilPlayers - 1 + recluseAmount)
                until (droisonedEvilPairs ~= evilPairs)
                evilPairs = droisonedEvilPairs
            end

            local infoLine = "There are " .. evilPairs .. " pair(s) of evil players sat next to each other"
            Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end

-- undertaker
function JoelBotC:UndertakerNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsUndertaker() and not ply.BotCDead then
            if JoelBotC.recentExecutee then
                local undertakerInfoPlayer = JoelBotC.recentExecutee
                local undertakerInfoRole   = ROLE_STRINGS[JoelBotC.recentExecutee.botc_role]

                if JoelBotC:IsDroisoned(ply) then
                    local undertakerDroisonedRolePool = {}
                    if JoelBotC:RegistersEvil(undertakerInfoPlayer) then
                        undertakerDroisonedRolePool = table.Copy(JoelBotC.demonBluffs)
                    else
                        undertakerDroisonedRolePool = table.Copy(JoelBotC.enabledMinions)
                    end
                    table.Shuffle(undertakerDroisonedRolePool)
                    undertakerInfoRole = ROLE_STRINGS[undertakerDroisonedRolePool[1]]
                end

                local infoLine = undertakerInfoPlayer:Nick() .. " was the " .. undertakerInfoRole
                Randomat:SmallNotify("You learn that " .. infoLine, 5, ply)
                JoelBotC:AppendInfoBook(ply, "Night " .. JoelBotC.currentNight .. ":", infoLine)
            end
        end
    end

    JoelBotC:NextNightStep()
end

-- noble
function JoelBotC:NobleNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsNoble() and not ply.BotCDead then
            local nobleInfoPool = {}
            local noblePick1, noblePick2, noblePick3
            local nobleGoodPool = table.Copy(JoelBotC.goodPlayers)
            local nobleEvilPool = {}

            table.Shuffle(nobleGoodPool)
            noblePick1 = nobleGoodPool[1]
            noblePick2 = nobleGoodPool[2]

            if (noblePick1:IsRecluse() or noblePick2:IsRecluse()) and math.random(0, 1) == 1 then
                noblePick3 = nobleGoodPool[3]
            else
                if math.random(1, 10) == 10 then
                    nobleEvilPool = table.Copy(JoelBotC.demonPlayers)
                else
                    nobleEvilPool = table.Copy(JoelBotC.minionPlayers)
                end
                table.Shuffle(nobleEvilPool)
                noblePick3 = nobleEvilPool[1]
            end

            if JoelBotC:IsDroisoned(ply) then
                repeat
                    table.Shuffle(nobleGoodPool)
                    noblePick1 = nobleGoodPool[1]
                    noblePick2 = nobleGoodPool[2]
                    noblePick3 = nobleGoodPool[3]
                until not (noblePick1:IsRecluse() or noblePick2:IsRecluse() or noblePick3:IsRecluse())
            end

            table.insert(nobleInfoPool, noblePick1)
            table.insert(nobleInfoPool, noblePick2)
            table.insert(nobleInfoPool, noblePick3)
            table.Shuffle(nobleInfoPool)

            local nobleInfo1 = nobleInfoPool[1]
            local nobleInfo2 = nobleInfoPool[2]
            local nobleInfo3 = nobleInfoPool[3]

            local infoLine = "One of " .. nobleInfo1:Nick() .. ", " .. nobleInfo2:Nick() .. " and " .. nobleInfo3:Nick() .. " is evil"
            Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end

-- investigator
function JoelBotC:InvestigatorNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsInvestigator() and not ply.BotCDead then
            local investigatorInfo1, investigatorInfo2
            local investigatorInfoPool  = {}
            local investigatorMinion    = nil
            local investigatorOther     = nil
            local investigatorMinionPool = table.Copy(JoelBotC.minionPlayers)
            local investigatorOtherPool  = table.Copy(JoelBotC.players)
            local investigatorMinionRole = nil

            table.Shuffle(investigatorMinionPool)
            investigatorMinion     = investigatorMinionPool[1]
            investigatorMinionRole = investigatorMinion:GetRoleString()

            repeat
                table.Shuffle(investigatorOtherPool)
                investigatorOther = investigatorOtherPool[1]
            until not (investigatorOther == ply or investigatorMinion == investigatorOther)

            for _, p in ipairs(JoelBotC.players) do
                if p:IsRecluse() then
                    if math.random(1, 3) == 1 then
                        investigatorMinion = p
                        local pool = table.Copy(JoelBotC.enabledMinions)
                        table.Shuffle(pool)
                        investigatorMinionRole = ROLE_STRINGS[pool[1]]
                    end
                end
            end

            if JoelBotC:IsDroisoned(ply) then
                local investigatorGoodPlayers = table.Copy(JoelBotC.goodPlayers)
                repeat
                    table.Shuffle(investigatorGoodPlayers)
                    investigatorMinion = investigatorGoodPlayers[1]
                    investigatorOther  = investigatorGoodPlayers[2]
                until not (investigatorMinion:IsRecluse() or investigatorOther:IsRecluse())

                local investigatorMinionRolePool
                if #JoelBotC.unusedMinions > 0 then
                    investigatorMinionRolePool = table.Copy(JoelBotC.unusedMinions)
                else
                    investigatorMinionRolePool = table.Copy(JoelBotC.enabledMinions)
                end

                local notInvestigatorMinionRole
                repeat
                    table.Shuffle(investigatorMinionRolePool)
                    notInvestigatorMinionRole = ROLE_STRINGS[investigatorMinionRolePool[1]]
                until (notInvestigatorMinionRole ~= investigatorMinionRole)
                investigatorMinionRole = notInvestigatorMinionRole
            end

            table.insert(investigatorInfoPool, investigatorMinion)
            table.insert(investigatorInfoPool, investigatorOther)
            table.Shuffle(investigatorInfoPool)
            investigatorInfo1 = investigatorInfoPool[1]
            investigatorInfo2 = investigatorInfoPool[2]

            local infoLine = "Either " .. investigatorInfo1:Nick() .. " or " .. investigatorInfo2:Nick() .. " is the " .. investigatorMinionRole
            Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end

-- monk
function JoelBotC:MonkNight()
    local didMonkStuff = false
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsMonk() and not ply.BotCDead then
            didMonkStuff = true

            JoelBotC.monkPlayer = ply

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Choose a player to protect from the Demon tonight", 5, ply)

            timer.Create("rdmtJoelBotCMonk10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCMonk5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCMonk4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCMonk3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCMonk2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCMonk1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCMonk0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCMonkProtect")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            JoelBotC.monkProtectedPlayer = nil
            hook.Add("Think", "rdmtJoelBotCMonkProtect", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC.monkProtectedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                    end
                    JoelBotC:SendSeatingGUIDestroy(ply)
                    JoelBotC:NextNightStep()

                    timer.Remove("rdmtJoelBotCMonk10")
                    timer.Remove("rdmtJoelBotCMonk5")
                    timer.Remove("rdmtJoelBotCMonk4")
                    timer.Remove("rdmtJoelBotCMonk3")
                    timer.Remove("rdmtJoelBotCMonk2")
                    timer.Remove("rdmtJoelBotCMonk1")
                    timer.Remove("rdmtJoelBotCMonk0")
                    hook.Remove("Think", "rdmtJoelBotCMonkProtect")
                end
            end)
        end
    end
    if not didMonkStuff then
        JoelBotC:NextNightStep()
    end
end

-- washerwoman
function JoelBotC:WasherwomanNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsWasherwoman() and not ply.BotCDead then
            local washerwomanInfo1, washerwomanInfo2
            local washerwomanInfoPool       = {}
            local washerwomanTownsfolk      = nil
            local washerwomanOther          = nil
            local washerwomanTownsfolkPool  = table.Copy(JoelBotC.townsfolkPlayers)
            local washerwomanOtherPool      = table.Copy(JoelBotC.players)
            local washerwomanTownsfolkRole  = nil

            repeat
                table.Shuffle(washerwomanTownsfolkPool)
                washerwomanTownsfolk = washerwomanTownsfolkPool[1]
            until (washerwomanTownsfolk ~= ply)
            washerwomanTownsfolkRole = washerwomanTownsfolk:GetRoleString()

            repeat
                table.Shuffle(washerwomanOtherPool)
                washerwomanOther = washerwomanOtherPool[1]
            until not (washerwomanOther == ply or washerwomanTownsfolk == washerwomanOther)

            if JoelBotC:IsDroisoned(ply) then
                local washerwomanMinionPool = table.Copy(JoelBotC.minionPlayers)
                repeat
                    table.Shuffle(washerwomanMinionPool)
                    washerwomanTownsfolk = washerwomanMinionPool[1]
                until (washerwomanTownsfolk ~= washerwomanOther)

                local droisonedPool
                if #JoelBotC.unusedTownsfolk > 0 then
                    droisonedPool = table.Copy(JoelBotC.unusedTownsfolk)
                else
                    droisonedPool = table.Copy(JoelBotC.enabledTownsfolk)
                end
                table.Shuffle(droisonedPool)
                washerwomanTownsfolkRole = droisonedPool[1]
            end

            table.insert(washerwomanInfoPool, washerwomanTownsfolk)
            table.insert(washerwomanInfoPool, washerwomanOther)
            table.Shuffle(washerwomanInfoPool)
            washerwomanInfo1 = washerwomanInfoPool[1]
            washerwomanInfo2 = washerwomanInfoPool[2]

            local infoLine = "Either " .. washerwomanInfo1:Nick() .. " or " .. washerwomanInfo2:Nick() .. " is the " .. washerwomanTownsfolkRole
            Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end

-- nightwatchman
function JoelBotC:NightwatchmanNight()
    local didNightwatchmanStuff = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsNightwatchman() and not ply.BotCDead and not JoelBotC.nightwatchmanAbilityUsed then
            didNightwatchmanStuff = true

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Use your ability tonight? Choose a player to be told you are the Nightwatchman", 5, ply)

            timer.Create("rdmtJoelBotCNightwatchman10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCNightwatchman5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCNightwatchman4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCNightwatchman3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCNightwatchman2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCNightwatchman1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCNightwatchman0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCNightwatchmanInform")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            hook.Add("Think", "rdmtJoelBotCNightwatchmanInform", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber then
                    if not JoelBotC:IsDroisoned(ply) then
                        local informedPly = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                        local nwInfoLine  = ply:Nick() .. " is the Nightwatchman"
                        Randomat:SmallNotify("Tonight you learn that " .. nwInfoLine, 5, informedPly)
                        JoelBotC:AppendInfoBook(informedPly, "Night " .. JoelBotC.currentNight .. ":", nwInfoLine)
                    end
                    JoelBotC.nightwatchmanAbilityUsed = true
                    JoelBotC:SendSeatingGUIDestroy(ply)
                    JoelBotC:NextNightStep()

                    timer.Remove("rdmtJoelBotCNightwatchman10")
                    timer.Remove("rdmtJoelBotCNightwatchman5")
                    timer.Remove("rdmtJoelBotCNightwatchman4")
                    timer.Remove("rdmtJoelBotCNightwatchman3")
                    timer.Remove("rdmtJoelBotCNightwatchman2")
                    timer.Remove("rdmtJoelBotCNightwatchman1")
                    timer.Remove("rdmtJoelBotCNightwatchman0")
                    hook.Remove("Think", "rdmtJoelBotCNightwatchmanInform")
                end
            end)
        end
    end

    if not didNightwatchmanStuff then
        JoelBotC:NextNightStep()
    end
end

-- grandmother
function JoelBotC:GrandmotherNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsGrandmother() and not ply.BotCDead then

            JoelBotC.grandmother = ply
            JoelBotC.grandchild  = nil

            local grandchild, grandchildRole
            local grandmotherPool = {}

            if #JoelBotC.outsiderPlayers > 0 then
                if math.random(0, 4) == 4 then
                    grandmotherPool = table.Copy(JoelBotC.outsiderPlayers)
                else
                    grandmotherPool = table.Copy(JoelBotC.townsfolkPlayers)
                end
            else
                grandmotherPool = table.Copy(JoelBotC.townsfolkPlayers)
            end

            repeat
                table.Shuffle(grandmotherPool)
                grandchild = grandmotherPool[1]
            until (grandchild ~= ply)
            JoelBotC.grandchild = grandchild
            grandchildRole = grandchild:GetRoleString()

            if JoelBotC:IsDroisoned(ply) then
                JoelBotC.grandchild = nil
                local droisonedPool, droisonedRolePool

                if math.random(0, 4) == 4 then
                    droisonedPool     = table.Copy(JoelBotC.demonPlayers)
                    droisonedRolePool = table.Copy(JoelBotC.demonBluffs)
                    table.Shuffle(droisonedPool)
                    grandchild = droisonedPool[1]
                    table.Shuffle(droisonedRolePool)
                    grandchildRole = ROLE_STRINGS[droisonedRolePool[1]]
                else
                    droisonedPool     = table.Copy(JoelBotC.minionPlayers)
                    droisonedRolePool = table.Copy(JoelBotC.demonBluffsPool)
                    table.Shuffle(droisonedPool)
                    grandchild = droisonedPool[1]
                    table.Shuffle(droisonedRolePool)
                    grandchildRole = ROLE_STRINGS[droisonedRolePool[1]]
                end
            end

            local infoLine = "Your grandchild is " .. grandchild:Nick() .. ", the " .. grandchildRole
            Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end

-- seamstress
function JoelBotC:SeamstressNight()
    local didSeamstressStuff = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsSeamstress() and not ply.BotCDead and not JoelBotC.seamstressAbilityUsed then
            didSeamstressStuff = true

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Use your ability tonight? Choose two\nplayers and learn if they're the same alignment", 5, ply)

            timer.Create("rdmtJoelBotCSeamstress10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCSeamstress5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCSeamstress4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCSeamstress3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCSeamstress2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCSeamstress1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCSeamstress0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCSeamstressChoose1")
                hook.Remove("Think", "rdmtJoelBotCSeamstressChoose2")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            local chosenSeat1 = nil
            local chosenSeat2 = nil

            hook.Add("Think", "rdmtJoelBotCSeamstressChoose1", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber then

                    chosenSeat1 = JoelBotC.seatingGUIButtonPressed

                    hook.Add("Think", "rdmtJoelBotCSeamstressChoose2", function()
                        if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber and JoelBotC.seatingGUIButtonPressed ~= chosenSeat1 then

                            chosenSeat2 = JoelBotC.seatingGUIButtonPressed

                            local chosenPlayer1 = JoelBotC.seatingOrder[chosenSeat1]
                            local chosenPlayer2 = JoelBotC.seatingOrder[chosenSeat2]

                            local sameTeam = (JoelBotC:RegistersEvil(chosenPlayer1) == JoelBotC:RegistersEvil(chosenPlayer2))
                            if JoelBotC:IsDroisoned(ply) then sameTeam = not sameTeam end

                            local infoLine
                            if sameTeam then
                                infoLine = chosenPlayer1:Nick() .. " and " .. chosenPlayer2:Nick() .. " are on the same team"
                            else
                                infoLine = chosenPlayer1:Nick() .. " and " .. chosenPlayer2:Nick() .. " are NOT on the same team"
                            end

                            Randomat:SmallNotify(infoLine, 5, ply)
                            JoelBotC:AppendInfoBook(ply, "Night " .. JoelBotC.currentNight .. ":", infoLine)

                            JoelBotC.seamstressAbilityUsed = true

                            JoelBotC:SendSeatingGUIDestroy(ply)
                            JoelBotC:NextNightStep()

                            timer.Remove("rdmtJoelBotCSeamstress10")
                            timer.Remove("rdmtJoelBotCSeamstress5")
                            timer.Remove("rdmtJoelBotCSeamstress4")
                            timer.Remove("rdmtJoelBotCSeamstress3")
                            timer.Remove("rdmtJoelBotCSeamstress2")
                            timer.Remove("rdmtJoelBotCSeamstress1")
                            timer.Remove("rdmtJoelBotCSeamstress0")
                            hook.Remove("Think", "rdmtJoelBotCSeamstressChoose2")
                        end

                        hook.Remove("Think", "rdmtJoelBotCSeamstressChoose1")
                    end)
                end
            end)
        end
    end

    if not didSeamstressStuff then
        JoelBotC:NextNightStep()
    end
end

-- librarian
function JoelBotC:LibrarianNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsLibrarian() and not ply.BotCDead then
            local librarianInfo1, librarianInfo2
            local librarianInfoPool    = {}
            local librarianOutsider    = nil
            local librarianOther       = nil
            local librarianOutsiderPool = table.Copy(JoelBotC.outsiderPlayers)
            local librarianOtherPool   = table.Copy(JoelBotC.players)
            local librarianOutsiderRole = nil

            if #librarianOutsiderPool == 0 then
                local infoLine = "There are no Outsiders"
                Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
                JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
            else
                repeat
                    table.Shuffle(librarianOutsiderPool)
                    librarianOutsider = librarianOutsiderPool[1]
                until (librarianOutsider ~= ply)
                librarianOutsiderRole = librarianOutsider:GetRoleString()

                repeat
                    table.Shuffle(librarianOtherPool)
                    librarianOther = librarianOtherPool[1]
                until not (librarianOther == ply or librarianOutsider == librarianOther)

                if JoelBotC:IsDroisoned(ply) then
                    local librarianMinionPool = table.Copy(JoelBotC.minionPlayers)
                    repeat
                        table.Shuffle(librarianMinionPool)
                        librarianOutsider = librarianMinionPool[1]
                    until (librarianOutsider ~= librarianOther)

                    local droisonedPool
                    if #JoelBotC.unusedOutsiders > 0 then
                        droisonedPool = table.Copy(JoelBotC.unusedOutsiders)
                    else
                        droisonedPool = table.Copy(JoelBotC.enabledOutsiders)
                    end
                    table.Shuffle(droisonedPool)
                    librarianOutsiderRole = droisonedPool[1]
                end

                table.insert(librarianInfoPool, librarianOutsider)
                table.insert(librarianInfoPool, librarianOther)
                table.Shuffle(librarianInfoPool)
                librarianInfo1 = librarianInfoPool[1]
                librarianInfo2 = librarianInfoPool[2]

                local infoLine = "Either " .. librarianInfo1:Nick() .. " or " .. librarianInfo2:Nick() .. " is the " .. librarianOutsiderRole
                Randomat:SmallNotify("Your starting information: " .. infoLine, 5, ply)
                JoelBotC:AppendInfoBook(ply, "Night 1:", infoLine)
            end
        end
    end

    JoelBotC:NextNightStep()
end


-- empath
local empathInfo
local deadNeighbours

function JoelBotC:EmpathNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsEmpath() and not ply.BotCDead then
            local previousEmpathInfo = empathInfo or nil
            empathInfo = 0
            local seatCount = #JoelBotC.seatingOrder
            local previousDeadNeighbours = deadNeighbours or nil
            deadNeighbours = 0

            -- Find the Empath's seat
            local seatIndex = nil
            for i, p in ipairs(JoelBotC.seatingOrder) do
                if p == ply then
                    seatIndex = i
                    break
                end
            end

            -- Find leftwards living neighbour
            local leftIndex = seatIndex
            repeat
                leftIndex = (leftIndex - 2) % seatCount + 1
                if not JoelBotC.seatingOrder[leftIndex].BotCDead then
                    deadNeighbours = deadNeighbours + 1
                end
            until not JoelBotC.seatingOrder[leftIndex].BotCDead

            local leftNeighbour = JoelBotC.seatingOrder[leftIndex]

            -- Find rightwards living neighbour
            local rightIndex = seatIndex
            repeat
                rightIndex = rightIndex % seatCount + 1
                if not JoelBotC.seatingOrder[rightIndex].BotCDead then
                    deadNeighbours = deadNeighbours + 1
                end
            until not JoelBotC.seatingOrder[rightIndex].BotCDead

            local rightNeighbour = JoelBotC.seatingOrder[rightIndex]

            -- Check if neighbours register as evil
            if JoelBotC:RegistersEvil(leftNeighbour) then
                empathInfo = empathInfo + 1
            end

            if JoelBotC:RegistersEvil(rightNeighbour) then
                empathInfo = empathInfo + 1
            end

            -- Droisoned bollocks
            if JoelBotC:IsDroisoned(ply) then
                if not previousEmpathInfo then previousEmpathInfo = math.random (0,2) end
                if previousDeadNeighbours == deadNeighbours then
                    empathInfo = previousEmpathInfo
                else
                    if empathInfo == 0 then
                        empathInfo = 1
                    elseif empathInfo == 1 then
                        if previousEmpathInfo == 0 or previousEmpathInfo == 1 then
                            empathInfo = 0
                        elseif previousEmpathInfo == 2 then
                            empathInfo = 1
                        end
                    elseif empathInfo == 2 then
                        if previousEmpathInfo == 0 or previousEmpathInfo == 1 then
                            empathInfo = 0
                        elseif previousEmpathInfo == 2 then
                            empathInfo = 1
                        end
                    end
                end
            end

            -- Actually give the information
            local infoLine
            if empathInfo == 0 then
                infoLine = "Neither of your alive neighbours are evil"
            elseif empathInfo == 1 then
                infoLine = "One of your alive neighbours is evil"
            elseif empathInfo == 2 then
                infoLine = "Both of your alive neighbours are evil"
            end

            Randomat:SmallNotify("Your nightly information: " .. infoLine, 5, ply)
            JoelBotC:AppendInfoBook(ply, "Night " .. JoelBotC.currentNight .. ":", infoLine)
        end
    end

    JoelBotC:NextNightStep()
end


-- ravenkeeper
function JoelBotC:RavenkeeperNight()
    local didRavenkeeperStuff = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsRavenkeeper() then
            if JoelBotC.ravenkeeperKilledByDemon and not JoelBotC.ravenkeeperAbilityUsed then
                didRavenkeeperStuff = true

                JoelBotC:SendSeatingGUICreate(ply)

                Randomat:SmallNotify("15 Seconds: You have been killed by the Demon.\n             Choose a player to learn their role", 5, ply)

                timer.Create("rdmtJoelBotCRavenkeeper10", 5, 1, function()
                    Randomat:SmallNotify("10 seconds to choose", 5, ply)
                end)
                timer.Create("rdmtJoelBotCRavenkeeper5", 10, 1, function()
                    Randomat:SmallNotify("5 seconds to choose", 1, ply)
                end)
                timer.Create("rdmtJoelBotCRavenkeeper4", 11, 1, function()
                    Randomat:SmallNotify("4 seconds to choose", 1, ply)
                end)
                timer.Create("rdmtJoelBotCRavenkeeper3", 12, 1, function()
                    Randomat:SmallNotify("3 seconds to choose", 1, ply)
                end)
                timer.Create("rdmtJoelBotCRavenkeeper2", 13, 1, function()
                    Randomat:SmallNotify("2 seconds to choose", 1, ply)
                end)
                timer.Create("rdmtJoelBotCRavenkeeper1", 14, 1, function()
                    Randomat:SmallNotify("1 second to choose", 1, ply)
                end)
                timer.Create("rdmtJoelBotCRavenkeeper0", 15, 1, function()
                    hook.Remove("Think", "rdmtJoelBotCRavenkeeperChoose")
                    JoelBotC:SendSeatingGUIDestroy(ply)
                    JoelBotC:NextNightStep()
                end)

                JoelBotC.seatingGUIButtonPressed = nil
                JoelBotC.seatingGUIPressingPlayer = nil
                local chosenPlayer = nil
                local chosenPlayerRole = nil

                hook.Add("Think", "rdmtJoelBotCRavenkeeperChoose", function()
                    if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then

                        chosenPlayer = JoelBotC.seatingOrder[JoelBotC.seatingGUIButtonPressed]
                        chosenPlayerRole = chosenPlayer:GetRoleString()

                        if JoelBotC:IsDroisoned(ply) then
                            if JoelBotC:RegistersEvil(chosenPlayer) then
                                local ravenkeeperDemonBluffPool = table.Copy(JoelBotC.demonBluffs)
                                table.Shuffle(ravenkeeperDemonBluffPool)
                                chosenPlayerRole = ROLE_STRINGS[ravenkeeperDemonBluffPool[1]]
                            else
                                local ravenkeeperEvilRolePool = table.Copy(JoelBotC.minionsInBag)
                                table.Add(ravenkeeperEvilRolePool, JoelBotC.demonsInBag)
                                table.Shuffle(ravenkeeperEvilRolePool)
                                chosenPlayerRole = ROLE_STRINGS[ravenkeeperEvilRolePool[1]]
                            end
                        end
                        JoelBotC:SendSeatingGUIDestroy(ply)
                        JoelBotC:NextNightStep()

                        local rkInfoLine = chosenPlayer:Nick() .. " is the " .. chosenPlayerRole
                        Randomat:SmallNotify(rkInfoLine, 5, ply)
                        JoelBotC:AppendInfoBook(ply, "Night " .. JoelBotC.currentNight .. ":", rkInfoLine)

                        timer.Remove("rdmtJoelBotCRavenkeeper10")
                        timer.Remove("rdmtJoelBotCRavenkeeper5")
                        timer.Remove("rdmtJoelBotCRavenkeeper4")
                        timer.Remove("rdmtJoelBotCRavenkeeper3")
                        timer.Remove("rdmtJoelBotCRavenkeeper2")
                        timer.Remove("rdmtJoelBotCRavenkeeper1")
                        timer.Remove("rdmtJoelBotCRavenkeeper0")
                        hook.Remove("Think", "rdmtJoelBotCRavenkeeperChoose")
                    end
                end)

                JoelBotC.ravenkeeperKilledByDemon = nil
                JoelBotC.ravenkeeperAbilityUsed = true
            else
                JoelBotC:NextNightStep()
            end
        end
    end
    if not didRavenkeeperStuff then
        JoelBotC:NextNightStep()
    end
end

-- fortuneteller
function JoelBotC.FortuneTellerRedHerring()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsFortuneTeller() then
            if JoelBotC.redHerring == nil then
                local fortunetellerRedHerringPool = {}
                fortunetellerRedHerringPool = table.Copy(JoelBotC.townsfolkPlayers)

                table.Shuffle(fortunetellerRedHerringPool)
                JoelBotC.redHerring = fortunetellerRedHerringPool[1]
                fortunetellerRedHerringPool[1].redHerring = true
            end
        end
    end
end

function JoelBotC:FortuneTellerNight()
    local didFortuneTellerStuff = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsFortuneTeller() then
            didFortuneTellerStuff = true

            -- Helper function for whether a chosen player should register as the Demon to the FT
            local function FortuneTellerYes(choice)
                if not IsValid(choice) then return false end
                return choice.demon or choice.redHerring or choice:IsRecluse()
            end

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Choose two players and learn if either is the Demon or your Red Herring", 5, ply)

            timer.Create("rdmtJoelBotCFortuneTeller10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCFortuneTeller5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCFortuneTeller4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCFortuneTeller3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCFortuneTeller2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCFortuneTeller1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCFortuneTeller0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCFortuneTellerChoose")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            local chosenPlayer1 = nil
            local chosenPlayer2 = nil
            local chosenSeat1 = nil
            local chosenSeat2 = nil

            hook.Add("Think", "rdmtJoelBotCFortuneTellerChoose1", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then

                    chosenSeat1 = JoelBotC.seatingGUIButtonPressed

                    hook.Add("Think", "rdmtJoelBotCFortuneTellerChoose2", function()
                        if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= chosenSeat1 then

                            chosenSeat2 = JoelBotC.seatingGUIButtonPressed

                            chosenPlayer1 = JoelBotC.seatingOrder[chosenSeat1]
                            chosenPlayer2 = JoelBotC.seatingOrder[chosenSeat2]

                            local fortunetellerGotDemon = false

                            if not JoelBotC:IsDroisoned(ply) then
                                if FortuneTellerYes(chosenPlayer1) or FortuneTellerYes(chosenPlayer2) then
                                    fortunetellerGotDemon = true
                                else
                                    fortunetellerGotDemon = false
                                end
                            else
                                if FortuneTellerYes(chosenPlayer1) or FortuneTellerYes(chosenPlayer2) then
                                    fortunetellerGotDemon = false
                                else
                                    fortunetellerGotDemon = true
                                end
                            end

                            local ftInfoLine
                            if fortunetellerGotDemon then
                                ftInfoLine = "Yes - one of " .. chosenPlayer1:Nick() .. " or " .. chosenPlayer2:Nick() .. " is the Demon"
                            else
                                ftInfoLine = "No - neither of " .. chosenPlayer1:Nick() .. " or " .. chosenPlayer2:Nick() .. " is the Demon"
                            end

                            Randomat:SmallNotify(ftInfoLine, 5, ply)
                            JoelBotC:AppendInfoBook(ply, "Night " .. JoelBotC.currentNight .. ":", ftInfoLine)

                            JoelBotC:SendSeatingGUIDestroy(ply)
                            JoelBotC:NextNightStep()

                            timer.Remove("rdmtJoelBotCFortuneTeller10")
                            timer.Remove("rdmtJoelBotCFortuneTeller5")
                            timer.Remove("rdmtJoelBotCFortuneTeller4")
                            timer.Remove("rdmtJoelBotCFortuneTeller3")
                            timer.Remove("rdmtJoelBotCFortuneTeller2")
                            timer.Remove("rdmtJoelBotCFortuneTeller1")
                            timer.Remove("rdmtJoelBotCFortuneTeller0")
                            hook.Remove("Think", "rdmtJoelBotCFortuneTellerChoose2")
                        end

                        hook.Remove("Think", "rdmtJoelBotCFortuneTellerChoose1")
                    end)
                end
            end)
        end
    end

    if not didFortuneTellerStuff then
        JoelBotC:NextNightStep()
    end
end


-- virgin



-- ogre
function JoelBotC:OgreNight()
    local didOgreStuff = false
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsOgre() then
            didOgreStuff = true

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Pick a player and join their team.\n             (You don't learn which team)", 5, ply)

            timer.Create("rdmtJoelBotCOgre10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCOgre5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCOgre4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCOgre3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCOgre2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCOgre1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCOgre0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCOgreChoose")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            local chosenPlayer = nil
            JoelBotC.ogreIsEvil = false

            hook.Add("Think", "rdmtJoelBotCOgreChoose", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then

                    chosenPlayer = JoelBotC.seatingOrder[JoelBotC.seatingGUIButtonPressed]

                    if JoelBotC:IsDroisoned(ply) then
                        JoelBotC.ogreIsEvil = false
                    elseif JoelBotC:RegistersEvil(chosenPlayer) then
                        JoelBotC.ogreIsEvil = true

                        if chosenPlayer:IsRecluse() then
                            local ogreInfoLine = "You chose the Recluse - you are now EVIL"
                            Randomat:SmallNotify("You chose the Recluse, so learn that you are now EVIL", 5, ply)
                            JoelBotC:AppendInfoBook(ply, "Night 1:", ogreInfoLine)
                        end
                    end
                    JoelBotC:SendSeatingGUIDestroy(ply)
                    JoelBotC:NextNightStep()

                    timer.Remove("rdmtJoelBotCOgre10")
                    timer.Remove("rdmtJoelBotCOgre5")
                    timer.Remove("rdmtJoelBotCOgre4")
                    timer.Remove("rdmtJoelBotCOgre3")
                    timer.Remove("rdmtJoelBotCOgre2")
                    timer.Remove("rdmtJoelBotCOgre1")
                    timer.Remove("rdmtJoelBotCOgre0")
                    hook.Remove("Think", "rdmtJoelBotCOgreChoose")
                end
            end)
        end
    end

    if not didOgreStuff then
        JoelBotC:NextNightStep()
    end
end



-- Snitch
function JoelBotC:SnitchExists()
    local snitchExists = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsSnitch() and not ply.BotCDead and not JoelBotC:IsDroisoned(ply) then
            snitchExists = true
        end
    end

    return snitchExists
end


-- Golem



-- sweetheart
function JoelBotC:SweetheartDeath(sweetheart)
    local sweetheartPoisonPool = {}
    local sweetheartPoisonedPlayer = nil

    if math.random(0, 4) == 4 then
        sweetheartPoisonPool = table.Copy(JoelBotC.outsiderPlayers)
    else
        sweetheartPoisonPool = table.Copy(JoelBotC.townsfolkPlayers)
    end

    repeat
        table.Shuffle(sweetheartPoisonPool)
        sweetheartPoisonedPlayer = sweetheartPoisonPool[1]
    until not (sweetheartPoisonedPlayer == sweetheart or sweetheartPoisonedPlayer.BotCDead)
end


-- saint



-- drunk




-- poisoner
function JoelBotC:PoisonerNight()
    local didPoisonerStuff = false
    -- local poisonerExists = nil

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsRole(ROLE_POISONERJBC) and not ply.BotCDead then
            didPoisonerStuff = true
            -- poisonerExists = true

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Choose a player to poison for tonight and tomorrow", 5, ply)

            timer.Create("rdmtJoelBotCPoisoner10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCPoisoner5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPoisoner4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPoisoner3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPoisoner2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPoisoner1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPoisoner0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCPoisonerPoison")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            if JoelBotC.poisonerPoisonedPlayer then
                JoelBotC.poisonerPoisonedPlayer.poisonerPoisoned = false
            end
            JoelBotC.poisonerPoisonedPlayer = nil
            hook.Add("Think", "rdmtJoelBotCPoisonerPoison", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC.poisonerPoisonedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                    end
                    JoelBotC:SendSeatingGUIDestroy(ply)
                    JoelBotC:NextNightStep()

                    timer.Remove("rdmtJoelBotCPoisoner10")
                    timer.Remove("rdmtJoelBotCPoisoner5")
                    timer.Remove("rdmtJoelBotCPoisoner4")
                    timer.Remove("rdmtJoelBotCPoisoner3")
                    timer.Remove("rdmtJoelBotCPoisoner2")
                    timer.Remove("rdmtJoelBotCPoisoner1")
                    timer.Remove("rdmtJoelBotCPoisoner0")
                    hook.Remove("Think", "rdmtJoelBotCPoisonerPoison")
                end
            end)
        end
    end

    if not didPoisonerStuff then
        JoelBotC:NextNightStep()
    end
end


-- scarletwoman
function JoelBotC:MakeScarletWomanDemon(demonType)
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsScarletWoman() and not ply.BotCDead and not JoelBotC:IsDroisoned(ply) then
            ply.minion = nil
            ply.demon = true

            table.RemoveByValue(JoelBotC.minionPlayers, ply)
            table.insert(JoelBotC.demonPlayers, ply)
            ply.botc_role = demonType

            Randomat:SetRole(ply, ply.botc_role)
            SendFullStateUpdate()

            Randomat:SmallNotify("You are now the " .. ROLE_STRINGS[demonType], 5, ply)
        end
    end
end



-- organgrinder
function JoelBotC:IsOGSober()
    local organgrinderSober = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsOrganGrinder() and not ply.BotCDead and not JoelBotC:IsDroisoned(ply) then
            organgrinderSober = true
        end
    end

    return organgrinderSober
end

function JoelBotC:OrganGrinderNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsOrganGrinder() and not ply.BotCDead then
            net.Start("rdmtJoelBotCOrganGrinderGUI")
            net.Send(ply)
        end
    end

    JoelBotC:NextNightStep()
end

net.Receive("rdmtJoelBotCOrganGrinderGUI", function(_, ply)
    local response = net.ReadBool()

    if ply:IsOrganGrinder() then
        ply.organgrinderDrunk = response
    end

    -- for _, ply in ipairs(JoelBotC.players) do
    --     if ply:IsOrganGrinder() then
    --         ply.organgrinderDrunk = response
    --     end
    -- end
end)

-- assassin
function JoelBotC:AssassinNight()
    local didAssassinStuff = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsRole(ROLE_ASSASSINJBC) and not ply.BotCDead and not JoelBotC.assassinAbilityUsed then
            didAssassinStuff = true

            JoelBotC.assassinTargetTonight = nil
            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Use your ability tonight?\nChoose a player to kill", 5, ply)

            timer.Create("rdmtJoelBotCAssassin10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCAssassin5", 10, 1, function()
            end)
            timer.Create("rdmtJoelBotCAssassin4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCAssassin3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCAssassin2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCAssassin1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCAssassin0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCAssassinKill")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            hook.Add("Think", "rdmtJoelBotCAssassinKill", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC.assassinTargetTonight = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                        JoelBotC:NightPreKill(JoelBotC.assassinTargetTonight, ply)
                    end
                    JoelBotC.assassinAbilityUsed = true
                    JoelBotC:SendSeatingGUIDestroy(ply)
                    JoelBotC:NextNightStep()

                    timer.Remove("rdmtJoelBotCAssassin10")
                    timer.Remove("rdmtJoelBotCAssassin5")
                    timer.Remove("rdmtJoelBotCAssassin4")
                    timer.Remove("rdmtJoelBotCAssassin3")
                    timer.Remove("rdmtJoelBotCAssassin2")
                    timer.Remove("rdmtJoelBotCAssassin1")
                    timer.Remove("rdmtJoelBotCAssassin0")
                    hook.Remove("Think", "rdmtJoelBotCAssassinKill")
                end
            end)
        end
    end

    if not didAssassinStuff then
        JoelBotC:NextNightStep()
    end
end


-- baron



-- pukka
function JoelBotC:PukkaNight()
    local didPukkaStuff
    -- local pukkaExists = nil

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsPukka() and not ply.BotCDead then
            didPukkaStuff = true
            -- pukkaExists = true

            JoelBotC.pukkaPoisonedPlayer = JoelBotC.pukkaPoisonedPlayer or nil
            JoelBotC.pukkaTonightPoisoned = nil
            JoelBotC.pukkaTonightKilled = nil

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Choose a player to poison tonight and kill tomorrow night", 5, ply)

            timer.Create("rdmtJoelBotCPukka10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCPukka5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPukka4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPukka3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPukka2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPukka1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCPukka0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCPukkaPoison")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil

            hook.Add("Think", "rdmtJoelBotCPukkaPoison", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC.pukkaTonightPoisoned = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                    end
                    JoelBotC:SendSeatingGUIDestroy(ply)
                    JoelBotC:NextNightStep()

                    timer.Remove("rdmtJoelBotCPukka10")
                    timer.Remove("rdmtJoelBotCPukka5")
                    timer.Remove("rdmtJoelBotCPukka4")
                    timer.Remove("rdmtJoelBotCPukka3")
                    timer.Remove("rdmtJoelBotCPukka2")
                    timer.Remove("rdmtJoelBotCPukka1")
                    timer.Remove("rdmtJoelBotCPukka0")

                    hook.Remove("Think", "rdmtJoelBotCPukkaPoison")
                end
            end)

            if JoelBotC.pukkaPoisonedPlayer then
                JoelBotC.pukkaTonightKilled = JoelBotC.pukkaPoisonedPlayer
                JoelBotC:NightPreKill(JoelBotC.pukkaTonightKilled, ply)
            end

            JoelBotC.pukkaPoisonedPlayer = JoelBotC.pukkaTonightPoisoned
        end
    end

    if not didPukkaStuff then
        JoelBotC:NextNightStep()
    end
end


-- imp
function JoelBotC:ImpNight()
    local didImpStuff = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsImp() and not ply.BotCDead then
            didImpStuff = true

            JoelBotC:SendSeatingGUICreate(ply)

            Randomat:SmallNotify("15 Seconds: Choose a player to kill tonight", 5, ply)

            timer.Create("rdmtJoelBotCImp10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCImp5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCImp4", 11, 1, function()
                Randomat:SmallNotify("4 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCImp3", 12, 1, function()
                Randomat:SmallNotify("3 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCImp2", 13, 1, function()
                Randomat:SmallNotify("2 seconds to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCImp1", 14, 1, function()
                Randomat:SmallNotify("1 second to choose", 1, ply)
            end)
            timer.Create("rdmtJoelBotCImp0", 15, 1, function()
                hook.Remove("Think", "rdmtJoelBotCImpKill")
                JoelBotC:SendSeatingGUIDestroy(ply)
                JoelBotC:NextNightStep()
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            JoelBotC.impTargetedPlayer = nil
            hook.Add("Think", "rdmtJoelBotCImpKill", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC.impTargetedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                    end
                    JoelBotC:SendSeatingGUIDestroy(ply)

                    timer.Remove("rdmtJoelBotCImp10")
                    timer.Remove("rdmtJoelBotCImp5")
                    timer.Remove("rdmtJoelBotCImp4")
                    timer.Remove("rdmtJoelBotCImp3")
                    timer.Remove("rdmtJoelBotCImp2")
                    timer.Remove("rdmtJoelBotCImp1")
                    timer.Remove("rdmtJoelBotCImp0")

                    if JoelBotC.impTargetedPlayer == ply then
                        local aliveMinions = {}
                        local newImp = nil
                        for _, min in ipairs(JoelBotC.minionPlayers) do
                            if min:IsScarletWoman() and not min.BotCDead and JoelBotC:AlivePlayerCount() >= 5 then
                                newImp = min
                            elseif not min.BotCDead then
                                table.insert(aliveMinions, min)
                            end
                        end

                        if not newImp and #aliveMinions > 0 then
                            table.Shuffle(aliveMinions)
                            newImp = aliveMinions[1]
                        end

                        if newImp then
                            Randomat:SetRole(newImp, ROLE_IMPJBC)
                            SendFullStateUpdate()
                        end
                    end

                    JoelBotC:NightPreKill(JoelBotC.impTargetedPlayer, ply)

                    JoelBotC:NextNightStep()

                    hook.Remove("Think", "rdmtJoelBotCImpKill")
                end
            end)
        end
    end

    if not didImpStuff then
        JoelBotC:NextNightStep()
    end
end


-- po
function JoelBotC:PoSingleKill(ply)
    JoelBotC:SendSeatingGUICreate(ply, "No kill tonight\n(3 tomorrow)")

    Randomat:SmallNotify("15 Seconds: Choose a player to kill tonight,\n        or charge and kill 3 tomorrow night", 5, ply)

    timer.Create("rdmtJoelBotCPo10", 5, 1, function() Randomat:SmallNotify("10 seconds to choose", 5, ply) end)
    timer.Create("rdmtJoelBotCPo5", 10, 1, function() Randomat:SmallNotify("5 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo4", 11, 1, function() Randomat:SmallNotify("4 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo3", 12, 1, function() Randomat:SmallNotify("3 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo2", 13, 1, function() Randomat:SmallNotify("2 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo1", 14, 1, function() Randomat:SmallNotify("1 second to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo0", 15, 1, function()
        hook.Remove("Think", "rdmtJoelBotCPoKill")
        JoelBotC:SendSeatingGUIDestroy(ply)
        JoelBotC:NextNightStep()
    end)

    JoelBotC.seatingGUIButtonPressed = nil
    JoelBotC.seatingGUIPressingPlayer = nil
    JoelBotC.poTargetedPlayer = nil
    hook.Add("Think", "rdmtJoelBotCPoKill", function()
        if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
            if not JoelBotC:IsDroisoned(ply) then
                if JoelBotC.seatingGUIButtonPressed == -1 then
                    JoelBotC.poChoseNoKill = true
                    JoelBotC.poTargetedPlayer = nil
                else
                    JoelBotC.poTargetedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                end
            end
            JoelBotC:SendSeatingGUIDestroy(ply)

            timer.Remove("rdmtJoelBotCPo10")
            timer.Remove("rdmtJoelBotCPo5")
            timer.Remove("rdmtJoelBotCPo4")
            timer.Remove("rdmtJoelBotCPo3")
            timer.Remove("rdmtJoelBotCPo2")
            timer.Remove("rdmtJoelBotCPo1")
            timer.Remove("rdmtJoelBotCPo0")

            if JoelBotC.poTargetedPlayer then
                JoelBotC:NightPreKill(JoelBotC.poTargetedPlayer, ply)
            end

            JoelBotC:NextNightStep()

            hook.Remove("Think", "rdmtJoelBotCPoKill")
        end
    end)
end


function JoelBotC:PoTripleKill(ply)

    local function ThirdKill()
        ----------------------------------------------------------------------------------------------------
        -- Third kill choice
        ----------------------------------------------------------------------------------------------------

        JoelBotC:SendSeatingGUICreate(ply)

        Randomat:SmallNotify("15 Seconds: Choose your third player to kill tonight", 5, ply)

        timer.Create("rdmtJoelBotCPo10", 5, 1, function() Randomat:SmallNotify("10 seconds to choose", 5, ply) end)
        timer.Create("rdmtJoelBotCPo5", 10, 1, function() Randomat:SmallNotify("5 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo4", 11, 1, function() Randomat:SmallNotify("4 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo3", 12, 1, function() Randomat:SmallNotify("3 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo2", 13, 1, function() Randomat:SmallNotify("2 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo1", 14, 1, function() Randomat:SmallNotify("1 second to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo0", 15, 1, function()
            hook.Remove("Think", "rdmtJoelBotCPoKill3")
            JoelBotC:SendSeatingGUIDestroy(ply)
            JoelBotC:NextNightStep()
        end)

        JoelBotC.seatingGUIButtonPressed = nil
        JoelBotC.seatingGUIPressingPlayer = nil
        JoelBotC.poTargetedPlayer = nil
        hook.Add("Think", "rdmtJoelBotCPoKill3", function()
            if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                if not JoelBotC:IsDroisoned(ply) then
                    JoelBotC.poTargetedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                end
                JoelBotC:SendSeatingGUIDestroy(ply)

                timer.Remove("rdmtJoelBotCPo10")
                timer.Remove("rdmtJoelBotCPo5")
                timer.Remove("rdmtJoelBotCPo4")
                timer.Remove("rdmtJoelBotCPo3")
                timer.Remove("rdmtJoelBotCPo2")
                timer.Remove("rdmtJoelBotCPo1")
                timer.Remove("rdmtJoelBotCPo0")

                if JoelBotC.poTargetedPlayer then
                    JoelBotC:NightPreKill(JoelBotC.poTargetedPlayer, ply)
                end

                JoelBotC:NextNightStep()

                hook.Remove("Think", "rdmtJoelBotCPoKill3")
            end
        end)
    end

    local function SecondKill()
        ----------------------------------------------------------------------------------------------------
        -- Second kill choice
        ----------------------------------------------------------------------------------------------------

        JoelBotC:SendSeatingGUICreate(ply)

        Randomat:SmallNotify("15 Seconds: Choose your second player to kill tonight", 5, ply)

        timer.Create("rdmtJoelBotCPo10", 5, 1, function() Randomat:SmallNotify("10 seconds to choose", 5, ply) end)
        timer.Create("rdmtJoelBotCPo5", 10, 1, function() Randomat:SmallNotify("5 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo4", 11, 1, function() Randomat:SmallNotify("4 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo3", 12, 1, function() Randomat:SmallNotify("3 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo2", 13, 1, function() Randomat:SmallNotify("2 seconds to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo1", 14, 1, function() Randomat:SmallNotify("1 second to choose", 1, ply) end)
        timer.Create("rdmtJoelBotCPo0", 15, 1, function()
            hook.Remove("Think", "rdmtJoelBotCPoKill2")
            JoelBotC:SendSeatingGUIDestroy(ply)
            JoelBotC:NextNightStep()
        end)

        JoelBotC.seatingGUIButtonPressed = nil
        JoelBotC.seatingGUIPressingPlayer = nil
        JoelBotC.poTargetedPlayer = nil
        hook.Add("Think", "rdmtJoelBotCPoKill2", function()
            if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                if not JoelBotC:IsDroisoned(ply) then
                    JoelBotC.poTargetedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                end
                JoelBotC:SendSeatingGUIDestroy(ply)

                timer.Remove("rdmtJoelBotCPo10")
                timer.Remove("rdmtJoelBotCPo5")
                timer.Remove("rdmtJoelBotCPo4")
                timer.Remove("rdmtJoelBotCPo3")
                timer.Remove("rdmtJoelBotCPo2")
                timer.Remove("rdmtJoelBotCPo1")
                timer.Remove("rdmtJoelBotCPo0")

                if JoelBotC.poTargetedPlayer then
                    JoelBotC:NightPreKill(JoelBotC.poTargetedPlayer, ply)
                end

                ThirdKill()

                hook.Remove("Think", "rdmtJoelBotCPoKill2")
            end
        end)
    end

    ----------------------------------------------------------------------------------------------------
    -- First kill choice
    ----------------------------------------------------------------------------------------------------

    JoelBotC:SendSeatingGUICreate(ply)

    Randomat:SmallNotify("15 Seconds: Choose your first player to kill tonight", 5, ply)

    timer.Create("rdmtJoelBotCPo10", 5, 1, function() Randomat:SmallNotify("10 seconds to choose", 5, ply) end)
    timer.Create("rdmtJoelBotCPo5", 10, 1, function() Randomat:SmallNotify("5 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo4", 11, 1, function() Randomat:SmallNotify("4 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo3", 12, 1, function() Randomat:SmallNotify("3 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo2", 13, 1, function() Randomat:SmallNotify("2 seconds to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo1", 14, 1, function() Randomat:SmallNotify("1 second to choose", 1, ply) end)
    timer.Create("rdmtJoelBotCPo0", 15, 1, function()
        hook.Remove("Think", "rdmtJoelBotCPoKill1")
        JoelBotC:SendSeatingGUIDestroy(ply)
        JoelBotC:NextNightStep()
    end)

    JoelBotC.seatingGUIButtonPressed = nil
    JoelBotC.seatingGUIPressingPlayer = nil
    JoelBotC.poTargetedPlayer = nil
    hook.Add("Think", "rdmtJoelBotCPoKill1", function()
        if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
            if not JoelBotC:IsDroisoned(ply) then
                JoelBotC.poTargetedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
            end
            JoelBotC:SendSeatingGUIDestroy(ply)

            timer.Remove("rdmtJoelBotCPo10")
            timer.Remove("rdmtJoelBotCPo5")
            timer.Remove("rdmtJoelBotCPo4")
            timer.Remove("rdmtJoelBotCPo3")
            timer.Remove("rdmtJoelBotCPo2")
            timer.Remove("rdmtJoelBotCPo1")
            timer.Remove("rdmtJoelBotCPo0")

            if JoelBotC.poTargetedPlayer then
                JoelBotC:NightPreKill(JoelBotC.poTargetedPlayer, ply)
            end

            SecondKill()

            hook.Remove("Think", "rdmtJoelBotCPoKill1")
        end
    end)

    JoelBotC.poChoseNoKill = false
end


function JoelBotC:PoNight()
    local didPoStuff = false

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsPo() and not ply.BotCDead then
            didPoStuff = true

            if JoelBotC.poChoseNoKill then
                JoelBotC:PoTripleKill(ply)
            else
                JoelBotC:PoSingleKill(ply)
            end

        end
    end

    if not didPoStuff then
        JoelBotC:NextNightStep()
    end
end

