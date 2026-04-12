AddCSLuaFile()

SWEP.Base = "weapon_tttbase"
SWEP.PrintName      = "Admin Book"
SWEP.Author         = "lolixtin/joel4848"
SWEP.Instructions   = "Right-click to use. ESC to close."

SWEP.Spawnable      = false
SWEP.AdminSpawnable = false

SWEP.Kind           = nil
SWEP.CanBuy         = {}
SWEP.LimitedStock   = false
SWEP.AllowDrop      = false
SWEP.IsSilent       = true
SWEP.NoSights       = true

SWEP.Slot           = 8
SWEP.SlotPos        = 1
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

-- SWEP.BookTexts        = { { Text = "" } }
-- SWEP.BookPage         = 1
-- SWEP.BookPageCapacity  = 1
-- SWEP.BookTitle        = "Signed Book"
-- SWEP.BookAuthor       = ""
local BookOpen         = false

-- local BOOK_SYNC_NET = "ttt_books_signedbook_sync"

if SERVER then
    util.AddNetworkString("TTT_adminBookChoice")

    net.Receive("TTT_adminBookChoice", function(len, ply)
        local buttonPressed = net.ReadInt(8)

        if buttonPressed == 1 then
            JoelBotC:SendSeatingGUICreate(ply)
        elseif buttonPressed == 2 then
            JoelBotC:SendSeatingGUIDestroy(ply)
        elseif buttonPressed == 3 then
            JoelBotC:MonkProtect()
        end
    end)
end

if CLIENT then

    surface.CreateFont( "ButtonFontLarge", {
        font = "Arial",
        size = 24, -- Change this value to increase/decrease size
        weight = 500,
    } )

    local AdminBookFrame = nil

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

    function SWEP:Think()
        if BookOpen and input.IsKeyDown(KEY_ESCAPE) then
            self:CloseBook()
            return
        end

    end

    function SWEP:Initialize()
        self:SetHoldType("normal")
    end

    function SWEP:Deploy()
        return true
    end

    function SWEP:Holster()
        if CLIENT and BookOpen then
            self:CloseBook()
        end
        return true
    end

    function SWEP:OnRemove()
        if CLIENT and BookOpen then
            self:CloseBook()
        end
    end

    function SWEP:PrimaryAttack()
        self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
    end

    function SWEP:SecondaryAttack()
        self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
        if CLIENT and not BookOpen then
            self:OpenBook()
        elseif CLIENT and BookOpen then
            self:CloseBook()
        end
    end

    local function sendButton(button)
        net.Start("TTT_adminBookChoice")
            net.WriteInt(button, 8)
        net.SendToServer()
    end

    function SWEP:OpenBook()
        if BookOpen then return end
        BookOpen = true

        local swep = self

        local client = LocalPlayer()
        local scrW, scrH = ScrW(), ScrH()
        local height = 300
        local width = 600
        local top = (scrH * 0.75) - (height / 2)
        local left = (scrW / 2) - (width / 2)

        -- Daddy frame
        AdminBookFrame = vgui.Create("DFrame")
        AdminBookFrame:SetSize(width, height)
        AdminBookFrame:SetPos(left, top)
        AdminBookFrame:SetTitle("")
        AdminBookFrame:SetDraggable(false)
        AdminBookFrame:ShowCloseButton(true)
        AdminBookFrame:SetDeleteOnClose(true)

        -- Have to draw something apparently but then make it alpha 0
        AdminBookFrame.Paint = function(self,w,h)
            draw.RoundedBox(0,4,4,w-8,h-8,Color(0, 0, 0))
        end

        -- Button grid
        local buttonCellSize = width * 0.1
        buttons = {}
        local buttonFunctions = {
            "Open Seat GUI",
            "Close Seat GUI",
            "Placeholder",
            "Placeholder",
            "Placeholder",
            "Placeholder",
            "Placeholder",
            "Placeholder",
            "Placeholder"
        }

        for y=1,3 do
            for x=1,3 do
                local id = (y-1)*3 + x

                local btn = vgui.Create("DButton", AdminBookFrame)

                btn:SetSize(buttonCellSize*3, buttonCellSize)
                btn:SetPos((x-1)*buttonCellSize*3 + 20, (y-1)*buttonCellSize + 20)
                btn:SetText(buttonFunctions[id])
                btn:SetFont("ButtonFontLarge")
                btn:SetVisible(true)

                buttons[id] = btn

                btn.OnDepressed = function(self)
                    net.Start("TTT_adminBookChoice")
                        net.WriteInt(id, 8)
                    net.SendToServer()
                    AdminBookFrame:Remove()
                    AdminBookFrame = nil
                    BookOpen = false
                end
            end
        end

    end

    function SWEP:CloseBook()
        if IsValid(AdminBookFrame) then
            AdminBookFrame:Remove()
        end

        AdminBookFrame = nil
        BookOpen = false
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