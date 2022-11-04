AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Arms Deal"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end

function ENT:Initialize()

	JM_GameMode_ArmsDeal_Start(self)

end


function JM_GameMode_ArmsDeal_Start(ent)

	-- Validation Checks
	if CLIENT then return end
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	-- Announce the Goal
	JM_Function_Announcement("[Arms Deal] Trade in firearms for information on the Traitor!", 0)

	-- Play the Sound
	JM_Function_PlaySound("gamemode/armsdeal_start.wav")

	-- Spawn the Objective Ents
	JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_08_armsdeal_ent", 1)


end