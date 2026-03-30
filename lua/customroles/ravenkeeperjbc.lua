local ROLE = {}

ROLE.nameraw = "ravenkeeperjbc"
ROLE.name = "Ravenkeeper"
ROLE.nameplural = "Ravenkeepers"
ROLE.nameext = "the Ravenkeeper"
ROLE.nameshort = "jbcrvn"

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
