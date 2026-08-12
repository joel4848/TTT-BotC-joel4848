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

    net.Receive("rdmtJoelBotCSendGrimRevealRoles", function()
        local grimReveal = net.ReadTable()
        if not grimReveal then return end

        local playersList = {}

        for seat, data in pairs(grimReveal) do
            table.insert(playersList, {
                seat = tonumber(seat) or 0,
                nick = IsValid(data.player) and data.player:Nick() or "Unknown",
                roleName = ROLE_STRINGS[data.role] or "Unknown",
                team = data.team or "townsfolk",
                weight = GetSortWeight(data.dead, data.team),
                rand = math.random()
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

        surface.SetFont("Minecraft40")
        local maxWidth = 0
        local textHeight = 0

        for _, pData in ipairs(playersList) do
            local fullText = pData.seat .. ". " .. pData.nick .. " was your " .. pData.roleName
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
                    return
                end
            end

            -- Layout positions
            local startX   = (ScrW() / 2) - (revealData.maxWidth / 2)
            local currentY = (ScrH() / 2) - (revealData.totalHeight / 2)

            local backgroundX      = startX - LINE_PADDING
            local backgroundY      = currentY - LINE_PADDING
            local backgroundWidth  = revealData.maxWidth + 2 * LINE_PADDING
            local backgroundHeight = revealData.totalHeight + 2 * LINE_PADDING

            draw.RoundedBox(10, backgroundX, backgroundY, backgroundWidth, backgroundHeight, Color(0, 0, 0, 220 * alphaMult))

            surface.SetFont("Minecraft40")

            for _, pData in ipairs(revealData.players) do
                local baseColor = Color(255, 255, 255, 255 * alphaMult)

                -- Seat numbers
                local part1 = pData.seat .. ". " .. pData.nick
                draw.SimpleText(part1, "Minecraft40", startX, currentY, baseColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                local myRevealStartTime = sTime + (pData.revealIndex * DELAY_BETWEEN_ROLES)

                if cTime >= myRevealStartTime then
                    local roleAlphaProg = math.Clamp((cTime - myRevealStartTime) / FADE_IN_ROLE_TIME, 0, 1)
                    local roleAlpha = 255 * roleAlphaProg * alphaMult

                    local p1Width, _ = surface.GetTextSize(part1)

                    local part2 = " was your "
                    local part2Color = Color(255, 255, 255, roleAlpha)
                    draw.SimpleText(part2, "Minecraft40", startX + p1Width, currentY, part2Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                    local p2Width, _ = surface.GetTextSize(part2)

                    -- Role
                    local tColor = TEAM_COLORS[pData.team] or TEAM_COLORS["townsfolk"]
                    local part3Color = Color(tColor.r, tColor.g, tColor.b, roleAlpha)
                    draw.SimpleText(pData.roleName, "Minecraft40", startX + p1Width + p2Width, currentY, part3Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                currentY = currentY + revealData.lineHeight
            end
        end)
    end)
end