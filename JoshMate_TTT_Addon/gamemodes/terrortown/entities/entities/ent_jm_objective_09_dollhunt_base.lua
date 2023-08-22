AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Doll Hunt"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end

function ENT:Initialize()

	JM_GameMode_DollHunt_Start(self)

end


function JM_GameMode_DollHunt_Start(ent)

	-- Validation Checks
	if CLIENT then return end
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	-- Announce the Goal
	JM_Function_Announcement("[Doll Hunt] Innocents bring the dolls back to the drop off point!", 0)

	-- Play the Sound
	JM_Function_PlaySound("gamemode/dollhunt_start.mp3")

	-- Spawn the Objective Ents
	JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_09_dollhunt_ent", 1)

	-- Spawn the Dolls
	JM_Function_SpawnThisThingInRandomPlacesWithAModel("models/maxofs2d/companion_doll.mdl", 5)

end