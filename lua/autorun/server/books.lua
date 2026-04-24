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

---------------------------------------------------------------
--  GiveSignedBook(ply, bookData)
---------------------------------------------------------------
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

---------------------------------------------------------------
--  UpdateSignedBook(ply, newBookData)
---------------------------------------------------------------
function UpdateSignedBook(ply, newBookData)
    if not IsValid(ply) then return nil end

    local existing = ply:GetWeapon("weapon_ttt_signedbook")
    if IsValid(existing) then existing:Remove() end

    return GiveSignedBook(ply, newBookData)
end

---------------------------------------------------------------
--  How to use
---------------------------------------------------------------
--[[
GiveBookQuill(ply)

GiveSignedBook(ply, {
    title  = "Detective's Notes",
    author = "The Detective",
    pages  = {
        { Text = "Page one content here.\n\nMore text on this page." },
        { Text = "Page two content." },
    }
})

GiveSignedBook(ply, {
    title  = "Secret Instructions",
    author = "The Admin",
    pages  = {
        { Segments = {
            { text = "WARNING: ", bold = true, color = Color(200,0,0) },
            { text = "Do not show this to anyone.\n\n" },
            { text = "Your target is ", italic = true },
            { text = "PlayerName", bold = true, underline = true, color = Color(0,0,200) },
            { text = "." },
        }},
        { Text = "Second page of instructions." },
    }
})

UpdateSignedBook(ply, {
    title = "Updated Notes",
    pages = { { Text = "This replaces the old content." } }
})
]]