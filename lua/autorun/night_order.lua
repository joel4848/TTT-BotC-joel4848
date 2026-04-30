JoelBotC = JoelBotC or {}
JoelBotC.rolesInGame = JoelBotC.rolesInGame or {}
JoelBotC.firstNightOrder = JoelBotC.firstNightOrder or {}
JoelBotC.otherNightOrder = JoelBotC.otherNightOrder or {}
JoelBotC.nightFunctions = JoelBotC.nightFunctions or {}
JoelBotC.isFirstNight = JoelBotC.isFirstNight or nil

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
    ROLE_SCARLETWOMANJBC,
    ROLE_IMPJBC,
    ROLE_PUKKAJBC,
    ROLE_POJBC,
    ROLE_ASSASSINJBC,
    ROLE_SWEETHEARTJBC,
    ROLE_GRANDMOTHERJBC,
    ROLE_RAVENKEEPERJBC,
    ROLE_EMPATHJBC,
    ROLE_FORTUNETELLERJBC,
    ROLE_UNDERTAKERJBC,
    ROLE_ORACLEJBC,
    ROLE_SEAMSTRESSJBC,
    ROLE_NIGHTWATCHMANJBC
}

if SERVER then

    util.AddNetworkString("rdmtJoelBotCNightStarts")
    util.AddNetworkString("rdmtJoelBotCNightEnds")

    local nightStep = nil
    
    function JoelBotC:DetermineRolesInGame()
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
        -- No info in a Teensyville game
        if #JoelBotC.players > 6 then
            -- Tell the Minions who the Demon and their fellow Minions are
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

                    self:SmallNotify(
                        "Your Demon is " .. dmn:Nick(),
                        5,
                        ply
                    )

                    timer.Simple(5, function()
                        self:SmallNotify(
                            minionMessage,
                            5,
                            ply
                        )
                    end)
                end
            end
        end
    end

    function JoelBotC:DemonInfo()
        -- No info in a Teensyville game
        if #JoelBotC.players > 6 then
            -- Tell the Demon their bluffs
            for _, ply in ipairs(JoelBotC.players) do
                if ply.demon then
                    self:SmallNotify(
                        "Your bluffs are " .. ROLE_STRINGS[JoelBotC.demonBluffs[1]] .. ", " .. ROLE_STRINGS[JoelBotC.demonBluffs[2]] .. " and " .. ROLE_STRINGS[JoelBotC.demonBluffs[3]],
                        5,
                        ply
                    )

                    local mns = table.Copy(JoelBotC.minionPlayers)
                    local minionMessage = nil

                    if #mns == 1 then
                        minionMessage = "Your Minion is " .. mns[1]:Nick()
                    elseif #mns == 2 then
                        minionMessage = "Your Minions are " .. mns[1]:Nick() .. " and " .. mns[2]:Nick()
                    elseif #mns == 3 then
                        minionMessage = "Your Minions are " .. mns[1]:Nick() .. ", " .. mns[2]:Nick() " and " .. mns[3]:Nick()
                    end

                    timer.Simple(5, function()
                        self:SmallNotify(
                            minionMessage,
                            5,
                            ply
                        )
                    end)
                end
            end
        end
    end

    function JoelBotC:StartDay()
        net.Start("rdmtJoelBotCNightEnds")
        net.Broadcast()
    end

    function JoelBotC:NextNightStep()
        if JoelBotC.isFirstNight then
            if nightStep > #JoelBotC.firstNightOrder then
                JoelBotC.isFirstNight = false
                JoelBotC:StartDay()
            else
                local currentRole = JoelBotC.firstNightOrder[nightStep]
                local currentFn = JoelBotC.nightFunctions[currentRole] or nil

                if JoelBotC.rolesInGame[currentRole] then
                    currentFn(JoelBotC)
                else
                    nightStep = nightStep + 1
                    JoelBotC:NextNightStep()
                end
            end
        else
            if nightStep > #JoelBotC.otherNightOrder then
                JoelBotC:StartDay()
            else
                local currentRole = JoelBotC.otherNightOrder[nightStep]
                local currentFn = JoelBotC.nightFunctions[currentRole] or nil

                if JoelBotC.rolesInGame[currentRole] then
                    currentFn(JoelBotC)
                else
                    nightStep = nightStep + 1
                    JoelBotC:NextNightStep()
                end
            end
        end

        nightStep = nightStep + 1
    end

    function JoelBotC:StartNight()

        net.Start("rdmtJoelBotCNightStarts")
        net.Broadcast()

        JoelBotC:GetNightFunctions()
        nightStep = 1

        if JoelBotC.isFirstNight then
            JoelBotC:MinionInfo()

            timer.Simple(10, function()
                JoelBotC:DemonInfo()

                timer.Simple(10, function()
                    JoelBotC:NextNightStep()
                end)
            end)
        else
            JoelBotC:NextNightStep()
        end
    end
end