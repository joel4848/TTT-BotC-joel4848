JoelBotC = JoelBotC or {}

JoelBotC.monkProtectedPlayer = nil
JoelBotC.poisonerPoisonedPlayer = nil
JoelBotC.players = JoelBotC.players or {}
JoelBotC.assassinAbilityUsed = nil

----------------------------------------------------------------------------------------------------------------------------
-- ROLE FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------

-- Is droisoned
function JoelBotC:IsDroisoned(ply)
    if not IsValid(ply) then return false end
    return ply.poisonerPoisoned or ply.pukkaPoisoned or ply.organgrinderDrunk or ply.botc_role == ROLE_DRUNKJBC
end

-- steward
function JoelBotC:StewardInfo()
    local stewardInfo = nil
    
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsSteward() then
            if JoelBotC:IsDroisoned(ply) then
                repeat
                    table.Shuffle(JoelBotC.players)
                    stewardInfo = JoelBotC.players[1]
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
function JoelBotC:KnightInfo()
    local knightInfo1 = nil
    local knightInfo2 = nil
    local knightInfoPool = {}

    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsKnight() then
            if JoelBotC:IsDroisoned(ply) then
                repeat
                    table.Shuffle(JoelBotC.players)

                    knightInfo1 = JoelBotC.players[1]
                    knightInfo1 = JoelBotC.players[2]
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
function JoelBotC:OracleInfo()
    for _, ply in ipairs (JoelBotC.players) do
        if ply:IsOracle() then
            local evilDead = 0

            -- Helper function to determine if a player registers as evil
            local function RegistersEvil(ply)
                if not IsValid(ply) then return false end
                return ply.evilTeam or ply.botc_role == ROLE_RECLUSEJBC
            end

            for _, ply in ipairs (JoelBotC.players) do
                if RegistersEvil(ply) and not ply:Alive() then
                    evilDead = evilDead + 1
                end
            end

            Randomat:SmallNotify(
                "Your starting information: " .. evilDead .. " dead players are evil",
                5,
                ply
            )
        end
    end
end

-- chef
function JoelBotC:ChefInfo()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsChef() then
            local evilPairs = 0
            local seatCount = #JoelBotC.seatingOrder

            -- Helper function to determine if a player registers as evil
            local function RegistersEvil(ply)
                if not IsValid(ply) then return false end
                return ply.evilTeam or ply:IsRecluse()
            end

            for i = 1, seatCount do
                local current = JoelBotC.seatingOrder[i]
                local nextSeat = JoelBotC.seatingOrder[i % seatCount + 1] -- wraps last seat to 1

                if RegistersEvil(current) and RegistersEvil(nextSeat) then
                    evilPairs = evilPairs + 1
                end
            end

            if JoelBotC:IsDroisoned(ply) then
                local recluseAmount = 0

                for _, ply in ipairs(JoelBotC.players) do
                    if ply:IsRecluse() then
                        recluseAmount = recluseAmount + 1
                    end
                end

                evilPairs = math.random(0, #JoelBotC.evilPlayers - 1 + recluseAmount)
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



-- noble
function JoelBotC:NobleInfo()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsNoble() then
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
function JoelBotC:InvestigatorInfo()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsInvestigator() then
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
function JoelBotC:MonkProtect()
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
function JoelBotC:WasherwomanInfo()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsWasherwoman() then
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
function JoelBotC:NightwatchmanInform()
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
function JoelBotC:GrandmotherInfo()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsGrandmother() then

            local grandchild = nil 
            local grandchildRole = nil 
            local grandmotherPool = {}

            
            if math.random(0,4) == 4 then
                grandmotherPool = JoelBotC.outsiderPlayers
            else
                grandmotherPool = JoelBotC.townsfolkPlayers
            end

            repeat
                table.Shuffle(grandmotherPool)
                grandchild = grandmotherPool[1]
            until not (grandchild == ply)
            grandchildRole = grandchild:GetRoleString()

            if JoelBotC:IsDroisoned(ply) then
                local droisonedGrandmotherRolePool = {}

                if math.random(0,4) == 4 then
                    droisonedGrandmotherPool = JoelBotC.demonPlayers
                    droisonedGrandmotherRolePool = table.Copy(JoelBotC.demonBluffs)

                    table.Shuffle(droisonedGrandmotherPool)
                    grandchild = droisonedGrandmotherPool[1]
                    table.Shuffle(droisonedGrandmotherRolePool)
                    grandchildRole = ROLE_STRINGS[droisonedGrandmotherRolePool[1]]
                else
                    droisonedGrandmotherPool = JoelBotC.minionPlayers
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



-- librarian
function JoelBotC:LibrarianInfo()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsLibrarian() then
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
function JoelBotC:EmpathInfo()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsEmpath() and ply:Alive() then
            local previousEmpathInfo = empathInfo or nil
            local empathInfo = 0 
            local seatCount = #JoelBotC.seatingOrder
            local previousDeadNeighbours = deadNeighbours or nil
            local deadNeighbours = 0

            -- Helper function to determine if a player registers as evil
            local function RegistersEvil(ply)
                if not IsValid(ply) then return false end
                return ply.evilTeam or ply:IsRecluse()
            end

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
                if not JoelBotC.seatingOrder[leftIndex]:Alive() then
                    deadNeighbours = deadNeighbours + 1
                end
            until JoelBotC.seatingOrder[leftIndex]:Alive()

            local leftNeighbour = JoelBotC.seatingOrder[leftIndex]

            -- Find rightwards living neighbour
            local rightIndex = seatIndex
            repeat
                rightIndex = rightIndex % seatCount + 1
                if not JoelBotC.seatingOrder[rightIndex]:Alive() then
                    deadNeighbours = deadNeighbours + 1
                end
            until JoelBotC.seatingOrder[rightIndex]:Alive()

            local rightNeighbour = JoelBotC.seatingOrder[rightIndex]

            -- Check if neighbours register as evil
            if RegistersEvil(leftNeighbour) then
                empathInfo = empathInfo + 1
            end

            if RegistersEvil(rightNeighbour) then
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



-- ravenkeeper



-- fortuneteller



-- virgin



-- ogre



-- moonchild



-- saint



-- drunk



-- recluse



-- poisoner
function JoelBotC:PoisonerPoison()
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



-- assassin
function JoelBotC:AssassinKill()
    for _, ply in ipairs(JoelBotC.players) do
        if ply:IsRole(ROLE_ASSASSINJBC) and not ply.BotCDead and not JoelBotC.assassinAbilityUsed then
            JoelBotC:SendSeatingGUICreate(ply)
            
            Randomat:SmallNotify("15 Seconds: Use your ability tonight? Choose a player to kill", 5, ply)
            
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
                    JoelBotC.assassinAbilityUsed = true
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