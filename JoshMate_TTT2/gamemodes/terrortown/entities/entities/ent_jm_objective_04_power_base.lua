AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Power"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

ENT.BatteryNumberLeft	= 6

if CLIENT then return end

function ENT:JM_GameMode_ProtectTheFiles_Start()

	-- Validation Checks
	if CLIENT then return end
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end
	
	-- Number of Files to Spawn
	local NumberOfThingsToSpawn = 1

	-- Announce the Goal
	JM_Function_Announcement("[Powerup] Innocents must capture all the batteries to win!", 0)

	-- Play the Sound
    JM_Function_PlaySound("gamemode/power_start.mp3")

	-- Spawn the Objective Ents
    local newBatteryList =  JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_04_power_ent", NumberOfThingsToSpawn)
	newBatteryList[1].batteryMaster = self


end

function ENT:Initialize()

	self:JM_GameMode_ProtectTheFiles_Start()

end

function ENT:SpawnNextBattery()
	
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	self.BatteryNumberLeft = self.BatteryNumberLeft - 1

	if self.BatteryNumberLeft <= 0 then
		JM_Function_PrintChat_All("Powerup", "All batteries have been captured! Innocents Win...")
		EndRound("innocents")
		JM_Function_PlaySound("gamemode/file_end.mp3")
	else
		JM_Function_PlaySound("gamemode/power_activate.mp3")
		JM_Function_PrintChat_All("Powerup", "A Battery has been Captured! (" .. tostring(self.BatteryNumberLeft) .. " Left!)")
		-- Spawn the Objective Ents
		local newBatteryList =  JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_04_power_ent", 1)
		newBatteryList[1].batteryMaster = self
	end
	

end
