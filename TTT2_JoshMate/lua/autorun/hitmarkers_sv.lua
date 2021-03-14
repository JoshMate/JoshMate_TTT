if CLIENT then return end

AddCSLuaFile( "autorun/hitmarkers_cl.lua" )
resource.AddFile( "sound/hitmarkers/hitmarker.ogg" )
resource.AddFile( "materials/hitmarkers/hitmarker.png" )

util.AddNetworkString( "hitmarker" )

hook.Add( "EntityTakeDamage", "hitmarkers", function( tar, info )

	if not tar:IsPlayer() and not tar:IsNPC() then return end
	local att = info:GetAttacker() 

	-- The Player Route
	if att:IsPlayer() then
		net.Start( "hitmarker" )
		net.WriteFloat(info:GetDamage())
		net.Send( att )
		return
	end

	-- The NPC Route
	if not att:IsPlayer() then
		if att:GetNWEntity("giveHitMarkersTo") == nil then return end
		if not IsValid(att:GetNWEntity("giveHitMarkersTo")) then return end
		net.Start( "hitmarker" )
		net.WriteFloat(info:GetDamage())
		net.Send( att:GetNWEntity("giveHitMarkersTo") )
		return
	end

end )
