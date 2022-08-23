AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Stash"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end


function ENT:Initialize()

	JM_GameMode_Stash_Start()

end


function JM_GameMode_Stash_Start()

	-- Validation Checks
	if CLIENT then return end
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end
	
	-- Number of Files to Spawn
	local NumberOfThingsToSpawn = 1

	-- Announce the Goal
	JM_Function_Announcement("[Stash] Traitors must locate and capture the Stash!", 0)

	-- Play the Sound
    JM_Function_PlaySound("gamemode/stash_start.mp3")

	-- Spawn the Objective Ents
    JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_05_stash_ent", NumberOfThingsToSpawn)


end