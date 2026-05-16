JoelBotC = JoelBotC or {}

CreateConVar("randomat_joelbotc_town_name", "San Joelsé", FCVAR_REPLICATED, "The town name displayed at the start of each new day")
JoelBotC.townName = GetConVar("randomat_joelbotc_town_name"):GetString()

if SERVER then
    util.AddNetworkString("rdmtJoelBotCNightEnds")
    util.AddNetworkString("rdmtJoelBotCDiscussionBegins")
    util.AddNetworkString("rdmtJoelBotCCentralMessage")
    util.AddNetworkString("rdmtJoelBotCEndDayVote")
    util.AddNetworkString("rdmtJoelBotCEndDay")

    JoelBotC.votesToEndDay = JoelBotC.votesToEndDay or {}

    function JoelBotC:SendCentralMessage(message, duration, ply, textColour, outlineColour)
        local messageText = {}
        local messageDuration = isnumber(duration) and math.Round(duration) or 5
        local txtCol = IsColor(textColour) and textColour or Color(255, 255, 255, 255)
        local outCol = IsColor(outlineColour) and outlineColour or Color(0, 0, 0, 255)

        if istable(message) then
            messageText = table.Copy(message)
        else
            table.insert(messageText, tostring(message))
        end

        if messageDuration > 60 then messageDuration = 60 end

        net.Start("rdmtJoelBotCCentralMessage")
            net.WriteTable(messageText)
            net.WriteInt(messageDuration, 7)
            net.WriteColor(txtCol)
            net.WriteColor(outCol)
        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end

    function JoelBotC:StartDay()
        net.Start("rdmtJoelBotCNightEnds")
        net.Broadcast()

        -- Reset votes for the new day
        JoelBotC.votesToEndDay = {}

        JoelBotC:SendCentralMessage("A new day dawns in " .. JoelBotC.townName .. "!", 5, nil, Color(50, 70, 255), Color(0, 0, 0))

        timer.Create("rdmtJoelBotCMorningMessageDelay", 5, 1, function()
            JoelBotC:MorningDeaths()
        end)
    end

    function JoelBotC:StartDiscussion()
        net.Start("rdmtJoelBotCDiscussionBegins")
        net.Broadcast()

        timer.Simple(3, function()
            JoelBotC:EndDay()
        end)

        local currentVotes = table.Count(JoelBotC.votesToEndDay)
        local requiredVotes = math.ceil(#player.GetAll() * 0.75)

        net.Start("rdmtJoelBotCEndDayVote")
            net.WriteInt(currentVotes, 8)
            net.WriteInt(requiredVotes, 8)
        net.Broadcast()
    end

    function JoelBotC:EndDay()
        net.Start("rdmtJoelBotCEndDay")
        net.Broadcast()
        JoelBotC.votesToEndDay = {}
        
        timer.Create("RdmtJoelBotCEndDayStartNominations", 5, 1, function()
            JoelBotC:StartNominations()
        end)
    end

    net.Receive("rdmtJoelBotCEndDayVote", function(len, ply)
        local isVoting = net.ReadBool()
        local sid64 = ply:SteamID64()

        if isVoting then
            JoelBotC.votesToEndDay[sid64] = true
        else
            JoelBotC.votesToEndDay[sid64] = nil
        end

        local currentVotes = table.Count(JoelBotC.votesToEndDay)
        local requiredVotes = math.ceil(#player.GetAll() * 0.75)

        -- Broadcast status to all clients
        net.Start("rdmtJoelBotCEndDayVote")
            net.WriteInt(currentVotes, 8)
            net.WriteInt(requiredVotes, 8)
        net.Broadcast()

        if currentVotes >= requiredVotes then
            JoelBotC:EndDay()
        end
    end)
end

if CLIENT then
    surface.CreateFont("Minecraft20", {
        font = "Minecraft",
        size = 20,
        weight = 500,
        additive = false,
        antialias = true
    })

    local activeCentralMessage = nil
    local bossBarData = nil
    local endDayButtonFrame = nil
    local voteStatus = "0/0 required votes"

    function JoelBotC:DisplayCentralMessage(message, duration, textColour, outlineColour)
        local msgTable = istable(message) and message or {message}
        activeCentralMessage = {
            lines = msgTable,
            endTime = CurTime() + duration,
            duration = duration,
            textColour = textColour or Color(255, 255, 255),
            outlineColour = outlineColour or Color(0, 0, 0)
        }
    end

    function JoelBotC:ToggleEndDayEarly()
        local newState = not self.votingToEndDay
        self.votingToEndDay = newState
        
        net.Start("rdmtJoelBotCEndDayVote")
            net.WriteBool(newState)
        net.SendToServer()
    end

    function JoelBotC:CreateEndDayEarlyButton()
        if IsValid(endDayButtonFrame) then endDayButtonFrame:Remove() end

        -- Define the frame
        endDayButtonFrame = vgui.Create("DFrame")
        local frameW, frameH = 400, 100
        endDayButtonFrame:SetSize(frameW, frameH)
        endDayButtonFrame:SetPos((ScrW() - frameW) / 2, 47)
        endDayButtonFrame:SetTitle("")
        endDayButtonFrame:ShowCloseButton(false)
        endDayButtonFrame:SetDraggable(false)

        function endDayButtonFrame:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
        end

        -- 2. Create the Button
        local btn = vgui.Create("DButton", endDayButtonFrame)
        btn:SetFont("Minecraft20")
        local endDayText = "End day early?"

        -- 3. Calculate Width based on Text
        surface.SetFont("Minecraft20")
        local textW, textH = surface.GetTextSize(endDayText)
        local padding = 20
        local btnW = textW + padding
        local btnH = 40

        btn:SetSize(btnW, btnH)
        btn:SetText(endDayText)

        btn:SetPos((frameW - btnW) / 2, (frameH - btnH) / 2)

        btn.DoClick = function()
            JoelBotC:ToggleEndDayEarly()
        end

    end

    function JoelBotC:DestroyEndDayEarlyButton()
        if IsValid(endDayButtonFrame) then
            endDayButtonFrame:Remove()
        end
        self.votingToEndDay = false
    end

    function JoelBotC:StartDiscussionTimer(duration)
        bossBarData = {
            start = CurTime(),
            duration = duration,
            endTime = CurTime() + duration
        }
        JoelBotC:CreateEndDayEarlyButton()
    end

    hook.Add("HUDPaint", "JoelBotC_DayHUD", function()
        -- Draw timer bar (kinda like a Minecraft boss bar)
        if bossBarData and CurTime() < bossBarData.endTime then
            local timeLeft = bossBarData.endTime - CurTime()
            local percentageKinda = math.Clamp(timeLeft / bossBarData.duration, 0, 1)

            local barW, barH = ScrW() / 5, 8
            local x, y = (ScrW() - barW) / 2, 50
            local cornerRadius = 10

            -- Change colour based on time remaining
            local fillColour = Color(0, 200, 0)
            if percentageKinda < 0.15 then 
                fillColour = Color(255, 0, 0)
            elseif percentageKinda < 0.33 then 
                fillColour = Color(200, 150, 0)
            end

            -- Timer bar outline
            draw.RoundedBox(cornerRadius, x - 1, y - 1, barW + 2, barH + 2, Color(0, 0, 0, 255))

            -- Timer bar inside background
            local backgroundColour = Color(fillColour.r * 0.7, fillColour.g * 0.7, fillColour.b * 0.7, 255)
            draw.RoundedBox(cornerRadius, x, y, barW, barH, backgroundColour)

            -- Timer bar fill
            local fillWidth = barW * percentageKinda
            if fillWidth > 0 then
                draw.RoundedBox(cornerRadius, x, y, fillWidth, barH, fillColour)
            end

            -- Timer text
            local mins = math.floor(timeLeft / 60)
            local secs = math.floor(timeLeft % 60)
            local timeStr = string.format("%02d:%02d", mins, secs)
            draw.SimpleTextOutlined(timeStr, "Minecraft25", ScrW() / 2, y - 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0, 255))

            -- Vote amount text
            surface.SetFont("Minecraft20")
            local voteStatusW, _ = surface.GetTextSize(voteStatus)
            if IsValid(endDayButtonFrame) then
                draw.SimpleTextOutlined(voteStatus, "Minecraft20", ScrW() / 2 - voteStatusW / 2, 140, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
            end
        end

        -- 2. Draw Central Messages
        if activeCentralMessage and CurTime() < activeCentralMessage.endTime then
            local timeRemaining = activeCentralMessage.endTime - CurTime()
            local alpha = 255
            if timeRemaining < 0.5 then
                alpha = (timeRemaining / 0.5) * 255
            end

            local font = "Minecraft50"
            surface.SetFont(font)
            local _, fontHeight = surface.GetTextSize("W")
            local totalHeight = #activeCentralMessage.lines * fontHeight
            local startY = (ScrH() - totalHeight) / 2

            for i, line in ipairs(activeCentralMessage.lines) do
                local textColour = activeCentralMessage.textColour
                local outlineColour = activeCentralMessage.outlineColour
                draw.SimpleTextOutlined(line, font, ScrW() / 2, startY + ((i - 1) * fontHeight), Color(textColour.r, textColour.g, textColour.b, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(outlineColour.r, outlineColour.g, outlineColour.b, alpha))
            end
        end
    end)

    net.Receive("rdmtJoelBotCCentralMessage", function()
        local message = net.ReadTable()
        local duration = net.ReadInt(7)
        local textColour = net.ReadColor()
        local outlineColour = net.ReadColor()
        JoelBotC:DisplayCentralMessage(message, duration, textColour, outlineColour)
    end)

    net.Receive("rdmtJoelBotCNightEnds", function()
        hook.Remove("RenderScreenspaceEffects", "JoelBOTC_NightEffect")
        hook.Remove("SetupWorldFog", "NightFog")
        hook.Remove("PostDrawSkyBox", "DarkSky")
    end)

    net.Receive("rdmtJoelBotCDiscussionBegins", function()
        JoelBotC:StartDiscussionTimer(3)
    end)

    net.Receive("rdmtJoelBotCEndDayVote", function()
        local current = net.ReadInt(8)
        local required = net.ReadInt(8)
        voteStatus = current .. "/" .. required .. " required votes"
    end)

    net.Receive("rdmtJoelBotCEndDay", function()
        bossBarData = nil
        JoelBotC:DestroyEndDayEarlyButton()
        local message = {"Discussion time is over!", "Time for nominations..."}
        JoelBotC:DisplayCentralMessage(message, 5, Color(100, 255, 50), Color(0, 0, 0))
    end)
end