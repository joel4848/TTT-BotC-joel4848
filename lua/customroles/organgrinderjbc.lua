local ROLE = {}

ROLE.nameraw = "organgrinderjbc"
ROLE.name = "Organ Grinder"
ROLE.nameplural = "Organs"
ROLE.nameext = "the Organ"
ROLE.nameshort = "jbcorg"

ROLE.desc = [[]]

ROLE.shortdesc = ""

ROLE.team = ROLE_TEAM_TRAITOR

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
