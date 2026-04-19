JoelBotC = JoelBotC or {}

JoelBotC.players = JoelBotC.players or {}
JoelBotC.isAlive = JoelBotC.isAlive or {}
JoelBotC.recentExecutee = JoelBotC.recentExecutee or nil
JoelBotC.deadPlayers = JoelBotC.deadPlayers or {}

if SERVER then
    
    function JoelBotC:Revive(ply)
        ply.BotCDead = false
        JoelBotC.isAlive[ply] = true

        JoelBotC:AliveDeadUpdate()
    end
    
    -- Tell clients who's dead and who's alive
    function JoelBotC:AliveDeadUpdate()
        net.Start("rdmtJoelBotCAliveDeadUpdate")
            net.WriteTable(JoelBotC.isAlive)
        net.Broadcast()
    end

    -- Non-execution kill (WIP)
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

    -- Execution kill (anvil go bonk)
    function JoelBotC:Execute(ply)
        if not IsValid(ply) or not ply:Alive() then return end

        JoelBotC.recentExecutee = ply

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

end