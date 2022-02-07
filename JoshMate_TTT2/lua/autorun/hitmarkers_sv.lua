if CLIENT then return end

AddCSLuaFile( "autorun/hitmarkers_cl.lua" )
resource.AddFile( "sound/hitmarkers/hitmarker.ogg" )
resource.AddFile( "materials/hitmarkers/hitmarker.png" )

util.AddNetworkString( "hitmarker" )

hook.Add( "EntityTakeDamage", "hitmarkers", function( tar, info )

	if not tar:IsPlayer() and not tar:IsNPC() then return end
	local att = info:GetAttacker() 

	local finDMG = 0
	local didThisKill = false

	if att:IsPlayer() and engine.ActiveGamemode() == "terrortown" then 
		finDMG = info:GetDamage() * att:GetDamageFactor()
		if finDMG >= tar:Health() then 
			finDMG = tar:Health()
			didThisKill = true
		end
	else
		finDMG = info:GetDamage()
		if finDMG >= tar:Health() then 
			finDMG = tar:Health() 
			didThisKill = true
		end
	end


	-- The Player Route
	if att:IsPlayer() then
		net.Start( "hitmarker" )
		net.WriteFloat(finDMG) 
		net.WriteBool(didThisKill)
		net.Send( att )
		return
	end

	-- The NPC Route
	if not att:IsPlayer() then
		if att:GetNWEntity("giveHitMarkersTo") == nil then return end
		if not IsValid(att:GetNWEntity("giveHitMarkersTo")) then return end
		finDMG = info:GetDamage()
		if finDMG >= tar:Health() then finDMG = tar:Health() end
		net.Start( "hitmarker" )
		net.WriteFloat(finDMG)
		net.WriteBool(didThisKill)
		net.Send( att:GetNWEntity("giveHitMarkersTo") )
		return
	end

end )
