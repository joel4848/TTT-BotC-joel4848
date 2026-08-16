JoelBotC = JoelBotC or {}

JoelBotC.players = JoelBotC.players or {}
JoelBotC.isAlive = JoelBotC.isAlive or {}
JoelBotC.recentExecutee = JoelBotC.recentExecutee or nil
JoelBotC.deadPlayers = JoelBotC.deadPlayers or {}
JoelBotC.morningDeaths = JoelBotC.morningDeaths or {}
JoelBotC.ghostVotes = JoelBotC.ghostVotes or {}
JoelBotC.saintExecuted = JoelBotC.saintExecuted or nil

if SERVER then
    util.AddNetworkString("rdmtJoelBotCRequestBoneData")
    util.AddNetworkString("rdmtJoelBotCBSendBoneData")

    util.AddNetworkString("rdmtJoelBotCAliveDeadUpdate")
    util.AddNetworkString("rdmtJoelBotCGhostVoteUpdate")

    function JoelBotC:AlivePlayerCount()
        local alivePlayerCount = 0
        for _, ply in ipairs(JoelBotC.players) do
            if not ply.BotCDead then
                alivePlayerCount = alivePlayerCount + 1
            end
        end

        return alivePlayerCount
    end

    -- Tell clients who's dead and who's alive
    function JoelBotC:AliveDeadUpdate()
        JoelBotC:DetermineGhostVotes()

        net.Start("rdmtJoelBotCAliveDeadUpdate")
            net.WriteTable(JoelBotC.isAlive)
        net.Broadcast()

        for _, ply in ipairs(JoelBotC.players) do
            JoelBotC:RebuildInfoBook(ply)
        end
    end

    function JoelBotC:Revive(ply)
        ply.BotCDead = false
        JoelBotC.isAlive[ply] = true

        JoelBotC:AliveDeadUpdate()
    end

    -- 'Kill' during the night (disable their ability but don't run the kill animation yet)
    function JoelBotC:NightPreKill(target, killer)
        if not killer:IsRole(ROLE_ASSASSINJBC) then
            if JoelBotC.monkProtectedPlayer == target and JoelBotC:IsRoleBotCAlive(ROLE_MONKJBC) and not JoelBotC:IsDroisoned(JoelBotC.monkPlayer) then
                return
            end
            if target:IsSoldier() and not JoelBotC:IsDroisoned(target) then
                return
            end
        end

        if target.demon and JoelBotC:AlivePlayerCount() >= 5 then
            JoelBotC:MakeScarletWomanDemon(target.botc_role)
        end

        if killer.demon and target:IsRavenkeeper() and not target.BotCDead then
            JoelBotC.ravenkeeperKilledByDemon = true
        end

        if target == JoelBotC.grandchild and not target.BotCDead and JoelBotC.grandmother.BotCDead then
            JoelBotC.grandmother.BotCDead = true
            table.insert(JoelBotC.morningDeaths, JoelBotC.grandmother)
        end

        if target:IsSweetheart() and not target.BotCDead and not JoelBotC:IsDroisoned(target) then
            JoelBotC:SweetheartDeath(target)
        end

        if not target.BotCDead then
            table.insert(JoelBotC.morningDeaths, target)
        end

        target.BotCDead = true
    end

    function JoelBotC:MorningDeaths()
        -- Announce who died in the night
        local names = {}
        for _, ply in ipairs(JoelBotC.morningDeaths) do
            table.insert(names, ply:Nick())
        end

        -- Over-complicate things because I don't like the Oxford comma
        local count = #names
        local announcementMessage = ""

        if JoelBotC.currentNight ~= 1 then
            if count == 0 then
                announcementMessage = "No one died in the night"
            elseif count == 1 then
                announcementMessage = "Last night, " .. names[1] .. " died"
            elseif count == 2 then
                announcementMessage = "Last night, " .. names[1] .. " and " .. names[2] .. " died"
            else
                local namesPart = table.concat(names, ", ", 1, count - 1)
                announcementMessage = "Last night, " .. namesPart .. " and " .. names[count] .. " died"
            end

            Randomat:SmallNotify(announcementMessage, 5)
        end

        -- Now kill them!
        for _, ply in ipairs(JoelBotC.morningDeaths) do
            JoelBotC:Kill(ply)
        end

        JoelBotC.morningDeaths = {}
        names = {}

        timer.Create("rdmtJoelBotCStartDiscussionDelay", 5, 1, function()
            JoelBotC.isCurrentlyNight = false
            timer.Create("rdmtJoelBotCStartDiscussionsAfterMorningDeaths", 0.5, 1, function()
                JoelBotC:StartDiscussion()
            end)
        end)
    end

    --------------------------------------------------------------------------
    -- Kill and body-creation bits
    --------------------------------------------------------------------------
    local function CreateBody(ply, plyPos, plyAng, boneTable)
        if not IsValid(ply) then return end

        local rag = ents.Create("prop_ragdoll")
        if not IsValid(rag) then return end

        rag:SetModel(ply:GetModel())
        rag:SetPos(plyPos or ply:GetPos())
        rag:SetAngles(plyAng or ply:GetAngles())
        rag:SetSkin(ply:GetSkin())
        rag:SetColor(ply:GetColor())
        rag:SetMaterial(ply:GetMaterial())

        for _, value in pairs(ply:GetBodyGroups()) do
            rag:SetBodygroup(value.id, ply:GetBodygroup(value.id))
        end

        rag:Spawn()
        rag:Activate()
        rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        -- Map client bone positions onto the ragdoll
        if boneTable and #boneTable > 0 then
            local boneMap = {}
            for _, boneData in ipairs(boneTable) do
                boneMap[boneData.id] = boneData
            end

            local numPhys = rag:GetPhysicsObjectCount() - 1
            local playerVel = ply:GetVelocity()

            for i = 0, numPhys do
                local phys = rag:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    local modelBone = rag:TranslatePhysBoneToBone(i)
                    local data = boneMap[modelBone]

                    if data then
                        phys:SetPos(data.pos)
                        phys:SetAngles(data.ang)
                        phys:SetVelocity(playerVel)
                    end
                end
            end
        end

        -------------- Corpse-searching stuff --------------
        if CORPSE then
            CORPSE.SetPlayerNick(rag, ply)
            CORPSE.SetFound(rag, true)
        end
        ply:SetNWBool("body_found", true)

        rag.sid64          = ply:SteamID64()
        rag.sid            = ply:SteamID()
        rag.player_ragdoll = true
        rag.time           = CurTime()
        rag.was_role       = ply.botc_role or ply:GetRole()
        rag.kills          = table.Copy(ply.kills)
        rag.is_botc_body   = true
        ----------------------------------------------------

        return rag
    end

    -- Receive correct body position from client
    net.Receive("rdmtJoelBotCBSendBoneData", function(len, sender)
        local plyPos = net.ReadVector()
        local plyAng = net.ReadAngle()
        local boneTable = net.ReadTable()

        if not IsValid(sender) then return end

        -- Create body in correct position
        CreateBody(sender, plyPos, plyAng, boneTable)
    end)

    function JoelBotC:Kill(ply)
        if not IsValid(ply) then return end

        if ply.demon and JoelBotC:AlivePlayerCount() >= 5 then
            JoelBotC:MakeScarletWomanDemon(ply.botc_role)
        end

        if ply:IsSweetheart() and not ply.BotCDead and not JoelBotC:IsDroisoned(ply) then
            JoelBotC:SweetheartDeath(ply)
        end

        if not ply.BotCDead then
            ply.hasGhostVote = true
        end

        ply.BotCDead = true
        JoelBotC.isAlive[ply] = false

        timer.Simple(0, function()
            ply:DoAnimationEvent(ACT_GMOD_DEATH, 2028)

            local seq = ply:SelectWeightedSequence(ACT_GMOD_DEATH)
            local seqDuration = ply:SequenceDuration(seq)
            local animationLength = 1

            if seqDuration > 0.9 then
                animationLength = 0.9
            elseif seq and seq ~= -1 then
                animationLength = ply:SequenceDuration(seq) - 0.1
            end

            -- Request bone data from the client near the end of the animation
            timer.Create("JoelBotC_RagdollWait_" .. ply:SteamID64(), animationLength, 1, function()
                if not IsValid(ply) then return end

                net.Start("rdmtJoelBotCRequestBoneData")
                    net.WriteBool(false)
                net.Send(ply)

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

    -- Execution kill (anvil go bonk)
    function JoelBotC:Execute(ply)
        local saintExecuted = false

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

        net.Start("rdmtJoelBotCRequestBoneData")
            net.WriteBool(true)
        net.Send(ply)

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

            if ply.demon and JoelBotC:AlivePlayerCount() >= 5 then
                JoelBotC:MakeScarletWomanDemon(ply.botc_role)
            end

            if ply:IsRole(ROLE_SAINTJBC) and ply.BotCDead ~= true and not JoelBotC:IsDroisoned(ply) then
                saintExecuted = true
            end

            if ply:IsSweetheart() and not ply.BotCDead and not JoelBotC:IsDroisoned(ply) then
                JoelBotC:SweetheartDeath(ply)
            end

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

            if CORPSE then
                CORPSE.SetPlayerNick(rag, ply)
                CORPSE.SetFound(rag, true)
            end
            ply:SetNWBool("body_found", true)

            rag.sid64          = ply:SteamID64()
            rag.sid            = ply:SteamID()
            rag.player_ragdoll = true
            rag.time           = CurTime()
            rag.was_role       = ply.botc_role or ply:GetRole()
            rag.kills          = table.Copy(ply.kills)
            rag.is_botc_body   = true

            -- Bonk the ragdoll into the ground like it got squished
            for i = 0, rag:GetPhysicsObjectCount() - 1 do
                local ragPhys = rag:GetPhysicsObjectNum(i)
                if IsValid(ragPhys) then
                    ragPhys:ApplyForceCenter(Vector(0, 0, -50000))
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

                if saintExecuted then JoelBotC.saintExecuted = true end
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

if CLIENT then
    local function LookUp()
        local ply = LocalPlayer()
        local eyeAngles = ply:EyeAngles()
        eyeAngles.x = -180

        ply:SetEyeAngles(eyeAngles)
    end

    net.Receive("rdmtJoelBotCRequestBoneData", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local isExecution = net.ReadBool()

        if isExecution then
            LookUp()
        else
            ply:SetupBones()

            local boneTable = {}
            local count = ply:GetBoneCount() or 0

            for i = 0, count - 1 do
                local pos, ang = ply:GetBonePosition(i)
                if pos and ang then
                    table.insert(boneTable, {
                        id = i,
                        pos = pos,
                        ang = ang
                    })
                end
            end

            net.Start("rdmtJoelBotCBSendBoneData")
                net.WriteVector(ply:GetPos())
                net.WriteAngle(ply:GetAngles())
                net.WriteTable(boneTable)
            net.SendToServer()
        end
    end)
end