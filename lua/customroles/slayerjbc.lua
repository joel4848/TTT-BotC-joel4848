local ROLE = {}

ROLE.nameraw = "slayerjbc"
ROLE.name = "Slayer"
ROLE.nameplural = "Slayers"
ROLE.nameext = "the Slayer"
ROLE.nameshort = "jbcsly"

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
