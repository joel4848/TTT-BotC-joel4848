local EVENT = {}

EVENT.Title = "JoelBotC"
EVENT.Description = "You know how this works!"
EVENT.id = "joelbotc"
EVENT.Categories = {"gamemode", "largeimpact", "rolechange"}

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
local slayerEnabled = CreateConVar("randomat_joelbotc_slayer_enabled", 1, FCVAR_NONE, "Whether the Slayer is on the script", 0, 1):GetBool()
local empathEnabled = CreateConVar("randomat_joelbotc_empath_enabled", 1, FCVAR_NONE, "Whether the Empath is on the script", 0, 1):GetBool()
local soldierEnabled = CreateConVar("randomat_joelbotc_soldier_enabled", 1, FCVAR_NONE, "Whether the Soldier is on the script", 0, 1):GetBool()
local ravenkeeperEnabled = CreateConVar("randomat_joelbotc_ravenkeeper_enabled", 1, FCVAR_NONE, "Whether the Ravenkeeper is on the script", 0, 1):GetBool()
local fortunetellerEnabled = CreateConVar("randomat_joelbotc_fortuneteller_enabled", 1, FCVAR_NONE, "Whether the Fortune is on the script", 0, 1):GetBool()
local virginEnabled = CreateConVar("randomat_joelbotc_virgin_enabled", 1, FCVAR_NONE, "Whether the Virgin is on the script", 0, 1):GetBool()
local ogreEnabled = CreateConVar("randomat_joelbotc_ogre_enabled", 1, FCVAR_NONE, "Whether the Ogre is on the script", 0, 1):GetBool()
local moonchildEnabled = CreateConVar("randomat_joelbotc_moonchild_enabled", 1, FCVAR_NONE, "Whether the Moonchild is on the script", 0, 1):GetBool()
local saintEnabled = CreateConVar("randomat_joelbotc_saint_enabled", 1, FCVAR_NONE, "Whether the Saint is on the script", 0, 1):GetBool()
local drunkEnabled = CreateConVar("randomat_joelbotc_drunk_enabled", 1, FCVAR_NONE, "Whether the Drunk is on the script", 0, 1):GetBool()
local recluseEnabled = CreateConVar("randomat_joelbotc_recluse_enabled", 1, FCVAR_NONE, "Whether the Recluse is on the script", 0, 1):GetBool()
local poisonerEnabled = CreateConVar("randomat_joelbotc_poisoner_enabled", 1, FCVAR_NONE, "Whether the Poisoner is on the script", 0, 1):GetBool()
local scarletwomanEnabled = CreateConVar("randomat_joelbotc_scarletwoman_enabled", 1, FCVAR_NONE, "Whether the Scarlet is on the script", 0, 1):GetBool()
local organgrinderEnabled = CreateConVar("randomat_joelbotc_organgrinder_enabled", 1, FCVAR_NONE, "Whether the Organ is on the script", 0, 1):GetBool()
local assassinEnabled = CreateConVar("randomat_joelbotc_assassin_enabled", 1, FCVAR_NONE, "Whether the Assassin is on the script", 0, 1):GetBool()
local baronEnabled = CreateConVar("randomat_joelbotc_baron_enabled", 1, FCVAR_NONE, "Whether the Baron is on the script", 0, 1):GetBool()
local pukkaEnabled = CreateConVar("randomat_joelbotc_pukka_enabled", 1, FCVAR_NONE, "Whether the Pukka is on the script", 0, 1):GetBool()
local impEnabled = CreateConVar("randomat_joelbotc_imp_enabled", 1, FCVAR_NONE, "Whether the Imp is on the script", 0, 1):GetBool()
local shabalothEnabled = CreateConVar("randomat_joelbotc_shabaloth_enabled", 1, FCVAR_NONE, "Whether the Shabaloth is on the script", 0, 1):GetBool()
local poEnabled = CreateConVar("randomat_joelbotc_po_enabled", 1, FCVAR_NONE, "Whether the Po is on the script", 0, 1):GetBool()
local ojoEnabled = CreateConVar("randomat_joelbotc_ojo_enabled", 1, FCVAR_NONE, "Whether the Ojo is on the script", 0, 1):GetBool()
-- /'Script' ----------------------------------------------------------------------------------------------------------------

local original_COLOR_DETECTIVE = {}
local original_COLOR_SPECIAL_INNOCENT = {}
local original_COLOR_SPECIAL_TRAITOR = {}
local original_COLOR_MONSTER = {}

function EVENT:Begin()

    local players = {}
    local townsfolkAmount = nil
    local outsidersAmount = nil
    local minionsAmount = nil
    local demonsAmount = nil
    local enabledTownsfolk = {}
    local enabledOutsiders = {}
    local enabledMinions = {}
    local enabledDemons = {}
    local townsfolkPlayers = {}
    local outsiderPlayers = {}
    local goodPlayers = {}
    local minionPlayers = {}
    local demonPlayers = {}
    local evilPlayers = {}
    local seatingOrder = {}

    -- Custom role colours
    original_COLOR_DETECTIVE = table.Copy(COLOR_DETECTIVE)
    original_COLOR_SPECIAL_INNOCENT = table.Copy(COLOR_SPECIAL_INNOCENT)
    original_COLOR_SPECIAL_TRAITOR = table.Copy(COLOR_SPECIAL_TRAITOR)
    original_COLOR_MONSTER = table.Copy(COLOR_MONSTER)

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

----------------------------------------------------------------------------------------------------------------------------
-- ASSIGN ROLES
----------------------------------------------------------------------------------------------------------------------------

    -- Determine roles on the 'script'
    if stewardEnabled then
        table.insert(enabledTownsfolk, ROLE_STEWARDJBC)
    end
    if knightEnabled then
        table.insert(enabledTownsfolk, ROLE_KNIGHTJBC)
    end
    if oracleEnabled then
        table.insert(enabledTownsfolk, ROLE_ORACLEJBC)
    end
    if chefEnabled then
        table.insert(enabledTownsfolk, ROLE_CHEFJBC)
    end
    if undertakerEnabled then
        table.insert(enabledTownsfolk, ROLE_UNDERTAKERJBC)
    end
    if nobleEnabled then
        table.insert(enabledTownsfolk, ROLE_NOBLEJBC)
    end
    if investigatorEnabled then
        table.insert(enabledTownsfolk, ROLE_INVESTIGATORJBC)
    end
    if monkEnabled then
        table.insert(enabledTownsfolk, ROLE_MONKJBC)
    end
    if washerwomanEnabled then
        table.insert(enabledTownsfolk, ROLE_WASHERWOMANJBC)
    end
    if nightwatchmanEnabled then
        table.insert(enabledTownsfolk, ROLE_NIGHTWATCHMANJBC)
    end
    if grandmotherEnabled then
        table.insert(enabledTownsfolk, ROLE_GRANDMOTHERJBC)
    end
    if seamstressEnabled then
        table.insert(enabledTownsfolk, ROLE_SEAMSTRESSJBC)
    end
    if librarianEnabled then
        table.insert(enabledTownsfolk, ROLE_LIBRARIANJBC)
    end
    if slayerEnabled then
        table.insert(enabledTownsfolk, ROLE_SLAYERJBC)
    end
    if empathEnabled then
        table.insert(enabledTownsfolk, ROLE_EMPATHJBC)
    end
    if soldierEnabled then
        table.insert(enabledTownsfolk, ROLE_SOLDIERJBC)
    end
    if ravenkeeperEnabled then
        table.insert(enabledTownsfolk, ROLE_RAVENKEEPERJBC)
    end
    if fortunetellerEnabled then
        table.insert(enabledTownsfolk, ROLE_FORTUNETELLERJBC)
    end
    if virginEnabled then
        table.insert(enabledTownsfolk, ROLE_VIRGINJBC)
    end
    if ogreEnabled then
        table.insert(enabledOutsiders, ROLE_OGREJBC)
    end
    if moonchildEnabled then
        table.insert(enabledOutsiders, ROLE_MOONCHILDJBC)
    end
    if saintEnabled then
        table.insert(enabledOutsiders, ROLE_SAINTJBC)
    end
    if drunkEnabled then
        table.insert(enabledOutsiders, ROLE_DRUNKJBC)
    end
    if recluseEnabled then
        table.insert(enabledOutsiders, ROLE_RECLUSEJBC)
    end
    if poisonerEnabled then
        table.insert(enabledMinions, ROLE_POISONERJBC)
    end
    if scarletwomanEnabled then
        table.insert(enabledMinions, ROLE_SCARLETWOMANJBC)
    end
    if organgrinderEnabled then
        table.insert(enabledMinions, ROLE_ORGANGRINDERJBC)
    end
    if assassinEnabled then
        table.insert(enabledMinions, ROLE_ASSASSINJBC)
    end
    if baronEnabled then
        table.insert(enabledMinions, ROLE_BARONJBC)
    end
    if pukkaEnabled then
        table.insert(enabledDemons, ROLE_PUKKAJBC)
    end
    if impEnabled then
        table.insert(enabledDemons, ROLE_IMPJBC)
    end
    if shabalothEnabled then
        table.insert(enabledDemons, ROLE_SHABALOTHJBC)
    end
    if poEnabled then
        table.insert(enabledDemons, ROLE_POJBC)
    end
    if ojoEnabled then
        table.insert(enabledDemons, ROLE_OJOJBC)
    end

    -- Get a table of (tabulate?) living players
    for _, ply in player.Iterator() do
        if IsValid(ply) and not ply:IsSpec() then
            table.insert(players, ply)
            ply.hasRole = nil
        end
    end

    -- Determine character type amounts
    if #players == 15 then
        townsfolkAmount = 9
        outsidersAmount = 2
        minionsAmount = 3
        demonsAmount = 1
    elseif #players == 14 then
        townsfolkAmount = 9
        outsidersAmount = 1
        minionsAmount = 3
        demonsAmount = 1
    elseif #players == 13 then
        townsfolkAmount = 9
        outsidersAmount = 0
        minionsAmount = 3
        demonsAmount = 1
    elseif #players == 12 then
        townsfolkAmount = 7
        outsidersAmount = 2
        minionsAmount = 2
        demonsAmount = 1
    elseif #players == 11 then
        townsfolkAmount = 7
        outsidersAmount = 1
        minionsAmount = 2
        demonsAmount = 1
    elseif #players == 10 then
        townsfolkAmount = 7
        outsidersAmount = 0
        minionsAmount = 2
        demonsAmount = 1
    elseif #players == 9 then
        townsfolkAmount = 5
        outsidersAmount = 2
        minionsAmount = 1
        demonsAmount = 1
    elseif #players == 8 then
        townsfolkAmount = 5
        outsidersAmount = 1
        minionsAmount = 1
        demonsAmount = 1
    elseif #players == 7 then
        townsfolkAmount = 5
        outsidersAmount = 0
        minionsAmount = 1
        demonsAmount = 1
    elseif #players == 6 then
        townsfolkAmount = 3
        outsidersAmount = 1
        minionsAmount = 1
        demonsAmount = 1
    elseif #players == 5 then
        townsfolkAmount = 3
        outsidersAmount = 0
        minionsAmount = 1
        demonsAmount = 1
    elseif #players == 1 then
        townsfolkAmount = 1
        outsidersAmount = 1
        minionsAmount = 1
        demonsAmount = 1

    --for testing
    else
        townsfolkAmount = 0
        outsidersAmount = 0
        minionsAmount = 4
        demonsAmount = 0
    end

    -- Assign character types to players

    -- Shuffle players
    table.Shuffle(players)

    -- Make working copies of character type tables and shuffle (Can one shuffle too much?)
    local townsfolkPool = table.Copy(enabledTownsfolk)
    local outsiderPool  = table.Copy(enabledOutsiders)
    local minionPool    = table.Copy(enabledMinions)
    local demonPool     = table.Copy(enabledDemons)

    table.Shuffle(townsfolkPool)
    table.Shuffle(outsiderPool)
    table.Shuffle(minionPool)
    table.Shuffle(demonPool)

    -- Fill the master role pool
    local rolePool = {}

    local function AddRoles(pool, amount, alignment)
        for i = 1, amount do
            local role = table.remove(pool)
            if role then
                rolePool[#rolePool + 1] = {role = role, alignment = alignment}
            end
        end
    end

    AddRoles(townsfolkPool, townsfolkAmount, "townsfolk")
    AddRoles(outsiderPool,  outsidersAmount, "outsider")
    AddRoles(minionPool,    minionsAmount,   "minion")
    AddRoles(demonPool,     demonsAmount,    "demon")

    -- More shufflage
    table.Shuffle(rolePool)

    -- Time to actually assign roles to players!
    for i, ply in ipairs(players) do
        local entry = rolePool[i]

        if entry.alignment == "townsfolk" then
            ply.townsfolk = true
        elseif entry.alignment == "outsider" then
            ply.outsider = true
        elseif entry.alignment == "minion" then
            ply.minion = true
        elseif entry.alignment == "demon" then
            ply.demon = true
        end

        ply.botc_role = entry.role
    end

    -- ... and make them that role!
    for _, ply in ipairs(players) do
        Randomat:SetRole(ply, ply.botc_role)
    end
    SendFullStateUpdate()

    -- Create tables of which players are each character type
    for _, ply in player.Iterator() do
        if IsValid(ply) and not ply:IsSpec() then
            if ply.townsfolk then
                table.insert(townsfolkPlayers, ply)
                table.insert(goodPlayers, ply)
            elseif ply.outsider then
                table.insert(outsiderPlayers, ply)
                table.insert(goodPlayers, ply)
            elseif ply.minion then
                table.insert(minionPlayers, ply)
                table.insert(evilPlayers, ply)
            elseif ply.demon then
                table.insert(demonPlayers, ply)
                table.insert(evilPlayers, ply)
            end
        end
    end

    -- Create seating order table
    seatingOrder = table.Copy(players)

    for i, ply in ipairs(seatingOrder) do
        PrintMessage(HUD_PRINTTALK, "Seat " .. i .. ": " .. ply:Nick())
    end

    ----------------------------------------------------------------------------------------------------------------------------
    -- ROLE FUNCTIONS
    ----------------------------------------------------------------------------------------------------------------------------

    -- steward
    local function StewardInfo()
        local stewardInfo = nil
        
        for _, ply in ipairs(players) do
            if ply:IsSteward() then
                if ply.droisoned then
                    repeat
                        table.Shuffle(players)
                        stewardInfo = players[1]
                    until not (stewardInfo == ply)
                else
                    repeat
                        table.Shuffle(goodPlayers)
                        stewardInfo = goodPlayers[1]
                    until not stewardInfo == ply
                end

                self:SmallNotify("Your starting information: " .. stewardInfo:Nick() .. " is good", 5, ply)
            end
        end
    end

    -- knight
    local function KnightInfo()
        local knightInfo1 = nil
        local knightInfo2 = nil
        local knightInfoPool = {}

        for _, ply in ipairs(players) do
            if ply:IsKnight() then
                if ply.droisoned then
                    repeat
                        table.Shuffle(players)

                        knightInfo1 = players[1]
                        knightInfo1 = players[2]
                    until not (knightInfo1 == ply or knightInfo2 == ply or knightInfo1 == knightInfo2)
                else
                    table.Add(knightInfoPool, goodPlayers)
                    table.Add(knightInfoPool, minionPlayers)
                    
                    repeat
                        table.Shuffle(knightInfoPool)

                        knightInfo1 = knightInfoPool[1]
                        knightInfo2 = knightInfoPool[2]
                    until not (knightInfo1 == ply or knightInfo2 == ply or knightInfo1 == knightInfo2)
                end

                self:SmallNotify("Your starting information: Neither " .. knightInfo1:Nick() .. " nor " .. knightInfo2:Nick() .. " is the Demon", 5, ply)
            end
        end
    end

    -- oracle



    -- chef



    -- undertaker



    -- noble



    -- investigator



    -- monk



    -- washerwoman



    -- nightwatchman



    -- grandmother



    -- seamstress



    -- librarian



    -- slayer



    -- empath



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



    -- scarletwoman



    -- organgrinder



    -- assassin



    -- baron



    -- pukka



    -- imp



    -- shabaloth



    -- po



    -- ojo

















end

function EVENT:End()
    if isActive then
        COLOR_DETECTIVE = table.Copy(original_COLOR_DETECTIVE)
        COLOR_SPECIAL_INNOCENT = table.Copy(original_COLOR_SPECIAL_INNOCENT)
        COLOR_SPECIAL_TRAITOR = table.Copy(original_COLOR_SPECIAL_TRAITOR)
        COLOR_MONSTER = table.Copy(original_COLOR_MONSTER)
    end

    UpdateRoleColours()
end

Randomat:register(EVENT)