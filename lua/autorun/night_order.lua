JoelBotC = JoelBotC or {}
JoelBotC.rolesInGame = JoelBotC.rolesInGame or {}
JoelBotC.otherNightOrder = JoelBotC.otherNightOrder or {}
JoelBotC.nightFunctions = JoelBotC.nightFunctions or {}
JoelBotC.firstNightOrderMaster = JoelBotC.firstNightOrderMaster or {}
JoelBotC.isFirstNight = JoelBotC.isFirstNight or nil
JoelBotC.currentNight = JoelBotC.currentNight or 0
JoelBotC.isCurrentlyNight = JoelBotC.isCurrentlyNight or nil

if SERVER then

    util.AddNetworkString("rdmtJoelBotCNightStarts")

    local nightStep = nil

    function JoelBotC:DetermineRolesInGame()

        -- Reset some role stuff
        JoelBotC.nightwatchmanAbilityUsed = nil

        -- Get roles in the game
        JoelBotC.rolesInGame = {
            [ROLE_STEWARDJBC] = false,
            [ROLE_KNIGHTJBC] = false,
            [ROLE_ORACLEJBC] = false,
            [ROLE_CHEFJBC] = false,
            [ROLE_UNDERTAKERJBC] = false,
            [ROLE_NOBLEJBC] = false,
            [ROLE_INVESTIGATORJBC] = false,
            [ROLE_MONKJBC] = false,
            [ROLE_WASHERWOMANJBC] = false,
            [ROLE_NIGHTWATCHMANJBC] = false,
            [ROLE_GRANDMOTHERJBC] = false,
            [ROLE_SEAMSTRESSJBC] = false,
            [ROLE_LIBRARIANJBC] = false,
            [ROLE_EMPATHJBC] = false,
            [ROLE_SOLDIERJBC] = false,
            [ROLE_RAVENKEEPERJBC] = false,
            [ROLE_FORTUNETELLERJBC] = false,
            [ROLE_VIRGINJBC] = false,
            [ROLE_OGREJBC] = false,
            [ROLE_SNITCHJBC] = false,
            [ROLE_GOLEMJBC] = false,
            [ROLE_SWEETHEARTJBC] = false,
            [ROLE_SAINTJBC] = false,
            [ROLE_DRUNKJBC] = false,
            [ROLE_RECLUSEJBC] = false,
            [ROLE_POISONERJBC] = false,
            [ROLE_SCARLETWOMANJBC] = false,
            [ROLE_ORGANGRINDERJBC] = false,
            [ROLE_ASSASSINJBC] = false,
            [ROLE_BARONJBC] = false,
            [ROLE_PUKKAJBC] = false,
            [ROLE_IMPJBC] = false,
            [ROLE_POJBC] = false,
        }

        for _, entry in ipairs(JoelBotC.rolePool) do
            local roleID = entry.role

            JoelBotC.rolesInGame[roleID] = true
        end

        -- Build night order master tables
        JoelBotC.firstNightOrderMaster = {
            ROLE_POISONERJBC,
            ROLE_ORGANGRINDERJBC,
            ROLE_PUKKAJBC,
            ROLE_WASHERWOMANJBC,
            ROLE_LIBRARIANJBC,
            ROLE_INVESTIGATORJBC,
            ROLE_CHEFJBC,
            ROLE_EMPATHJBC,
            ROLE_FORTUNETELLERJBC,
            ROLE_GRANDMOTHERJBC,
            ROLE_SEAMSTRESSJBC,
            ROLE_STEWARDJBC,
            ROLE_KNIGHTJBC,
            ROLE_NOBLEJBC,
            ROLE_NIGHTWATCHMANJBC,
            ROLE_OGREJBC
        }

        JoelBotC.otherNightOrderMaster = {
            ROLE_POISONERJBC,
            ROLE_MONKJBC,
            ROLE_ORGANGRINDERJBC,
            ROLE_IMPJBC,
            ROLE_PUKKAJBC,
            ROLE_POJBC,
            ROLE_ASSASSINJBC,
            ROLE_RAVENKEEPERJBC,
            ROLE_EMPATHJBC,
            ROLE_FORTUNETELLERJBC,
            ROLE_UNDERTAKERJBC,
            ROLE_ORACLEJBC,
            ROLE_SEAMSTRESSJBC,
            ROLE_NIGHTWATCHMANJBC
        }

        -- Build first night order table
        JoelBotC.firstNightOrder = {}

        for _, role in ipairs(JoelBotC.firstNightOrderMaster) do
            if JoelBotC.rolesInGame[role] then
                table.insert(JoelBotC.firstNightOrder, role)
            end
        end

        -- Build other night order table
        JoelBotC.otherNightOrder = {}

        for _, role in ipairs(JoelBotC.otherNightOrderMaster) do
            if JoelBotC.rolesInGame[role] then
                table.insert(JoelBotC.otherNightOrder, role)
            end
        end
    end

    function JoelBotC:MinionInfo()
        if #JoelBotC.players > 6 then
            local dmn = JoelBotC.demonPlayers[1]
            local mns = table.Copy(JoelBotC.minionPlayers)
            local minionMessage = nil

            for _, ply in ipairs(JoelBotC.players) do
                if ply.minion then
                    if #mns == 1 then
                        minionMessage = "There are no other Minions"
                    elseif #mns == 2 then
                        if mns[1] == ply then
                            minionMessage = "Your fellow Minion is " .. mns[2]:Nick()
                        else
                            minionMessage = "Your fellow Minion is " .. mns[1]:Nick()
                        end
                    elseif #mns == 3 then
                        if mns[1] == ply then
                            minionMessage = "Your fellow Minions are " .. mns[2]:Nick() .. " and " .. mns[3]:Nick()
                        elseif mns[2] == ply then
                            minionMessage = "Your fellow Minions are " .. mns[1]:Nick() .. " and " .. mns[3]:Nick()
                        elseif mns[3] == ply then
                            minionMessage = "Your fellow Minions are " .. mns[1]:Nick() .. " and " .. mns[2]:Nick()
                        end
                    end

                    Randomat:SmallNotify("Your Demon is " .. dmn:Nick(), 5, ply)
                    timer.Simple(5, function()
                        Randomat:SmallNotify(minionMessage, 5, ply)
                    end)

                    -- Book entry
                    JoelBotC:AppendInfoBook(ply, "Minion info:", "Your Demon is " .. dmn:Nick() .. ".\n" .. minionMessage)
                end
            end
        end
    end

    function JoelBotC:DemonInfo()
        local bluffStr = ROLE_STRINGS[JoelBotC.demonBluffs[1]] .. ", " .. ROLE_STRINGS[JoelBotC.demonBluffs[2]] .. " and " .. ROLE_STRINGS[JoelBotC.demonBluffs[3]]

        if #JoelBotC.players > 6 then
            for _, ply in ipairs(JoelBotC.players) do
                if ply.demon then
                    Randomat:SmallNotify(
                        "Your bluffs are " .. bluffStr,
                        5, ply
                    )

                    local mns = table.Copy(JoelBotC.minionPlayers)
                    local minionMessage = nil

                    if #mns == 1 then
                        minionMessage = "Your Minion is " .. mns[1]:Nick()
                    elseif #mns == 2 then
                        minionMessage = "Your Minions are " .. mns[1]:Nick() .. " and " .. mns[2]:Nick()
                    elseif #mns == 3 then
                        minionMessage = "Your Minions are " .. mns[1]:Nick() .. ", " .. mns[2]:Nick() .. " and " .. mns[3]:Nick()
                    end

                    timer.Simple(5, function()
                        Randomat:SmallNotify(minionMessage, 5, ply)
                    end)

                    -- Book entry
                    JoelBotC:AppendInfoBook(ply, "Demon info:",
                        "Your bluffs are " .. bluffStr .. ".\n" .. minionMessage)
                end
            end
        end
        if JoelBotC:SnitchExists() then
            for _, ply in ipairs(JoelBotC.players) do
                if ply.minion then
                    Randomat:SmallNotify(
                        "There is a Snitch! The bluffs are " .. bluffStr,
                        5, ply
                    )
                end

                -- Book entry
                JoelBotC:AppendInfoBook(ply, "There is a Snitch!",
                    "The bluffs are " .. bluffStr)
            end
        end
    end

    function JoelBotC:NextNightStep()
        if not JoelBotC.BotCEventRunning then return end

        timer.Simple(1, function()
            if JoelBotC.isFirstNight then

                -- print("---------------------------------------------------------------------")
                -- print("-----------                  NIGHT 1                     ------------")
                -- print("---------------------------------------------------------------------")
                -- print("Time: " .. math.floor(SysTime()))
                -- print("Ran Next Night Step")
                -- print("nightStep = " .. nightStep)
                -- print("#JoelBotC.firstNightOrderMaster = " .. #JoelBotC.firstNightOrderMaster)

                if nightStep > #JoelBotC.firstNightOrderMaster then
                    JoelBotC.isFirstNight = false
                    nightStep = 1
                    JoelBotC:StartDay()
                else
                    local currentRole = JoelBotC.firstNightOrderMaster[nightStep]
                    local roleData = JoelBotC.nightFunctions[currentRole]
                    local currentFn = JoelBotC.nightFunctions[currentRole] or nil

                    if JoelBotC.rolesInGame[currentRole] then
                        -- print("Running function: " .. roleData.name)
                        nightStep = nightStep + 1
                        roleData.fn(JoelBotC)
                    else
                        -- print("Role not in game - " .. roleData.name)
                        nightStep = nightStep + 1
                        JoelBotC:NextNightStep()
                    end
                end
            else
                -- print("---------------------------------------------------------------------")
                -- print("-----------                OTHER NIGHT                   ------------")
                -- print("---------------------------------------------------------------------")
                -- print("Time: " .. math.floor(SysTime()))
                -- print("Ran Next Night Step")
                -- print("nightStep = " .. nightStep)
                -- print("#JoelBotC.otherNightOrderMaster = " .. #JoelBotC.otherNightOrderMaster)

                if nightStep > #JoelBotC.otherNightOrderMaster then
                    nightStep = 1
                    JoelBotC:StartDay()
                else
                    local currentRole = JoelBotC.otherNightOrderMaster[nightStep]
                    local roleData = JoelBotC.nightFunctions[currentRole]
                    local currentFn = JoelBotC.nightFunctions[currentRole] or nil

                    if JoelBotC.rolesInGame[currentRole] then
                        -- print("Running function: " .. roleData.name)
                        nightStep = nightStep + 1
                        roleData.fn(JoelBotC)
                    else
                        -- print("Role not in game - " .. roleData.name)
                        nightStep = nightStep + 1
                        JoelBotC:NextNightStep()
                    end
                end
            end
        end)
    end

    function JoelBotC:StartNight()
        JoelBotC.isCurrentlyNight = true

        JoelBotC.currentNight = JoelBotC.currentNight + 1
        nightStep = 1

        -- net.Start("rdmtJoelBotCNightStarts")
        -- net.Broadcast()

        JoelBotC:GetNightFunctions()

        if JoelBotC.isFirstNight then
            if #JoelBotC.players > 6 then
                JoelBotC:MinionInfo()

                timer.Simple(3, function()
                    JoelBotC:DemonInfo()

                    timer.Simple(10, function()
                        JoelBotC:NextNightStep()
                    end)
                end)
            else
                JoelBotC:MinionInfo()

                timer.Simple(1, function()
                    JoelBotC:DemonInfo()

                    timer.Simple(1, function()
                        JoelBotC:NextNightStep()
                    end)
                end)
            end
        else
            JoelBotC:NextNightStep()
        end
    end
end