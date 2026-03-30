local EVENT = {}

EVENT.Title = "Legally distinct sanguinous fluid on the time-spire"
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

local players = {}
local townsfolkAmount = nil
local outsidersAmount = nil
local minionsAmount = nil
local demonsAmount = nil
local enabledTownsfolk = {}
local enabledOutsiders = {}
local enabledMinions = {}
local enabledDemons = {}

function EVENT:Begin()

----------------------------------------------------------------------------------------------------------------------------
-- ASSIGN ROLES
----------------------------------------------------------------------------------------------------------------------------

    -- Determine roles on the 'script'




    -- Get a table of (tabulate?) living players
    for _, p in player.Iterator() do
        if IsValid(p) and not p:IsSpec() then
            table.insert(players, p)
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
    elseif #players < 5 then

    elseif #players > 15 then

    end

end

Randomat:register(EVENT)