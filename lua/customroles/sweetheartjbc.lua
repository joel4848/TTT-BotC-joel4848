local ROLE = {}

ROLE.nameraw = "sweetheartjbc"
ROLE.name = "Sweetheart"
ROLE.nameplural = "Sweethearts"
ROLE.nameext = "the Sweetheart"
ROLE.nameshort = "jbcswh"

ROLE.blockspawnconvars = true

ROLE.desc = [[]]

ROLE.shortdesc = ""

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.shop = nil
ROLE.loadout = {}

ROLE.startingcredits = nil

ROLE.startinghealth = nil
ROLE.maxhealth = nil

ROLE.isactive = nil
ROLE.selectionpredicate = nil
ROLE.shouldactlikejester = nil

ROLE.translations = {}

ROLE.convars = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end
