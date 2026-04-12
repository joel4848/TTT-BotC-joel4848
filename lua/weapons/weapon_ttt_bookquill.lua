AddCSLuaFile()

SWEP.Base = "weapon_tttbase"
SWEP.PrintName         = "Notebook"
SWEP.Author            = "lolixtin/joel4848"
SWEP.Instructions      = "Right-click to open/write. ESC to close and save."

SWEP.Spawnable         = false
SWEP.AdminSpawnable    = false

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = {}
SWEP.LimitedStock = false
SWEP.AllowDrop = false
SWEP.IsSilent = true
SWEP.NoSights = true

-- TTT slots
SWEP.Slot              = 6
SWEP.SlotPos           = 1
SWEP.EquipMenuData     = { type = "Book" }
SWEP.DrawAmmo          = false
SWEP.DrawCrosshair     = false
SWEP.HoldType          = "slam"

-- Model shown in hands / on the ground
SWEP.WorldModel        = "models/lolixtin/mc_bookquill.mdl"
SWEP.ViewModel         = "models/lolixtin/mc_bookquill.mdl"

-- No sounds / recoil
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

-- Book data stored on the weapon itself
SWEP.BookTexts        = {{Text = ""}}
SWEP.BookPage         = 1
SWEP.BookPageCapacity = 1
SWEP.BookOpen         = false

-----------------------------------------------------
--  Shared bits
-----------------------------------------------------

function SWEP:SetupDataTables()
    
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    -- Close the book GUI if player changes weapon
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

-----------------------------------------------------
--  Primary fire (do nothing)
-----------------------------------------------------
function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
end

-----------------------------------------------------
--  Secondary fire (open book)
-----------------------------------------------------
function SWEP:SecondaryAttack()
    self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
    if CLIENT then
        if not self.BookOpen then
            self:OpenBook()
        end
    end
end

-----------------------------------------------------
--  Client bits
-----------------------------------------------------
if CLIENT then

    -- Called when the player presses ESC while the book is open.
    -- We hook Think to watch for it.
    function SWEP:Think()
        if self.BookOpen and input.IsKeyDown(KEY_ESCAPE) then
            self:CloseBook()
        end
    end

    -----------------------------------------------------
    --  OpenBook - build book GUI
    -----------------------------------------------------
    function SWEP:OpenBook()
        if self.BookOpen then return end
        self.BookOpen = true

        local swep = self

        swep.BookPage = swep.BookPage or 1

        local BW = ScrW() * 0.35
        local BH = BW * (308/250)
        local BX = ScrW()/2 - BW/2
        local BY = ScrH()/2 - BH/2 - 40   -- vertically centred-ish

        -- Text area inset from book edges
        local TAX = BX + BW * 0.10
        local TAY = BY + BH * 0.16
        local TAW = BW * 0.80
        local TAH = BH * 0.65

        -- Page navigation buttons
        local PBW = BW * 0.195
        local PBH = PBW * (31.5/48.75)
        local PBY = BY + BH * 0.81

        -- 'Done' button
        local DoneW = BW * 0.51 * 0.5
        local DoneH = 48 * (BH/308) * 0.5
        local DoneX = ScrW()/2 + BW * 0.02
        local DoneY = BY + BH + 4

        -- Daddy frame
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

        -- MC book background image
        local background = vgui.Create("DImage", Frame)
        background:SetImage("materials/book-br.png")
        background:SetPos(BX, BY)
        background:SetSize(BW, BH)

        -- Typey area
        local TextAreaBG = vgui.Create("DPanel", Frame)
        TextAreaBG:SetBackgroundColor(Color(255, 250, 238))
        TextAreaBG:SetSize(TAW, TAH)
        TextAreaBG:SetPos(TAX, TAY)

        local TextArea = vgui.Create("DTextEntry", TextAreaBG)
        TextArea:SetPaintBackground(false)
        TextArea:Dock(FILL)
        TextArea:SetEditable(true)
        TextArea:SetMaximumCharCount(370)
        TextArea:SetVerticalScrollbarEnabled(true)
        TextArea:SetEnterAllowed(false)
        TextArea:SetHistoryEnabled(false)
        TextArea:SetPlaceholderText("Write something...")
        TextArea:SetMultiline(true)
        TextArea:SetFont("Minecraft30")
        TextArea:SetText(swep.BookTexts[swep.BookPage].Text)
        swep._TextArea = TextArea

        function TextArea:OnChange()
            swep.BookTexts[swep.BookPage].Text = TextArea:GetText()
        end

        -- Title label (blank for B&Q as not signed)
        local TitleLabel = vgui.Create("DLabel", Frame)
        TitleLabel:SetText("Notebook")
        TitleLabel:SetSize(BW * 0.8, 40)
        TitleLabel:SetColor(color_black)
        TitleLabel:SetFont("Minecraft40")
        TitleLabel:SetPos(BX + BW * 0.10, BY + BH * 0.06)

        -- Page counter
        local PageLevel = vgui.Create("DLabel", Frame)
        PageLevel:SetColor(color_black)
        PageLevel:SetPos(BX + BW * 0.30, PBY + PBH / 2.5)
        PageLevel:SetSize(BW * 0.4, 30)
        PageLevel:SetFont("Minecraft30")
        PageLevel:SetContentAlignment(5)

        local function UpdatePageLabel()
            PageLevel:SetText("Page " .. swep.BookPage .. "/" .. swep.BookPageCapacity)
        end
        UpdatePageLabel()

        -- PageUp/PageDown buttons
        local PageUp = vgui.Create("DImageButton", Frame)
        PageUp:SetSize(PBW, PBH)
        PageUp:SetPos(BX + BW * 0.7, PBY)
        PageUp:SetImage("materials/pageup.png")

        local PageDown = vgui.Create("DImageButton", Frame)
        PageDown:SetSize(PBW, PBH)
        PageDown:SetPos(BX + BW * 0.10, PBY)
        PageDown:SetImage("materials/pagedown.png")
        PageDown:SetVisible(false)

        -- If opened on max page, hide PageUp button
        if swep.BookPage == 32 then
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
        if swep.BookPage < 32 then
            PageUp:SetVisible(true)
        end

        PageUp.DoClick = function()
            surface.PlaySound("click.mp3")
            -- Save current page text first
            swep.BookTexts[swep.BookPage].Text = TextArea:GetText()
            if swep.BookPage >= swep.BookPageCapacity then
                -- Add a new page
                swep.BookPage = swep.BookPage + 1
                swep.BookPageCapacity = swep.BookPageCapacity + 1
                table.insert(swep.BookTexts, swep.BookPage, {Text = ""})
                TextArea:SetText("")
            else
                swep.BookPage = swep.BookPage + 1
                TextArea:SetText(swep.BookTexts[swep.BookPage].Text)
            end
            UpdatePageLabel()

            -- If now on page 32 (arbitrary max allowed no. of pages, as safetystop), hide PageUp button
            if swep.BookPage == 32 then
                PageUp:SetVisible(false)
            end
            -- If now not on first page, show PageDown button
            if swep.BookPage > 1 then
                PageDown:SetVisible(true)
            end
        end

        PageDown.DoClick = function()
            surface.PlaySound("click.mp3")
            swep.BookTexts[swep.BookPage].Text = TextArea:GetText()
            if swep.BookPage > 1 then
                swep.BookPage = swep.BookPage - 1
            end
            TextArea:SetText(swep.BookTexts[swep.BookPage].Text)
            UpdatePageLabel()

            -- If now on first page, hide PageDown button
            if swep.BookPage == 1 then
                PageDown:SetVisible(false)
            end
            -- If now not on last page, show PageUp button
            if swep.BookPage < 32 then
                PageUp:SetVisible(true)
            end
        end

        -- 'Done' button
        local buttonDone = vgui.Create("DButton", Frame)
        buttonDone:SetText("Done")
        buttonDone:SetPos(DoneX, DoneY)
        buttonDone:SetSize(DoneW, DoneH)
        buttonDone.DoClick = function()
            surface.PlaySound("click.mp3")
            swep:CloseBook()
        end

        -- 'ESC to close' message
        local hintLabel = vgui.Create("DLabel", Frame)
        hintLabel:SetText("Press ESC to save & close")
        hintLabel:SetColor(Color(180, 180, 180))
        hintLabel:SizeToContents()
        hintLabel:SetPos(BX, DoneY + DoneH + 4)
    end

    -----------------------------------------------------
    --  CloseBook – save text/close GUI
    -----------------------------------------------------
    function SWEP:CloseBook()
        -- Save whatever is currently in the text area for the current page
        if IsValid(self._TextArea) then
            self.BookTexts[self.BookPage].Text = self._TextArea:GetText()
        end
        if IsValid(self._BookFrame) then
            self._BookFrame:Remove()
        end
        self._BookFrame = nil
        self._TextArea  = nil
        self.BookOpen   = false
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