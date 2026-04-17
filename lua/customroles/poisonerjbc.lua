local ROLE = {}

ROLE.nameraw = "poisonerjbc"
ROLE.name = "Poisoner"
ROLE.nameplural = "Poisoners"
ROLE.nameext = "the Poisoner"
ROLE.nameshort = "jbcpsn"

ROLE.blockspawnconvars = true

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
