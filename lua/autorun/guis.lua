JoelBotC = JoelBotC or {}
JoelBotC.seatingOrderClient = JoelBotC.seatingOrderClient or {}

-----------------------------------------------------------------------------------------
---------------------------------------SERVER--------------------------------------------
-----------------------------------------------------------------------------------------

if SERVER then

    util.AddNetworkString("rdmtJoelBotCSeatingGUIOpen")
    util.AddNetworkString("rdmtJoelBotCSeatingGUIClose")
    util.AddNetworkString("rdmtJoelBotCSeatingGUIChoice")

    JoelBotC.seatingGUIButtonPressed = nil
    JoelBotC.seatingGUIPressingPlayer = nil

    function JoelBotC:SendSeatingGUICreate(ply)
        if ply then
            net.Start("rdmtJoelBotCSeatingGUIOpen")
            net.Send(ply)
        else
            net.Start("rdmtJoelBotCSeatingGUIOpen")
            net.Broadcast()
        end
    end

    function JoelBotC:SendSeatingGUIDestroy(ply)
        if ply then
            net.Start("rdmtJoelBotCSeatingGUIClose")
            net.Send(ply)
        else
            net.Start("rdmtJoelBotCSeatingGUIClose")
            net.Broadcast()
        end
    end

    net.Receive("rdmtJoelBotCSeatingGUIChoice", function(_, ply)
        JoelBotC.seatingGUIButtonPressed = net.ReadInt(6)
        JoelBotC.seatingGUIPressingPlayer = ply
    end)
end

-----------------------------------------------------------------------------------------
---------------------------------------CLIENT--------------------------------------------
-----------------------------------------------------------------------------------------

if CLIENT then

    net.Receive("rdmtJoelBotCSeatingOrder", function()
        JoelBotC.seatingOrderClient = {}
        JoelBotC.seatingOrderClient = net.ReadTable()
    end)

    local function SeatingGUIButtonPressed(btn)
        net.Start("rdmtJoelBotCSeatingGUIChoice")
            net.WriteInt(btn, 6)
        net.SendToServer()
    end
    -------------------------------------------------------------------------------------
    -- Title splash image
    -------------------------------------------------------------------------------------

    local botcTitleParent
    local titleFrameScale = 1

    function JoelBotC:BotCTitleCreate()
        local client = LocalPlayer()

        if IsValid(client) and not client:IsSpec() then
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
    end

    function JoelBotC:BotCTitleDestroy()
        if IsValid(botcTitleParent) then
            botcTitleParent:Remove()
        end
    end

    -------------------------------------------------------------------------------------
    -- Seating GUI
    -------------------------------------------------------------------------------------

    local nomGUI = nil
    local nomGUIButtonSize = 60
    local nomGUIScale = 1.0

    function JoelBotC:SeatingGUICreate()
        if IsValid(nomGUI) then return end

        local players = JoelBotC.seatingOrderClient
        local count = #JoelBotC.seatingOrderClient
        if count <= 0 then return end


        local ratio = 4 
        local nomGUIVerticalStretch = 0.6
        local nomGUIPolePush = 0.1 


        nomGUI = vgui.Create("DPanel")
        nomGUI:SetSize(ScrW(), ScrH())
        nomGUI:SetPos(0, 0)
        nomGUI:SetMouseInputEnabled(true)
        nomGUI:SetKeyboardInputEnabled(false)
        nomGUI.Paint = nil

        local size = nomGUIButtonSize * nomGUIScale
        -- More players = bigger circle
        local baseRadius = ((math.min(ScrW(), ScrH()) * 0.6) * nomGUIScale) / (15 / (count+1))

        local cx, cy = ScrW() / 2, ScrH() / 2

        for i = 1, count do
            local baseAngle = (i - 1) * (2 * math.pi / count)
            local warpedAngle = baseAngle + (nomGUIPolePush * math.sin(2 * baseAngle))
            local finalAngle = warpedAngle - (math.pi / 2)

            local x = cx + math.cos(finalAngle) * baseRadius
            local y = cy + math.sin(finalAngle) * (baseRadius * nomGUIVerticalStretch)

            local finalX = x - (size * ratio / 2)
            local finalY = y - (size / 2)

            local btn = vgui.Create("DButton", nomGUI)
            btn:SetSize(size * ratio, size)
            btn:SetPos(finalX, finalY)

            local ply = JoelBotC.seatingOrderClient[i]
            local name = (IsValid(ply) and ply:Nick()) or "Disconnected"
            btn:SetText(i .. ". " .. name)

            btn:SetFont("Minecraft20")
            btn:SetTextColor(Color(0, 0, 0))
            btn.isPressed = false

            btn.Paint = function(self, w, h)
                if self.isPressed then
                    surface.SetDrawColor(0, 120, 255)
                else
                    local colour = (JoelBotC.seatColours[i]) or Color(200, 200, 200)
                    surface.SetDrawColor(colour)
                end
                surface.DrawRect(0, 0, w, h)
            end

            btn.OnMousePressed = function(self)
                self.isPressed = true
                SeatingGUIButtonPressed(i)
            end
            btn.OnMouseReleased = function(self) self.isPressed = false end
        end
    end

    function JoelBotC:SeatingGUIDestroy()
        if IsValid(nomGUI) then
            nomGUI:Remove()
            nomGUI = nil
        end
    end

    net.Receive("rdmtJoelBotCSeatingGUIOpen", function()
        JoelBotC:SeatingGUICreate()
    end)
    net.Receive("rdmtJoelBotCSeatingGUIClose", function()
        JoelBotC:SeatingGUIDestroy()
    end)
end