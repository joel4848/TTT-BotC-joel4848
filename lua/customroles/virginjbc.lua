local ROLE = {}

ROLE.nameraw = "virginjbc"
ROLE.name = "Virgin"
ROLE.nameplural = "Virgins"
ROLE.nameext = "the Virgin"
ROLE.nameshort = "jbcvrg"

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
