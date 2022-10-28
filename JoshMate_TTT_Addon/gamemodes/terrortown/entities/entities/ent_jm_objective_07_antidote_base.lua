AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Antidote"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end

local JM_Objective_Antidote_SpawnTime_Min 			= 3
local JM_Objective_Antidote_SpawnTime_Max 			= 6

function ENT:Initialize()

	self.hasTriggeredOnce = false
	self.Antidote_AppearTime = CurTime() + math.random(JM_Objective_Antidote_SpawnTime_Min,JM_Objective_Antidote_SpawnTime_Max)

end

function ENT:Think()

	if self.hasTriggeredOnce == false and self.Antidote_AppearTime <= CurTime() then
		self.hasTriggeredOnce = true
		JM_GameMode_Antidote_Start(self)
	end

end



function JM_GameMode_Antidote_Start(ent)

	-- Validation Checks
	if CLIENT then return end
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            JM_GiveBuffToThisPlayer("jm_buff_antidotepoison",ply,ent)
        end
    end

	-- Announce the Goal
	JM_Function_Announcement("[Antidote] You are all dying of poison, get to the Antidote!", 0)

	-- Play the Sound
	JM_Function_PlaySound("gamemode/antidote_start.mp3")

	-- Spawn the Objective Ents
	JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_07_antidote_ent", 1)


end