AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Files"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end


function ENT:Initialize()

	JM_GameMode_ProtectTheFiles_Start()

end


function JM_GameMode_ProtectTheFiles_Start()

	-- Validation Checks
	if CLIENT then return end
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end
	
	-- Number of Files to Spawn
	local NumberOfThingsToSpawn = 5

	-- Announce the Goal
	JM_Function_Announcement("[Protect The Files] Innocents must protect " .. tostring(NumberOfThingsToSpawn) .. " Files!", 0)

	-- Play the Sound
    JM_Function_PlaySound("gamemode/file_start.wav")

	-- Spawn the Objective Ents
    JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_01_file_ent", NumberOfThingsToSpawn)


end