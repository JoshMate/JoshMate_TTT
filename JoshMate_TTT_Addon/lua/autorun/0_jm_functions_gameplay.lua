-- Give these files out to clients (As they contain Client Code)
AddCSLuaFile()

-----------------------------------------------
--  Register Network Strings
-----------------------------------------------

-- Register the Network strings on both Server for later calling
if SERVER then
	util.AddNetworkString("JM_Net_BodyDiscovered")
end

-----------------------------------------------
--  Reset Server Settings (Things like gravity)
-----------------------------------------------

function JM_Function_ResetAllSettings()

	RunConsoleCommand("sv_gravity", 600)
	RunConsoleCommand("sv_friction", 8)
	RunConsoleCommand("sv_airaccelerate", 10)
	RunConsoleCommand("sv_accelerate", 10)

	-- Slow Mo Clock
	if timer.Exists("Timer_SloMo_Clock") then timer.Destroy("Timer_SloMo_Clock") end
	game.SetTimeScale(1)

	JM_Function_ResetPlayerSettings()

end

function JM_Function_ResetPlayerSettings()
	-- Set all players Vars
	local plys = player.GetAll()
	for i = 1, #plys do
		local ply = plys[i]
		if (ply:IsValid()) then
			ply:SetCanZoom(false)
			ply:SetJumpPower(180)
			ply:SetCrouchedWalkSpeed(0.3)
			ply:SetRunSpeed(220)
			ply:SetWalkSpeed(220)
			ply:SetMaxSpeed(220)
		    ply:SetModelScale(1, 1)
			ply:SetViewOffset(Vector(0, 0, 64 * 1 ))
			ply:SetViewOffsetDucked(Vector(0, 0, 64 * 1  / 2))
		end
	end	
end

if SERVER then
	hook.Add("TTTEndRound", "JM_End_Reset_CVars", function() JM_Function_ResetAllSettings() end)
	hook.Add("TTTPrepareRound", "JM_Prep_Reset_CVars", function() JM_Function_ResetAllSettings() end)
	hook.Add("TTTBeginRound", "JM_Begin_Reset_CVars", function() JM_Function_ResetPlayerSettings() end)
end


-----------------------------------------------
-- Start of Body Discovered Code (Message on bodies found)
-----------------------------------------------

function JM_Function_BodyDiscovered(plyFinder, plyDiscovered)

	if CLIENT then return end

	local A = plyFinder:Nick()
	local B = plyDiscovered:Nick()
	local C = plyDiscovered:GetRoleStringRaw()

	net.Start("JM_Net_BodyDiscovered")
	net.WriteString(tostring(A))
	net.WriteString(tostring(B))
	net.WriteString(tostring(C))
	net.Broadcast()

	JM_Function_Karma_Reward(plyFinder, JM_KARMA_REWARD_ACTION_FINDBODY, "Body found")
	if plyDiscovered:IsTraitor() then JM_Function_Karma_Reward(plyFinder, JM_KARMA_REWARD_ACTION_FINDBODYTRAITORBONUS, "Traitory Body found") end

end

-- The Code that runs on the Client's PC
if CLIENT then
	net.Receive("JM_Net_BodyDiscovered", function(_) 
			
		plyFinder = net.ReadString()
		plyDiscoveredName = net.ReadString()
		plyDiscoveredRole = net.ReadString()

		surface.PlaySound("effect_discoverbody.mp3")

		local textPrefixColour =  Color( 50, 50, 50 )
		local textBodyColour =  Color( 255, 255, 255 )
		local textFinalRoleName = "ERROR"

		if plyDiscoveredRole == "innocent" then
			textBodyColour =  Color( 0, 255, 0 )
			textFinalRoleName = "Innocent"
		end

		if plyDiscoveredRole == "traitor" then
			textBodyColour =  Color( 255, 0, 0 )
			textFinalRoleName = "Traitor"
		end

		if plyDiscoveredRole == "detective" then
			textBodyColour =  Color( 0, 150, 255)
			textFinalRoleName = "Detective"
		end

	
		chat.AddText( textPrefixColour, "[Dead Body] ", Color( 255, 255, 255 ), tostring(plyFinder), " found: ", tostring(plyDiscoveredName), textBodyColour, " [", tostring(textFinalRoleName),"]")
		
	end)
end

-----------------------------------------------
-- Send Hit Marker (Gives Hitmarker to Player)
-----------------------------------------------

function JM_Function_GiveHitMarkerToPlayer(playerRecievingHitMarker, damageDealtToTarget, didThisDamageKillTarget)

	if CLIENT then return end

	if playerRecievingHitMarker == nil or not playerRecievingHitMarker:IsPlayer() then return end

	-- JM Changes Extra Hit Marker
	net.Start( "JM_Net_HitMarker" )
	net.WriteFloat(damageDealtToTarget)
	net.WriteBool(didThisDamageKillTarget)
	net.Send(playerRecievingHitMarker)
	-- End Of

end


-----------------------------------------------
-- Spawn ents randomly (Uses Care Package and Player Spawns)
-----------------------------------------------

function JM_Function_SpawnThisThingInRandomPlaces(thingToSpawn, numberOfTimes)

    local NumberToSpawn = numberOfTimes
    local possibleSpawns = ents.FindByClass( "ent_jm_carepackage_spawn" )
    local possibleSpawnsPlayer = ents.FindByClass( "info_player_start" )
	local listOfAllSpawnedItems = {}
    
    for i=1,NumberToSpawn do 

        local randomChoice = math.random( 0, 100 )

        -- 5% chance to use a player spawn
        if randomChoice > 5 then

            if #possibleSpawns > 0 then
                local randomChoice = math.random(1, #possibleSpawns)
                local spawn = possibleSpawns[randomChoice]
                table.remove( possibleSpawns, randomChoice )
                
                local ent = ents.Create(thingToSpawn)
                ent:SetPos(spawn:GetPos() + Vector(0, 0, 14))
                ent:Spawn()  
                ent.gmEntIndex = i
				table.insert( listOfAllSpawnedItems, ent)
            else

                if #possibleSpawnsPlayer > 0 then
                    local randomChoice = math.random(1, #possibleSpawnsPlayer)
                    local spawn = possibleSpawnsPlayer[randomChoice]
                    table.remove( possibleSpawnsPlayer, randomChoice )
                    
                    local ent = ents.Create(thingToSpawn)
                    ent:SetPos(spawn:GetPos() + Vector(0, 0, 6))
                    ent:Spawn()  
                    ent.gmEntIndex = i
					table.insert( listOfAllSpawnedItems, ent)
                end

            end

        else

            if #possibleSpawnsPlayer > 0 then
                local randomChoice = math.random(1, #possibleSpawnsPlayer)
                local spawn = possibleSpawnsPlayer[randomChoice]
                table.remove( possibleSpawnsPlayer, randomChoice )
                
                local ent = ents.Create(thingToSpawn)
                ent:SetPos(spawn:GetPos() + Vector(0, 0, 6))
                ent:Spawn()  
                ent.gmEntIndex = i
				table.insert( listOfAllSpawnedItems, ent)
            end

        end
        
    end

	return listOfAllSpawnedItems

end

-----------------------------------------------
-- Spawn ents randomly with a given model (Uses Care Package and Player Spawns)
-----------------------------------------------

function JM_Function_SpawnThisThingInRandomPlacesWithAModel(modelName, numberOfTimes)

    local NumberToSpawn = numberOfTimes
    local possibleSpawns = ents.FindByClass( "ent_jm_carepackage_spawn" )
    local possibleSpawnsPlayer = ents.FindByClass( "info_player_start" )
	local listOfAllSpawnedItems = {}
    
    for i=1,NumberToSpawn do 

        local randomChoice = math.random( 0, 100 )

        -- 5% chance to use a player spawn
        if randomChoice > 5 then

            if #possibleSpawns > 0 then
                local randomChoice = math.random(1, #possibleSpawns)
                local spawn = possibleSpawns[randomChoice]
                table.remove( possibleSpawns, randomChoice )
                
                local ent = ents.Create("prop_physics")
				ent:SetModel(modelName)
				ent:PhysicsInit(SOLID_VPHYSICS)
				ent:SetMoveType(MOVETYPE_VPHYSICS)
				ent:SetSolid(SOLID_VPHYSICS)
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                ent:SetPos(spawn:GetPos() + Vector(0, 0, 14))
                ent:Spawn()
				local entPhysics = ent:GetPhysicsObject()
				if entPhysics:IsValid() then
					entPhysics:Wake()
				end  
                ent.gmEntIndex = i
				table.insert( listOfAllSpawnedItems, ent)
            else

                if #possibleSpawnsPlayer > 0 then
                    local randomChoice = math.random(1, #possibleSpawnsPlayer)
                    local spawn = possibleSpawnsPlayer[randomChoice]
                    table.remove( possibleSpawnsPlayer, randomChoice )
                    
                    local ent = ents.Create("prop_physics")
                    ent:SetModel(modelName)
					ent:PhysicsInit(SOLID_VPHYSICS)
					ent:SetMoveType(MOVETYPE_VPHYSICS)
					ent:SetSolid(SOLID_VPHYSICS)
					ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					ent:SetPos(spawn:GetPos() + Vector(0, 0, 14))
					ent:Spawn()
					local entPhysics = ent:GetPhysicsObject()
					if entPhysics:IsValid() then
						entPhysics:Wake()
					end    
                    ent.gmEntIndex = i
					table.insert( listOfAllSpawnedItems, ent)
                end

            end

        else

            if #possibleSpawnsPlayer > 0 then
                local randomChoice = math.random(1, #possibleSpawnsPlayer)
                local spawn = possibleSpawnsPlayer[randomChoice]
                table.remove( possibleSpawnsPlayer, randomChoice )
                
                local ent = ents.Create("prop_physics")
				ent:SetModel(modelName)
				ent:PhysicsInit(SOLID_VPHYSICS)
				ent:SetMoveType(MOVETYPE_VPHYSICS)
				ent:SetSolid(SOLID_VPHYSICS)
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				ent:SetPos(spawn:GetPos() + Vector(0, 0, 14))
				ent:Spawn()
				local entPhysics = ent:GetPhysicsObject()
				if entPhysics:IsValid() then
					entPhysics:Wake()
				end 
                ent.gmEntIndex = i
				table.insert( listOfAllSpawnedItems, ent)
            end

        end
        
    end

	return listOfAllSpawnedItems

end

-----------------------------------------------
-- Teleport player to a random Spot (Uses Care Package and Player Spawns)
-----------------------------------------------

function JM_Function_TeleportPlayerToARandomPlace(Player)

    local possibleSpawns = ents.FindByClass( "ent_jm_carepackage_spawn" )
    local possibleSpawnsPlayer = ents.FindByClass( "info_player_start" )
	local listOfAllSpawnedItems = {}
    
	local randomChoice = math.random( 0, 100 )

	-- 5% chance to use a player spawn
	if randomChoice > 5 then

		if #possibleSpawns > 0 then
			local randomChoice = math.random(1, #possibleSpawns)
			local spawn = possibleSpawns[randomChoice]
			table.remove( possibleSpawns, randomChoice )
			Player:SetPos(spawn:GetPos() + Vector(0, 0, 8))
			return spawn:GetPos()
		else

			if #possibleSpawnsPlayer > 0 then
				local randomChoice = math.random(1, #possibleSpawnsPlayer)
				local spawn = possibleSpawnsPlayer[randomChoice]
				Player:SetPos(spawn:GetPos() + Vector(0, 0, 8))
				return spawn:GetPos()
			end

		end

	else

		if #possibleSpawnsPlayer > 0 then
			local randomChoice = math.random(1, #possibleSpawnsPlayer)
			local spawn = possibleSpawnsPlayer[randomChoice]
			Player:SetPos(spawn:GetPos() + Vector(0, 0, 8))
			return spawn:GetPos()
		end

	end

	

end

-- ##############################################
-- Josh Mate New Warning Icon Code
-- ##############################################

function JM_Function_SendHUDWarning(isEnabled, entIndex, strIconPath, vecEntPos, timeExpire, whoCanSee)

	

	if SERVER then
		-- Start the Network Message Process
		net.Start("JM_NET_CustomHudWarning") 

		-- Send the current status of this ent
		net.WriteBool(isEnabled)

		-- Send this ents ID
		net.WriteUInt(entIndex, 16)

		-- If disabled, don't bother sending all this too
		if isEnabled then

			-- send the string path of the icon to use
			net.WriteString(strIconPath)
			-- send the vector to use for distance calcs
			net.WriteVector(vecEntPos)
			-- Send a timestamp in which the Icon will count down to (C4 Timer etc..) (0 for no timer)
			net.WriteFloat(timeExpire)
			-- send the string to display next to icon
			-- whoCanSee 0 = everyone 1 = Traitors 2 = Detectives
			net.WriteInt(whoCanSee, 8)
			
		end

		-- Finalise and send the message
		net.Broadcast()
		
	end
end

-- ##############################################
-- Josh Mate Add Round
-- ##############################################

function JM_Function_AddRounds(roundsToAdd) 
	if CLIENT then return end
	local curRounds = GetGlobalInt("ttt_rounds_left", 6)
	curRounds = curRounds + roundsToAdd
	SetGlobalInt("ttt_rounds_left",curRounds)
	GAMEMODE:SyncGlobals()
end

-- ##############################################
-- Josh Mate Remove Round
-- ##############################################

function JM_Function_RemoveRounds(roundsToRemove) 
	if CLIENT then return end
	local curRounds = GetGlobalInt("ttt_rounds_left", 6)
	curRounds = curRounds - roundsToRemove
	SetGlobalInt("ttt_rounds_left",curRounds)
	GAMEMODE:SyncGlobals()
end