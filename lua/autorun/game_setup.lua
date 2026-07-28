JoelBotC = JoelBotC or {}

if SERVER then

    -- 'Script' -----------------------------------------------------------------------------------------------------------------
    local stewardEnabled = CreateConVar("randomat_joelbotc_steward_enabled", 1, FCVAR_NONE, "Whether the Steward is on the script", 0, 1):GetBool()
    local knightEnabled = CreateConVar("randomat_joelbotc_knight_enabled", 1, FCVAR_NONE, "Whether the Knight is on the script", 0, 1):GetBool()
    local oracleEnabled = CreateConVar("randomat_joelbotc_oracle_enabled", 1, FCVAR_NONE, "Whether the Oracle is on the script", 0, 1):GetBool()
    local chefEnabled = CreateConVar("randomat_joelbotc_chef_enabled", 1, FCVAR_NONE, "Whether the Chef is on the script", 0, 1):GetBool()
    local undertakerEnabled = CreateConVar("randomat_joelbotc_undertaker_enabled", 1, FCVAR_NONE, "Whether the Undertaker is on the script", 0, 1):GetBool()
    local nobleEnabled = CreateConVar("randomat_joelbotc_noble_enabled", 1, FCVAR_NONE, "Whether the Noble is on the script", 0, 1):GetBool()
    local investigatorEnabled = CreateConVar("randomat_joelbotc_investigator_enabled", 1, FCVAR_NONE, "Whether the Investigator is on the script", 0, 1):GetBool()
    local monkEnabled = CreateConVar("randomat_joelbotc_monk_enabled", 1, FCVAR_NONE, "Whether the Monk is on the script", 0, 1):GetBool()
    local washerwomanEnabled = CreateConVar("randomat_joelbotc_washerwoman_enabled", 1, FCVAR_NONE, "Whether the Washerwoman is on the script", 0, 1):GetBool()
    local nightwatchmanEnabled = CreateConVar("randomat_joelbotc_nightwatchman_enabled", 1, FCVAR_NONE, "Whether the Nightwatchman is on the script", 0, 1):GetBool()
    local grandmotherEnabled = CreateConVar("randomat_joelbotc_grandmother_enabled", 1, FCVAR_NONE, "Whether the Grandmother is on the script", 0, 1):GetBool()
    local seamstressEnabled = CreateConVar("randomat_joelbotc_seamstress_enabled", 1, FCVAR_NONE, "Whether the Seamstress is on the script", 0, 1):GetBool()
    local librarianEnabled = CreateConVar("randomat_joelbotc_librarian_enabled", 1, FCVAR_NONE, "Whether the Librarian is on the script", 0, 1):GetBool()
    local empathEnabled = CreateConVar("randomat_joelbotc_empath_enabled", 1, FCVAR_NONE, "Whether the Empath is on the script", 0, 1):GetBool()
    local soldierEnabled = CreateConVar("randomat_joelbotc_soldier_enabled", 1, FCVAR_NONE, "Whether the Soldier is on the script", 0, 1):GetBool()
    local ravenkeeperEnabled = CreateConVar("randomat_joelbotc_ravenkeeper_enabled", 1, FCVAR_NONE, "Whether the Ravenkeeper is on the script", 0, 1):GetBool()
    local fortunetellerEnabled = CreateConVar("randomat_joelbotc_fortuneteller_enabled", 1, FCVAR_NONE, "Whether the Fortune Teller is on the script", 0, 1):GetBool()
    local virginEnabled = CreateConVar("randomat_joelbotc_virgin_enabled", 1, FCVAR_NONE, "Whether the Virgin is on the script", 0, 1):GetBool()
    local ogreEnabled = CreateConVar("randomat_joelbotc_ogre_enabled", 1, FCVAR_NONE, "Whether the Ogre is on the script", 0, 1):GetBool()
    local snitchEnabled = CreateConVar("randomat_joelbotc_snitch_enabled", 1, FCVAR_NONE, "Whether the Snitch is on the script", 0, 1):GetBool()
    local golemEnabled = CreateConVar("randomat_joelbotc_golem_enabled", 1, FCVAR_NONE, "Whether the Golem is on the script", 0, 1):GetBool()
    local sweetheartEnabled = CreateConVar("randomat_joelbotc_sweetheart_enabled", 1, FCVAR_NONE, "Whether the Sweetheart is on the script", 0, 1):GetBool()
    local saintEnabled = CreateConVar("randomat_joelbotc_saint_enabled", 1, FCVAR_NONE, "Whether the Saint is on the script", 0, 1):GetBool()
    -- local drunkEnabled = CreateConVar("randomat_joelbotc_drunk_enabled", 0, FCVAR_NONE, "Whether the Drunk is on the script", 0, 1):GetBool()
    local recluseEnabled = CreateConVar("randomat_joelbotc_recluse_enabled", 1, FCVAR_NONE, "Whether the Recluse is on the script", 0, 1):GetBool()
    local poisonerEnabled = CreateConVar("randomat_joelbotc_poisoner_enabled", 1, FCVAR_NONE, "Whether the Poisoner is on the script", 0, 1):GetBool()
    local scarletwomanEnabled = CreateConVar("randomat_joelbotc_scarletwoman_enabled", 1, FCVAR_NONE, "Whether the Scarlet Woman is on the script", 0, 1):GetBool()
    local organgrinderEnabled = CreateConVar("randomat_joelbotc_organgrinder_enabled", 1, FCVAR_NONE, "Whether the Organ Grinder is on the script", 0, 1):GetBool()
    local assassinEnabled = CreateConVar("randomat_joelbotc_assassin_enabled", 1, FCVAR_NONE, "Whether the Assassin is on the script", 0, 1):GetBool()
    local baronEnabled = CreateConVar("randomat_joelbotc_baron_enabled", 1, FCVAR_NONE, "Whether the Baron is on the script", 0, 1):GetBool()
    -- local pukkaEnabled = CreateConVar("randomat_joelbotc_pukka_enabled", 1, FCVAR_NONE, "Whether the Pukka is on the script", 0, 1):GetBool()
    local impEnabled = CreateConVar("randomat_joelbotc_imp_enabled", 1, FCVAR_NONE, "Whether the Imp is on the script", 0, 1):GetBool()
    local poEnabled = CreateConVar("randomat_joelbotc_po_enabled", 1, FCVAR_NONE, "Whether the Po is on the script", 0, 1):GetBool()
    -- /'Script' ----------------------------------------------------------------------------------------------------------------

    JoelBotC.original_COLOR_DETECTIVE = JoelBotC.original_COLOR_DETECTIVE or {}
    JoelBotC.original_COLOR_SPECIAL_INNOCENT = JoelBotC.original_COLOR_SPECIAL_INNOCENT or {}
    JoelBotC.original_COLOR_SPECIAL_TRAITOR = JoelBotC.original_COLOR_SPECIAL_TRAITOR or {}
    JoelBotC.original_COLOR_MONSTER = JoelBotC.original_COLOR_MONSTER or {}

    JoelBotC.players = JoelBotC.players or {}
    JoelBotC.isAlive = JoelBotC.isAlive or {}
    JoelBotC.rolesInGame = JoelBotC.rolesInGame or {}
    JoelBotC.rolePool = JoelBotC.rolePool or {}
    JoelBotC.deadPlayers = JoelBotC.deadPlayers or {}
    JoelBotC.unusedTownsfolk = JoelBotC.unusedTownsfolk or {}
    JoelBotC.unusedOutsiders = JoelBotC.unusedOutsiders or {}
    JoelBotC.unusedMinions = JoelBotC.unusedMinions or {}
    JoelBotC.unusedDemons = JoelBotC.unusedDemons or {}

    local townsfolkAmount = nil
    local outsidersAmount = nil
    local minionsAmount = nil
    local demonsAmount = nil
    JoelBotC.enabledTownsfolk = {}
    JoelBotC.enabledOutsiders = {}
    JoelBotC.enabledMinions = {}
    JoelBotC.enabledDemons = {}
    JoelBotC.townsfolkPlayers = {}
    JoelBotC.outsiderPlayers = {}
    JoelBotC.goodPlayers = {}
    JoelBotC.minionPlayers = {}
    JoelBotC.demonPlayers = {}
    JoelBotC.evilPlayers = {}
    JoelBotC.seatingOrder = {}
    JoelBotC.demonBluffsPool = {}
    JoelBotC.demonBluffs = {}
    JoelBotC.players = {}
    JoelBotC.townsfolkInBag = {}
    JoelBotC.outsidersInBag = {}
    JoelBotC.minionsInBag = {}
    JoelBotC.demonsInBag = {}

    function JoelBotC:ChangeRoleColours()
        -- Custom role colours
        JoelBotC.original_COLOR_DETECTIVE = table.Copy(COLOR_DETECTIVE)
        JoelBotC.original_COLOR_SPECIAL_INNOCENT = table.Copy(COLOR_SPECIAL_INNOCENT)
        JoelBotC.original_COLOR_SPECIAL_TRAITOR = table.Copy(COLOR_SPECIAL_TRAITOR)
        JoelBotC.original_COLOR_MONSTER = table.Copy(COLOR_MONSTER)

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
    end

    function JoelBotC:BuildGameScript()
        -- Determine roles on the 'script'
        JoelBotC.enabledTownsfolk = {}
        JoelBotC.enabledOutsiders = {}
        JoelBotC.enabledMinions = {}
        JoelBotC.enabledDemons = {}
        if stewardEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_STEWARDJBC)
        end
        if knightEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_KNIGHTJBC)
        end
        if oracleEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_ORACLEJBC)
        end
        if chefEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_CHEFJBC)
        end
        if undertakerEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_UNDERTAKERJBC)
        end
        if nobleEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_NOBLEJBC)
        end
        if investigatorEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_INVESTIGATORJBC)
        end
        if monkEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_MONKJBC)
        end
        if washerwomanEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_WASHERWOMANJBC)
        end
        if nightwatchmanEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_NIGHTWATCHMANJBC)
        end
        if grandmotherEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_GRANDMOTHERJBC)
        end
        if seamstressEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_SEAMSTRESSJBC)
        end
        if librarianEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_LIBRARIANJBC)
        end
        if empathEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_EMPATHJBC)
        end
        if soldierEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_SOLDIERJBC)
        end
        if ravenkeeperEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_RAVENKEEPERJBC)
        end
        if fortunetellerEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_FORTUNETELLERJBC)
        end
        if virginEnabled then
            table.insert(JoelBotC.enabledTownsfolk, ROLE_VIRGINJBC)
        end
        if ogreEnabled then
            table.insert(JoelBotC.enabledOutsiders, ROLE_OGREJBC)
        end
        if snitchEnabled then
            table.insert(JoelBotC.enabledOutsiders, ROLE_SNITCHJBC)
        end
        if golemEnabled then
            table.insert(JoelBotC.enabledOutsiders, ROLE_GOLEMJBC)
        end
        if sweetheartEnabled then
            table.insert(JoelBotC.enabledOutsiders, ROLE_MOONCHILDJBC)
        end
        if saintEnabled then
            table.insert(JoelBotC.enabledOutsiders, ROLE_SAINTJBC)
        end
        -- if drunkEnabled then
            -- The Drunk is not currently implemented
            -- table.insert(JoelBotC.enabledOutsiders, ROLE_DRUNKJBC)
        -- end
        if recluseEnabled then
            table.insert(JoelBotC.enabledOutsiders, ROLE_RECLUSEJBC)
        end
        if poisonerEnabled then
            table.insert(JoelBotC.enabledMinions, ROLE_POISONERJBC)
        end
        if scarletwomanEnabled then
            table.insert(JoelBotC.enabledMinions, ROLE_SCARLETWOMANJBC)
        end
        if organgrinderEnabled then
            table.insert(JoelBotC.enabledMinions, ROLE_ORGANGRINDERJBC)
        end
        if assassinEnabled then
            table.insert(JoelBotC.enabledMinions, ROLE_ASSASSINJBC)
            JoelBotC.assassinAbilityUsed = false
        end
        if baronEnabled then
            table.insert(JoelBotC.enabledMinions, ROLE_BARONJBC)
        end
        -- if pukkaEnabled then
            -- The Pukka is currently broken
            -- table.insert(JoelBotC.enabledDemons, ROLE_PUKKAJBC)
        -- end
        if impEnabled then
            table.insert(JoelBotC.enabledDemons, ROLE_IMPJBC)
        end
        if poEnabled then
            table.insert(JoelBotC.enabledDemons, ROLE_POJBC)
        end
    end

    function JoelBotC:BuildGameBag()
        -- Get a table of (tabulate?) living players
        JoelBotC.players = {}
        for _, ply in player.Iterator() do
            if IsValid(ply) and not ply:IsSpec() then
                table.insert(JoelBotC.players, ply)
                ply.hasRole = nil
                ply.currentRole = ply:GetRole() or nil
                JoelBotC.isAlive[ply] = true

                ply:StripWeapons()
                ply:SetFOV(0, 0.2)
                ply:Give("weapon_ttt_unarmed")
                ply:Give("weapon_zm_carry")
                ply:Give("weapon_zm_improvised")
                ply:SelectWeapon("weapon_zm_improvised")

                -- Reset various things
                ply.botc_role = nil
                ply.golemNominated = nil
                ply.BotCDead = nil
                ply.hasGhostVote = nil
                ply.townsfolk = nil
                ply.outsider = nil
                ply.minion = nil
                ply.demon = nil
                ply.goodTeam = nil
                ply.evilTeam = nil
                ply.seatNumber = nil
                ply.nominated = nil
                ply.hasBeenNominated = nil
                ply.infoBookSegments = {}
                ply.poisonerPoisoned = nil
                ply.pukkaPoisoned = nil
                ply.organgrinderDrunk = nil
            end
        end

        JoelBotC.deadPlayers = {}

        -- Determine character type amounts
        if #JoelBotC.players == 15 then
            townsfolkAmount = 9
            outsidersAmount = 2
            minionsAmount = 3
            demonsAmount = 1
        elseif #JoelBotC.players == 14 then
            townsfolkAmount = 9
            outsidersAmount = 1
            minionsAmount = 3
            demonsAmount = 1
        elseif #JoelBotC.players == 13 then
            townsfolkAmount = 9
            outsidersAmount = 0
            minionsAmount = 3
            demonsAmount = 1
        elseif #JoelBotC.players == 12 then
            townsfolkAmount = 7
            outsidersAmount = 2
            minionsAmount = 2
            demonsAmount = 1
        elseif #JoelBotC.players == 11 then
            townsfolkAmount = 7
            outsidersAmount = 1
            minionsAmount = 2
            demonsAmount = 1
        elseif #JoelBotC.players == 10 then
            townsfolkAmount = 7
            outsidersAmount = 0
            minionsAmount = 2
            demonsAmount = 1
        elseif #JoelBotC.players == 9 then
            townsfolkAmount = 5
            outsidersAmount = 2
            minionsAmount = 1
            demonsAmount = 1
        elseif #JoelBotC.players == 8 then
            townsfolkAmount = 5
            outsidersAmount = 1
            minionsAmount = 1
            demonsAmount = 1
        elseif #JoelBotC.players == 7 then
            townsfolkAmount = 5
            outsidersAmount = 0
            minionsAmount = 1
            demonsAmount = 1
        elseif #JoelBotC.players == 6 then
            townsfolkAmount = 3
            outsidersAmount = 1
            minionsAmount = 1
            demonsAmount = 1
        elseif #JoelBotC.players == 5 then
            townsfolkAmount = 3
            outsidersAmount = 0
            minionsAmount = 1
            demonsAmount = 1
        elseif #JoelBotC.players == 1 then
            townsfolkAmount = 1
            outsidersAmount = 1
            minionsAmount = 1
            demonsAmount = 1

        --for testing
        else
            townsfolkAmount = 1
            outsidersAmount = 1
            minionsAmount = 1
            demonsAmount = 1
        end

        -- Shuffle players
        table.Shuffle(JoelBotC.players)

        -- Make working copies of character type tables and shuffle
        local townsfolkPool = table.Copy(JoelBotC.enabledTownsfolk)
        local outsiderPool = table.Copy(JoelBotC.enabledOutsiders)
        local minionPool = table.Copy(JoelBotC.enabledMinions)
        local demonPool = table.Copy(JoelBotC.enabledDemons)

        table.Shuffle(townsfolkPool)
        table.Shuffle(outsiderPool)
        table.Shuffle(minionPool)
        table.Shuffle(demonPool)

        -- Fill the master role pool
        JoelBotC.rolePool = {}

        local function AddRoles(pool, amount, alignment)
            for i = 1, amount do
                local role = table.remove(pool)
                if role then
                    JoelBotC.rolePool[#JoelBotC.rolePool + 1] = {role = role, alignment = alignment}
                end
            end
        end

        AddRoles(townsfolkPool, townsfolkAmount, "townsfolk")
        AddRoles(outsiderPool, outsidersAmount, "outsider")
        AddRoles(minionPool, minionsAmount, "minion")
        AddRoles(demonPool, demonsAmount, "demon")

        -- Baron bollocks
        local hasBaron = false
        for _, data in ipairs(JoelBotC.rolePool) do
            if data.role == ROLE_BARONJBC then
                hasBaron = true
                break
            end
        end

        if hasBaron then
            local townsfolkRemoved = 0

            for i = #JoelBotC.rolePool, 1, -1 do
                if townsfolkRemoved >= 2 then break end

                local data = JoelBotC.rolePool[i]

                if data.alignment == "townsfolk" and data.role ~= ROLE_EMPATHJBC and data.role ~= ROLE_FORTUNETELLERJBC then
                    local removedData = table.remove(JoelBotC.rolePool, i)
                    table.insert(townsfolkPool, removedData.role)

                    townsfolkRemoved = townsfolkRemoved + 1
                end
            end

            table.Shuffle(outsiderPool)

            local outsidersAdded = 0
            for i = 1, 2 do
                local nextOutsider = table.remove(outsiderPool)
                if nextOutsider then
                    table.insert(JoelBotC.rolePool, {role = nextOutsider, alignment = "outsider"})
                    outsidersAdded = outsidersAdded + 1
                end
            end
        end

        JoelBotC.unusedTownsfolk = table.Copy(townsfolkPool)
        JoelBotC.unusedOutsiders = table.Copy(outsiderPool)
        JoelBotC.unusedMinions = table.Copy(minionPool)
        JoelBotC.unusedDemons = table.Copy(demonPool)
    end

    function JoelBotC:SelectDemonBluffs()
        JoelBotC.demonBluffsTownsfolkPool = {}
        JoelBotC.demonBluffsOutsiderPool = {}
        JoelBotC.demonBluffs = {}

        table.Add(JoelBotC.demonBluffsTownsfolkPool, JoelBotC.unusedTownsfolk)
        table.Add(JoelBotC.demonBluffsOutsiderPool, JoelBotC.unusedOutsiders)

        -- Remove any roles we don't want to be Demon bluffs here
        -- table.RemoveByValue(JoelBotC.demonBluffsOutsiderPool, ROLE_RECLUSEJBC)
        -- table.RemoveByValue(JoelBotC.demonBluffsOutsiderPool, ROLE_DRUNKJBC)
        -- table.RemoveByValue(JoelBotC.demonBluffsPool, ROLE_NIGHTWATCHMANJBC)

        -- Pick which roles should be bluffs - two Townsfolk, one Outsider
        table.Shuffle(JoelBotC.demonBluffsTownsfolkPool)

        table.insert(JoelBotC.demonBluffs, 1, JoelBotC.demonBluffsTownsfolkPool[1])
        table.insert(JoelBotC.demonBluffs, 2, JoelBotC.demonBluffsTownsfolkPool[2])
        table.Shuffle(JoelBotC.demonBluffsOutsiderPool)

        table.insert(JoelBotC.demonBluffs, 3, JoelBotC.demonBluffsOutsiderPool[1])

        -- Try and make one of either the Empath or the Fortune Teller (or any ongoing info role added in the future) a bluff
        local empathAvailableAsBluff = nil
        local fortunetellerAvailableAsBluff = nil
        local empathOrFTAreBluff = nil

        for _, role in ipairs(JoelBotC.demonBluffsTownsfolkPool) do
            if role == ROLE_EMPATHJBC then
                empathAvailableAsBluff = true
            end
            if role == ROLE_FORTUNETELLERJBC  then
                fortunetellerAvailableAsBluff = true
            end
        end

        for _, role in ipairs(JoelBotC.demonBluffs) do
            if role == ROLE_EMPATHJBC or role == ROLE_FORTUNETELLERJBC then
                empathOrFTAreBluff = true
            end
        end

        if not empathOrFTAreBluff then
            local empathFTPool = {}
            if empathAvailableAsBluff then
                table.insert(empathFTPool, ROLE_EMPATHJBC)
            end
            if fortunetellerAvailableAsBluff then
                table.insert(empathFTPool, ROLE_FORTUNETELLERJBC)
            end

            local addedBluff = nil
            if #empathFTPool > 0 then
                -- table.Shuffle(empathFTPool)
                -- Not using table.Shuffle because it didn't actually seem to shuffle
                JoelBotC.demonBluffs[1] = empathFTPool[math.random(1,#empathFTPool)]
                addedBluff = JoelBotC.demonBluffs[1] or nil
            end

            if addedBluff then
                table.RemoveByValue(empathFTPool, addedBluff)
            end
        end
    end

    function JoelBotC:AssignRolesAndSeats()
        -- More shufflage
        table.Shuffle(JoelBotC.rolePool)

        JoelBotC.townsfolkInBag = {}
        JoelBotC.outsidersInBag = {}
        JoelBotC.minionsInBag = {}
        JoelBotC.demonsInBag = {}

        -- Time to actually assign roles to players!
        for i, ply in ipairs(JoelBotC.players) do
            local entry = JoelBotC.rolePool[i]

            -- Reset flags because I forgot this like an idiot and got VERY confused during testing
            ply.townsfolk = nil
            ply.outsider = nil
            ply.minion = nil
            ply.demon = nil
            ply.goodTeam = nil
            ply.evilTeam = nil

            if entry.alignment == "townsfolk" then
                ply.townsfolk = true
                ply.goodTeam = true
                table.insert(JoelBotC.townsfolkInBag, entry.role)
            elseif entry.alignment == "outsider" then
                ply.outsider = true
                ply.goodTeam = true
                table.insert(JoelBotC.outsidersInBag, entry.role)
            elseif entry.alignment == "minion" then
                ply.minion = true
                ply.evilTeam = true
                table.insert(JoelBotC.minionsInBag, entry.role)
            elseif entry.alignment == "demon" then
                ply.demon = true
                ply.evilTeam = true
                table.insert(JoelBotC.demonsInBag, entry.role)
            end

            ply.botc_role = entry.role
        end

        -- ... and make them that role!
        for _, ply in ipairs(JoelBotC.players) do
            Randomat:SetRole(ply, ply.botc_role)
        end
        SendFullStateUpdate()

        -- Create tables of which players are each character type
        JoelBotC.townsfolkPlayers = {}
        JoelBotC.outsiderPlayers = {}
        JoelBotC.minionPlayers = {}
        JoelBotC.demonPlayers = {}
        JoelBotC.goodPlayers = {}
        JoelBotC.evilPlayers = {}

        for _, ply in player.Iterator() do
            if IsValid(ply) and not ply:IsSpec() then
                if ply.townsfolk then
                    table.insert(JoelBotC.townsfolkPlayers, ply)
                elseif ply.outsider then
                    table.insert(JoelBotC.outsiderPlayers, ply)
                elseif ply.minion then
                    table.insert(JoelBotC.minionPlayers, ply)
                elseif ply.demon then
                    table.insert(JoelBotC.demonPlayers, ply)
                end

                if ply.goodTeam then
                    table.insert(JoelBotC.goodPlayers, ply)
                elseif ply.evilTeam then
                    table.insert(JoelBotC.evilPlayers, ply)
                end
            end
        end

        -- Create seating order table
        JoelBotC.seatingOrder = table.Copy(JoelBotC.players)

        for i, ply in ipairs(JoelBotC.seatingOrder) do
            -- PrintMessage(HUD_PRINTTALK, "Seat " .. i .. ": " .. ply:Nick() .. " - " .. ROLE_STRINGS[ply.botc_role])
            ply.seatNumber = i
        end

        net.Start("rdmtJoelBotCSeatingOrder")
            net.WriteTable(JoelBotC.seatingOrder)
        net.Broadcast()
        JoelBotC:AliveDeadUpdate()
    end

    function JoelBotC:GiveStartingBooks()
        JoelBotC:RoleAbilitiesForBook()

        for _, ply in ipairs(JoelBotC.players) do
            -- Give notebook and admin book
            GiveBookQuill(ply)
            ply:Give("weapon_ttt_joelbotc_adminbook")

            -- Set up this player's info book segment store (role + ability + divider)
            JoelBotC:InitInfoBook(ply)

            -- Issue the signed book (all 4 pages, "Your info" starts with just role/ability)
            JoelBotC:RebuildInfoBook(ply)

            ply:SelectWeapon("weapon_ttt_signedbook")
        end
    end

end