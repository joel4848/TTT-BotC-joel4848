JoelBotC = JoelBotC or {}

JoelBotC.monkProtectedPlayer = nil
JoelBotC.poisonerPoisonedPlayer = nil
JoelBotC.players = JoelBotC.players or {}
JoelBotC.assassinAbilityUsed = nil
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

function JoelBotC:GetNightFunctions()
    JoelBotC.nightFunctions = {
        [ROLE_STEWARDJBC] = JoelBotC.StewardNight,
        [ROLE_KNIGHTJBC] = JoelBotC.KnightNight,
        [ROLE_ORACLEJBC] = JoelBotC.OracleNight,
        [ROLE_CHEFJBC] = JoelBotC.ChefNight,
        [ROLE_UNDERTAKERJBC] = JoelBotC.UndertakerNight,
        [ROLE_NOBLEJBC] = JoelBotC.NobleNight,
        [ROLE_INVESTIGATORJBC] = JoelBotC.InvestigatorNight,
        [ROLE_MONKJBC] = JoelBotC.MonkNight,
        [ROLE_WASHERWOMANJBC] = JoelBotC.WasherwomanNight,
        [ROLE_NIGHTWATCHMANJBC] = JoelBotC.NightwatchmanNight,
        [ROLE_GRANDMOTHERJBC] = JoelBotC.GrandmotherNight,
        [ROLE_SEAMSTRESSJBC] = JoelBotC.SeamstressNight,
        [ROLE_LIBRARIANJBC] = JoelBotC.LibrarianNight,
        [ROLE_EMPATHJBC] = JoelBotC.EmpathNight,
        [ROLE_RAVENKEEPERJBC] = JoelBotC.RavenkeeperNight,
        [ROLE_FORTUNETELLERJBC] = JoelBotC.FortuneTellerNight,
        [ROLE_OGREJBC] = JoelBotC.OgreNight,
        [ROLE_MOONCHILDJBC] = JoelBotC.MoonchildNight,
        [ROLE_POISONERJBC] = JoelBotC.PoisonerNight,
        [ROLE_ORGANGRINDERJBC] = JoelBotC.OrganGrinderNight,
        [ROLE_ASSASSINJBC] = JoelBotC.AssassinNight,
        [ROLE_PUKKAJBC] = JoelBotC.PukkaNight,
        [ROLE_IMPJBC] = JoelBotC.ImpNight,
        [ROLE_SHABALOTHJBC] = JoelBotC.ShabalothNight,
        [ROLE_POJBC] = JoelBotC.PoNight,
        [ROLE_OJOJBC] = JoelBotC.OjoNight
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

-- steward
function JoelBotC:StewardNight()
    local stewardInfo = nil
    
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsSteward() and not ply.BotCDead then
            if JoelBotC:IsDroisoned(ply) then
                repeat
                    table.Shuffle(JoelBotC.evilPlayers)
                    stewardInfo = JoelBotC.evilPlayers[1]
                until not (stewardInfo == ply)
            else
                repeat
                    table.Shuffle(JoelBotC.goodPlayers)
                    stewardInfo = JoelBotC.goodPlayers[1]
                until not stewardInfo == ply
            end

            Randomat:SmallNotify("Your starting information: " .. stewardInfo:Nick() .. " is good", 5, ply)
        end
    end
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

            Randomat:SmallNotify("Your starting information: Neither " .. knightInfo1:Nick() .. " nor " .. knightInfo2:Nick() .. " is the Demon", 5, ply)
        end
    end
end

-- oracle
function JoelBotC:OracleNight()
    for _, ply in ipairs (JoelBotC.players) do
        if ply:IsOracle() and not ply.BotCDead then
            local previousEvilDead = previousEvilDead or 0
            local previousDeadPlayerAmount = previousDeadPlayerAmount or 0

            local evilDead = 0
            local deadPlayerAmount = #JoelBotC.deadPlayers

            for _, ply in ipairs (JoelBotC.players) do
                if JoelBotC:RegistersEvil(ply) and ply.BotCDead then
                    evilDead = evilDead + 1
                end
            end

            if not JoelBotC:IsDroisoned(ply) then
                Randomat:SmallNotify(
                    "Your starting information: " .. evilDead .. " dead players are evil",
                    5,
                    ply
                )
            else
                -- If no one new has died, do nothing
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
                
                Randomat:SmallNotify(
                    "Your starting information: " .. evilDead .. " dead players are evil",
                    5,
                    ply
                )
            end

            previousEvilDead = evilDead
            previousDeadPlayerAmount = deadPlayerAmount
        end
    end
end

-- chef
function JoelBotC:ChefNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsChef() and not ply.BotCDead then
            local evilPairs = 0
            local seatCount = #JoelBotC.seatingOrder

            for i = 1, seatCount do
                local current = JoelBotC.seatingOrder[i]
                local nextSeat = JoelBotC.seatingOrder[i % seatCount + 1] -- wraps last seat to 1

                if JoelBotC:RegistersEvil(current) and JoelBotC:RegistersEvil(nextSeat) then
                    evilPairs = evilPairs + 1
                end
            end

            if JoelBotC:IsDroisoned(ply) then
                local recluseAmount = 0
                local droisonedEvilPairs = nil

                for _, ply in ipairs(JoelBotC.players) do
                    if ply:IsRecluse() then
                        recluseAmount = recluseAmount + 1
                    end
                end

                repeat
                    droisonedEvilPairs = math.random(0, #JoelBotC.evilPlayers - 1 + recluseAmount)
                until not (droisonedEvilPairs == evilPairs)

                evilPairs = droisonedEvilPairs
            end

            Randomat:SmallNotify(
                "Your starting information: There are " .. evilPairs .. " pairs of evil players sat next to each other",
                5,
                ply
            )
        end
    end
end

-- undertaker
function JoelBotC:UndertakerNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsUndertaker() and not ply.BotCDead then
            if JoelBotC.recentExecutee then
                local undertakerInfoPlayer = nil
                local undertakerInfoRole = nil

                undertakerInfoPlayer = JoelBotC.recentExecutee
                undertakerInfoRole = ROLE_STRINGS[JoelBotC.recentExecutee.botc_role]

                if JoelBotC:IsDroisoned(ply) then
                    local undertakerDroisonedRole = nil
                    local undertakerDroisonedRolePool = {}
                    local undertakerDroisonedAlreadyShownRolePool = undertakerDroisonedAlreadyShownRolePool or {}
                    if JoelBotC:RegistersEvil(undertakerInfoPlayer) then
                        undertakerDroisonedRolePool = table.Copy(JoelBotC.demonBluffs)
                    else
                        undertakerDroisonedRolePool = table.Copy(JoelBotC.enabledMinions)
                    end

                    table.Shuffle(undertakerDroisonedRolePool)
                    undertakerInfoRole = ROLE_STRINGS[undertakerDroisonedRolePool[1]]
                end

                Randomat:SmallNotify(
                    "You learn that " .. undertakerInfoPlayer .. " was the " .. undertakerInfoRole,
                    5,
                    ply
                )
            end
        end
    end
end

-- noble
function JoelBotC:NobleNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsNoble() and not ply.BotCDead then
            local nobleInfo1 = nil
            local nobleInfo2 = nil
            local nobleInfo3 = nil
            local nobleInfoPool = {}

            local noblePick1 = nil
            local noblePick2 = nil
            local noblePick3 = nil
            local nobleGoodPool = table.Copy(JoelBotC.goodPlayers)
            local nobleEvilPool = {}

            table.Shuffle(nobleGoodPool)
            noblePick1 = nobleGoodPool[1]
            noblePick2 = nobleGoodPool[2]

            if (noblePick1:IsRecluse() or noblePick2:IsRecluse()) and math.random(0, 1) == 1 then
                noblepick3 = nobleGoodPool[3]
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

            nobleInfo1 = nobleInfoPool[1]
            nobleInfo2 = nobleInfoPool[2]
            nobleInfo3 = nobleInfoPool[3]

            Randomat:SmallNotify(
                "Your starting information: One of " .. nobleInfo1:Nick() .. ", " .. nobleInfo2:Nick() .. " and " .. nobleInfo3:Nick() .. " is evil",
                5,
                ply
            )
        end
    end
end

-- investigator
function JoelBotC:InvestigatorNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsInvestigator() and not ply.BotCDead then
            local investigatorInfo1 = nil
            local investigatorInfo2 = nil
            local investigatorInfoPool = {}
            local investigatorMinion = nil
            local investigatorOther = nil
            local investigatorMinionPool = table.Copy(JoelBotC.minionPlayers)
            local investigatorOtherPool = table.Copy(JoelBotC.players)
            local investigatorMinionRole = nil

            table.Shuffle(investigatorMinionPool)
            investigatorMinion = investigatorMinionPool[1]
            investigatorMinionRole = investigatorMinion:GetRoleString()

            repeat
                table.Shuffle(investigatorOtherPool)

                investigatorOther = investigatorOtherPool[1]
            until not (investigatorOther == ply or investigatorMinion == investigatorOther)

            for _, p in ipairs(JoelBotC.players) do
                if p:IsRecluse() then
                    if math.random(1, 3) == 1 then
                        investigatorMinion = p
                        local investigatorMinionRolePool = table.Copy(JoelBotC.enabledMinions)
                        table.Shuffle(investigatorMinionRolePool)
                        investigatorMinionRole = ROLE_STRINGS[investigatorMinionRolePool[1]]
                    end
                end
            end

            if JoelBotC:IsDroisoned(ply) then
                repeat
                    local investigatorGoodPlayers = table.Copy(JoelBotC.goodPlayers)
                    table.Shuffle(investigatorGoodPlayers)
                    investigatorMinion = investigatorGoodPlayers[1]
                    investigatorOther = investigatorGoodPlayers[2]
                until not (investigatorMinion:IsRecluse() or investigatorOther:IsRecluse())

                if #JoelBotC.unusedMinions > 0 then
                    local investigatorMinionRolePool = table.Copy(JoelBotC.unusedMinions)
                else
                    local investigatorMinionRolePool = table.Copy(JoelBotC.enabledMinions)
                end

                repeat
                    table.Shuffle(investigatorMinionRolePool)
                    notInvestigatorMinionRole = ROLE_STRINGS[investigatorMinionRolePool[1]]
                until not (notInvestigatorMinionRole == investigatorMinionRole)

                investigatorMinionRole = notInvestigatorMinionRole
            end

            table.insert(investigatorInfoPool, investigatorMinion)
            table.insert(investigatorInfoPool, investigatorOther)

            table.Shuffle(investigatorInfoPool)
            investigatorInfo1 = investigatorInfoPool[1]
            investigatorInfo2 = investigatorInfoPool[2]

            Randomat:SmallNotify(
                "Your starting information: Either " .. investigatorInfo1:Nick() .. " or " .. investigatorInfo2:Nick() .. " is the " .. investigatorMinionRole,
                5,
                ply
            )
        end
    end
end

-- monk
function JoelBotC:MonkNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsMonk() and not ply.BotCDead then
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
                hook.Remove("Think", "rdmtJoelBotcMonkProtect")
                JoelBotC:SendSeatingGUIDestroy(ply)
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            JoelBotC.monkProtectedPlayer = nil
            hook.Add("Think", "rdmtJoelBotcMonkProtect", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC.monkProtectedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                    end
                    JoelBotC:SendSeatingGUIDestroy(ply)

                    timer.Remove("rdmtJoelBotCMonk10")
                    timer.Remove("rdmtJoelBotCMonk5")
                    timer.Remove("rdmtJoelBotCMonk4")
                    timer.Remove("rdmtJoelBotCMonk3")
                    timer.Remove("rdmtJoelBotCMonk2")
                    timer.Remove("rdmtJoelBotCMonk1")
                    timer.Remove("rdmtJoelBotCMonk0")
                    hook.Remove("Think", "rdmtJoelBotcMonkProtect")
                end
            end)
        end
    end
end

-- washerwoman
function JoelBotC:WasherwomanNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsWasherwoman() and not ply.BotCDead then
            local washerwomanInfo1 = nil
            local washerwomanInfo2 = nil
            local washerwomanInfoPool = {}
            local washerwomanTownsfolk = nil
            local washerwomanOther = nil
            local washerwomanTownsfolkPool = table.Copy(JoelBotC.townsfolkPlayers)
            local washerwomanOtherPool = table.Copy(JoelBotC.players)
            local washerwomanTownsfolkRole = nil

            repeat
                table.Shuffle(washerwomanTownsfolkPool)
                washerwomanTownsfolk = washerwomanTownsfolkPool[1]
            until not (washerwomanTownsfolk == ply)
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
                until not (washerwomanTownsfolk == washerwomanOther)

                if #JoelBotC.unusedTownsfolk > 0 then
                    local droisonedWasherwomanTownsfolkRolePool = table.Copy(JoelBotC.unusedTownsfolk)
                else
                    local droisonedWasherwomanTownsfolkRolePool = table.Copy(JoelBotC.enabledTownsfolk)
                end
                local droisonedWasherwomanTownsfolkRole = nil

                table.Shuffle(droisonedWasherwomanTownsfolkRolePool)
                droisonedWasherwomanTownsfolkRole = droisonedWasherwomanTownsfolkRolePool[1]
                washerwomanTownsfolkRole = droisonedWasherwomanTownsfolkRole
            end

            table.insert(washerwomanInfoPool, washerwomanTownsfolk)
            table.insert(washerwomanInfoPool, washerwomanOther)

            table.Shuffle(washerwomanInfoPool)
            washerwomanInfo1 = washerwomanInfoPool[1]
            washerwomanInfo2 = washerwomanInfoPool[2]

            Randomat:SmallNotify(
                "Your starting information: Either " .. washerwomanInfo1:Nick() .. " or " .. washerwomanInfo2:Nick() .. " is the " .. washerwomanTownsfolkRole,
                5,
                ply
            )
        end
    end
end

-- nightwatchman
function JoelBotC:NightwatchmanNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsNightwatchman() and not ply.BotCDead and not JoelBotC.nightwatchmanAbilityUsed then
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
                hook.Remove("Think", "rdmtJoelBotcNightwatchmanInform")
                JoelBotC:SendSeatingGUIDestroy(ply)
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            hook.Add("Think", "rdmtJoelBotcNightwatchmanInform", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber then
                    if not JoelBotC:IsDroisoned(ply) then
                        Randomat:SmallNotify("Tonight you learn that " .. ply:Nick() .. " is the Nightwatchman", 5, JoelBotC.players[JoelBotC.seatingGUIButtonPressed])
                    end
                    JoelBotC.nightwatchmanAbilityUsed = true
                    JoelBotC:SendSeatingGUIDestroy(ply)

                    timer.Remove("rdmtJoelBotCNightwatchman10")
                    timer.Remove("rdmtJoelBotCNightwatchman5")
                    timer.Remove("rdmtJoelBotCNightwatchman4")
                    timer.Remove("rdmtJoelBotCNightwatchman3")
                    timer.Remove("rdmtJoelBotCNightwatchman2")
                    timer.Remove("rdmtJoelBotCNightwatchman1")
                    timer.Remove("rdmtJoelBotCNightwatchman0")
                    hook.Remove("Think", "rdmtJoelBotcNightwatchmanInform")
                end
            end)
        end
    end
end

-- grandmother
function JoelBotC:GrandmotherNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsGrandmother() and not ply.BotCDead then

            local grandchild = nil 
            local grandchildRole = nil 
            local grandmotherPool = {}

            if math.random(0,4) == 4 then
                grandmotherPool = table.Copy(JoelBotC.outsiderPlayers)
            else
                grandmotherPool = table.Copy(JoelBotC.townsfolkPlayers)
            end

            repeat
                table.Shuffle(grandmotherPool)
                grandchild = grandmotherPool[1]
            until not (grandchild == ply)
            grandchildRole = grandchild:GetRoleString()

            if JoelBotC:IsDroisoned(ply) then
                local droisonedGrandmotherRolePool = {}

                if math.random(0,4) == 4 then
                    droisonedGrandmotherPool = table.Copy(JoelBotC.demonPlayers)
                    droisonedGrandmotherRolePool = table.Copy(JoelBotC.demonBluffs)

                    table.Shuffle(droisonedGrandmotherPool)
                    grandchild = droisonedGrandmotherPool[1]
                    table.Shuffle(droisonedGrandmotherRolePool)
                    grandchildRole = ROLE_STRINGS[droisonedGrandmotherRolePool[1]]
                else
                    droisonedGrandmotherPool = table.Copy(JoelBotC.minionPlayers)
                    droisonedGrandmotherRolePool = table.Copy(JoelBotC.demonBluffsPool)

                    table.Shuffle(droisonedGrandmotherPool)
                    grandchild = droisonedGrandmotherPool[1]
                    table.Shuffle(droisonedGrandmotherRolePool)
                    grandchildRole = ROLE_STRINGS[droisonedGrandmotherRolePool[1]]
                end
            end

            Randomat:SmallNotify(
                "Your starting information: Your grandchild is " .. grandchild:Nick() .. ", the " .. grandchildRole,
                5,
                ply
            )
        end
    end
end

-- seamstress
function JoelBotC:SeamstressNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsSeamstress() and not ply.BotCDead then
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
                hook.Remove("Think", "rdmtJoelBotcSeamstressChoose1")
                hook.Remove("Think", "rdmtJoelBotcSeamstressChoose2")
                JoelBotC:SendSeatingGUIDestroy(ply)
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            local chosenSeat1 = nil
            local chosenSeat2 = nil

            hook.Add("Think", "rdmtJoelBotcSeamstressChoose1", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber then

                    chosenSeat1 = JoelBotC.seatingGUIButtonPressed

                    hook.Add("Think", "rdmtJoelBotcSeamstressChoose2", function()
                        if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil and JoelBotC.seatingGUIButtonPressed ~= ply.seatNumber and JoelBotC.seatingGUIButtonPressed ~= chosenSeat1 then

                            chosenSeat2 = JoelBotC.seatingGUIButtonPressed

                            chosenPlayer1 = JoelBotC.seatingOrder[chosenSeat1]
                            chosenPlayer2 = JoelBotC.seatingOrder[chosenSeat2]

                            if not JoelBotC:IsDroisoned(ply) then
                                if JoelBotC:RegistersEvil(chosenPlayer1) == JoelBotC:RegistersEvil(chosenPlayer2) then
                                    Randomat:SmallNotify(
                                        chosenPlayer1:Nick() .. " and " .. chosenPlayer2:Nick() .. "are on the same team",
                                        5,
                                        ply
                                    )
                                else
                                    Randomat:SmallNotify(
                                        chosenPlayer1:Nick() .. " and " .. chosenPlayer2:Nick() .. "are NOT on the same team",
                                        5,
                                        ply
                                    )
                                end
                            else
                                if JoelBotC:RegistersEvil(chosenPlayer1) == JoelBotC:RegistersEvil(chosenPlayer2) then
                                    Randomat:SmallNotify(
                                        chosenPlayer1:Nick() .. " and " .. chosenPlayer2:Nick() .. "are NOT on the same team",
                                        5,
                                        ply
                                    )
                                else
                                    Randomat:SmallNotify(
                                        chosenPlayer1:Nick() .. " and " .. chosenPlayer2:Nick() .. "are on the same team",
                                        5,
                                        ply
                                    )
                                end
                            end

                            timer.Remove("rdmtJoelBotCSeamstress10")
                            timer.Remove("rdmtJoelBotCSeamstress5")
                            timer.Remove("rdmtJoelBotCSeamstress4")
                            timer.Remove("rdmtJoelBotCSeamstress3")
                            timer.Remove("rdmtJoelBotCSeamstress2")
                            timer.Remove("rdmtJoelBotCSeamstress1")
                            timer.Remove("rdmtJoelBotCSeamstress0")
                            hook.Remove("Think", "rdmtJoelBotcSeamstressChoose2")
                        end

                        hook.Remove("Think", "rdmtJoelBotcSeamstressChoose1")
                    end)
                end
            end)
        end
    end
end

-- librarian
function JoelBotC:LibrarianNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsLibrarian() and not ply.BotCDead then
            local librarianInfo1 = nil
            local librarianInfo2 = nil
            local librarianInfoPool = {}
            local librarianOutsider = nil
            local librarianOther = nil
            local librarianOutsiderPool = table.Copy(JoelBotC.outsiderPlayers)
            local librarianOtherPool = table.Copy(JoelBotC.players)
            local librarianOutsiderRole = nil

            if #librarianOutsiderPool == 0 then
                Randomat:SmallNotify(
                    "Your starting information: There are no Outsiders",
                    5,
                    ply
                )
            else
                repeat
                    table.Shuffle(librarianOutsiderPool)
                    librarianOutsider = librarianOutsiderPool[1]
                until not (librarianOutsider == ply)
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
                    until not (librarianOutsider == librarianOther)

                    if #JoelBotC.unusedOutsiders > 0 then
                        local droisonedLibrarianOutsiderRolePool = table.Copy(JoelBotC.unusedOutsiders)
                    else
                        local droisonedLibrarianOutsiderRolePool = table.Copy(JoelBotC.enabledOutsiders)
                    end
                    local droisonedLibrarianOutsiderRole = nil

                    table.Shuffle(droisonedLibrarianOutsiderRolePool)
                    droisonedLibrarianOutsiderRole = droisonedLibrarianOutsiderRolePool[1]
                    librarianOutsiderRole = droisonedLibrarianOutsiderRole
                end

                table.insert(librarianInfoPool, librarianOutsider)
                table.insert(librarianInfoPool, librarianOther)

                table.Shuffle(librarianInfoPool)
                librarianInfo1 = librarianInfoPool[1]
                librarianInfo2 = librarianInfoPool[2]

                Randomat:SmallNotify(
                    "Your starting information: Either " .. librarianInfo1:Nick() .. " or " .. librarianInfo2:Nick() .. " is the " .. librarianOutsiderRole,
                    5,
                    ply
                )
            end
        end
    end
end

-- slayer



-- empath
function JoelBotC:EmpathNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsEmpath() and not ply.BotCDead then
            local previousEmpathInfo = empathInfo or nil
            local empathInfo = 0 
            local seatCount = #JoelBotC.seatingOrder
            local previousDeadNeighbours = deadNeighbours or nil
            local deadNeighbours = 0

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
            until JoelBotC.seatingOrder[leftIndex].BotCDead

            local leftNeighbour = JoelBotC.seatingOrder[leftIndex]

            -- Find rightwards living neighbour
            local rightIndex = seatIndex
            repeat
                rightIndex = rightIndex % seatCount + 1
                if not JoelBotC.seatingOrder[rightIndex].BotCDead then
                    deadNeighbours = deadNeighbours + 1
                end
            until JoelBotC.seatingOrder[rightIndex].BotCDead

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
            if empathInfo == 0 then
                Randomat:SmallNotify(
                        "Your nightly information: None of your alive neighbours are evil",
                        5,
                        ply
                    )
            elseif empathInfo == 1 then
                Randomat:SmallNotify(
                        "Your nightly information: One of your alive neighbours is evil",
                        5,
                        ply
                    )
            elseif empathInfo == 2 then
                Randomat:SmallNotify(
                        "Your nightly information: Both of your alive neighbours are evil",
                        5,
                        ply
                    )
            end
        end
    end
end

-- soldier
-- No active role ability


-- ravenkeeper
function JoelBotC:RavenkeeperNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsRavenkeeper() and JoelBotC.ravenkeeperKilledByDemon then
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
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            local chosenPlayer = nil
            local chosenPlayerRole = nil

            hook.Add("Think", "rdmtJoelBotCRavenkeeperChoose", function()
                print("Running Ravenkeeper think hook")
                print("Button pressed = " .. tostring(JoelBotC.seatingGUIButtonPressed))
                print("Ply = " .. tostring(ply) .. " and Pressing Player  = " .. tostring(JoelBotC.seatingGUIPressingPlayer))
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

                    Randomat:SmallNotify(
                        chosenPlayer:Nick() .. " is the " .. chosenPlayerRole,
                        5,
                        ply
                    )

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
        end
    end
end

-- fortuneteller
function JoelBotC.FortuneTellerRedHerring()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsFortuneTeller() then
            if JoelBotC.redHerring == nil then
                local table fortunetellerRedHerringPool = table.Copy(JoelBotC.townsfolkPlayers)

                table.Shuffle(fortunetellerRedHerringPool)
                JoelBotC.redHerring = fortunetellerRedHerringPool[1]
                fortunetellerRedHerringPool[1].redHerring = true
            end
        end
    end
end

function JoelBotC:FortuneTellerNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsFortuneTeller() then

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
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            local chosenPlayer1 = nil
            local chosenPlayer2 = nil
            local chosenSeat1 = nil
            local chosenSeat2 = nil

            hook.Add("Think", "rdmtJoelBotcFortuneTellerChoose1", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then

                    chosenSeat1 = JoelBotC.seatingGUIButtonPressed

                    hook.Add("Think", "rdmtJoelBotcFortuneTellerChoose2", function()
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

                            if fortunetellerGotDemon then
                                Randomat:SmallNotify(
                                    "Yes - one of " .. chosenPlayer1:Nick() .. " or " ..chosenPlayer2:Nick() .. " is the Demon",
                                    5,
                                    ply
                                )
                            else
                                Randomat:SmallNotify(
                                    "No - neither of " .. chosenPlayer1:Nick() .. " or " ..chosenPlayer2:Nick() .. " is the Demon",
                                    5,
                                    ply
                                )
                            end

                            timer.Remove("rdmtJoelBotCFortuneTeller10")
                            timer.Remove("rdmtJoelBotCFortuneTeller5")
                            timer.Remove("rdmtJoelBotCFortuneTeller4")
                            timer.Remove("rdmtJoelBotCFortuneTeller3")
                            timer.Remove("rdmtJoelBotCFortuneTeller2")
                            timer.Remove("rdmtJoelBotCFortuneTeller1")
                            timer.Remove("rdmtJoelBotCFortuneTeller0")
                            hook.Remove("Think", "rdmtJoelBotcFortuneTellerChoose2")
                        end

                        hook.Remove("Think", "rdmtJoelBotcFortuneTellerChoose1")
                    end)
                end
            end)
        end
    end
end


-- virgin



-- ogre



-- sweetheart



-- saint



-- drunk



-- recluse



-- poisoner
function JoelBotC:PoisonerNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsRole(ROLE_POSIONERJBC) and not ply.BotCDead then
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
                hook.Remove("Think", "rdmtJoelBotcPoisonerPoison")
                JoelBotC:SendSeatingGUIDestroy(ply)
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            JoelBotC.poisonerPoisonedPlayer.poisonerPoisoned = false
            JoelBotC.poisonerPoisonedPlayer = nil
            hook.Add("Think", "rdmtJoelBotcPoisonerPoison", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC.poisonerPoisonedPlayer = JoelBotC.players[JoelBotC.seatingGUIButtonPressed]
                    end
                    JoelBotC:SendSeatingGUIDestroy(ply)

                    timer.Remove("rdmtJoelBotCPoisoner10")
                    timer.Remove("rdmtJoelBotCPoisoner5")
                    timer.Remove("rdmtJoelBotCPoisoner4")
                    timer.Remove("rdmtJoelBotCPoisoner3")
                    timer.Remove("rdmtJoelBotCPoisoner2")
                    timer.Remove("rdmtJoelBotCPoisoner1")
                    timer.Remove("rdmtJoelBotCPoisoner0")
                    hook.Remove("Think", "rdmtJoelBotcPoisonerPoison")
                end
            end)
        end
    end
end


-- scarletwoman



-- organgrinder
function JoelBotC:OrganGrinderNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsOrganGrinder() and not ply.BotCDead then
            net.Start("rdmtJoelBotCOrganGrinderGUI")
            net.Send(ply)
        end
    end
end

net.Receive("rdmtJoelBotCOrganGrinderGUI", function(len, ply)
    local response = net.ReadBool()
    
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsOrganGrinder() then
            ply.organgrinderDrunk = response

        end
    end
end)

-- assassin
function JoelBotC:AssassinNight()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsRole(ROLE_ASSASSINJBC) and not ply.BotCDead and not JoelBotC.assassinAbilityUsed then
            JoelBotC:SendSeatingGUICreate(ply)
            
            Randomat:SmallNotify("15 Seconds: Use your ability tonight?\nChoose a player to kill", 5, ply)
            
            timer.Create("rdmtJoelBotCAssassin10", 5, 1, function()
                Randomat:SmallNotify("10 seconds to choose", 5, ply)
            end)
            timer.Create("rdmtJoelBotCAssassin5", 10, 1, function()
                Randomat:SmallNotify("5 seconds to choose", 1, ply)
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
                hook.Remove("Think", "rdmtJoelBotcAssassinKill")
                JoelBotC:SendSeatingGUIDestroy(ply)
            end)

            JoelBotC.seatingGUIButtonPressed = nil
            JoelBotC.seatingGUIPressingPlayer = nil
            hook.Add("Think", "rdmtJoelBotcAssassinKill", function()
                if JoelBotC.seatingGUIPressingPlayer == ply and JoelBotC.seatingGUIButtonPressed ~= nil then
                    if not JoelBotC:IsDroisoned(ply) then
                        JoelBotC:Kill(JoelBotC.players[JoelBotC.seatingGUIButtonPressed])
                    end
                    -- JoelBotC.assassinAbilityUsed = true
                    JoelBotC:SendSeatingGUIDestroy(ply)

                    timer.Remove("rdmtJoelBotCAssassin10")
                    timer.Remove("rdmtJoelBotCAssassin5")
                    timer.Remove("rdmtJoelBotCAssassin4")
                    timer.Remove("rdmtJoelBotCAssassin3")
                    timer.Remove("rdmtJoelBotCAssassin2")
                    timer.Remove("rdmtJoelBotCAssassin1")
                    timer.Remove("rdmtJoelBotCAssassin0")
                    hook.Remove("Think", "rdmtJoelBotcAssassinKill")
                end
            end)
        end
    end
end


-- baron



-- pukka



-- imp



-- shabaloth



-- po



-- ojo