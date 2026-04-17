local EVENT = {}

JoelBotC = JoelBotC or {}

EVENT.Title = "JoelBotC"
EVENT.Description = "You know how this works!"
EVENT.id = "joelbotc"
EVENT.Categories = {"gamemode", "largeimpact", "rolechange"}

util.AddNetworkString("rdmtJoelBotCSeatingOrder")
util.AddNetworkString("rdmtJoelBotCAliveDeadUpdate")

-- 'Script' -----------------------------------------------------------------------------------------------------------------
local stewardEnabled = CreateConVar("randomat_joelbotc_steward_enabled", 1, FCVAR_NONE, "Whether the Steward is on the script", 0, 1):GetBool()
local knightEnabled = CreateConVar("randomat_joelbotc_knight_enabled", 1, FCVAR_NONE, "Whether the Knight is on the script", 0, 1):GetBool()
local oracleEnabled = CreateConVar("randomat_joelbotc_oracle_enabled", 1, FCVAR_NONE, "Whether the Oracle is on the script", 0, 1):GetBool()
local chefEnabled = CreateConVar("randomat_joelbotc_chef_enabled", 1, FCVAR_NONE, "Whether the Chef is on the script", 0, 1):GetBool()
local undertakerEnabled = CreateConVar("randomat_joelbotc_undertaker_enabled", 1, FCVAR_NONE, "Whether the Undertaker is on the script", 0, 1):GetBool()
local nobleEnabled = CreateConVar("randomat_joelbotc_noble_enabled", 1, FCVAR_NONE, "Whether the Noble is on the script", 0, 1):GetBool()
local investigatorEnabled = CreateConVar("randomat_joelbotc_investigator_enabled", 1, FCVAR_NONE, "Whether the Investigator is on the script", 0, 1):GetBool()
local monkEnabled = CreateConVar("randomat_joelbotc_monk_enabled", 1, FCVAR_NONE, "Whether the Monk is on the script", 0, 1):GetBool()
local washerwomanEnabled = CreateConVar("randomat_joelbotc_washerwoman_enabled", 1, FCVAR_NONE, "Whether the Washerwoman is on the script", 0, 1):GetBool()
local nightwatchmanEnabled = CreateConVar("randomat_joelbotc_nightwatchman_enabled", 1, FCVAR_NONE, "Whether the Nightwatchman is on the script", 0, 1):GetBool()
local grandmotherEnabled = CreateConVar("randomat_joelbotc_grandmother_enabled", 1, FCVAR_NONE, "Whether the Grandmother is on the script", 0, 1):GetBool()
local seamstressEnabled = CreateConVar("randomat_joelbotc_seamstress_enabled", 1, FCVAR_NONE, "Whether the Seamstress is on the script", 0, 1):GetBool()
local librarianEnabled = CreateConVar("randomat_joelbotc_librarian_enabled", 1, FCVAR_NONE, "Whether the Librarian is on the script", 0, 1):GetBool()
local slayerEnabled = CreateConVar("randomat_joelbotc_slayer_enabled", 1, FCVAR_NONE, "Whether the Slayer is on the script", 0, 1):GetBool()
local empathEnabled = CreateConVar("randomat_joelbotc_empath_enabled", 1, FCVAR_NONE, "Whether the Empath is on the script", 0, 1):GetBool()
local soldierEnabled = CreateConVar("randomat_joelbotc_soldier_enabled", 1, FCVAR_NONE, "Whether the Soldier is on the script", 0, 1):GetBool()
local ravenkeeperEnabled = CreateConVar("randomat_joelbotc_ravenkeeper_enabled", 1, FCVAR_NONE, "Whether the Ravenkeeper is on the script", 0, 1):GetBool()
local fortunetellerEnabled = CreateConVar("randomat_joelbotc_fortuneteller_enabled", 1, FCVAR_NONE, "Whether the Fortune Teller is on the script", 0, 1):GetBool()
local virginEnabled = CreateConVar("randomat_joelbotc_virgin_enabled", 1, FCVAR_NONE, "Whether the Virgin is on the script", 0, 1):GetBool()
local ogreEnabled = CreateConVar("randomat_joelbotc_ogre_enabled", 1, FCVAR_NONE, "Whether the Ogre is on the script", 0, 1):GetBool()
local moonchildEnabled = CreateConVar("randomat_joelbotc_moonchild_enabled", 1, FCVAR_NONE, "Whether the Moonchild is on the script", 0, 1):GetBool()
local saintEnabled = CreateConVar("randomat_joelbotc_saint_enabled", 1, FCVAR_NONE, "Whether the Saint is on the script", 0, 1):GetBool()
local drunkEnabled = CreateConVar("randomat_joelbotc_drunk_enabled", 1, FCVAR_NONE, "Whether the Drunk is on the script", 0, 1):GetBool()
local recluseEnabled = CreateConVar("randomat_joelbotc_recluse_enabled", 1, FCVAR_NONE, "Whether the Recluse is on the script", 0, 1):GetBool()
local poisonerEnabled = CreateConVar("randomat_joelbotc_poisoner_enabled", 1, FCVAR_NONE, "Whether the Poisoner is on the script", 0, 1):GetBool()
local scarletwomanEnabled = CreateConVar("randomat_joelbotc_scarletwoman_enabled", 1, FCVAR_NONE, "Whether the Scarlet Woman is on the script", 0, 1):GetBool()
local organgrinderEnabled = CreateConVar("randomat_joelbotc_organgrinder_enabled", 1, FCVAR_NONE, "Whether the Organ Grinder is on the script", 0, 1):GetBool()
local assassinEnabled = CreateConVar("randomat_joelbotc_assassin_enabled", 1, FCVAR_NONE, "Whether the Assassin is on the script", 0, 1):GetBool()
local baronEnabled = CreateConVar("randomat_joelbotc_baron_enabled", 1, FCVAR_NONE, "Whether the Baron is on the script", 0, 1):GetBool()
local pukkaEnabled = CreateConVar("randomat_joelbotc_pukka_enabled", 1, FCVAR_NONE, "Whether the Pukka is on the script", 0, 1):GetBool()
local impEnabled = CreateConVar("randomat_joelbotc_imp_enabled", 1, FCVAR_NONE, "Whether the Imp is on the script", 0, 1):GetBool()
local shabalothEnabled = CreateConVar("randomat_joelbotc_shabaloth_enabled", 1, FCVAR_NONE, "Whether the Shabaloth is on the script", 0, 1):GetBool()
local poEnabled = CreateConVar("randomat_joelbotc_po_enabled", 1, FCVAR_NONE, "Whether the Po is on the script", 0, 1):GetBool()
local ojoEnabled = CreateConVar("randomat_joelbotc_ojo_enabled", 1, FCVAR_NONE, "Whether the Ojo is on the script", 0, 1):GetBool()
-- /'Script' ----------------------------------------------------------------------------------------------------------------

local original_COLOR_DETECTIVE = {}
local original_COLOR_SPECIAL_INNOCENT = {}
local original_COLOR_SPECIAL_TRAITOR = {}
local original_COLOR_MONSTER = {}

JoelBotC.players = JoelBotC.players or {}
JoelBotC.isAlive = JoelBotC.isAlive or {}

local originalDetectiveCvar = nil

function EVENT:Begin()

    originalDetectiveCvar = GetConVar("ttt_detectives_hide_special_mode"):GetInt()
    GetConVar("ttt_detectives_hide_special_mode"):SetInt(2)

    function JoelBotC:AliveDeadUpdate()
        net.Start("rdmtJoelBotCAliveDeadUpdate")
            net.WriteTable(JoelBotC.isAlive)
        net.Broadcast()
    end

    function JoelBotC:Kill(ply)
        if not IsValid(ply) then return end

        if not ply.BotCDead then
            ply.hasGhostVote = true
        end

        ply.BotCDead = true
        JoelBotC.isAlive[ply] = false

        ply:DoAnimationEvent(ACT_GMOD_DEATH, 2028)
        
        timer.Simple(0, function()
            animationLength = ply:SequenceDuration()

            -- Wait until the player hits the ground
            timer.Create("JoelBotC_RagdollWait_" .. ply:SteamID64(), animationLength, 1, function()
                -- Create ragdoll at player position/pose etc.
                ply:CreateRagdoll()
                local rag = ply:GetRagdollEntity()
                print("rag pos = " .. tostring(rag:GetPos() or nil))
                print("rag angles = " .. tostring(rag:GetAngles() or nil))
                print("ply pos = " .. tostring(ply:GetPos() or nil))
                print("ply angles = " .. tostring(ply:GetAngles() or nil))
                
                timer.Simple(0.2, function()
                    if not IsValid(rag) then return end

                    local rag2 = ents.Create("prop_ragdoll")
                    if not IsValid(rag2) then return end

                    rag2:SetModel(ply:GetModel())
                    rag2:SetPos(rag:GetPos())
                    rag2:SetAngles(rag:GetAngles())
                    rag2:SetSkin(ply:GetSkin())

                    local num = rag2:GetPhysicsObjectCount() - 1
                    local v = rag:GetVelocity()
                    for i = 0, num do
                        local bone = rag2:GetPhysicsObjectNum(i)
                        if IsValid(bone) then
                            local bp, ba = rag:GetBonePosition(rag2:TranslatePhysBoneToBone(i))
                            if bp and ba then
                                bone:SetPos(bp)
                                bone:SetAngles(ba)
                            end
                        
                            -- not sure if this will work:
                            bone:SetVelocity(v)
                        end
                    end

                    rag2:Spawn()
                    rag:Remove()
                end)

                timer.Simple(0, function()
                    ply:SetNoDraw(true)
                end)

                local executeeWeapons = ply:GetWeapons() or {}
                for _, wep in ipairs(executeeWeapons) do
                    wep:SetNoDraw(true)
                end
                -- After 3 seconds, show the ghost player
                timer.Simple(3, function()
                    if not IsValid(ply) then return end
                    ply:SetNoDraw(false)
                    for _, wep in ipairs(executeeWeapons) do
                        wep:SetNoDraw(false)
                    end
                    JoelBotC:AliveDeadUpdate()
                end)
            end)
        end)
    end

    -- function JoelBotC:Kill(ply)
    --     if not IsValid(ply) then return end
    -- 
    --     if not ply.BotCDead then
    --         ply.hasGhostVote = true
    --     end
    -- 
    --     ply.BotCDead = true
    --     JoelBotC.isAlive[ply] = false
    -- 
    --     -- Play the falling death animation
    --     ply:DoAnimationEvent(ACT_GMOD_DEATH, 2028)
    -- 
    --     local ragModel = nil
    --     local ragPos = nil
    --     local ragAngles = nil
    -- 
    --     -- Wait until the player hits the ground
    --     timer.Create("JoelBotC_RagdollWait_" .. ply:SteamID64(), 0, 0, function()
    -- 
    --         print("Timer running")
    -- 
    --         if not IsValid(ply) then
    --             timer.Remove("JoelBotC_RagdollWait_" .. ply:SteamID64())
    --             return
    --         end
    -- 
    --         if IsValid(rag) then
    --             rag:Remove()
    --         end
    -- 
    --         if not ply:IsPlayingGesture(2028) then
    --             timer.Remove("JoelBotC_RagdollWait_" .. ply:SteamID64())
    -- 
    --             -- local rag = ply:CreateRagdoll()
    --             -- local rag = ents.Create("prop_ragdoll")
    --             -- rag:SetModel(ragModel)
    --             -- rag:SetPos(ragPos)
    --             -- rag:SetAngles(ragAngles)
    --             -- rag:Spawn()
    -- 
    --             ply:SetNoDraw(true)
    -- 
    --             timer.Simple(3, function()
    --                 if not IsValid(ply) then return end
    -- 
    --                 JoelBotC:AliveDeadUpdate()
    --                 ply:SetNoDraw(false)
    -- 
    --                 ply:SetColor(Color(255,255,255,100))
    --                 ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    -- 
    --             end)
    --         end
    -- 
    --         ragModel = ply:GetModel()
    --         ragPos = ply:GetPos()
    --         ragAngles = ply:GetAngles()
    -- 
    --         local rag = ply:CreateRagdoll()
    -- 
    --     end)
    -- 
    -- end

    -- function JoelBotC:Kill(ply)
    --     if not IsValid(ply) then return end
-- 
    --     if not ply.BotCDead then
    --         ply.hasGhostVote = true
    --     end
-- 
    --     ply.BotCDead = true
    --     JoelBotC.isAlive[ply] = false
-- 
    --     local originalCollisionGroup = ply:GetCollisionGroup() or 0
    --     print("Player collision group = " .. ply:GetCollisionGroup())
    --     ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    --     print("Player collision group = " .. ply:GetCollisionGroup())
-- 
    --     ply:DoAnimationEvent(ACT_GMOD_DEATH, 2028)
-- 
    --     local ragModel = nil
    --     local ragPos = nil
    --     local ragAngles = nil
-- 
    --     -- Wait until the player hits the ground
    --     timer.Create("JoelBotC_RagdollWait_" .. ply:SteamID64(), 0, 0, function()
-- 
    --         print("Timer running")
-- 
    --         if not IsValid(ply) then
    --             timer.Remove("JoelBotC_RagdollWait_" .. ply:SteamID64())
    --             return
    --         end
-- 
    --         if not ply:IsPlayingGesture(2028) then
    --             timer.Remove("JoelBotC_RagdollWait_" .. ply:SteamID64())
    --             print("Timer removed ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
-- 
    --             -- Hide the player and their weapons
    --             ply:SetNoDraw(true)
    --             local executeeWeapons = ply:GetWeapons() or {}
    --             for _, wep in ipairs(executeeWeapons) do
    --                 wep:SetNoDraw(true)
    --             end
-- 
    --             -- Create ragdoll at the player's position
    --             local rag = ply:CreateRagdoll()
    --             -- local rag = ents.Create("prop_ragdoll")
    --             -- rag:SetModel(ragModel)
    --             -- rag:SetPos(ragPos)
    --             -- rag:SetAngles(ragAngles)
    --             -- rag:Spawn()
-- 
    --             print("ragModel = " .. tostring(ragModel))
    --             print("ragPos = " .. tostring(ragPos))
    --             print("ragAngles = " .. tostring(ragAngles))
    --             print("ply:GetModel = " .. tostring(ply:GetModel()))
    --             print("ply:GetPos = " .. tostring(ply:GetPos()))
    --             print("ply:GetAngles = " .. tostring(ply:GetAngles()))
-- 
    --             -- After 3 seconds, show ghost player
    --             timer.Simple(3, function()
    --                 if not IsValid(ply) then return end
    --             
    --                 ply:SetNoDraw(false)
    --             
    --                 ply:SelectWeapon("weapon_ttt_unarmed")
-- 
    --                 ply:SetCollisionGroup(originalCollisionGroup)
    --                 print("Player collision group = " .. ply:GetCollisionGroup())
    --             
    --                 for _, wep in ipairs(executeeWeapons) do
    --                     if IsValid(wep) then
    --                         wep:SetNoDraw(false)
    --                     end
    --                 end
    --             
    --                 -- Ghost appearance
    --                 ply:SetColor(Color(255,255,255,100))
    --                 ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    --             
    --                 JoelBotC:AliveDeadUpdate()
    --             
    --                 -- Remove ragdoll
    --                 -- if IsValid(rag) then rag:Remove() end
    --             end)
    --         end
-- 
    --         ragModel = ply:GetModel()
    --         ragPos = ply:GetPos()
    --         ragAngles = ply:GetAngles()
-- 
    --         print("****************************************************")
    --         print("ragModel = " .. tostring(ragModel))
    --         print("ragPos = " .. tostring(ragPos))
    --         print("ragAngles = " .. tostring(ragAngles))
    --         print("ply:GetModel = " .. tostring(ply:GetModel()))
    --         print("ply:GetPos = " .. tostring(ply:GetPos()))
    --         print("ply:GetAngles = " .. tostring(ply:GetAngles()))
    --         print("****************************************************")
-- 
-- 
    --     end)
    -- end

    function JoelBotC:Revive(ply)
        ply.BotCDead = false
        JoelBotC.isAlive[ply] = true

        JoelBotC:AliveDeadUpdate()
    end

    function JoelBotC:Execute(ply)
        if not IsValid(ply) or not ply:Alive() then return end

        ply:Freeze(true)
        ply:SetCanWalk(false)

        ply:DoAnimationEvent(ACT_GMOD_GESTURE_WAVE)

        local anvil = ents.Create("prop_physics")
        if not IsValid(anvil) then return end

        anvil:SetModel("models/minecraft/anvil.mdl")
        anvil:SetPos(ply:GetPos() + Vector(0,0,2000))
        anvil:SetAngles(Angle(0,0,0))
        anvil:SetOwner(ply)
        anvil:SetModelScale(0.7,0)

        -- Make anvil still work even if the player is indoors
        anvil:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

        anvil:Spawn()

        local phys = anvil:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:SetMass(4000)
            phys:ApplyForceCenter(Vector(0,0,-6000))
        end

        -- Enable collision shortly before impact
        -- Probably redundant because I'm going to apply force to the ragdoll, but meh
        timer.Simple(1, function()
            if IsValid(anvil) then
                print("Changed anvil collision group")
                anvil:SetCollisionGroup(COLLISION_GROUP_NONE)
            end
        end)

        -- Bonk sound
        timer.Simple(2.4, function()
            if IsValid(ply) then
                ply:EmitSound("anvil_land_loud.wav", 511, 100, 1)
            end
        end)

        -- Kill player and spawn ragdoll just before impact
        timer.Simple(2.6, function()
            if not IsValid(ply) then return end

            if not ply.BotCDead then
                ply.hasGhostVote = true
            end

            ply.BotCDead = true
            JoelBotC.isAlive[ply] = false

            -- Save the player's collision group and disable collisions with props
            local oldCollision = ply:GetCollisionGroup()
            ply:SetCollisionGroup(COLLISION_GROUP_WORLD)

            -- Hide the player and their weapons
            ply:SetNoDraw(true)
            local executeeWeapons = ply:GetWeapons() or {}
            for _, wep in ipairs(executeeWeapons) do
                wep:SetNoDraw(true)
            end

            -- Create ragdoll at the player's position
            local rag = ents.Create("prop_ragdoll")
            rag:SetModel(ply:GetModel())
            rag:SetPos(ply:GetPos())
            rag:SetAngles(ply:GetAngles())
            rag:Spawn()

            -- Bonk the ragdoll into the ground like it got squished
            for i = 0, rag:GetPhysicsObjectCount() - 1 do
                local phys = rag:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    phys:ApplyForceCenter(Vector(0, 0, -50000))
                end
            end

            -- Restore collision after 1 second
            timer.Simple(1, function()
                if IsValid(ply) then
                    ply:SetCollisionGroup(oldCollision)
                end
            end)

            -- After 3 seconds, show ghost player
            timer.Simple(3, function()
                if not IsValid(ply) then return end

                ply:SetNoDraw(false)

                ply:SelectWeapon("weapon_ttt_unarmed")

                for _, wep in ipairs(executeeWeapons) do
                    if IsValid(wep) then
                        wep:SetNoDraw(false)
                    end
                end

                -- Ghost appearance
                ply:SetColor(Color(255,255,255,100))
                ply:SetRenderMode(RENDERMODE_TRANSALPHA)

                JoelBotC:AliveDeadUpdate()

                -- Remove ragdoll
                -- if IsValid(rag) then rag:Remove() end
            end)

            if ply:IsFrozen() then
                ply:Freeze(false)
            end

            ply:SetCanWalk(true)

            if IsValid(anvil) then
                timer.Simple(5, function()
                    if IsValid(anvil) then
                        anvil:Remove()
                    end
                end)
            end
        end)
    end

    local townsfolkAmount = nil
    local outsidersAmount = nil
    local minionsAmount = nil
    local demonsAmount = nil
    local enabledTownsfolk = {}
    local enabledOutsiders = {}
    JoelBotC.enabledMinions = {}
    local enabledDemons = {}
    JoelBotC.townsfolkPlayers = {}
    JoelBotC.outsiderPlayers = {}
    JoelBotC.goodPlayers = {}
    JoelBotC.minionPlayers = {}
    JoelBotC.demonPlayers = {}
    JoelBotC.evilPlayers = {}
    JoelBotC.seatingOrder = {}
    JoelBotC.demonBluffsPool = {}
    JoelBotC.demonBluffs = {}
    JoelBotC.players = {}

    -- Custom role colours
    original_COLOR_DETECTIVE = table.Copy(COLOR_DETECTIVE)
    original_COLOR_SPECIAL_INNOCENT = table.Copy(COLOR_SPECIAL_INNOCENT)
    original_COLOR_SPECIAL_TRAITOR = table.Copy(COLOR_SPECIAL_TRAITOR)
    original_COLOR_MONSTER = table.Copy(COLOR_MONSTER)

    COLOR_DETECTIVE = {
        ["default"] = Color(31, 101, 255, 255),
        ["simple"] = Color(31, 101, 255, 255),
        ["protan"] = Color(31, 101, 255, 255),
        ["deutan"] = Color(31, 101, 255, 255),
        ["tritan"] = Color(31, 101, 255, 255)
    }

    COLOR_SPECIAL_INNOCENT = {
        ["default"] = Color(70, 213, 255, 255),
        ["simple"] = Color(70, 213, 255, 255),
        ["protan"] = Color(70, 213, 255, 255),
        ["deutan"] = Color(70, 213, 255, 255),
        ["tritan"] = Color(70, 213, 255, 255)
    }

    COLOR_SPECIAL_TRAITOR = {
        ["default"] = Color(255, 105, 0, 255),
        ["simple"] = Color(255, 105, 0, 255),
        ["protan"] = Color(255, 105, 0, 255),
        ["deutan"] = Color(255, 105, 0, 255),
        ["tritan"] = Color(255, 105, 0, 255)
    }

    COLOR_MONSTER = {
        ["default"] = Color(206, 1, 0, 255),
        ["simple"] = Color(206, 1, 0, 255),
        ["protan"] = Color(206, 1, 0, 255),
        ["deutan"] = Color(206, 1, 0, 255),
        ["tritan"] = Color(206, 1, 0, 255)
    }

    UpdateRoleColours()

----------------------------------------------------------------------------------------------------------------------------
-- ASSIGN ROLES
----------------------------------------------------------------------------------------------------------------------------

    -- Determine roles on the 'script'
    if stewardEnabled then
        table.insert(enabledTownsfolk, ROLE_STEWARDJBC)
    end
    if knightEnabled then
        table.insert(enabledTownsfolk, ROLE_KNIGHTJBC)
    end
    if oracleEnabled then
        table.insert(enabledTownsfolk, ROLE_ORACLEJBC)
    end
    if chefEnabled then
        table.insert(enabledTownsfolk, ROLE_CHEFJBC)
    end
    if undertakerEnabled then
        table.insert(enabledTownsfolk, ROLE_UNDERTAKERJBC)
    end
    if nobleEnabled then
        table.insert(enabledTownsfolk, ROLE_NOBLEJBC)
    end
    if investigatorEnabled then
        table.insert(enabledTownsfolk, ROLE_INVESTIGATORJBC)
    end
    if monkEnabled then
        table.insert(enabledTownsfolk, ROLE_MONKJBC)
    end
    if washerwomanEnabled then
        table.insert(enabledTownsfolk, ROLE_WASHERWOMANJBC)
    end
    if nightwatchmanEnabled then
        table.insert(enabledTownsfolk, ROLE_NIGHTWATCHMANJBC)
    end
    if grandmotherEnabled then
        table.insert(enabledTownsfolk, ROLE_GRANDMOTHERJBC)
    end
    if seamstressEnabled then
        table.insert(enabledTownsfolk, ROLE_SEAMSTRESSJBC)
    end
    if librarianEnabled then
        table.insert(enabledTownsfolk, ROLE_LIBRARIANJBC)
    end
    if slayerEnabled then
        table.insert(enabledTownsfolk, ROLE_SLAYERJBC)
    end
    if empathEnabled then
        table.insert(enabledTownsfolk, ROLE_EMPATHJBC)
    end
    if soldierEnabled then
        table.insert(enabledTownsfolk, ROLE_SOLDIERJBC)
    end
    if ravenkeeperEnabled then
        table.insert(enabledTownsfolk, ROLE_RAVENKEEPERJBC)
    end
    if fortunetellerEnabled then
        table.insert(enabledTownsfolk, ROLE_FORTUNETELLERJBC)
    end
    if virginEnabled then
        table.insert(enabledTownsfolk, ROLE_VIRGINJBC)
    end
    if ogreEnabled then
        table.insert(enabledOutsiders, ROLE_OGREJBC)
    end
    if moonchildEnabled then
        table.insert(enabledOutsiders, ROLE_MOONCHILDJBC)
    end
    if saintEnabled then
        table.insert(enabledOutsiders, ROLE_SAINTJBC)
    end
    if drunkEnabled then
        table.insert(enabledOutsiders, ROLE_DRUNKJBC)
    end
    if recluseEnabled then
        table.insert(enabledOutsiders, ROLE_RECLUSEJBC)
    end
    if poisonerEnabled then
        table.insert(JoelBotC.enabledMinions, ROLE_POISONERJBC)
    end
    if scarletwomanEnabled then
        table.insert(JoelBotC.enabledMinions, ROLE_SCARLETWOMANJBC)
    end
    if organgrinderEnabled then
        table.insert(JoelBotC.enabledMinions, ROLE_ORGANGRINDERJBC)
    end
    if assassinEnabled then
        table.insert(JoelBotC.enabledMinions, ROLE_ASSASSINJBC)
        JoelBotC.assassinAbilityUsed = false
    end
    if baronEnabled then
        table.insert(JoelBotC.enabledMinions, ROLE_BARONJBC)
    end
    if pukkaEnabled then
        table.insert(enabledDemons, ROLE_PUKKAJBC)
    end
    if impEnabled then
        table.insert(enabledDemons, ROLE_IMPJBC)
    end
    if shabalothEnabled then
        table.insert(enabledDemons, ROLE_SHABALOTHJBC)
    end
    if poEnabled then
        table.insert(enabledDemons, ROLE_POJBC)
    end
    if ojoEnabled then
        table.insert(enabledDemons, ROLE_OJOJBC)
    end

    -- Get a table of (tabulate?) living players
    for _, ply in player.Iterator() do
        if IsValid(ply) and not ply:IsSpec() then
            table.insert(JoelBotC.players, ply)
            ply.hasRole = nil
            ply.currentRole = ply:GetRole() or nil
            ply.BotCDead = false
            JoelBotC.isAlive[ply] = true

            ply:StripWeapons()
            ply:SetFOV(0, 0.2)
            ply:Give("weapon_ttt_unarmed")
            ply:Give("weapon_zm_carry")
        end
    end

    -- Determine character type amounts
    if #JoelBotC.players == 15 then
        townsfolkAmount = 9
        outsidersAmount = 2
        minionsAmount = 3
        demonsAmount = 1
    elseif #JoelBotC.players == 14 then
        townsfolkAmount = 9
        outsidersAmount = 1
        minionsAmount = 3
        demonsAmount = 1
    elseif #JoelBotC.players == 13 then
        townsfolkAmount = 9
        outsidersAmount = 0
        minionsAmount = 3
        demonsAmount = 1
    elseif #JoelBotC.players == 12 then
        townsfolkAmount = 7
        outsidersAmount = 2
        minionsAmount = 2
        demonsAmount = 1
    elseif #JoelBotC.players == 11 then
        townsfolkAmount = 7
        outsidersAmount = 1
        minionsAmount = 2
        demonsAmount = 1
    elseif #JoelBotC.players == 10 then
        townsfolkAmount = 7
        outsidersAmount = 0
        minionsAmount = 2
        demonsAmount = 1
    elseif #JoelBotC.players == 9 then
        townsfolkAmount = 5
        outsidersAmount = 2
        minionsAmount = 1
        demonsAmount = 1
    elseif #JoelBotC.players == 8 then
        townsfolkAmount = 5
        outsidersAmount = 1
        minionsAmount = 1
        demonsAmount = 1
    elseif #JoelBotC.players == 7 then
        townsfolkAmount = 5
        outsidersAmount = 0
        minionsAmount = 1
        demonsAmount = 1
    elseif #JoelBotC.players == 6 then
        townsfolkAmount = 3
        outsidersAmount = 1
        minionsAmount = 1
        demonsAmount = 1
    elseif #JoelBotC.players == 5 then
        townsfolkAmount = 3
        outsidersAmount = 0
        minionsAmount = 1
        demonsAmount = 1
    elseif #JoelBotC.players == 1 then
        townsfolkAmount = 1
        outsidersAmount = 1
        minionsAmount = 1
        demonsAmount = 1

    --for testing
    else
        townsfolkAmount = 0
        outsidersAmount = 0
        minionsAmount = 4
        demonsAmount = 0
    end

    -- Assign character types to players

    -- Shuffle players
    table.Shuffle(JoelBotC.players)

    -- Make working copies of character type tables and shuffle (Can one shuffle too much?)
    local townsfolkPool = table.Copy(enabledTownsfolk)
    local outsiderPool  = table.Copy(enabledOutsiders)
    local minionPool    = table.Copy(JoelBotC.enabledMinions)
    local demonPool     = table.Copy(enabledDemons)

    table.Shuffle(townsfolkPool)
    table.Shuffle(outsiderPool)
    table.Shuffle(minionPool)
    table.Shuffle(demonPool)

    -- Fill the master role pool
    local rolePool = {}

    local function AddRoles(pool, amount, alignment)
        for i = 1, amount do
            local role = table.remove(pool)
            if role then
                rolePool[#rolePool + 1] = {role = role, alignment = alignment}
            end
        end
    end

    AddRoles(townsfolkPool, townsfolkAmount, "townsfolk")
    AddRoles(outsiderPool,  outsidersAmount, "outsider")
    AddRoles(minionPool,    minionsAmount,   "minion")
    AddRoles(demonPool,     demonsAmount,    "demon")

    -- Create Demon's bluff pool (not-in-play good roles) -------------------------------------------------------
    JoelBotC.demonBluffsTownsfolkPool = {}
    JoelBotC.demonBluffsOutsiderPool = {}

    table.Add(JoelBotC.demonBluffsTownsfolkPool, townsfolkPool)
    table.Add(JoelBotC.demonBluffsOutsiderPool, outsiderPool)

    -- Remove any roles we don't want to be Demon bluffs here
    table.RemoveByValue(JoelBotC.demonBluffsOutsiderPool, ROLE_RECLUSEJBC)
    table.RemoveByValue(JoelBotC.demonBluffsOutsiderPool, ROLE_DRUNKJBC)
    -- table.RemoveByValue(JoelBotC.demonBluffsPool, ROLE_NIGHTWATCHMANJBC)

    -- Pick which roles should be bluffs - two Townsfolk, one Outsider
    table.Shuffle(JoelBotC.demonBluffsTownsfolkPool)
    table.insert(JoelBotC.demonBluffs, 1, JoelBotC.demonBluffsTownsfolkPool[1])
    table.insert(JoelBotC.demonBluffs, 2, JoelBotC.demonBluffsTownsfolkPool[2])
    table.Shuffle(JoelBotC.demonBluffsOutsiderPool)
    table.insert(JoelBotC.demonBluffs, 3, JoelBotC.demonBluffsOutsiderPool[1])

    -- Try and make one of either the Empath or the Fortune Teller (or any ongoing info role added in the future) a bluff
    local empathAvailableAsBluff = nil
    local fortunetellerAvailableAsBluff = nil
    local empathOrFTAreBluff = nil

    for _, role in ipairs(JoelBotC.demonBluffsTownsfolkPool) do
        if role == ROLE_EMPATHJBC then
            empathAvailableAsBluff = true
        end
        if role == ROLE_FORTUNETELLERJBC  then
            fortunetellerAvailableAsBluff = true
        end
    end

    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- for key, value in ipairs(JoelBotC.demonBluffsTownsfolkPool) do
    --     print(key, ROLE_STRINGS[value])
    -- end
    -- print("Empath avaialable as bluff = ".. tostring(empathAvailableAsBluff))
    -- print("FT avaialable as bluff = ".. tostring(fortunetellerAvailableAsBluff))

    for _, role in ipairs(JoelBotC.demonBluffs) do
        if role == ROLE_EMPATHJBC or role == ROLE_FORTUNETELLERJBC then
            empathOrFTAreBluff = true
        end
    end

    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- for key, value in ipairs(JoelBotC.demonBluffs) do
    --     print(key, ROLE_STRINGS[value])
    -- end
    -- print("Empath or FT are bluff: " .. tostring(empathOrFTAreBluff))

    if not empathOrFTAreBluff then
        local empathFTPool = {}
        table.insert(empathFTPool, ROLE_EMPATHJBC)
        table.insert(empathFTPool, ROLE_FORTUNETELLERJBC)

        -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        -- print("Empath/FT pool pre-remove:")
        -- for key, value in ipairs(empathFTPool) do
        --     print(key, ROLE_STRINGS[value])
        -- end

        for _, role in ipairs(rolePool) do
            if role == ROLE_EMPATHJBC or role == ROLE_FORTUNETELLERJBC then
                table.RemoveByValue(empathFTPool, role)
            end
        end

        -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        -- print("Empath/FT pool post-remove:")
        -- for key, value in ipairs(empathFTPool) do
        --     print(key, ROLE_STRINGS[value])
        -- end
        -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

        if #empathFTPool > 0 then
            -- table.Shuffle(empathFTPool)
            -- Not using table.Shuffle because it didn't actually seem to shuffle
            JoelBotC.demonBluffs[1] = empathFTPool[math.random(1,2)]
        end
    end

    -- for key, value in ipairs(JoelBotC.demonBluffs) do
    --     print(key, ROLE_STRINGS[value])
    -- end

    -- More shufflage
    table.Shuffle(rolePool)

    -- Time to actually assign roles to players!
    for i, ply in ipairs(JoelBotC.players) do
        local entry = rolePool[i]

        -- Reset flags because I forgot this like an idiot and got VERY confused during testing
        ply.townsfolk = nil
        ply.outsider = nil
        ply.minion = nil
        ply.demon = nil
        ply.goodTeam = nil
        ply.evilTeam = nil

        if entry.alignment == "townsfolk" then
            ply.townsfolk = true
            ply.goodTeam = true
        elseif entry.alignment == "outsider" then
            ply.outsider = true
            ply.goodTeam = true
        elseif entry.alignment == "minion" then
            ply.minion = true
            ply.evilTeam = true
        elseif entry.alignment == "demon" then
            ply.demon = true
            ply.evilTeam = true
        end

        ply.botc_role = entry.role
    end

    -- ... and make them that role!
    for _, ply in ipairs(JoelBotC.players) do
        Randomat:SetRole(ply, ply.botc_role)
    end
    SendFullStateUpdate()

    -- Create tables of which players are each character type
    for _, ply in player.Iterator() do
        if IsValid(ply) and not ply:IsSpec() then
            if ply.townsfolk then
                table.insert(JoelBotC.townsfolkPlayers, ply)
            elseif ply.outsider then
                table.insert(JoelBotC.outsiderPlayers, ply)
            elseif ply.minion then
                table.insert(JoelBotC.minionPlayers, ply)
            elseif ply.demon then
                table.insert(JoelBotC.demonPlayers, ply)
            end

            if ply.goodTeam then
                table.insert(JoelBotC.goodPlayers, ply)
            elseif ply.evilTeam then
                table.insert(JoelBotC.evilPlayers, ply)
            end
        end
    end

    -- Tell the Demon their bluffs
    for _, ply in ipairs(JoelBotC.players) do
        if ply.demon then
            timer.Simple(4, function()
                self:SmallNotify(
                    "Your bluffs are " .. ROLE_STRINGS[JoelBotC.demonBluffs[1]] .. ", " .. ROLE_STRINGS[JoelBotC.demonBluffs[2]] .. " and " .. ROLE_STRINGS[JoelBotC.demonBluffs[3]],
                    5,
                    ply
                )
            end)
        end
    end

    -- Create seating order table
    JoelBotC.seatingOrder = table.Copy(JoelBotC.players)

    for i, ply in ipairs(JoelBotC.seatingOrder) do
        PrintMessage(HUD_PRINTTALK, "Seat " .. i .. ": " .. ply:Nick())
        ply.seatNumber = i
    end

    net.Start("rdmtJoelBotCSeatingOrder")
        net.WriteTable(JoelBotC.seatingOrder)
    net.Broadcast()
    JoelBotC:AliveDeadUpdate()

    -- timer.Simple(8, function()
    --     net.Start("rdmtJoelBotCOpenSeatingGUI")
    --     net.Broadcast()
    -- end)

    ----------------------------------------------------------------------------------------------------------------------------
    -- GIVE STARTING BOOKS
    ----------------------------------------------------------------------------------------------------------------------------

    timer.Simple(1, function()
        for _, ply in ipairs(JoelBotC.players) do
            -- Give notebook
            GiveBookQuill(ply)

            ply:Give("weapon_ttt_joelbotc_adminbook")

            -- Prepare seating text segments
            local seatingSegments = {}
                    
            -- "SEATING" title
            table.insert(seatingSegments, {
                text = "SEATING:\n\n",
                color = Color(100,0,200),
                bold = true,
                italic = true,
                underline = true,
                align = "center"
            })
            
            -- Add each player
            for i, ply in ipairs(JoelBotC.seatingOrder) do
                if i < 10 then
                    table.insert(seatingSegments, {
                        text = "Seat " .. i .. ":   " .. ply:Nick() .. "\n",
                        color = Color(0,0,0), -- black text
                        bold = false,
                        italic = false,
                        underline = false,
                        align = "left"
                    })
                else
                    table.insert(seatingSegments, {
                        text = "Seat " .. i .. ": " .. ply:Nick() .. "\n",
                        color = Color(0,0,0), -- black text
                        bold = false,
                        italic = false,
                        underline = false,
                        align = "left"
                    })
                end
            end
            
            -- Give the signed book
            GiveSignedBook(ply, {
                title  = "Your Information",
                author = "The Storyteller",
                pages  = {
                
                    { Segments = seatingSegments },
                
                    -- Next page etc.
                    { Segments = {
                        { text = "Test", bold = true, align = "center" }
                    }}
                
                }
            })

            ply:SelectWeapon("weapon_ttt_signedbook")
        end
    end)

end

function EVENT:End(isActive)
    -- Revert colours to default
    if isActive then
        COLOR_DETECTIVE = table.Copy(original_COLOR_DETECTIVE)
        COLOR_SPECIAL_INNOCENT = table.Copy(original_COLOR_SPECIAL_INNOCENT)
        COLOR_SPECIAL_TRAITOR = table.Copy(original_COLOR_SPECIAL_TRAITOR)
        COLOR_MONSTER = table.Copy(original_COLOR_MONSTER)
    end
    UpdateRoleColours()

    -- Remove books and give crowbar
    for i, ply in pairs(self:GetAlivePlayers()) do
        for _, wep in ipairs(ply:GetWeapons()) do
            if wep:GetClass() == "weapon_ttt_bookquill" or wep:GetClass() == "weapon_ttt_signedbook" or wep:GetClass() == "weapon_ttt_joelbotc_adminbook" then
                ply:StripWeapon(wep:GetClass())
            end
        end

        ply:Give("weapon_zm_improvised")
        ply:SelectWeapon("weapon_zm_improvised")
    end


    -- Revert players to original roles
    if isActive then
        for _, ply in ipairs(JoelBotC.players) do
            if ply.currentRole ~= nil and IsValid(ply) and not ply:IsSpec() then
                Randomat:SetRole(ply, ply.currentRole)
            end
        end
    end
    SendFullStateUpdate()

    -- Remove timers
    if isActive then
        local timerCount = #JoelBotC.players

        for timerNumber = 1, timerCount do
            local timerName = "rdmtJoelBotCMoveBigHand_" .. timerCount
                timer.Remove(timerName)
        end
    end

    -- Revert convars
    if isActive then
        GetConVar("ttt_detectives_hide_special_mode"):SetInt(originalDetectiveCvar)
    end

    --------------------------------------------------------------------------------
    -- Role function stuff
    --------------------------------------------------------------------------------
    -- Monk
    timer.Remove("rdmtJoelBotCMonk10")
    timer.Remove("rdmtJoelBotCMonk5")
    timer.Remove("rdmtJoelBotCMonk4")
    timer.Remove("rdmtJoelBotCMonk3")
    timer.Remove("rdmtJoelBotCMonk2")
    timer.Remove("rdmtJoelBotCMonk1")
    timer.Remove("rdmtJoelBotCMonk0")
    hook.Remove("Think", "rdmtJoelBotcMonkProtect")

    -- Assassin
    timer.Remove("rdmtJoelBotCAssassin10")
    timer.Remove("rdmtJoelBotCAssassin5")
    timer.Remove("rdmtJoelBotCAssassin4")
    timer.Remove("rdmtJoelBotCAssassin3")
    timer.Remove("rdmtJoelBotCAssassin2")
    timer.Remove("rdmtJoelBotCAssassin1")
    timer.Remove("rdmtJoelBotCAssassin0")
    hook.Remove("Think", "rdmtJoelBotcAssassinKill")

end

Randomat:register(EVENT)