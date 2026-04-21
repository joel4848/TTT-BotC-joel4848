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
    ROLE_SHABALOTHJBC,
    ROLE_POJBC,
    ROLE_OJOJBC,
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
            [ROLE_SLAYERJBC] = false,
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
            [ROLE_SHABALOTHJBC] = false,
            [ROLE_POJBC] = false,
            [ROLE_OJOJBC] = false
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

    end

    function JoelBotC:DemonInfo()
        -- Tell the Demon their bluffs
        for _, ply in ipairs(JoelBotC.players) do
            if ply.demon then
                self:SmallNotify(
                    "Your bluffs are " .. ROLE_STRINGS[JoelBotC.demonBluffs[1]] .. ", " .. ROLE_STRINGS[JoelBotC.demonBluffs[2]] .. " and " .. ROLE_STRINGS[JoelBotC.demonBluffs[3]],
                    5,
                    ply
                )
            end
        end
    end

    function JoelBotC:NextNightStep()
        if JoelBotC.isFirstNight then
            if nightStep > #JoelBotC.firstNightOrderMaster then
                JoelBotC.isFirstNight = false
                JoelBotC:StartDay()
            else
                local currentRole = JoelBotC.firstNightOrderMaster[nightStep]
                local currentFn = JoelBotC.nightFunctions[currentRole] or nil

                if JoelBotC.rolesInGame[currentRole] then
                    currentFn(JoelBotC)
                else
                    nightStep = nightStep + 1
                    JoelBotC:NextNightStep()
                end
            end
        else
            if nightStep > #JoelBotC.otherNightOrderMaster then
                JoelBotC:StartDay()
            else
                local currentRole = JoelBotC.otherNightOrderMaster[nightStep]
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
        JoelBotC:GetNightFunctions()

        if JoelBotC.isFirstNight then
            JoelBotC:MinionInfo()
            JoelBotC:DemonInfo()
        end

        nightStep = 1

        JoelBotC:NextNightStep()
    end
end