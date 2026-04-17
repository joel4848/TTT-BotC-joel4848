local ROLE = {}

ROLE.nameraw = "moonchildjbc"
ROLE.name = "Moonchild"
ROLE.nameplural = "Moonchilds"
ROLE.nameext = "the Moonchild"
ROLE.nameshort = "jbcmch"

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
