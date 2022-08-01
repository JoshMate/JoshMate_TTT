AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Infection"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

local GameMode_Infection_Zombie_Spawn_Delay			= 20
local GameMode_Infection_Zombie_StartingHealth		= 60

function ENT:Initialize()

	JM_GameMode_Infection_Start()
	self.TimeTilNextZombieSpawn = CurTime() + GameMode_Infection_Zombie_Spawn_Delay

end

function ENT:Think()

	-- Spawn New Wave of Zombies
	if CurTime() >= self.TimeTilNextZombieSpawn then
		self.TimeTilNextZombieSpawn = CurTime() + GameMode_Infection_Zombie_Spawn_Delay
		self:Infection_SpawnInWaveOfZombies() 
	end

end


function ENT:Infection_SpawnInWaveOfZombies() 

	local possibleNewZombies = {}

	-- Build a list of possible targets
	for _,pl in pairs(player.GetAll()) do
		if pl:IsValid() and not pl:Alive() then 
			table.insert(possibleNewZombies, pl)
		end
	end

	if #possibleNewZombies > 0 then 

		-- Inform the traitors of the new target
		for _,pl in pairs(possibleNewZombies) do
			if pl:IsValid() and not pl:Alive() then 

				if SERVER then 

					local newListOfPlayers = {pl}
					ulx.respawn(pl, newListOfPlayers, true )
					pl:StripWeapons()
					pl:SetCredits(0)
					pl:Give("weapon_jm_equip_zombiemodemelee")
					pl:SetMaxHealth(GameMode_Infection_Zombie_StartingHealth)
					pl:SetHealth(GameMode_Infection_Zombie_StartingHealth)
					ulx.force( pl, newListOfPlayers, "traitor", true )
					JM_GiveBuffToThisPlayer("jm_buff_zombiemode",pl,nil)
					JM_Function_PrintChat(pl, "Infection", "You have come back as a zombie Traitor! Kill Innocents to win!") 

					-- TP Player to a random Spot
					JM_Function_TeleportPlayerToARandomPlace(pl)

				end

			end
		end	
	end

	

end



function JM_GameMode_Infection_Start()

	-- Validation Checks
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	-- Announce the Goal
	JM_Function_Announcement("[Infection] Dead players will become Traitor Zombies!", 0)

	-- Play the Sound
	JM_Function_PlaySound("gamemode/infection_start.mp3")


end