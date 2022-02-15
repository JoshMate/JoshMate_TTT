AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Bomb Setter"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Sets Bombs"
ENT.Instructions        = "Sets Bombs"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end

local JM_Objective_DefuseTheBomb_SpawnTime_Min 			= 15
local JM_Objective_DefuseTheBomb_SpawnTime_Max 			= 90

function ENT:Initialize()

	self.hasTriggeredOnce = false
	self.DefuseBomb_AppearTime = CurTime() + math.random(JM_Objective_DefuseTheBomb_SpawnTime_Min,JM_Objective_DefuseTheBomb_SpawnTime_Max)

end

function ENT:Think()

	if self.hasTriggeredOnce == false and self.DefuseBomb_AppearTime <= CurTime() then
		self.hasTriggeredOnce = true
		JM_GameMode_DefuseBombsChoseBombAmountAndSpawn()
	end

end



function JM_GameMode_DefuseBombsChoseBombAmountAndSpawn()

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	
	local NumberOfPeopleAlive 		= 0
	for _,pl in pairs(player.GetAll()) do

		if pl:Alive() then 
			NumberOfPeopleAlive = NumberOfPeopleAlive + 1
		end
	end

	local NumberOfBombsToSpawn 			= 5
	if NumberOfPeopleAlive <= 10 then 	NumberOfBombsToSpawn = 4 end
	if NumberOfPeopleAlive <= 5 then 	NumberOfBombsToSpawn = 3 end
	if NumberOfPeopleAlive <= 3 then 	NumberOfBombsToSpawn = 2 end

	JM_Function_PlaySound("gamemode/bomb_started.wav")
	JM_Function_Announcement("New Objective: Innocents you have 60 seconds to defuse " .. tostring(NumberOfBombsToSpawn) .. " Bombs!", 0)

	JM_GameMode_Function_SpawnThisThingRandomly("ent_jm_objective_02_bomb", NumberOfBombsToSpawn)


end