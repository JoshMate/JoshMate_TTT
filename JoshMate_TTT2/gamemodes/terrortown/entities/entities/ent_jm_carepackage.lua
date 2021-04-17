AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Care Package"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Drops Loot"
ENT.Instructions                = "Drops Loot"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

end

function Loot_SpawnThis(carepackage,thingToSpawn)
	local ent = ents.Create(thingToSpawn)
	ent:SetPos(carepackage:GetPos())
    ent:Spawn()
end

function Barrier_Effects_Destroyed(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	util.Effect("TeslaHitboxes", effect, true, true)
	util.Effect("cball_explode", effect, true, true)
end


function ENT:Use( activator, caller )

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() and activator:Alive() then
			
			self:EmitSound("carepackage_open.wav")
			activator:ChatPrint("[Care Package] - You have looted a care package!")

			if(activator:IsTraitor()) then
				activator:ChatPrint("[Care Package] - Loot: +1 Credit (Traitor Bonus Loot)")
				activator:AddCredits(1)
			end
			

			local randomLootChoice = math.random(1, 14)

			if randomLootChoice == 1 then
				activator:ChatPrint("[Care Package] - Loot: Advanced Pistol")
				Loot_SpawnThis(self,"weapon_jm_zloot_advanced_pistol")
				
			end

			if randomLootChoice == 2 then
				activator:ChatPrint("[Care Package] - Loot: Advanced SMG")
				Loot_SpawnThis(self,"weapon_jm_zloot_advanced_smg")
				
			end

			if randomLootChoice == 3 then
				activator:ChatPrint("[Care Package] - Loot: Advanced Shotgun")
				Loot_SpawnThis(self,"weapon_jm_zloot_advanced_shotgun")
				
			end
			
			if randomLootChoice == 4 then
				activator:ChatPrint("[Care Package] - Loot: Advanced Rifle")
				Loot_SpawnThis(self,"weapon_jm_zloot_advanced_rifle")
				
			end

			if randomLootChoice == 5 then
				activator:ChatPrint("[Care Package] - Loot: Advanced Sniper")
				Loot_SpawnThis(self,"weapon_jm_zloot_advanced_sniper")
				
			end

			
			if randomLootChoice == 6 then
				activator:ChatPrint("[Care Package] - Loot: Health Boost")
				activator:SetMaxHealth(activator:GetMaxHealth() + 50)
				activator:SetHealth(activator:GetMaxHealth())
				JM_GiveBuffToThisPlayer(jm_buff_health, activator, self)
			end


			if randomLootChoice == 7 then
				activator:ChatPrint("[Care Package] - Loot: Speed Boost")
				JM_GiveBuffToThisPlayer(jm_buff_speedboost, activator, self)
			end
			
			if randomLootChoice == 8 then
				activator:ChatPrint("[Care Package] - Loot: Health Regeneration")
				JM_GiveBuffToThisPlayer(jm_buff_regeneration, activator, self)
			end

			
			

			if randomLootChoice == 9 then
				activator:ChatPrint("[Care Package] - Loot: Gus Adamiw Radio")
				Loot_SpawnThis(self,"ent_jm_zloot_gusradio")
			end

			if randomLootChoice == 10 then
				activator:ChatPrint("[Care Package] - Loot: A little Friend")
				Loot_SpawnThis(self,"npc_rollermine")
			end

			if randomLootChoice == 11 then
				activator:ChatPrint("[Care Package] - Loot: Manhacks!")

				local JM_ManHackLifeStart = CurTime()
				local deployAmount = 12
				local deployLifeTime = 60

				local npc = nil
				for i = deployAmount,1,-1 do 
					npc = ents.Create("npc_manhack")
					npc:SetPos(self.GetPos())
					npc:SetShouldServerRagdoll(false)
					npc:Spawn()
					npc.JM_ManHackLifeStart = JM_ManHackLifeStart         
				end

				timer.Simple(deployLifeTime, function () 

					for k, v in ipairs( ents.FindByClass("npc_manhack") ) do
						if (v.JM_ManHackLifeStart <= CurTime() - (deployLifeTime - 1)) then
						Barrier_Effects_Destroyed(v) 
						v:Remove()
						end
					end

				end)
			end

			if randomLootChoice == 12 then
				activator:ChatPrint("[Care Package] - Loot: Pigeon")
				Loot_SpawnThis(self,"npc_pigeon")
			end

			if randomLootChoice == 13 then
				activator:ChatPrint("[Care Package] - Loot: Mega Tracker")
				for _, ply in ipairs( player.GetAll() ) do
					if (ply:IsTerror() and ply:Alive() and not ply:SteamID64() == activator:SteamID64() ) then
						JM_GiveBuffToThisPlayer("jm_buff_megatracker",ply,self)
					end
				end
			end
			
			if randomLootChoice == 14 then
				activator:ChatPrint("[Care Package] - Loot: Mega Frag Grenade")
				Loot_SpawnThis(self,"weapon_jm_zloot_mega_frag")
			end

			

			

			self:Remove()
		end
		
	end
	
end

function ENT:Think()
end

-- ESP Halo effect

local JM_CarePackage_Halo_Colour = Color(150,0,255,255)

hook.Add( "PreDrawHalos", "Halos_CarePackage", function()

    halo.Add( ents.FindByClass( "ent_jm_carepackage*" ), JM_CarePackage_Halo_Colour, 5, 5, 2, true, true )
 
 end )

 -- ESP Halo effect
hook.Add( "PreDrawHalos", "Halos_Mega_Tracker", function()

	local players = {}
	local count = 0
 
	 for _, ply in ipairs( player.GetAll() ) do
		 if (ply:IsTerror() and ply:Alive() and ply:GetNWBool("isMegaTracked") ) then
			 count = count + 1
			 players[ count ] = ply
		 end
	 end
 
	 halo.Add( players, Color( 255, 255, 0 ), 5, 5, 2, true, true )
 
 end )