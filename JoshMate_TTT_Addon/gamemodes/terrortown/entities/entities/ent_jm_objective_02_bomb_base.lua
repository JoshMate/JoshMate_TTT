AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Bomb"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end

local JM_Objective_DefuseTheBomb_SpawnTime_Min 			= 20
local JM_Objective_DefuseTheBomb_SpawnTime_Max 			= 120

function ENT:Initialize()

	self.hasTriggeredOnce = false
	self.DefuseBomb_AppearTime = CurTime() + math.random(JM_Objective_DefuseTheBomb_SpawnTime_Min,JM_Objective_DefuseTheBomb_SpawnTime_Max)

	self.Objective_Bomb_Time_Fuse		= 60
	self.Objective_Bomb_Time_Spawn		= CurTime()
	self.Objective_Bomb_Time_Detonate   = self.Objective_Bomb_Time_Spawn + self.Objective_Bomb_Time_Fuse

	self.Objective_Bomb_HasWarned_Half		= false
	self.Objective_Bomb_HasWarned_Close		= false
	self.Objective_Bomb_HasWarned_Detonate	= false

end

function ENT:Think()

	if self.hasTriggeredOnce == false and self.DefuseBomb_AppearTime <= CurTime() then
		self.hasTriggeredOnce = true
		self.Objective_Bomb_Time_Spawn		= CurTime()
		self.Objective_Bomb_Time_Detonate   = self.Objective_Bomb_Time_Spawn + self.Objective_Bomb_Time_Fuse
		JM_GameMode_DefuseTheBombs_Start()
		
	end
		
	if self.hasTriggeredOnce == true then

		if CLIENT then return end

		-- Half Time Left
		if (CurTime() + (self.Objective_Bomb_Time_Fuse/2)) >= self.Objective_Bomb_Time_Detonate and not self.Objective_Bomb_HasWarned_Half then

			local listOfObjectives = ents.FindByClass( "ent_jm_objective_02_bomb_ent" )
			if #listOfObjectives <= 0 then return end

			local timeLeftOnTimer = self.Objective_Bomb_Time_Detonate - CurTime()

			self.Objective_Bomb_HasWarned_Half = true

			JM_Function_PrintChat_All("Defuse The Bombs", "Bomb Timer: 30 Seconds!")
			JM_Function_PlaySound("gamemode/bomb_half.wav")

		end

		-- 10 Seconds Left
		if (CurTime() + 10) >= self.Objective_Bomb_Time_Detonate and not self.Objective_Bomb_HasWarned_Close then

			local listOfObjectives = ents.FindByClass( "ent_jm_objective_02_bomb_ent" )
			if #listOfObjectives <= 0 then return end

			self.Objective_Bomb_HasWarned_Close = true
			local timeLeftOnTimer = self.Objective_Bomb_Time_Detonate - CurTime()
			JM_Function_PrintChat_All("Defuse The Bombs", "Bomb Timer: 10 Seconds!")
			JM_Function_PlaySound("gamemode/bomb_close.wav")

		end

		-- DETONATE!
		if CurTime() >= self.Objective_Bomb_Time_Detonate and not self.Objective_Bomb_HasWarned_Detonate then

			local listOfObjectives = ents.FindByClass( "ent_jm_objective_02_bomb_ent" )
			if #listOfObjectives <= 0 then return end

			self.Objective_Bomb_HasWarned_Detonate = true
			JM_Function_PrintChat_All("Defuse The Bombs", "The Bombs have Detonated! Traitors Win...")
			JM_Function_PlaySound("c4_huge_boom.wav")

			for _, ply in ipairs( player.GetAll() ) do
				if (ply:IsValid() and ply:IsTerror() and ply:Alive()) and not ply:IsTraitor() then

					local effect = EffectData()
					effect:SetStart(ply:GetPos())
					effect:SetOrigin(ply:GetPos())
					util.Effect("Explosion", effect, true, true)
					util.Effect("HelicopterMegaBomb", effect, true, true)

					ply:TakeDamage( 9999, ply, self)
				end
			end
		end
	end
end



function JM_GameMode_DefuseTheBombs_Start()

	-- Validation Checks
	if CLIENT then return end
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	-- Number of Files to Spawn
	local NumberOfPeopleAlive 		= 0
	for _,pl in pairs(player.GetAll()) do

		if pl:Alive() then 
			NumberOfPeopleAlive = NumberOfPeopleAlive + 1
		end
	end

	local NumberOfBombsToSpawn 			= 7
	if NumberOfPeopleAlive <= 10 then 	NumberOfBombsToSpawn = 6 end
	if NumberOfPeopleAlive <= 7 then 	NumberOfBombsToSpawn = 5 end
	if NumberOfPeopleAlive <= 5 then 	NumberOfBombsToSpawn = 4 end
	if NumberOfPeopleAlive <= 3 then 	NumberOfBombsToSpawn = 2 end

	-- Announce the Goal
	JM_Function_Announcement("[Defuse The Bombs] Innocents have 60 seconds to defuse " .. tostring(NumberOfBombsToSpawn) .. " Bombs!", 0)

	-- Play the Sound
	JM_Function_PlaySound("gamemode/bomb_started.wav")

	-- Spawn the Objective Ents
	JM_Function_SpawnThisThingInRandomPlaces("ent_jm_objective_02_bomb_ent", NumberOfBombsToSpawn)


end