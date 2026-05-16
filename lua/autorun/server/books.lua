if not SERVER then return end

util.AddNetworkString("ttt_books_signedbook_sync")

local BOOK_SYNC_NET = "ttt_books_signedbook_sync"

local function SanitisePages(pages)
    local out = {}

    for _, page in ipairs(pages or {}) do
        if istable(page) and istable(page.Segments) then
            local segs = {}

            for _, seg in ipairs(page.Segments) do
                local s = {
                    text      = tostring(seg.text or ""),
                    bold      = seg.bold and true or false,
                    italic    = seg.italic and true or false,
                    underline = seg.underline and true or false,
                    align     = (seg.align == "center" or seg.align == "right") and seg.align or "left",
                }

                if istable(seg.color) then
                    s.color = {
                        r = tonumber(seg.color.r) or 0,
                        g = tonumber(seg.color.g) or 0,
                        b = tonumber(seg.color.b) or 0,
                    }
                end

                segs[#segs + 1] = s
            end

            out[#out + 1] = { Segments = segs }
        else
            out[#out + 1] = { Text = tostring((page and page.Text) or "") }
        end
    end

    if #out == 0 then
        out[1] = { Text = "" }
    end

    return out
end

local function SendSignedBookData(ply, wep, payload)
    if not IsValid(ply) or not IsValid(wep) then return end

    local json = util.TableToJSON(payload, false)
    if not json then
        ErrorNoHalt("[TTT Books] Failed to encode signed book payload as JSON\n")
        return
    end

    if #json > 65532 then
        ErrorNoHalt("[TTT Books] Signed book payload is too large for a single net message\n")
        return
    end

    net.Start(BOOK_SYNC_NET)
        net.WriteUInt(wep:EntIndex(), 16)
        net.WriteString(json)
    net.Send(ply)
end

---------------------------------------------------------------
--  GiveBookQuill(ply)
---------------------------------------------------------------
function GiveBookQuill(ply)
    if not IsValid(ply) then return nil end

    local existing = ply:GetWeapon("weapon_ttt_bookquill")
    if IsValid(existing) then existing:Remove() end

    local wep = ply:Give("weapon_ttt_bookquill")
    if not IsValid(wep) then
        ErrorNoHalt("[TTT Books] Failed to give weapon_ttt_bookquill to " .. tostring(ply) .. "\n")
        return nil
    end

    wep.BookTexts        = { { Text = "" } }
    wep.BookPage         = 1
    wep.BookPageCapacity = 1

    return wep
end

function GiveSignedBook(ply, bookData)
    if not IsValid(ply) then return nil end

    if type(bookData) ~= "table" then
        ErrorNoHalt("[TTT Books] GiveSignedBook: bookData must be a table\n")
        return nil
    end

    if type(bookData.pages) ~= "table" or #bookData.pages == 0 then
        ErrorNoHalt("[TTT Books] GiveSignedBook: bookData.pages must be a non-empty array\n")
        return nil
    end

    local wep = ply:Give("weapon_ttt_signedbook")
    if not IsValid(wep) then
        ErrorNoHalt("[TTT Books] Failed to give weapon_ttt_signedbook to " .. tostring(ply) .. "\n")
        return nil
    end

    local pages = SanitisePages(bookData.pages)
    local payload = {
        title  = tostring(bookData.title or "Signed Book"),
        author = tostring(bookData.author or ""),
        pages  = pages,
    }

    timer.Simple(0, function()
        if IsValid(ply) and IsValid(wep) then
            SendSignedBookData(ply, wep, payload)
        end
    end)

    wep.BookTitle        = payload.title
    wep.BookAuthor       = payload.author
    wep.BookTexts        = payload.pages
    wep.BookPageCapacity = #payload.pages
    wep.BookPage         = 1

    return wep
end

function SendSignedBookUpdate(ply, newBookData)
    if not IsValid(ply) then return end

    local wep = ply:GetWeapon("weapon_ttt_signedbook")
    if not IsValid(wep) then
        wep = ply:Give("weapon_ttt_signedbook")
        --ErrorNoHalt("[TTT Books] SendSignedBookUpdate: " .. tostring(ply) .. " has no signed book to update\n")
        --return
    end

    local pages = SanitisePages(newBookData.pages)
    local payload = {
        title  = tostring(newBookData.title or "Signed Book"),
        author = tostring(newBookData.author or ""),
        pages  = pages,
    }

    wep.BookTitle        = payload.title
    wep.BookAuthor       = payload.author
    wep.BookTexts        = payload.pages
    wep.BookPageCapacity = #payload.pages

    SendSignedBookData(ply, wep, payload)
end

-- Legacy
function UpdateSignedBook(ply, newBookData)
    if not IsValid(ply) then return nil end

    local existing = ply:GetWeapon("weapon_ttt_signedbook")
    if IsValid(existing) then existing:Remove() end

    return GiveSignedBook(ply, newBookData)
end

JoelBotC = JoelBotC or {}
JoelBotC.roleAbilities = JoelBotC.roleAbilities or {}

function JoelBotC:RoleAbilitiesForBook()
    JoelBotC.roleAbilities = {
        [ROLE_STEWARDJBC]       = "You start knowing 1 good player",
        [ROLE_KNIGHTJBC]        = "You start knowing 2 players who are not the Demon",
        [ROLE_ORACLEJBC]        = "Each night*, you learn how many dead players are evil",
        [ROLE_CHEFJBC]          = "You start knowing how many pairs of evil players there are",
        [ROLE_UNDERTAKERJBC]    = "Each night*, you learn which character died by execution today",
        [ROLE_NOBLEJBC]         = "You start knowing 3 players, 1 and only 1 of whom is evil",
        [ROLE_INVESTIGATORJBC]  = "You start knowing that 1 of 2 players is a particular Minion",
        [ROLE_MONKJBC]          = "Each night*, choose a player (not yourself): they are safe from the Demon tonight",
        [ROLE_WASHERWOMANJBC]   = "You start knowing that 1 of 2 players is a particular Townsfolk",
        [ROLE_NIGHTWATCHMANJBC] = "Once per game, at night, choose a player: they learn you are the Nightwatchman",
        [ROLE_GRANDMOTHERJBC]   = "You start knowing a good player and their role. If the Demon kills them, you die too",
        [ROLE_SEAMSTRESSJBC]    = "Once per game, at night, choose 2 players: you learn if they are the same alignment",
        [ROLE_LIBRARIANJBC]     = "You start knowing that 1 of 2 players is a particular Outsider (or that there are none)",
        [ROLE_EMPATHJBC]        = "Each night, you learn how many of your alive neighbours are evil",
        [ROLE_SOLDIERJBC]       = "You are safe from the Demon",
        [ROLE_RAVENKEEPERJBC]   = "If you die at night, choose a player and learn their role",
        [ROLE_FORTUNETELLERJBC] = "Each night, choose 2 players and learn if either is the Demon (or your Red Herring)",
        [ROLE_VIRGINJBC]        = "The 1st time you are nominated, if the nominator is a Townsfolk, they are executed immediately",
        [ROLE_OGREJBC]          = "On your 1st night, choose a player and become their alignment",
        [ROLE_SNITCHJBC]        = "Minions get 3 bluffs (as well as the Demon)",
        [ROLE_GOLEMJBC]         = "You can only nominate once per game. If the person you nominate isn't the Demon, they die",
        [ROLE_SWEETHEARTJBC]    = "When you die, 1 player is drunk from now on",
        [ROLE_SAINTJBC]         = "If you die by execution, your team loses",
        [ROLE_DRUNKJBC]         = "You do not know you are the Drunk. You think you are a Townsfolk role, but your ability malfunctions",
        [ROLE_RECLUSEJBC]       = "You might register as evil and as a Minion or Demon, even if dead",
        [ROLE_POISONERJBC]      = "Each night, choose a player: they are poisoned tonight and tomorrow",
        [ROLE_SCARLETWOMANJBC]  = "If there are 5 or more players alive and the Demon dies, you become the Demon",
        [ROLE_ORGANGRINDERJBC]  = "Votes and vote tallies are secret. Each night, chose if you are drunk tomorrow (so votes/tallies are not secret)",
        [ROLE_ASSASSINJBC]      = "Once per game, at night, choose a player: they die, even if they could not otherwise",
        [ROLE_BARONJBC]         = "There are 2 extra Outsiders in play",
        [ROLE_PUKKAJBC]         = "Each night, choose a player: they are poisoned. The previously poisoned player dies then stops being poisoned",
        [ROLE_IMPJBC]           = "Each night*, choose a player: they die. If you kill yourself this way, a Minion becomes the Imp",
        [ROLE_POJBC]            = "Each night*, you may choose a player: they die. If your last choice was no one, choose 3 players tonight",
    }
end

function JoelBotC:InitInfoBook(ply)
    if not IsValid(ply) then return end

    local roleID      = ply.botc_role or ply:GetRole()
    local roleName    = ROLE_STRINGS[roleID] or "Unknown"
    local roleAbility = JoelBotC.roleAbilities[roleID] or "no ability description available"

    ply.infoBookSegments = {
        { text = "Role:\n",    bold = true, underline = true },
        { text = roleName .. " - " .. roleAbility .. "\n" },
        { text = "------------------------\n", color = Color(100, 100, 100) },
    }
end

function JoelBotC:AppendInfoBook(ply, sectionTitle, infoLine)
    if not IsValid(ply) then return end
    if not ply.infoBookSegments then return end

    table.insert(ply.infoBookSegments, {
        text      = sectionTitle .. "\n",
        bold      = true,
        underline = true,
    })

    table.insert(ply.infoBookSegments, {
        text = infoLine .. "\n",
    })

    JoelBotC:RebuildInfoBook(ply)
end

function JoelBotC:RebuildInfoBook(ply)
    if not IsValid(ply) then return end

    local seatingSegments = {}
    table.insert(seatingSegments, {
        text      = "Seating:\n\n",
        color     = Color(100, 0, 200),
        bold      = true,
        underline = true,
        align     = "center",
    })
    for i, p in ipairs(JoelBotC.seatingOrder) do
        local prefix = (i < 10) and ("Seat " .. i .. ":   ") or ("Seat " .. i .. ": ")
        table.insert(seatingSegments, {
            text      = prefix .. p:Nick() .. "\n",
            color     = Color(0, 0, 0),
            bold      = false,
            italic    = false,
            underline = false,
            align     = "left",
        })
    end

    local bookData = {
        title  = "Your Information",
        author = "The Storyteller",
        pages  = {
            -- Page 1: Contents
            { Segments = {
                { text = "\n\nContents:", bold = true, align = "center" },
                { text = "\n\n" },
                { text = "Page 2: ", bold = true },
                { text = "Wtf is going on?" },
                { text = "\n" },
                { text = "Page 3: ", bold = true },
                { text = "Seating order" },
                { text = "\n" },
                { text = "Page 4: ", bold = true },
                { text = "Your info" },
            }},
            -- Page 2: Explanation
            { Segments = {
                { text = "Wtf is going on?", bold = true, underline = true, align = "center" },
                { text = "\n" },
                { text = "Hello, and welcome to " },
                { text = "Joel4848's ", bold = true },
                { text = "BotC in, uh, TTT!" },
                { text = "\n\n" },
                { text = "Your role is " },
                { text = ROLE_STRINGS_EXT[ply:GetRole()] .. "! " },
                { text = "You'll find your ability in the " },
                { text = "\"Your info\" ", bold = true },
                { text = "section." },
                { text = "\n\n" },
                { text = "This is a fully-automated, barely-tested, completely non-guaranteed implementation of BotC. If you enjoyed my other randomats so far then... that's a surprise. Good luck!" },
            }},
            -- Page 3: Seating
            { Segments = seatingSegments },
            -- Page 4: 'Your info'
            { Segments = ply.infoBookSegments },
        },
    }

    SendSignedBookUpdate(ply, bookData)
end