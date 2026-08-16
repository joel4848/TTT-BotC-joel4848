JoelBotC = JoelBotC or {}

if SERVER then
    util.AddNetworkString("rdmtJoelBotCSendGrimRevealRoles")

    function JoelBotC:DoGrimReveal()
        local grimReveal = {}

        for _, ply in ipairs(JoelBotC.players) do
            local team = nil
            if ply.townsfolk then
                team = "townsfolk"
            elseif ply.outsider then
                team = "outsider"
            elseif ply.minion then
                team = "minion"
            elseif ply.demon then
                team = "demon"
            end

            grimReveal[ply.seatNumber] = {player = ply, role = ply.botc_role, dead = ply.BotCDead, team = team}
        end

        net.Start("rdmtJoelBotCSendGrimRevealRoles")
            net.WriteTable(grimReveal, false)
        net.Broadcast()
    end
end

if CLIENT then
    resource.AddFile("resource/fonts/Minecraft.ttf")
    surface.CreateFont("Minecraft80", {
        font = "Minecraft",
        size = 80,
        weight = 1000,
        additive = false,
        antialias = true
    })

    resource.AddFile("resource/fonts/Minecraft.ttf")
    surface.CreateFont("Minecraft30_bold", {
        font = "Minecraft",
        size = 30,
        weight = 2000,
        additive = false,
        antialias = true
    })


    local FADE_IN_ROLE_TIME    = 0.5
    local DELAY_BETWEEN_ROLES  = 3.0
    local DELAY_BEFORE_FADEOUT = 5.0
    local FADE_OUT_TOTAL_TIME  = 2.0

    local LINE_PADDING = 15

    local TEAM_COLORS = {
        townsfolk = Color(31, 101, 255, 255),
        outsider  = Color(70, 213, 255, 255),
        minion    = Color(255, 105, 0, 255),
        demon     = Color(206, 1, 0, 255)
    }

    local revealData = nil

    local function GetSortWeight(dead, team)
        local weight = 0
        if team == "demon" then
            weight = dead and 50 or 60
        elseif team == "minion" then
            weight = dead and 30 or 40
        else
            weight = dead and 10 or 20
        end
        return weight
    end

    JoelBotC.GOMPanels = JoelBotC.GOMPanels or {}

    for _, pnl in ipairs(JoelBotC.GOMPanels) do
        pnl:Remove()
    end

    local function DoGrimReveal(grimReveal)
        local playersList = {}

        for seat, data in pairs(grimReveal) do
            table.insert(playersList, {
                seat = tonumber(seat) or 0,
                nick = IsValid(data.player) and data.player:Nick() or "Unknown",
                roleName = ROLE_STRINGS[data.role] or "Unknown",
                team = data.team or "townsfolk",
                weight = GetSortWeight(data.dead, data.team),
                rand = math.random(),
                dead = data.dead
            })
        end

        table.sort(playersList, function(a, b)
            if a.weight == b.weight then
                return a.rand < b.rand
            end
            return a.weight < b.weight
        end)

        for i, pData in ipairs(playersList) do
            pData.revealIndex = i
        end

        table.sort(playersList, function(a, b)
            return a.seat < b.seat
        end)

        local allAlive = true
        for _, data in ipairs(playersList) do
            if data.dead then allAlive = false end
        end

        surface.SetFont("Minecraft25")
        local maxWidth = 0
        local textHeight = 0

        for _, pData in ipairs(playersList) do
            local part2 = " was your "

            if pData.team == "minion" or pData.team == "demon" then
                part2 = " was the "
            end

            local fullText = pData.seat .. ". " .. pData.nick .. part2 .. pData.roleName
            local w, h = surface.GetTextSize(fullText)
            if w > maxWidth then maxWidth = w end
            if h > textHeight then textHeight = h end
        end

        local lineHeight = textHeight + LINE_PADDING
        local totalHeight = (#playersList * lineHeight) - LINE_PADDING

        revealData = {
            players = playersList,
            startTime = CurTime(),
            maxWidth = maxWidth,
            totalHeight = totalHeight,
            lineHeight = lineHeight
        }

        -- local matGhost = Material("vgui/ttt/joelbotc/ghost_grim.png")
        local matScroll = Material("vgui/ttt/joelbotc/scroll_with_border.png")

        hook.Add("HUDPaint", "JoelBotC_DrawGrimReveal", function()
            if not revealData then
                hook.Remove("HUDPaint", "JoelBotC_DrawGrimReveal")
                return
            end

            local cTime = CurTime()
            local sTime = revealData.startTime

            local totalRevealPhaseTime = #revealData.players * DELAY_BETWEEN_ROLES
            local fadeOutStartTime = sTime + totalRevealPhaseTime + DELAY_BEFORE_FADEOUT

            local alphaMult = 1
            if cTime >= fadeOutStartTime then
                local timeInFade = cTime - fadeOutStartTime
                alphaMult = 1 - (timeInFade / FADE_OUT_TOTAL_TIME)

                if alphaMult <= 0 then
                    revealData = nil
                    hook.Remove("HUDPaint", "JoelBotC_DrawGrimReveal")

                    net.Start("rdmtJoelBotCSendGrimRevealRoles")
                    net.SendToServer()
                    return
                end
            end

            local scrollW, scrollH = 920, 920
            local scrollX, scrollY = ScrW() / 2 - scrollW / 2, ScrH() / 2 - scrollH / 2
            surface.SetDrawColor(255, 255, 255, 255 * alphaMult)
            surface.SetMaterial(matScroll)
            surface.DrawTexturedRect(scrollX, scrollY, scrollW, scrollH)

            -- Layout positions
            local scrollPadding = 10
            local startX        = scrollX + 115 + scrollPadding -- (ScrW() / 2) - (revealData.maxWidth / 2)
            local currentY      = scrollY + 180 + scrollPadding -- (ScrH() / 2) - (revealData.totalHeight / 2)

            -- local backgroundX      = startX - LINE_PADDING
            -- local backgroundY      = currentY - LINE_PADDING
            -- local backgroundWidth  = revealData.maxWidth + 2 * LINE_PADDING
            -- local backgroundHeight = revealData.totalHeight + 2 * LINE_PADDING

            -- if not allAlive then
            --     backgroundX     = backgroundX - LINE_PADDING - textHeight
            --     backgroundWidth = backgroundWidth + LINE_PADDING + textHeight
            -- end

            -- draw.RoundedBox(10, backgroundX, backgroundY, backgroundWidth, backgroundHeight, Color(0, 0, 0, 220 * alphaMult))

            surface.SetFont("Minecraft25")

            local skullWidth, _ = surface.GetTextSize("☠ ")

            -- local iconSize = textHeight * 1.2 or revealData.lineHeight * 1.2

            for _, pData in ipairs(revealData.players) do
                local baseColour = pData.dead and Color(100, 100, 100, 255 * alphaMult) or Color(0, 0, 0, 255 * alphaMult)

                -- Draw a ghost icon if the player's dead
                -- if pData.dead then
                --     local ghostX = startX - math.floor(LINE_PADDING / 2) - math.floor(iconSize / 2)

                --     surface.SetDrawColor(baseColour)
                --     surface.SetMaterial(matGhost)
                --     surface.DrawTexturedRect(ghostX, currentY, iconSize, iconSize)
                -- end

                -- Seat numbers
                local segStartX = startX + skullWidth
                if pData.seat < 10 then segStartX = segStartX + 18 end
                local part1   = pData.seat .. ". " .. pData.nick
                draw.SimpleText(part1, "Minecraft25", segStartX, currentY, baseColour, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                if pData.dead then
                    draw.SimpleText("☠ ", "Minecraft25", startX, currentY, baseColour, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                local thisRevealStartTime = sTime + (pData.revealIndex * DELAY_BETWEEN_ROLES)

                if cTime >= thisRevealStartTime then
                    local roleAlphaProg = math.Clamp((cTime - thisRevealStartTime) / FADE_IN_ROLE_TIME, 0, 1)
                    local roleAlpha = 255 * roleAlphaProg * alphaMult

                    local p1Width, _ = surface.GetTextSize(part1)

                    local part2 = " was your "

                    if pData.team == "minion" or pData.team == "demon" then
                        part2 = " was the "
                    end

                    draw.SimpleText(part2, "Minecraft25", segStartX + p1Width, currentY, Color(baseColour.r, baseColour.g, baseColour.b, roleAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                    local p2Width, _ = surface.GetTextSize(part2)

                    -- Role
                    surface.SetFont("Minecraft30_bold")
                    local _, roleHeightLarge = surface.GetTextSize(pData.roleName)
                    surface.SetFont("Minecraft25")
                    local _, roleHeightSmall = surface.GetTextSize(pData.roleName)
                    local roleHeightOffset = 0
                    if pData.team == "demon" then roleHeightOffset = (roleHeightLarge - roleHeightSmall) / 2 end

                    local tColor = TEAM_COLORS[pData.team] or TEAM_COLORS["townsfolk"]
                    local part3Color = Color(tColor.r, tColor.g, tColor.b, roleAlpha)
                    draw.SimpleText(pData.roleName, pData.team == "demon" and "Minecraft30_bold" or "Minecraft25", segStartX + p1Width + p2Width, currentY - roleHeightOffset, part3Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                currentY = currentY + revealData.lineHeight
            end
        end)
    end

    local function DoGameOverMessage(grimReveal)
        local gom = vgui.Create("DPanel")
        gom:SetSize(ScrW(), ScrH())
        gom:SetPos(0, 0)

        table.insert(JoelBotC.GOMPanels, gom)

        local msg1 = "And with that..."
        local msg2 = "the game "
        local msg3 = "is "
        local msg4 = "over."
        local msg5 = "Let's take a look at the Grim..."

        local fullLine1Text = msg1
        local fullLine2Text = msg2 .. msg3 .. msg4
        local line3Text     = msg5

        local startTime = CurTime()

        gom.Paint = function(_, w, h)
            local elapsed = CurTime() - startTime

            surface.SetFont("Minecraft80")

            -- Lines 1 and 2
            if elapsed < 7 then
                local alpha = 255
                if elapsed >= 6 then
                    alpha = math.Clamp((1 - (elapsed - 6)) * 255, 0, 255)
                end

                local colText    = Color(20, 0, 100, alpha)
                local colOutline = Color(50, 0, 255, alpha)

                local _, line1H      = surface.GetTextSize(fullLine1Text)
                local line2W, line2H = surface.GetTextSize(fullLine2Text)
                local padding        = line1H / 2
                local totalH         = line1H + padding + line2H

                local line1X, line1Y = (ScrW() / 2), (ScrH() / 2) - (totalH / 2)
                local line2Y         = line1Y + line1H + padding
                local line2LeftX     = (ScrW() / 2) - (line2W / 2)

                -- Line 1
                draw.SimpleTextOutlined(fullLine1Text, "Minecraft80", line1X, line1Y, colText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, colOutline)

                -- Line 2 bit by bit
                local curLine2Text = ""
                if elapsed >= 4 then
                    curLine2Text = fullLine2Text
                elseif elapsed >= 3 then
                    curLine2Text = msg2 .. msg3
                elseif elapsed >= 2 then
                    curLine2Text = msg2
                end

                if curLine2Text ~= "" then
                    draw.SimpleTextOutlined(curLine2Text, "Minecraft80", line2LeftX, line2Y, colText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, colOutline)
                end

            -- Line 3
            elseif elapsed < 10 then
                local alpha = 255
                if elapsed >= 9 then
                    alpha = math.Clamp((1 - (elapsed - 9)) * 255, 0, 255)
                end

                local colText    = Color(20, 0, 100, alpha)
                local colOutline = Color(50, 0, 255, alpha)

                draw.SimpleTextOutlined(line3Text, "Minecraft80", ScrW() / 2, ScrH() / 2, colText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, colOutline)

            -- Remove the panel
            else
                if not gom.Finished then
                    gom.Finished = true
                    timer.Simple(0, function()
                        if IsValid(gom) then
                            gom:Remove()
                        end
                    end)
                    timer.Simple(1, function()
                        DoGrimReveal(grimReveal)
                    end)
                end
            end
        end
    end

    net.Receive("rdmtJoelBotCSendGrimRevealRoles", function()
        local grimReveal = net.ReadTable()
        if not grimReveal then return end

        -- DoGrimReveal(grimReveal)
        DoGameOverMessage(grimReveal)
    end)
end