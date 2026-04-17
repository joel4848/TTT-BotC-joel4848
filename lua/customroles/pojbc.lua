local ROLE = {}

ROLE.nameraw = "pojbc"
ROLE.name = "Po"
ROLE.nameplural = "Pos"
ROLE.nameext = "the Po"
ROLE.nameshort = "jbcpo"

ROLE.blockspawnconvars = true

ROLE.desc = [[]]

ROLE.shortdesc = ""

ROLE.team = ROLE_TEAM_MONSTER

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
