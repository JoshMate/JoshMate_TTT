-- Give these files out
AddCSLuaFile()

-- Function To Reset Everything
function JM_ResetAllSettings()

	RunConsoleCommand("sv_gravity", 600)
	RunConsoleCommand("sv_friction", 8)
	RunConsoleCommand("sv_airaccelerate", 10)
	RunConsoleCommand("sv_accelerate", 10)

	-- Slow Mo Clock
	if timer.Exists("Timer_SloMo_Clock") then timer.Destroy("Timer_SloMo_Clock") end
	game.SetTimeScale(1)

end

--- Josh Mate Reset Gravity Etc...
if SERVER then

	hook.Add("TTTEndRound", "JM_End_Reset_CVars", function() JM_ResetAllSettings() end)
	hook.Add("TTTPrepareRound", "JM_Prep_Reset_CVars", function() JM_ResetAllSettings() end)

end
