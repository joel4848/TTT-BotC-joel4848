local ROLE = {}

ROLE.nameraw = "fortunetellerjbc"
ROLE.name = "Fortune Teller"
ROLE.nameplural = "Fortune Tellers"
ROLE.nameext = "the Fortune Teller"
ROLE.nameshort = "jbcfrt"

ROLE.blockspawnconvars = true

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
