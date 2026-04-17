JoelBotC = JoelBotC or {}
JoelBotC.seatingOrderClient = JoelBotC.seatingOrderClient or {}
JoelBotC.clientGUIOpen = JoelBotC.clientGUIOpen or nil

-----------------------------------------------------------------------------------------
-- SHARED (Convars accessible on both client and server via FCVAR_REPLICATED)
-----------------------------------------------------------------------------------------

local nominationTimeCvar = CreateConVar("randomat_joelbotc_nomination_time", 15, FCVAR_REPLICATED, "Time (seconds) to make each nomination", 5, 60)
local prosecutionTimeCvar = CreateConVar("randomat_joelbotc_prosecution_time", 30, FCVAR_REPLICATED, "Prosecution speech time (seconds)", 5, 60)
local defenceTimeCvar = CreateConVar("randomat_joelbotc_defence_time", 30, FCVAR_REPLICATED, "Defence speech time (seconds)", 5, 60)
local voteIntervalCvar = CreateConVar("randomat_joelbotc_vote_interval", 1.5, FCVAR_REPLICATED, "Time between each vote being locked in (seconds)", 1, 5)

local nominationTime = nominationTimeCvar:GetInt()
local prosecutionTime = prosecutionTimeCvar:GetInt()
local defenceTime = defenceTimeCvar:GetInt()
local voteInterval = voteIntervalCvar:GetFloat()

-----------------------------------------------------------------------------------------
---------------------------------------SERVER--------------------------------------------
-----------------------------------------------------------------------------------------

if SERVER then

    util.AddNetworkString("rdmtJoelBotCNominationGUIOpen")      -- tells player(s) to open the nomination GUI
    util.AddNetworkString("rdmtJoelBotCNominationGUIClose")     -- tells player(s) to close the nomination GUI (duh)
    util.AddNetworkString("rdmtJoelBotCNominationGUIChoice")    -- sends the button a player presses to the server
    util.AddNetworkString("rdmtJoelBotCNomPhase")               -- tells players the current phase & data
    util.AddNetworkString("rdmtJoelBotCNomTimer")               -- broadcasts a countdown value each second; I wanted to do this via
                                                                -- timers but that wouldn't work with early end prosecution/defence?
                                                                -- Maybe I could do it with timer.Remove but I'm here now
    util.AddNetworkString("rdmtJoelBotCVoteToggle")             -- tells server and players that someone toggled their vote on/off
    util.AddNetworkString("rdmtJoelBotCVoteLockIn")             -- for big hand movement & vote counting
    util.AddNetworkString("rdmtJoelBotCNomMessage")             -- sends various messages to one or all clients
    util.AddNetworkString("rdmtJoelBotCEndSpeech")              -- nominator/nominee ending prosecution/defence early

    -- State
    JoelBotC.nominationsOpen  = false   -- can players click to nominate
    JoelBotC.votingOpen       = false   -- can players toggle their vote
    JoelBotC.currentNominee   = nil     -- seat number of the current nominee
    JoelBotC.currentNominator = nil     -- seat number of the current nominator
    JoelBotC.marked           = nil     -- player currently marked for execution
    JoelBotC.markedVotes      = 0       -- vote count that put them on the block
    JoelBotC.playerVotes      = {}      -- [ply] = true/false current vote toggle state
    JoelBotC.lockedInSeats    = {}      -- [seatIndex] = true once that seat's vote is locked in

    -------------------------------------------------------------------------------------
    -- Helper bois
    -------------------------------------------------------------------------------------

    -- Broadcast nomination phase and associated bits and bobs
    local function BroadcastPhase(phase, data)
        net.Start("rdmtJoelBotCNomPhase")
            net.WriteString(phase)
            net.WriteTable(data or {})
        net.Broadcast()
    end

    -- Broadcast the various countdown timers
    local function BroadcastTimer(seconds)
        net.Start("rdmtJoelBotCNomTimer")
            net.WriteInt(math.max(0, seconds), 8)
        net.Broadcast()
    end

    -- Countdown timer
    local function RunCountdown(timerName, seconds, tickFn, doneFn)
        timer.Remove(timerName)
        local remaining = seconds
        tickFn(remaining)
        timer.Create(timerName, 1, seconds, function()
            remaining = remaining - 1
            tickFn(remaining)
            if remaining <= 0 then
                timer.Remove(timerName)
                if doneFn then doneFn() end
            end
        end)
    end

    -- Send open nomination GUI
    function JoelBotC:SendNominationGUICreate(ply)
        net.Start("rdmtJoelBotCNominationGUIOpen")
        if ply then net.Send(ply) else net.Broadcast() end
    end

    -- Send close nomination GUI
    function JoelBotC:SendNominationGUIDestroy(ply)
        net.Start("rdmtJoelBotCNominationGUIClose")
        if ply then net.Send(ply) else net.Broadcast() end
    end

    -------------------------------------------------------------------------------------
    -- Network receiver bois
    -------------------------------------------------------------------------------------

    -- Receive when a player presses a button and which button it was that they pressed
    net.Receive("rdmtJoelBotCNominationGUIChoice", function(_, ply)
        if not JoelBotC.nominationsOpen then return end
        local nominatorSeat = ply.seatNumber
        if not nominatorSeat then return end
        JoelBotC:PlayerNominated(nominatorSeat, net.ReadInt(6))
    end)

    -- Receive when nominator/nominee ends a speech phase early (true = prosecution, false = defence)
    net.Receive("rdmtJoelBotCEndSpeech", function(_, ply)
        if ply.seatNumber ~= JoelBotC.currentNominator then return end
        local isProsecution = net.ReadBool()
        if isProsecution and JoelBotC._prosecutionEndCallback then
            JoelBotC._prosecutionEndCallback()
        elseif not isProsecution and JoelBotC._defenceEndCallback then
            JoelBotC._defenceEndCallback()
        end
    end)

    -- Receive when a player presses their vote toggle button
    net.Receive("rdmtJoelBotCVoteToggle", function(_, ply)
        JoelBotC:ToggleVote(ply)
    end)

    -------------------------------------------------------------------------------------
    -- Start Nominations
    -------------------------------------------------------------------------------------

    function JoelBotC:StartNominations()
        JoelBotC:SendNominationGUICreate()

        JoelBotC.nominationsOpen = true
        JoelBotC.votingOpen = false

        BroadcastPhase("nominations", {
            isFirstNomination = true,
            nominationTime = nominationTimeCvar:GetInt(),
        })

        RunCountdown("rdmtJoelBotCNominationCountdown", nominationTimeCvar:GetInt(),
            function(remaining) BroadcastTimer(remaining) end,
            function()
                if JoelBotC.nominationsOpen then JoelBotC:NominationsOver() end
            end
        )
    end

    -------------------------------------------------------------------------------------
    -- Player Nominated
    -------------------------------------------------------------------------------------

    function JoelBotC:PlayerNominated(nominatorSeat, nomineeSeat)
        local nominatorPly = JoelBotC.seatingOrder[nominatorSeat]
        local nomineePly = JoelBotC.seatingOrder[nomineeSeat]
        if not IsValid(nominatorPly) or not IsValid(nomineePly) then return end

        local alreadyNominated = (nominatorPly.nominated == true)
        local alreadyBeenNominated = (nomineePly.hasBeenNominated == true)

        if alreadyNominated or alreadyBeenNominated then
            local msg
            if alreadyNominated and alreadyBeenNominated then
                msg = "You have already nominated today! " .. nomineePly:Nick() .. " has already been nominated today!"
            elseif alreadyNominated then
                msg = "You have already nominated today!"
            else
                msg = nomineePly:Nick() .. " has already been nominated today!"
            end
            net.Start("rdmtJoelBotCNomMessage")
                net.WriteString(msg)
            net.Send(nominatorPly)
            return
        end

        nominatorPly.nominated = true
        nomineePly.hasBeenNominated = true

        JoelBotC.nominationsOpen = false
        JoelBotC.votingOpen = true
        timer.Remove("rdmtJoelBotCNominationCountdown")

        JoelBotC.currentNominator = nominatorSeat
        JoelBotC.currentNominee = nomineeSeat
        JoelBotC.lockedInSeats = {}

        JoelBotC.playerVotes = {}
        for _, p in ipairs(JoelBotC.seatingOrder) do
            JoelBotC.playerVotes[p] = false
        end

        local nominatorNick = nominatorPly:Nick()
        local nomineeNick = nomineePly:Nick()
        PrintMessage(HUD_PRINTTALK, nominatorNick .. " nominated " .. nomineeNick)

        BroadcastPhase("prosecution", {
            nominatorSeat = nominatorSeat,
            nomineeSeat = nomineeSeat,
            nominatorName = nominatorNick,
            nomineeName = nomineeNick,
            prosecutionTime = prosecutionTimeCvar:GetInt(),
        })

        RunCountdown("rdmtJoelBotCProsecution", prosecutionTimeCvar:GetInt(),
            function(remaining) BroadcastTimer(remaining) end,
            function() JoelBotC:StartDefence(nominatorSeat, nomineeSeat, nomineeNick, defenceTimeCvar:GetInt()) end
        )

        JoelBotC._prosecutionEndCallback = function()
            timer.Remove("rdmtJoelBotCProsecution")
            JoelBotC:StartDefence(nominatorSeat, nomineeSeat, nomineeNick, defenceTimeCvar:GetInt())
        end
    end

    -- Start defence
    function JoelBotC:StartDefence(nominatorSeat, nomineeSeat, nomineeNick, defenceTime)
        JoelBotC._prosecutionEndCallback = nil

        BroadcastPhase("defence", {
            nominatorSeat = nominatorSeat,
            nomineeSeat = nomineeSeat,
            nomineeName = nomineeNick,
            defenceTime = defenceTimeCvar:GetInt(),
        })

        RunCountdown("rdmtJoelBotCDefence", defenceTimeCvar:GetInt(),
            function(remaining) BroadcastTimer(remaining) end,
            function() JoelBotC:StartVoteCountdown(nomineeSeat) end
        )

        JoelBotC._defenceEndCallback = function()
            timer.Remove("rdmtJoelBotCDefence")
            JoelBotC:StartVoteCountdown(nomineeSeat)
        end
    end

    -- 3 second countdown before starting vote
    function JoelBotC:StartVoteCountdown(nomineeSeat)
        JoelBotC._defenceEndCallback = nil

        BroadcastPhase("votecountdown", { nomineeSeat = nomineeSeat })

        RunCountdown("rdmtJoelBotCVoteCD", 3,
            function(remaining) BroadcastTimer(remaining) end,
            function() JoelBotC:StartVote() end
        )
    end

    -------------------------------------------------------------------------------------
    -- Vote toggling malarkey
    -------------------------------------------------------------------------------------

    function JoelBotC:ToggleVote(ply)
        if not JoelBotC.votingOpen then return end
        -- Prevent toggling once this player's vote has already been locked in
        if JoelBotC.lockedInSeats[ply.seatNumber] then return end

        local currentVote = JoelBotC.playerVotes[ply] or false

        -- Dead players who've used their ghost vote can't vote (need to add some indicator for ghost votes)
        if not currentVote and ply.BotCDead and not ply.hasGhostVote then return end

        JoelBotC.playerVotes[ply] = not currentVote

        net.Start("rdmtJoelBotCVoteToggle")
            net.WriteInt(ply.seatNumber, 6)
            net.WriteBool(JoelBotC.playerVotes[ply])
        net.Broadcast()
    end

    -------------------------------------------------------------------------------------
    -- Start vote process
    -------------------------------------------------------------------------------------

    function JoelBotC:StartVote()

        local count = #JoelBotC.seatingOrder
        local nomineeSeat = JoelBotC.currentNominee
        local interval = voteIntervalCvar:GetFloat()

        -- Work out seat order starting with clockwise from nominee and wrapping around to nominee
        local order = {}
        for k = 1, count do
            order[k] = ((nomineeSeat - 1 + k) % count) + 1
        end

        local votesReceived = 0

        BroadcastPhase("voting", {
            nomineeSeat = nomineeSeat,
            interval = interval,
        })

        for step = 1, count do
            local seat = order[step]
            local lockInTime = step * interval
            local timerLength = lockInTime - interval / 2
            local timerName1 = "rdmtJoelBotCMoveBigHand_" .. step
            local timerName2 = "rdmtJoelBotCLockInVote_" .. step

            -- Make hand start moving halfway through the vote interval (looks kinda more like a clock ticking, maybe adjust?)
            timer.Create(timerName1, timerLength, 1, function()
                net.Start("rdmtJoelBotCVoteLockIn")
                    net.WriteInt(seat, 6)
                    net.WriteBool(false) -- Tell big hand to move
                net.Broadcast()
            end)

            -- Hand arrives; lock in and count this vote
            timer.Create(timerName2, lockInTime, 1, function()
                JoelBotC.lockedInSeats[seat] = true

                net.Start("rdmtJoelBotCVoteLockIn")
                    net.WriteInt(seat, 6)
                    net.WriteBool(true) -- Tell player which vote was just locked in (to remove their toggle vote button if it was theirs)
                net.Broadcast()

                local ply = JoelBotC.seatingOrder[seat]
                if IsValid(ply) and JoelBotC.playerVotes[ply] then
                    votesReceived = votesReceived + 1
                    PrintMessage(HUD_PRINTTALK, ply:Nick() .. " voted - " .. votesReceived .. " vote" .. (votesReceived == 1 and "" or "s") .. " received")
                    if ply.BotCDead then
                        ply.hasGhostVote = false
                    end
                end

                if step == count then
                    JoelBotC.votingOpen = false
                    timer.Simple(0.1, function()
                        JoelBotC:VoteComplete(nomineeSeat, votesReceived)
                    end)
                end
            end)
        end
    end

    -------------------------------------------------------------------------------------
    -- Vote complete (counting votes/checking whether to mark nominee stuff)
    -------------------------------------------------------------------------------------

    function JoelBotC:VoteComplete(nomineeSeat, votes)
        local count = #JoelBotC.seatingOrder
        local threshold = math.ceil(count / 2)
        local nomineeNick = JoelBotC.seatingOrder[nomineeSeat]:Nick()
        local vStr = votes .. " vote" .. (votes == 1 and "" or "s")

        -- Decide whether the new player is marked and the message to display
        local resultMsg
        if votes < threshold then
            resultMsg = vStr .. " is not enough to mark " .. nomineeNick .. " for execution"
        elseif JoelBotC.marked == nil then
            JoelBotC.marked = JoelBotC.seatingOrder[nomineeSeat]
            JoelBotC.markedVotes = votes
            resultMsg = vStr .. " is enough - " .. nomineeNick .. " is marked for execution!"
        elseif votes > JoelBotC.markedVotes then
            JoelBotC.marked = JoelBotC.seatingOrder[nomineeSeat]
            JoelBotC.markedVotes = votes
            resultMsg = vStr .. " is enough - " .. nomineeNick .. " is marked for execution!"
        elseif votes == JoelBotC.markedVotes then
            JoelBotC.marked = nil
            JoelBotC.markedVotes = votes
            resultMsg = vStr .. " is a tie! No one is marked for execution"
        else
            resultMsg = vStr .. " is not enough to mark " .. nomineeNick .. " for execution"
        end

        -- Display the message
        PrintMessage(HUD_PRINTTALK, resultMsg)

        net.Start("rdmtJoelBotCNomMessage")
            net.WriteString(resultMsg)
        net.Broadcast()

        BroadcastPhase("result", {message = resultMsg})

        -- Reopen nominations after 5 seconds
        timer.Create("rdmtJoelBotCReopenNominations", 5, 1, function()
            JoelBotC.nominationsOpen = true
            JoelBotC.votingOpen = false

            BroadcastPhase("nominations", {
                isFirstNomination = false,
                nominationTime = nominationTimeCvar:GetInt(),
            })

            RunCountdown("rdmtJoelBotCNominationCountdown", nominationTimeCvar:GetInt(),
                function(remaining) BroadcastTimer(remaining) end,
                function()
                    if JoelBotC.nominationsOpen then JoelBotC:NominationsOver() end
                end
            )
        end)
    end

    -------------------------------------------------------------------------------------
    -- Nominations over
    -------------------------------------------------------------------------------------

    function JoelBotC:NominationsOver()
        JoelBotC.nominationsOpen = false
        JoelBotC.votingOpen      = false

        timer.Remove("rdmtJoelBotCNominationCountdown")
        timer.Remove("rdmtJoelBotCProsecution")
        timer.Remove("rdmtJoelBotCDefence")
        timer.Remove("rdmtJoelBotCVoteCD")

        JoelBotC:SendNominationGUIDestroy()
        BroadcastPhase("close", {})

        -- Announce result of the nomination/voting session
        local resultMsg
        if not IsValid(JoelBotC.marked) then
            resultMsg = "The day ends and no one is executed"
        else
            resultMsg = "The day ends and " .. JoelBotC.marked:Nick() .. " is executed!"
        end
        PrintMessage(HUD_PRINTTALK, resultMsg)

        -- Execute the marked player
        if IsValid(JoelBotC.marked) then
            JoelBotC:Execute(JoelBotC.marked)
            -- JoelBotC:Kill(JoelBotC.marked)
        end

        -- Reset nominations state
        for _, ply in ipairs(JoelBotC.seatingOrder) do
            if IsValid(ply) then
                ply.nominated        = false
                ply.hasBeenNominated = false
            end
        end
        JoelBotC.playerVotes             = {}
        JoelBotC.lockedInSeats           = {}
        JoelBotC.marked                  = nil
        JoelBotC.markedVotes             = 0
        JoelBotC.currentNominee          = nil
        JoelBotC.currentNominator        = nil
        JoelBotC._prosecutionEndCallback = nil
        JoelBotC._defenceEndCallback     = nil
    end

end

-----------------------------------------------------------------------------------------
---------------------------------------CLIENT--------------------------------------------
-----------------------------------------------------------------------------------------

if CLIENT then

    local nominationTime = nominationTimeCvar:GetInt()
    local prosecutionTime = prosecutionTimeCvar:GetInt()
    local defenceTime = defenceTimeCvar:GetInt()
    local voteInterval = voteIntervalCvar:GetFloat()

    -------------------------------------------------------------------------------------
    -- Network helpey bois
    -------------------------------------------------------------------------------------

    local function SendButtonPress(seatIndex)
        net.Start("rdmtJoelBotCNominationGUIChoice")
            net.WriteInt(seatIndex, 6)
        net.SendToServer()
    end

    local function SendEndSpeech(isProsecution)
        net.Start("rdmtJoelBotCEndSpeech")
            net.WriteBool(isProsecution)
        net.SendToServer()
    end

    local function SendToggleVote()
        net.Start("rdmtJoelBotCVoteToggle")
        net.SendToServer()
    end

    -------------------------------------------------------------------------------------
    -- Rotation helper
    -------------------------------------------------------------------------------------

    function surface.DrawTexturedRectRotatedPoint(x, y, w, h, rot, x0, y0)
        local c = math.cos(math.rad(rot))
        local s = math.sin(math.rad(rot))
        local newx = y0 * s - x0 * c
        local newy = y0 * c + x0 * s
        surface.DrawTexturedRectRotated(x + newx, y + newy, w, h, rot)
    end

    -------------------------------------------------------------------------------------
    -- Hand animation state stuff
    -------------------------------------------------------------------------------------
    local nomButtonAngle = {}

    -- Big hand
    local bigCurrentAngle = 0
    local bigStartAngle = 0
    local bigTargetAngle = 0
    local bigRotStartTime = 0
    local bigRotPeriod = 0.5

    -- Small hand
    local smallCurrentAngle = 0
    local smallStartAngle = 0
    local smallTargetAngle = 0
    local smallRotStartTime = 0
    local smallRotPeriod = 0.5

    local function SetHandTarget(isSmall, targetSeat, period)
        if not nomButtonAngle[targetSeat] then return end
        period = period or 0.5
        local tgt = nomButtonAngle[targetSeat] % 360
        if isSmall then
            smallStartAngle = smallCurrentAngle % 360
            smallTargetAngle = tgt
            smallRotStartTime = CurTime()
            smallRotPeriod = period
        else
            bigStartAngle = bigCurrentAngle % 360
            bigTargetAngle = tgt
            bigRotStartTime = CurTime()
            bigRotPeriod = period
        end
    end

    local function AnimateHand(start, target, startTime, period)
        local fraction = math.Clamp((CurTime() - startTime) / period, 0, 1)
        local diff = (target - start + 180) % 360 - 180
        if diff <= -180 then diff = 180 end
        return start + (diff * fraction)
    end

    -------------------------------------------------------------------------------------
    -- GUI/overlay state bits
    -------------------------------------------------------------------------------------
    local nomGUI = nil
    local nomGUIButtonSize = 60
    local nomGUIScale = 1.0

    local overlayPhase = "none"
    local overlayTimer = 0
    local overlayData = {}

    local seatVoteOn = {} -- [seatIndex] = true/false

    local endSpeechBtn = nil
    local voteToggleBtn = nil

    -- Bottom message (errors, vote results etc.)
    local bottomMessage = ""
    local bottomExpiry  = 0

    local topBtnTop = 0
    local lowestBtnBottom = 0

    local voteIcon = {}

    -------------------------------------------------------------------------------------
    -- Functions for the extra buttons
    -------------------------------------------------------------------------------------

    local function DestroyEndSpeechButton()
        if IsValid(endSpeechBtn) then endSpeechBtn:Remove() endSpeechBtn = nil end
    end

    local function DestroyVoteToggleButton()
        if IsValid(voteToggleBtn) then voteToggleBtn:Remove() voteToggleBtn = nil end
    end

    local function CreateEndSpeechButton(label, isProsecution)
        DestroyEndSpeechButton()
        if not IsValid(nomGUI) then return end

        local btnW, btnH = 300, 50
        endSpeechBtn = vgui.Create("DButton", nomGUI)
        endSpeechBtn:SetSize(btnW, btnH)
        endSpeechBtn:SetPos(ScrW() / 2 - btnW / 2, lowestBtnBottom + (ScrH() - lowestBtnBottom) / 2 - btnH / 2)
        endSpeechBtn:SetText(label)
        endSpeechBtn:SetFont("Minecraft20")
        endSpeechBtn:SetTextColor(Color(255, 255, 255))
        endSpeechBtn.Paint = function(self, w, h)
            surface.SetDrawColor(180, 60, 60)
            surface.DrawRect(0, 0, w, h)
        end
        endSpeechBtn.DoClick = function()
            SendEndSpeech(isProsecution)
        end
    end

    local function CreateVoteToggleButton()
        DestroyVoteToggleButton()
        if not IsValid(nomGUI) then return end

        local btnW, btnH = 300, 60
        local btnY = ScrH() / 2 - btnH / 2
        -- local btnY = lowestBtnBottom + (ScrH() - lowestBtnBottom) / 2 - btnH / 2

        voteToggleBtn = vgui.Create("DButton", nomGUI)
        voteToggleBtn:SetSize(btnW, btnH)
        voteToggleBtn:SetPos(ScrW() / 2 - btnW / 2, btnY)
        voteToggleBtn:SetFont("Minecraft20")
        voteToggleBtn:SetTextColor(Color(0, 0, 0))

        local mySeat = LocalPlayer().seatNumber

        local function Refresh()
            local on = seatVoteOn[mySeat] or false
            voteToggleBtn:SetText(on and "Toggle vote off" or "Toggle vote on")
        end
        Refresh()

        voteToggleBtn.Refresh = Refresh
        voteToggleBtn.Paint = function(self, w, h)
            surface.SetDrawColor((seatVoteOn[mySeat] and Color(50, 200, 100)) or Color(255, 150, 0))
            surface.DrawRect(0, 0, w, h)
        end
        voteToggleBtn.DoClick = function()
            SendToggleVote()
        end
    end

    -------------------------------------------------------------------------------------
    -- Announcement messages for each phase
    -------------------------------------------------------------------------------------

    local function GetOverlayLines()
        local t = overlayTimer
        if overlayPhase == "nominations" then
            return {
                overlayData.isFirstNomination and "Nominations are now open." or "",
                "Time left to nominate: " .. t,
            }
        elseif overlayPhase == "prosecution" then
            return {
                (overlayData.nominatorName or "?") .. " nominated " .. (overlayData.nomineeName or "?"),
                "Prosecution: " .. t .. " seconds",
            }
        elseif overlayPhase == "defence" then
            return {
                overlayData.nomineeName or "?",
                "Defence: " .. t .. " seconds",
            }
        elseif overlayPhase == "votecountdown" then
            return {"Voting will start in " .. t .. "..."}
        elseif overlayPhase == "voting" then
            return {"Voting in progress..."}
        elseif overlayPhase == "result" then
            return {overlayData.message or ""}
        end
        return {}
    end

    -------------------------------------------------------------------------------------
    -- Network receivers
    -------------------------------------------------------------------------------------

    net.Receive("rdmtJoelBotCNomPhase", function()
        local phase = net.ReadString()
        local data = net.ReadTable()
        overlayPhase = phase
        overlayData = data

        DestroyEndSpeechButton()
        DestroyVoteToggleButton()

        local mySeat = LocalPlayer().seatNumber

        if phase == "nominations" then
            overlayTimer = data.nominationTime or nominationTime
            if data.isFirstNomination then
                bigCurrentAngle = 0
                bigStartAngle = 0
                bigTargetAngle = 0
                smallCurrentAngle = 0
                smallStartAngle = 0
                smallTargetAngle = 0
            end
            seatVoteOn = {}

        elseif phase == "prosecution" then
            overlayTimer = data.prosecutionTime or prosecutionTime
            SetHandTarget(false, data.nomineeSeat)
            SetHandTarget(true, data.nominatorSeat)

            CreateVoteToggleButton()

            if mySeat == data.nominatorSeat then
                CreateEndSpeechButton("End prosecution now", true)
            end

        elseif phase == "defence" then
            overlayTimer = data.defenceTime or defenceTime

            CreateVoteToggleButton()

            if mySeat == data.nomineeSeat then
                CreateEndSpeechButton("End defence now", false)
            end

        elseif phase == "votecountdown" then
            overlayTimer = 3

            CreateVoteToggleButton()

        elseif phase == "voting" then
            overlayTimer = 0

            CreateVoteToggleButton()

        elseif phase == "result" then
            overlayTimer = 0

        elseif phase == "close" then
            overlayPhase = "none"
        end
    end)

    net.Receive("rdmtJoelBotCNomTimer", function()
        overlayTimer = net.ReadInt(8)
    end)

    net.Receive("rdmtJoelBotCVoteToggle", function()
        local seat = net.ReadInt(6)
        local voteOn = net.ReadBool()
        seatVoteOn[seat] = voteOn
        if IsValid(voteToggleBtn) and voteToggleBtn.Refresh then
            voteToggleBtn:Refresh()
        end
        if IsValid(voteIcon[seat]) then
            voteIcon[seat]:SetVisible(voteOn)
        end
    end)

    net.Receive("rdmtJoelBotCVoteLockIn", function()
        local seat = net.ReadInt(6)
        local arrived = net.ReadBool()

        if arrived then
            if nomButtonAngle[seat] then
                bigTargetAngle = nomButtonAngle[seat] % 360
            end
            -- Once this player's own vote is locked in, remove their toggle button
            if IsValid(voteToggleBtn) and LocalPlayer().seatNumber == seat then
                DestroyVoteToggleButton()
            end
        else
            SetHandTarget(false, seat, voteIntervalCvar:GetFloat() / 2)
        end
    end)

    net.Receive("rdmtJoelBotCNomMessage", function()
        bottomMessage = net.ReadString()
        bottomExpiry = CurTime() + 5
    end)

    -------------------------------------------------------------------------------------
    -- Nomination GUI Create
    -------------------------------------------------------------------------------------

    function JoelBotC:NominationGUICreate()
        if IsValid(nomGUI) then return end

        JoelBotC.clientGUIOpen = true

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

        local size = nomGUIButtonSize * nomGUIScale
        local baseRadius = ((math.min(ScrW(), ScrH()) * 0.6) * nomGUIScale) * (0.5 + (count - 5) / 20)
        local cx, cy = ScrW() / 2, ScrH() / 2

        bigCurrentAngle = 0
        bigStartAngle = 0
        bigTargetAngle = 0
        smallCurrentAngle = 0
        smallStartAngle = 0
        smallTargetAngle = 0
        seatVoteOn = {}
        topBtnTop = math.huge
        lowestBtnBottom = 0
        local buttonWidth = {}

        nomGUI.Paint = function(self, w, h)
            bigCurrentAngle = AnimateHand(bigStartAngle, bigTargetAngle, bigRotStartTime, bigRotPeriod)
            smallCurrentAngle = AnimateHand(smallStartAngle, smallTargetAngle, smallRotStartTime, smallRotPeriod)

            surface.SetDrawColor(255, 255, 255, 255)
            draw.NoTexture()

            local bigHandLength = baseRadius * 0.6
            local bigHandThick = 4 * nomGUIScale
            local smallHandLength = baseRadius * 0.35
            local smallHandThick = 3 * nomGUIScale

            surface.DrawTexturedRectRotatedPoint(cx, cy, bigHandThick, bigHandLength, bigCurrentAngle, 0, -bigHandLength / 2)
            surface.DrawTexturedRectRotatedPoint(cx, cy, smallHandThick, smallHandLength, smallCurrentAngle, 0, -smallHandLength / 2)

            -- Overlay text: top middle of screen
            local lines = GetOverlayLines()
            if #lines > 0 then
                surface.SetFont("Minecraft40")
                local lineH = 48
                local totalH = lineH * #lines
                local startY = topBtnTop / 2 - totalH / 2

                for idx, line in ipairs(lines) do
                    local lineY = startY + (idx - 1) * lineH
                    draw.SimpleText(line, "Minecraft40", cx + 2, lineY + 2, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER)
                    draw.SimpleText(line, "Minecraft40", cx, lineY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
                end
            end

            -- Bottom middle of screen
            if bottomMessage ~= "" and CurTime() < bottomExpiry then
                local alpha = 255
                local timeLeft = bottomExpiry - CurTime()
                if timeLeft < 1 then alpha = math.floor(timeLeft * 255) end
                local bottomY = lowestBtnBottom + (ScrH() - lowestBtnBottom) / 2
                draw.SimpleText(bottomMessage, "Minecraft20", cx + 1, bottomY + 1, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
                draw.SimpleText(bottomMessage, "Minecraft20", cx, bottomY, Color(255, 220, 80,  alpha), TEXT_ALIGN_CENTER)
            end
        end

        -- Build seat buttons
        for i = 1, count do
            local baseAngle = (i - 1) * (2 * math.pi / count)
            local warpedAngle = baseAngle + (nomGUIPolePush * math.sin(2 * baseAngle))
            local finalAngle = warpedAngle - (math.pi / 2)

            local x = cx + math.cos(finalAngle) * baseRadius
            local y = cy + math.sin(finalAngle) * (baseRadius * nomGUIVerticalStretch)

            nomButtonAngle[i] = -(math.deg(math.atan2(y - cy, x - cx)) + 90)

            local ply = JoelBotC.seatingOrderClient[i]
            local name = (IsValid(ply) and ply:Nick()) or "Disconnected"
            local btnText = i .. ". " .. name

            surface.SetFont("Minecraft20")
            local textW, _ = surface.GetTextSize(btnText)
            local finalWidth = math.max(size * ratio, textW + 30)
            local finalX = x - (finalWidth / 2)
            local finalY = y - (size / 2)
            buttonWidth[i] = finalWidth

            -- Track top/bottom button extents for overlay/bottom/button placement
            if finalY < topBtnTop then
                topBtnTop = finalY
            end
            if finalY + size > lowestBtnBottom then
                lowestBtnBottom = finalY + size 
            end

            local btn = vgui.Create("DButton", nomGUI)
            btn:SetSize(finalWidth, size)
            btn:SetPos(finalX, finalY)
            btn:SetText(btnText)
            btn:SetFont("Minecraft20")
            btn:SetTextColor(Color(0, 0, 0))
            btn.isPressed = false
            btn.seatIndex = i

            btn.Paint = function(self, w, h)
                -- if seatVoteOn[self.seatIndex] then
                --     surface.SetDrawColor(50, 200, 100)
                if self.isPressed and overlayPhase == "nominations" then
                    surface.SetDrawColor(0, 120, 255)
                else
                    local colour = (JoelBotC.seatColours and JoelBotC.seatColours[i]) or Color(200, 200, 200)
                    surface.SetDrawColor(colour)
                end
                surface.DrawRect(0, 0, w, h)
            end

            btn.OnMousePressed = function(self) self.isPressed = true end
            btn.OnMouseReleased = function(self)
                self.isPressed = false
                SendButtonPress(self.seatIndex)
                print("overlayPhase = " .. overlayPhase)
            end
        end

        -- Vote icons
        for i = 1, count do
            local voteIconSize = size * 1.4
            local voteIconGap = 25 + 15/count
        
            local baseAngle = (i - 1) * (2 * math.pi / count)
            local warpedAngle = baseAngle + (nomGUIPolePush * math.sin(2 * baseAngle))
            local finalAngle = warpedAngle - (math.pi / 2)
        
            local buttonX = cx + math.cos(finalAngle) * baseRadius
            local buttonY = cy + math.sin(finalAngle) * (baseRadius * nomGUIVerticalStretch)
        
            -- Direction from button to centre
            local dx = cx - buttonX
            local dy = cy - buttonY
        
            local len = math.sqrt(dx * dx + dy * dy)
            dx = dx / len
            dy = dy / len
        
            -- Button dimensions
            local bw = buttonWidth[i] or 100
            local bh = size
        
            local hx = bw / 2
            local hy = bh / 2
        
            -- Distance from button centre to edge in this direction
            local edgeDist = 1 / math.sqrt((dx * dx) / (hx * hx) + (dy * dy) / (hy * hy))
        
            -- Icon centre distance from button centre
            local offset = edgeDist + voteIconGap + (voteIconSize / 2)
        
            local iconX = buttonX + dx * offset
            local iconY = buttonY + dy * offset
        
            voteIcon[i] = vgui.Create("DImage", nomGUI)
            voteIcon[i]:SetSize(voteIconSize, voteIconSize)
            voteIcon[i]:SetPos(iconX - voteIconSize / 2, iconY - voteIconSize / 2)
            voteIcon[i].seatIndex = i
            voteIcon[i]:SetImage("vgui/ttt/joelbotc/vote_icon.png")
            voteIcon[i]:SetVisible(false)
        end
    end

    function JoelBotC:NominationGUIDestroy()
        DestroyEndSpeechButton()
        DestroyVoteToggleButton()
        if IsValid(nomGUI) then
            nomGUI:Remove()
            nomGUI = nil
            JoelBotC.clientGUIOpen = nil
        end
        overlayPhase = "none"
        seatVoteOn   = {}
    end

    net.Receive("rdmtJoelBotCNominationGUIOpen", function() JoelBotC:NominationGUICreate() end)
    net.Receive("rdmtJoelBotCNominationGUIClose", function() JoelBotC:NominationGUIDestroy() end)

end