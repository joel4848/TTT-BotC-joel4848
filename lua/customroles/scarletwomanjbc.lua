local ROLE = {}

ROLE.nameraw = "scarletwomanjbc"
ROLE.name = "Scarlet Woman"
ROLE.nameplural = "Scarlet Women"
ROLE.nameext = "the Scarlet Woman"
ROLE.nameshort = "jbcswm"

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
