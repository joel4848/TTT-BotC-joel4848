JoelBotC = JoelBotC or {}


if SERVER then
    util.AddNetworkString("rdmtJoelBotCMiddleMessage") -- sends nomination 'error' messages
    util.AddNetworkString("rdmtJoelBotCBottomMessage") -- sends who (if anyone) is on the block, and minimum required votes

    function JoelBotC:SendMiddleMessage(message, duration, target)
        msg = message or ""
        dtn = duration or 3

        net.Start("rdmtJoelBotCMiddleMessage")
            net.WriteString(msg)
            net.WriteInt(dtn, 7)
        if target then
            net.Send(target)
        else
            net.Broadcast()
        end
    end

    function JoelBotC:UpdateBottomMessage(clear, nominated, marked)
        local clearMessage = clear ~= false
        local requiredVotes = JoelBotC:DetermineRequiredVotes()
        local nominatedNick = nominated and nominated:Nick() or nil
        local markedNick = marked and marked:Nick() or nil
        local finalMessage = ""

        if not JoelBotC:IsOGSober() then
            if nominatedNick and markedNick then
                finalMessage = "Nominated: " .. nominatedNick .. " | Marked: " .. markedNick .. " | Votes required: " .. requiredVotes .. " (" .. (requiredVotes - 1) .. " to tie)"
            elseif nominatedNick then
                finalMessage = "Nominated: " .. nominatedNick .. " | Votes required: " .. requiredVotes
            elseif markedNick then
                finalMessage = "Marked: " .. markedNick .. " | Votes required: " .. requiredVotes .. " (" .. (requiredVotes - 1) .. " to tie)"
            end
        else
            if nominatedNick then
                finalMessage = "Nominated: " .. nominatedNick .. " | Marked: ? | Votes required: ?"
            else
                finalMessage = "Marked: ? | Votes required: ?"
            end
        end

        if clearMessage then
            finalMessage = ""
        end

        net.Start("rdmtJoelBotCBottomMessage")
            net.WriteString(finalMessage)
        net.Broadcast()
    end
end

if CLIENT then
    -- Middle message (Errors, vote results etc.)
    local middleMessage = ""
    local middleExpiry  = 0

    function JoelBotC:MessageOverlayCreate()
        if IsValid(msgOverlay) then return end

        msgOverlay = vgui.Create("DPanel")
        msgOverlay:SetSize(ScrW(), ScrH())
        msgOverlay:SetPos(0, 0)
        msgOverlay:SetMouseInputEnabled(false)
        msgOverlay:SetKeyboardInputEnabled(false)
        msgOverlay:SetPaintBackgroundEnabled(false)

        msgOverlay.Paint = function(_, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            draw.NoTexture()
        end

        local middle = vgui.Create("DPanel", msgGUI)
        middle:SetSize(ScrW(), ScrH())
        middle:SetPos(0,0)
        middle:SetMouseInputEnabled(false)
        middle:SetKeyboardInputEnabled(false)
        middle:SetPaintBackgroundEnabled(false)

        function middle:Think()
            self:MoveToFront()
        end

        middle.Paint = function(_, w, h)
            -- Middle message
            if middleMessage ~= "" and CurTime() < middleExpiry then
                draw.SimpleTextOutlined(middleMessage, "Minecraft40", ScrW() / 2, ScrH() / 2, Color(255, 170, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
            end
        end
    end

    function JoelBotC:MessageOverlayDestroy()
        if IsValid(msgOverlay) then
            msgOverlay:Remove()
            msgOverlay = nil
        end
    end

    net.Receive("rdmtJoelBotCMiddleMessage", function()
        middleMessage = net.ReadString()
        local duration = net.ReadInt(7)
        middleExpiry = CurTime() + duration
    end)




end