local EVENT = {}
EVENT.id = "joelbotc"

JoelBotC = JoelBotC or {}

local original_COLOR_DETECTIVE = {}
local original_COLOR_SPECIAL_INNOCENT = {}
local original_COLOR_SPECIAL_TRAITOR = {}
local original_COLOR_MONSTER = {}
local eventActive = nil

JoelBotC.isAliveClient = JoelBotC.isAliveClient or {}
JoelBotC.seatingOrderClient = JoelBotC.seatingOrderClient or {}

function EVENT:Begin()

    eventActive = true

    for _, ply in ipairs(player.GetAll()) do
        ply.originalColour = ply:GetColor()
        ply.originalRenderMode = ply:GetRenderMode()
    end

    net.Receive("rdmtJoelBotCAliveDeadUpdate", function()
        JoelBotC.isAliveClient = net.ReadTable()

        for _, ply in ipairs(JoelBotC.seatingOrderClient) do
            if JoelBotC.isAliveClient[ply] == false then
                ply:SetColor(Color(255, 255, 255, 100))
                ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            else
                ply:SetColor(Color(255, 255, 255, 255))
                ply:SetRenderMode(RENDERMODE_NORMAL)
            end
        end
    end)

    -- Opening splash screen
    JoelBotC:BotCTitleCreate()
    timer.Simple(1, function()
        JoelBotC:BotCTitleDestroy()
    end)

    -- JoelBotC:SeatingGUICreate()

    -------------------------------------------------------------------------------------
    -- Custom role colours
    -------------------------------------------------------------------------------------
    original_COLOR_DETECTIVE = table.Copy(COLOR_DETECTIVE)
    original_COLOR_SPECIAL_INNOCENT = table.Copy(COLOR_SPECIAL_INNOCENT)
    original_COLOR_SPECIAL_TRAITOR = table.Copy(COLOR_SPECIAL_TRAITOR)
    original_COLOR_MONSTER = table.Copy(COLOR_MONSTER)

    COLOR_DETECTIVE = {
        ["default"] = Color(31, 101, 255, 255),
        ["simple"] = Color(31, 101, 255, 255),
        ["protan"] = Color(31, 101, 255, 255),
        ["deutan"] = Color(31, 101, 255, 255),
        ["tritan"] = Color(31, 101, 255, 255)
    }

    COLOR_SPECIAL_INNOCENT = {
        ["default"] = Color(70, 213, 255, 255),
        ["simple"] = Color(70, 213, 255, 255),
        ["protan"] = Color(70, 213, 255, 255),
        ["deutan"] = Color(70, 213, 255, 255),
        ["tritan"] = Color(70, 213, 255, 255)
    }

    COLOR_SPECIAL_TRAITOR = {
        ["default"] = Color(255, 105, 0, 255),
        ["simple"] = Color(255, 105, 0, 255),
        ["protan"] = Color(255, 105, 0, 255),
        ["deutan"] = Color(255, 105, 0, 255),
        ["tritan"] = Color(255, 105, 0, 255)
    }

    COLOR_MONSTER = {
        ["default"] = Color(206, 1, 0, 255),
        ["simple"] = Color(206, 1, 0, 255),
        ["protan"] = Color(206, 1, 0, 255),
        ["deutan"] = Color(206, 1, 0, 255),
        ["tritan"] = Color(206, 1, 0, 255)
    }

    UpdateRoleColours()

    net.Receive("rdmtJoelBotCOpenSeatingGUI", function()
        JoelBotC:SeatingGUICreate()
    end)
end

function EVENT:End()

    -- Remove any overlays etc.
    JoelBotC:SeatingGUIDestroy()
    JoelBotC:BotCTitleDestroy()

    -- Reset team colours
    if eventActive then
        COLOR_DETECTIVE = table.Copy(original_COLOR_DETECTIVE)
        COLOR_SPECIAL_INNOCENT = table.Copy(original_COLOR_SPECIAL_INNOCENT)
        COLOR_SPECIAL_TRAITOR = table.Copy(original_COLOR_SPECIAL_TRAITOR)
        COLOR_MONSTER = table.Copy(original_COLOR_MONSTER)
    end
    UpdateRoleColours()

    if eventActive then
        for _, ply in ipairs(player.GetAll()) do
            ply:SetColor(ply.originalColour)
            ply:SetRenderMode(ply.originalRenderMode)
        end
    end
    
end

Randomat:register(EVENT)