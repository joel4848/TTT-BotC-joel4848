local EVENT = {}
EVENT.id = "joelbotc"

local botcTitleParent
local titleFrameScale = 1
local isShowingTitle = false

local original_COLOR_DETECTIVE = {}
local original_COLOR_SPECIAL_INNOCENT = {}
local original_COLOR_SPECIAL_TRAITOR = {}
local original_COLOR_MONSTER = {}

function EVENT:Begin()

    local client = LocalPlayer()

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

    -------------------------------------------------------------------------------------
    -- Title image
    -------------------------------------------------------------------------------------

    if IsValid(client) and not client:IsSpec() then
        isShowingTitle = true
        local scrW, scrH = ScrW(), ScrH()

        local imgW, imgH = 2096, 538
        local maxScale = math.min(scrW / imgW, scrH / imgH)
        local finalScale = maxScale * 0.87 * titleFrameScale
        local width  = imgW * finalScale
        local height = imgH * finalScale
        local top  = (scrH / 2) - (height / 2)
        local left = (scrW / 2) - (width / 2)

        botcTitleParent = vgui.Create("DFrame")
        botcTitleParent:SetSize(width, height)
        botcTitleParent:SetPos(left, top)
        botcTitleParent:SetTitle("")
        botcTitleParent:SetDraggable(false)
        botcTitleParent:ShowCloseButton(false)
        botcTitleParent:SetDeleteOnClose(true)

        -- Have to draw something apparently but then make it alpha 0
        botcTitleParent.Paint = function(self,w,h)
            draw.RoundedBox(0,4,4,w-8,h-8,Color(0, 0, 0))
        end

        -- Joel BotC title image
        botcTitleImage = vgui.Create("DImage", botcTitleParent)
        botcTitleImage:SetSize(width, height)
        botcTitleImage:SetImage("vgui/ttt/joelbotc/joelbotctitle.png")
    end

    timer.Simple(5, function()
        if IsValid(botcTitleParent) then
            botcTitleParent:Close()
        end

        isShowingTitle = false
    end)

end

function EVENT:End()
    if isActive then
        COLOR_DETECTIVE = table.Copy(original_COLOR_DETECTIVE)
        COLOR_SPECIAL_INNOCENT = table.Copy(original_COLOR_SPECIAL_INNOCENT)
        COLOR_SPECIAL_TRAITOR = table.Copy(original_COLOR_SPECIAL_TRAITOR)
        COLOR_MONSTER = table.Copy(original_COLOR_MONSTER)
    end

    UpdateRoleColours()

    if IsValid(botcTitleParent) then
        botcTitleParent:Close()
        isShowingTitle = false
    end
end

Randomat:register(EVENT)