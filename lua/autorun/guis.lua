JoelBotC = JoelBotC or {}
JoelBotC.seatingOrderClient = JoelBotC.seatingOrderClient or {}
JoelBotC.clientGUIOpen = JoelBotC.clientGUIOpen or nil

-----------------------------------------------------------------------------------------
---------------------------------------SERVER--------------------------------------------
-----------------------------------------------------------------------------------------

if SERVER then

    util.AddNetworkString("rdmtJoelBotCSeatingGUIOpen")
    util.AddNetworkString("rdmtJoelBotCSeatingGUIClose")
    util.AddNetworkString("rdmtJoelBotCSeatingGUIChoice")
    util.AddNetworkString("rdmtJoelBotCOrganGrinderGUI")

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

        for i, ply in ipairs(JoelBotC.seatingOrderClient) do
            ply.seatNumber = i
        end
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

    local seatingGUI = nil
    local seatingGUIButtonSize = 60
    local seatingGUIScale = 1.0

    function JoelBotC:SeatingGUICreate()
        if IsValid(seatingGUI) then return end

        JoelBotC.clientGUIOpen = true

        local players = JoelBotC.seatingOrderClient
        local count = #JoelBotC.seatingOrderClient
        if count <= 0 then return end


        local ratio = 4 
        local seatingGUIVerticalStretch = 0.6
        local seatingGUIPolePush = 0.1 


        seatingGUI = vgui.Create("DPanel")
        seatingGUI:SetSize(ScrW(), ScrH())
        seatingGUI:SetPos(0, 0)
        seatingGUI:SetMouseInputEnabled(true)
        seatingGUI:SetKeyboardInputEnabled(false)
        seatingGUI.Paint = nil

        local size = seatingGUIButtonSize * seatingGUIScale
        -- More players = bigger circle
        local baseRadius = ((math.min(ScrW(), ScrH()) * 0.6) * seatingGUIScale) / (15 / (count+1))

        local cx, cy = ScrW() / 2, ScrH() / 2

        for i = 1, count do
            local baseAngle = (i - 1) * (2 * math.pi / count)
            local warpedAngle = baseAngle + (seatingGUIPolePush * math.sin(2 * baseAngle))
            local finalAngle = warpedAngle - (math.pi / 2)

            local x = cx + math.cos(finalAngle) * baseRadius
            local y = cy + math.sin(finalAngle) * (baseRadius * seatingGUIVerticalStretch)

            local finalX = x - (size * ratio / 2)
            local finalY = y - (size / 2)

            local btn = vgui.Create("DButton", seatingGUI)
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
        if IsValid(seatingGUI) then
            seatingGUI:Remove()
            seatingGUI = nil
            JoelBotC.clientGUIOpen = nil
        end
    end

    function JoelBotC:OgGUICreate()
        ogGUI = vgui.Create("DPanel")
        ogGUI:SetSize(ScrW(), ScrH())
        ogGUI:SetPos(0, 0)
        ogGUI:SetMouseInputEnabled(true)

        timer.Create("rdmtJoelBotCOGChoice", 15, 1, function()
            net.Start("rdmtJoelBotCOrganGrinderGUI")
                net.WriteBool(false)
            net.SendToServer()
        
            JoelBotC:OgGUIDestroy()
        end)

        ogGUI.Paint = function(self, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            draw.NoTexture()

            local cx, cy = ScrW() / 2, ScrH() / 2

            local timeLeft = math.ceil(timer.TimeLeft("rdmtJoelBotCOGChoice"))

            draw.SimpleText(timeLeft .. " seconds: Do you want to be drunk or sober tomorrow?", "Minecraft40", cx + 2, cy +177, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleTextOutlined(timeLeft .. " seconds: Do you want to be drunk or sober tomorrow?", "Minecraft40", cx, cy + 175, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        end

        local height = ScrH() / 10
        local width = 2 * height
        local Dx = ScrW()/2 - width / 2 - 200
        local Sx = ScrW()/2 - width / 2 + 200
        local y = ScrH()/2 - height / 2 + 300

        local drunk = vgui.Create("DButton", ogGUI)
        drunk:SetSize(width, height)
        drunk:SetPos(Dx, y)
        drunk:SetText("Drunk")
        drunk:SetFont("Minecraft30")
        drunk:SetTextColor(Color(0, 0, 0))
        drunk.isPressed = false

        drunk.Paint = function(self, w, h)
            if self.isPressed and self:IsHovered() then
                surface.SetDrawColor(0, 120, 255)
            else
                surface.SetDrawColor(255, 100, 0)
            end
            surface.DrawRect(0, 0, w, h)
        end

        drunk.OnMousePressed = function(self)
            self.isPressed = true
        end
        drunk.OnMouseReleased = function(self)
            if self.isPressed == true then
                self.isPressed = false

                net.Start("rdmtJoelBotCOrganGrinderGUI")
                    net.WriteBool(true)
                net.SendToServer()

                timer.Remove("rdmtJoelBotCOGChoice")

                JoelBotC:OgGUIDestroy()
            end
        end

        local sober = vgui.Create("DButton", ogGUI)
        sober:SetSize(width, height)
        sober:SetPos(Sx, y)
        sober:SetText("Sober")
        sober:SetFont("Minecraft30")
        sober:SetTextColor(Color(0, 0, 0))
        sober.isPressed = false

        sober.Paint = function(self, w, h)
            if self.isPressed and self:IsHovered() then
                surface.SetDrawColor(0, 120, 255)
            else
                surface.SetDrawColor(0, 255, 0)
            end
            surface.DrawRect(0, 0, w, h)
        end

        sober.OnMousePressed = function(self)
            self.isPressed = true
        end
        sober.OnMouseReleased = function(self)
            if self.isPressed == true then
                self.isPressed = false

                net.Start("rdmtJoelBotCOrganGrinderGUI")
                    net.WriteBool(false)
                net.SendToServer()

                timer.Remove("rdmtJoelBotCOGChoice")

                JoelBotC:OgGUIDestroy()
            end
        end
    end

    function JoelBotC:OgGUIDestroy()
        if IsValid(ogGUI) then
            ogGUI:Remove()
            ogGUI = nil
        end
    end

    net.Receive("rdmtJoelBotCSeatingGUIOpen", function()
        JoelBotC:SeatingGUICreate()
    end)
    net.Receive("rdmtJoelBotCSeatingGUIClose", function()
        JoelBotC:SeatingGUIDestroy()
    end)

    net.Receive("rdmtJoelBotCOrganGrinderGUI", function()
        JoelBotC:OgGUICreate()
    end)
end