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

end

if SERVER then

	hook.Add("TTTEndRound", "JM_End_Reset_CVars", function() JM_Function_ResetAllSettings() end)
	hook.Add("TTTPrepareRound", "JM_Prep_Reset_CVars", function() JM_Function_ResetAllSettings() end)

end


-----------------------------------------------
-- Start of Body Discovered Code (Message on bodies found)
-----------------------------------------------

function JM_Function_BodyDiscovered(finder, plyDiscovered)

	if CLIENT then return end

	local A = finder
	local B = plyDiscovered:Nick()
	local C = plyDiscovered:GetRoleStringRaw()

	net.Start("JM_Net_BodyDiscovered")
	net.WriteString(tostring(A))
	net.WriteString(tostring(B))
	net.WriteString(tostring(C))
	net.Broadcast()

end

-- The Code that runs on the Client's PC
if CLIENT then
	net.Receive("JM_Net_BodyDiscovered", function(_) 
			
		plyFinder = net.ReadString()
		plyDiscoveredName = net.ReadString()
		plyDiscoveredRole = net.ReadString()

		surface.PlaySound("effect_discoverbody.mp3")

		local textPrefixColour =  Color( 20, 20, 20 )
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
			textBodyColour =  Color( 0, 0, 255)
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

	-- JM Changes Extra Hit Marker
	net.Start( "JM_Net_HitMarker" )
	net.WriteFloat(damageDealtToTarget)
	net.WriteBool(didThisDamageKillTarget)
	net.Send(playerRecievingHitMarker)
	-- End Of

end