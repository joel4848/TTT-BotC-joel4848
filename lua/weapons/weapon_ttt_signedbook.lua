-- weapon_ttt_signedbook.lua
-- TTT Signed Book weapon (read-only; content set by server when giving)

AddCSLuaFile()

SWEP.Base = "weapon_tttbase"
SWEP.PrintName      = "Info Book"
SWEP.Author         = "lolixtin/joel4848"
SWEP.Instructions   = "Right-click to read. ESC to close."

SWEP.Spawnable      = false
SWEP.AdminSpawnable = false

SWEP.Kind           = WEAPON_EQUIP
SWEP.CanBuy         = {}
SWEP.LimitedStock   = false
SWEP.AllowDrop      = false
SWEP.IsSilent       = true
SWEP.NoSights       = true

SWEP.Slot           = 6
SWEP.SlotPos        = 2
SWEP.EquipMenuData  = { type = "Book" }

SWEP.DrawAmmo       = false
SWEP.DrawCrosshair  = false
SWEP.HoldType       = "slam"

SWEP.WorldModel     = "models/lolixtin/mc_signed_book.mdl"
SWEP.ViewModel      = "models/lolixtin/mc_signed_book.mdl"

SWEP.Primary.ClipSize     = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"

SWEP.Secondary.ClipSize   = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.BookTexts        = { { Text = "" } }
SWEP.BookPage         = 1
SWEP.BookPageCapacity  = 1
SWEP.BookTitle        = "Signed Book"
SWEP.BookAuthor       = ""
SWEP.BookOpen         = false

local BOOK_SYNC_NET = "ttt_books_signedbook_sync"

if CLIENT then

    resource.AddFile("resource/fonts/Minecraft.ttf")
    surface.CreateFont("Minecraft40", {
        font = "Minecraft",
        size = 40,
        weight = 2000,
        additive = false,
        antialias = true
    })
    
    resource.AddFile("resource/fonts/Minecraft.ttf")
    surface.CreateFont("Minecraft30", {
        font = "Minecraft",
        size = 30,
        weight = 500,
        additive = false,
        antialias = true
    })

    resource.AddFile("resource/fonts/Minecraft.ttf")
    surface.CreateFont("Minecraft20", {
        font = "Minecraft",
        size = 20,
        weight = 500,
        additive = false,
        antialias = true
    })

    local pendingSignedBookData = {}
    local createdFonts = {}

    local function NormalizeSegmentColor(c)
        if istable(c) then
            return Color(
                tonumber(c.r) or 0,
                tonumber(c.g) or 0,
                tonumber(c.b) or 0,
                255
            )
        end

        return color_black
    end

    local function BuildFormattedFont(bold, italic, underline)
        local key = (bold and "B" or "") .. (italic and "I" or "") .. (underline and "U" or "")
        local name = "TTTBookFont_" .. (key == "" and "Normal" or key)

        if not createdFonts[name] then
            surface.CreateFont(name, {
                font      = "Minecraft",
                size      = 28,
                weight    = bold and 700 or 400,
                italic    = italic or false,
                underline = underline or false,
            })
            createdFonts[name] = true
        end

        return name
    end

    net.Receive(BOOK_SYNC_NET, function()
        local entIndex = net.ReadUInt(16)
        local raw = net.ReadString()

        pendingSignedBookData[entIndex] = raw

        local ent = Entity(entIndex)
        if IsValid(ent) and ent:GetClass() == "weapon_ttt_signedbook" and ent.ApplyRawBookData then
            ent:ApplyRawBookData(raw)
            pendingSignedBookData[entIndex] = nil
        end
    end)

    function SWEP:BuildPageLayout(pageData, maxWidth)
        local segments = {}
        
        if istable(pageData) and istable(pageData.Segments) then
            segments = pageData.Segments
        else
            segments = {
                { text = tostring((pageData and pageData.Text) or "") }
            }
        end
    
        local lines = {}
        local currentAlign = "left"
        local currentLine = { tokens = {}, width = 0, align = "left" }
        local lineHeight = 18
    
        local function pushLine()
            lines[#lines + 1] = currentLine
            currentLine = { tokens = {}, width = 0, align = currentAlign }
        end
    
        local function addToken(tokenText, fontName, tokenColor)
            if tokenText == "" then return end
        
            surface.SetFont(fontName)
            local tokenW, tokenH = surface.GetTextSize(tokenText)
            lineHeight = math.max(lineHeight, tokenH + 3)
        
            if currentLine.width > 0 and currentLine.width + tokenW > maxWidth then
                pushLine()
            end
        
            currentLine.tokens[#currentLine.tokens + 1] = {
                text  = tokenText,
                font  = fontName,
                color = tokenColor,
            }
        
            currentLine.width = currentLine.width + tokenW
        end
    
        local function processText(rawText, fontName, tokenColor, align)
            rawText = tostring(rawText or "")
            currentAlign = align or "left"
            currentLine.align = currentAlign
        
            local paragraphs = string.Split(rawText, "\n")
        
            for i, paragraph in ipairs(paragraphs) do
                if i > 1 then
                    pushLine()
                end
            
                if paragraph ~= "" then
                    local matched = false
                
                    for word, trailingSpaces in paragraph:gmatch("([^%s]+)(%s*)") do
                        matched = true
                        addToken(word .. trailingSpaces, fontName, tokenColor)
                    end
                
                    if not matched then
                        addToken(paragraph, fontName, tokenColor)
                    end
                end
            end
        end
    
        for _, seg in ipairs(segments) do
            local fontName = BuildFormattedFont(seg.bold, seg.italic, seg.underline)
            local tokenColor = NormalizeSegmentColor(seg.color)
        
            processText(seg.text, fontName, tokenColor, seg.align)
        end
    
        if #currentLine.tokens > 0 then
            lines[#lines + 1] = currentLine
        end
        
        if #lines == 0 then
            lines[1] = { tokens = {}, width = 0, align = "left" }
        end
    
        return lines, lineHeight
    end

    function SWEP:ApplyBookPayload(decoded)
        if not istable(decoded) then return end

        self.BookTitle  = tostring(decoded.title or "Signed Book")
        self.BookAuthor = tostring(decoded.author or "")

        if istable(decoded.pages) and #decoded.pages > 0 then
            self.BookTexts = decoded.pages
        else
            self.BookTexts = { { Text = "" } }
        end

        self.BookPageCapacity = math.max(#self.BookTexts, 1)
        self.BookPage = math.Clamp(self.BookPage or 1, 1, self.BookPageCapacity)

        if self.BookOpen then
            self:CloseBook()
            self:OpenBook()
        end
    end

    function SWEP:ApplyRawBookData(raw)
        if not isstring(raw) or raw == "" then return end
        if raw == self._LastRaw then return end

        self._LastRaw = raw

        local decoded = util.JSONToTable(raw)
        if decoded then
            self:ApplyBookPayload(decoded)
        end
    end

    function SWEP:Think()
        if self.BookOpen and input.IsKeyDown(KEY_ESCAPE) then
            self:CloseBook()
            return
        end

        local raw = pendingSignedBookData[self:EntIndex()]
        if raw then
            pendingSignedBookData[self:EntIndex()] = nil
            self:ApplyRawBookData(raw)
        end
    end

    function SWEP:Initialize()
        self:SetHoldType("normal")
    end

    function SWEP:Deploy()
        return true
    end

    function SWEP:Holster()
        if CLIENT and self.BookOpen then
            self:CloseBook()
        end
        return true
    end

    function SWEP:OnRemove()
        if CLIENT and self.BookOpen then
            self:CloseBook()
        end
    end

    function SWEP:PrimaryAttack()
        self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
    end

    function SWEP:SecondaryAttack()
        self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
        if CLIENT and not self.BookOpen then
            self:OpenBook()
        end
    end

    function SWEP:OpenBook()
        if self.BookOpen then return end
        self.BookOpen = true

        local swep = self

        local BW = ScrW() * 0.35
        local BH = BW * (308 / 250)
        local BX = ScrW() / 2 - BW / 2
        local BY = ScrH() / 2 - BH / 2 - 40

        local TAX = BX + BW * 0.10
        local TAY = BY + BH * 0.16
        local TAW = BW * 0.80
        local TAH = BH * 0.65

        local PBW = BW * 0.195
        local PBH = PBW * (31.5 / 48.75)
        local PBY = BY + BH * 0.81

        local DoneW = BW * 0.51 * 0.5
        local DoneH = 48 * (BH / 308) * 0.5
        local DoneX = ScrW() / 2 + BW * 0.02
        local DoneY = BY + BH + 4

        local Frame = vgui.Create("DFrame")
        Frame:SetBGColor(color_white)
        Frame:SetSize(ScrW(), ScrH())
        Frame:SetVisible(true)
        Frame:SetDraggable(false)
        Frame:ShowCloseButton(false)
        Frame:SetTitle("")
        Frame:Center()
        Frame:MakePopup()
        Frame.Paint = function()
            surface.SetDrawColor(Color(0, 0, 0, 175))
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
        swep._BookFrame = Frame

        local background = vgui.Create("DImage", Frame)
        background:SetImage("materials/book-br.png")
        background:SetPos(BX, BY)
        background:SetSize(BW, BH)

        local TitleLabel = vgui.Create("DLabel", Frame)
        TitleLabel:SetText(swep.BookTitle)
        TitleLabel:SetSize(BW * 0.8, 40)
        TitleLabel:SetColor(color_black)
        TitleLabel:SetFont("Minecraft40")
        TitleLabel:SetPos(BX + BW * 0.10, BY + BH * 0.06)

        if swep.BookAuthor ~= "" then
            local AuthLabel = vgui.Create("DLabel", Frame)
            AuthLabel:SetText("by " .. swep.BookAuthor)
            AuthLabel:SetFont("Minecraft20")
            AuthLabel:SetSize(BW * 0.56, 30)
            AuthLabel:SetColor(Color(80, 80, 80))
            AuthLabel:SetPos(BX + BW * 0.10, BY + BH * 0.11)
        end

        local PageLevel = vgui.Create("DLabel", Frame)
        PageLevel:SetColor(color_black)
        PageLevel:SetPos(BX + BW * 0.30, PBY + PBH / 2.5)
        PageLevel:SetSize(BW * 0.4, 30)
        PageLevel:SetFont("Minecraft30")
        PageLevel:SetContentAlignment(5)

        -- Painted the background to make dialing in the alignment significantly the easier
        -- PageLevel.Paint = function(self,w,h)
        --     draw.RoundedBox(2,0,0,w,h,Color(90, 170, 255))
        -- end

        local function UpdatePageLabel()
            PageLevel:SetText("Page " .. swep.BookPage .. "/" .. swep.BookPageCapacity)
        end
        UpdatePageLabel()

        local function RenderPage()
            if IsValid(swep._TextScroll) then
                swep._TextScroll:Remove()
            end

            local pageData = swep.BookTexts[swep.BookPage] or { Text = "" }

            local scroll = vgui.Create("DScrollPanel", Frame)
            scroll:SetPos(TAX, TAY)
            scroll:SetSize(TAW, TAH)
            scroll.Paint = function(self, w, h)
                surface.SetDrawColor(Color(255, 250, 238))
                surface.DrawRect(0, 0, w, h)
                -- surface.SetDrawColor(Color(0, 0, 0))
                -- surface.DrawOutlinedRect(0, 0, w, h, 2)
            end

            local contentWidth = math.max(TAW - 24, 32)
            local layout, lineHeight = swep:BuildPageLayout(pageData, contentWidth - 8)

            local content = vgui.Create("DPanel")
            content:SetSize(contentWidth, math.max(#layout * lineHeight + 8, TAH))
            content:SetBackgroundColor(Color(0, 0, 0, 0))
            content._Layout = layout
            content._LineHeight = lineHeight
            content.Paint = function(self, w, h)
            local y = 4

            for _, line in ipairs(self._Layout or {}) do
                local x = 4
            
                if line.align == "center" then
                    x = (w - line.width) / 2
                end
            
                for _, token in ipairs(line.tokens or {}) do
                    surface.SetFont(token.font)
                    surface.SetTextColor(token.color)
                    surface.SetTextPos(x, y)
                    surface.DrawText(token.text)
                
                    x = x + select(1, surface.GetTextSize(token.text))
                end
            
                y = y + (self._LineHeight or 18)
            end
        end

            scroll:AddItem(content)

            swep._TextScroll = scroll
            swep._TextContent = content
        end

        RenderPage()


        
        -- PageUp
        local PageUp = vgui.Create("DImageButton", Frame)
        PageUp:SetSize(PBW, PBH)
        PageUp:SetPos(BX + BW * 0.7, PBY)
        PageUp:SetImage("materials/pageup.png")
        PageUp:SetVisible(false)
        
        -- PageDown
        local PageDown = vgui.Create("DImageButton", Frame)
        PageDown:SetSize(PBW, PBH)
        PageDown:SetPos(BX + BW * 0.10, PBY)
        PageDown:SetImage("materials/pagedown.png")
        PageDown:SetVisible(false)

        -- If opened on last page, hide PageUp button
        if swep.BookPage == swep.BookPageCapacity then
            PageUp:SetVisible(false)
        end
        -- If opened not on first page, show PageDown button
        if swep.BookPage > 1 then
            PageDown:SetVisible(true)
        end
        -- If opened on first page, hide PageDown button
        if swep.BookPage == 1 then
            PageDown:SetVisible(false)
        end
        -- If opened not on last page, show PageUp button
        if swep.BookPage < swep.BookPageCapacity then
            PageUp:SetVisible(true)
        end

        PageUp.DoClick = function()
            surface.PlaySound("click.mp3")
            if swep.BookPage < swep.BookPageCapacity then
                swep.BookPage = swep.BookPage + 1
                UpdatePageLabel()
                RenderPage()
            end
            -- If now on last page, hide PageUp button
            if swep.BookPage == swep.BookPageCapacity then
                PageUp:SetVisible(false)
            end
            -- If now not on first page, show PageDown button
            if swep.BookPage > 1 then
                PageDown:SetVisible(true)
            end
        end
        -- Only show PageUp button if there are > 1 pages
        if swep.BookPageCapacity > 1 then
            PageUp:SetVisible(true)
        end

        PageDown.DoClick = function()
            surface.PlaySound("click.mp3")
            if swep.BookPage > 1 then
                swep.BookPage = swep.BookPage - 1
                UpdatePageLabel()
                RenderPage()
            end
            -- If now on first page, hide PageDown button
            if swep.BookPage == 1 then
                PageDown:SetVisible(false)
            end
            -- If now not on last page, show PageUp button
            if swep.BookPage < swep.BookPageCapacity then
                PageUp:SetVisible(true)
            end
        end

        local buttonClose = vgui.Create("DButton", Frame)
        buttonClose:SetText("Close")
        buttonClose:SetPos(DoneX, DoneY)
        buttonClose:SetSize(DoneW, DoneH)
        buttonClose.DoClick = function()
            surface.PlaySound("click.mp3")
            swep:CloseBook()
        end

        local hintLabel = vgui.Create("DLabel", Frame)
        hintLabel:SetText("Press ESC to close")
        hintLabel:SetColor(Color(180, 180, 180))
        hintLabel:SizeToContents()
        hintLabel:SetPos(BX, DoneY + DoneH + 4)
    end

    function SWEP:CloseBook()
        if IsValid(self._BookFrame) then
            self._BookFrame:Remove()
        end

        self._BookFrame = nil
        self._TextScroll = nil
        self._TextContent = nil
        self.BookOpen = false
    end

    -----------------------------------------------------
    -- VIEW MODEL / WORLD MODEL OVERRIDES
    -----------------------------------------------------

    function SWEP:GetViewModelPosition(pos, ang)
        self:SetModelScale(0.5, 0)

        -- Hold position lower and to the right, out of the way
        pos = pos + ang:Forward() * 20 + ang:Right() * -12 + ang:Up() * -10
        ang:RotateAroundAxis(ang:Right(), 70)
        ang:RotateAroundAxis(ang:Up(), 110)
        ang:RotateAroundAxis(ang:Forward(), 180)

        return pos, ang
    end

    function SWEP:DrawWorldModel()

        self:SetModelScale(0.5, 0)

        if not IsValid(self.Owner) then
            self:DrawModel()
            return
        end

        local hand = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if not hand then
            self:DrawModel()
            return
        end

        local pos, ang = self.Owner:GetBonePosition(hand)
        if not pos then
            self:DrawModel()
            return
        end

        local offset = ang:Forward() * 5 + ang:Right() * 1.5 + ang:Up() * -2
        pos = pos + offset

        -- Rotate to match natural holding angle
        ang:RotateAroundAxis(ang:Up(), 0)
        ang:RotateAroundAxis(ang:Right(), 0) 
        ang:RotateAroundAxis(ang:Forward(), 0)

        self:SetPos(pos)
        self:SetAngles(ang)
        self:SetupBones()
        self:DrawModel()
    end
end