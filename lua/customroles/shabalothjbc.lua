local ROLE = {}

ROLE.nameraw = "shabalothjbc"
ROLE.name = "Shabaloth"
ROLE.nameplural = "Shabaloths"
ROLE.nameext = "the Shabaloth"
ROLE.nameshort = "jbcshb"

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
