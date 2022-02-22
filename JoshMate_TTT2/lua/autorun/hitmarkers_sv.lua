if CLIENT then return end

AddCSLuaFile( "autorun/hitmarkers_cl.lua" )
resource.AddFile( "sound/hitmarkers/hitmarker.ogg" )
resource.AddFile( "materials/hitmarkers/hitmarker.png" )

util.AddNetworkString( "hitmarker" )

hook.Add( "PostEntityTakeDamage", "hitmarkers", function( tar, info, isTaken )

	if not tar:IsPlayer() and not tar:IsNPC() then return end
	local att = info:GetAttacker() 

	local finDMG = 0
	local didThisKill = false

	finDMG = info:GetDamage()

	finDMG = math.Clamp(finDMG, 0, tar:GetMaxHealth())

	if tar:Health() <= 0 then
		didThisKill = true
	end

	if isTaken == false then
		finDMG = 0
		didThisKill = false
	end

	
	-- The NPC Route
	if not att:IsPlayer() then
		if att:GetNWEntity("giveHitMarkersTo") == nil then return end
		if not IsValid(att:GetNWEntity("giveHitMarkersTo")) then return end

		net.Start( "hitmarker" )
		net.WriteFloat(finDMG)
		net.WriteBool(didThisKill)
		net.Send( att:GetNWEntity("giveHitMarkersTo") )
		return
	else

		-- Send Hit Markers to Players
		net.Start( "hitmarker" )
		net.WriteFloat(finDMG) 
		net.WriteBool(didThisKill)
		net.Send( att )

	end


	

	

end)
