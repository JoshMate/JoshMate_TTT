if SERVER then return end

local mat_hitmarker = Material( "hitmarkers/hitmarker.png" )
local snd_hitmarker = Sound( "hitmarkers/hitmarker.ogg" )

local Hitmarkers_time				= 0.5
local HitMarker_Size				= 128
local HitMarker_CritThreshold		= 50

local stacker_time			= 1
local stacker_time_last		= 0
local stacker_amount 		= 0

local last_time = 0
local damage = 0

net.Receive( "hitmarker", function()
	surface.PlaySound( snd_hitmarker )
	last_time = (CurTime() + Hitmarkers_time)
	stacker_time_last = (CurTime() + stacker_time)
	damage = net.ReadFloat()
	stacker_amount = math.floor(stacker_amount + damage)
end )

hook.Add( "HUDPaint", "hitmarkers", function()

	local size = math.max( HitMarker_Size, 0 )	

	if stacker_time_last < CurTime() then
		stacker_amount = 0
	end
	if stacker_amount > 0 then

		surface.SetTextColor( 255, 255, 255, ( stacker_time_last - CurTime() ) * 255  )
		
		if stacker_amount >= 50 then 
			surface.SetTextColor( 255, 255, 0, ( stacker_time_last - CurTime() ) * 255  )
		end
		if stacker_amount >= 75 then 
			surface.SetTextColor( 255, 150, 0, ( stacker_time_last - CurTime() ) * 255  )
		end
		if stacker_amount >= 100 then 
			surface.SetTextColor( 255, 0, 0, ( stacker_time_last - CurTime() ) * 255  )
		end
		
		surface.SetFont( "DermaLarge" )
		surface.SetTextPos( (ScrW()/2) + (size/2), (ScrH()/2) - (size/2)) 
		surface.DrawText( tostring(stacker_amount))
	end
	-- Hit Markers
	if last_time < CurTime() then return end

	if damage >= HitMarker_CritThreshold then
		surface.SetDrawColor( 255, 0, 0, ( last_time - CurTime() ) * 255 )
		
	else
		surface.SetDrawColor( 255, 255, 255, ( last_time - CurTime() ) * 255 )
	end

	surface.SetMaterial( mat_hitmarker )
	surface.DrawTexturedRect(
		ScrW() / 2 - size / 2, ScrH() / 2 - size / 2,
		size, size )
end)

