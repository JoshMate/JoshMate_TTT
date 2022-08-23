if SERVER then return end

local mat_hitmarker = Material( "hitmarkers/hitmarker.png" )
local snd_hitmarker = Sound( "hitmarkers/hitmarker.ogg" )

local mat_killskull = Material( "hitmarkers/skullmarker.png" )
local snd_killskull = Sound( "hitmarkers/skullmarker.mp3" )

local Hitmarkers_time				= 0.5
local HitMarker_Size				= 128
local HitMarker_Size_Skull			= 32

local stacker_time			= 2.5
local stacker_time_last		= 0
local stacker_amount 		= 0
local stacker_colourOffSet  = 0

local last_time = 0
local damage = 0
local wasKill = false
local wasKillCount = 0

net.Receive( "JM_Net_HitMarker", function()
	surface.PlaySound( snd_hitmarker )
	last_time = (CurTime() + Hitmarkers_time)
	stacker_time_last = (CurTime() + stacker_time)
	damage = net.ReadFloat()
	wasKill = net.ReadBool()
	stacker_amount = math.floor(stacker_amount + damage)
	if wasKill == true then 
		wasKillCount = wasKillCount + 1 
		surface.PlaySound( snd_killskull )
	end
end )

hook.Add( "HUDPaint", "hitmarkers", function()

	local size = math.max( HitMarker_Size, 0 )	

	if stacker_time_last < CurTime() then
		stacker_amount = 0
		wasKillCount = 0
	end
	if stacker_amount > 0 then

		surface.SetTextColor( 255, 255, 255, ( stacker_time_last - CurTime() ) * 255  )

		surface.SetFont( "DermaLarge" )
		surface.SetTextPos( (ScrW()/2) + (size/2), (ScrH()/2) - (size/2)) 
		surface.DrawText( tostring(stacker_amount))

		-- Kill Skulls
		for i=1,wasKillCount do 
			surface.SetDrawColor( 255, 255, 255, ( stacker_time_last - CurTime() ) * 255  )
			surface.SetMaterial( mat_killskull )
			surface.DrawTexturedRect((ScrW()/2) + 32 + (HitMarker_Size_Skull*i), (ScrH()/2) - (HitMarker_Size_Skull) ,HitMarker_Size_Skull, HitMarker_Size_Skull )
		end 
	end


	-- Hit Markers
	if last_time < CurTime() then return end

	if wasKill == true then
		surface.SetDrawColor( 255, 0, 0, ( last_time - CurTime() ) * 255 )	
	else
		if damage > 0 then 
			surface.SetDrawColor( 255, 255, 255, ( last_time - CurTime() ) * 255 )
		else
			surface.SetDrawColor( 0, 255, 80, ( last_time - CurTime() ) * 255 )
		end
	end
	surface.SetMaterial( mat_hitmarker )
	surface.DrawTexturedRect(ScrW() / 2 - size / 2, ScrH() / 2 - size / 2,size, size )

end)

