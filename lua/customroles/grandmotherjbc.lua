local ROLE = {}

ROLE.nameraw = "grandmotherjbc"
ROLE.name = "Grandmother"
ROLE.nameplural = "Grandmothers"
ROLE.nameext = "the Grandmother"
ROLE.nameshort = "jbcgrm"

ROLE.desc = [[]]

ROLE.shortdesc = ""

ROLE.team = ROLE_TEAM_DETECTIVE

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
