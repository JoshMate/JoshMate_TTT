AddCSLuaFile()
include("ent_jm_carepackage_loot.lua")

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

function CarePackageUsedEffect(ent)
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
			
			-- All Care Packages

			self:EmitSound("carepackage_open.wav")
			CarePackageUsedEffect(self)

			if(activator:IsTraitor()) then
				activator:ChatPrint("[Care Package] - Loot: +1 Credit (Traitor Bonus Loot)")
				activator:AddCredits(1)
			end

			-- Random Roller
			
			local RNGGoodOrBad = math.random(1, 100)
			local ChanceOfBad	= 30 -- Change of Good will be 100 minus this number

			
			if (RNGGoodOrBad <= ChanceOfBad) then
				
				self:Loot_Bad( activator, caller )

			else

				self:Loot_Good( activator, caller )

			end
		
			Loot_SpawnThis(self,"weapon_jm_zloot_ninjablade")
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
 
	 halo.Add( players, Color( 255, 255, 0 ), 2, 2, 3, true, true )
 
 end )


 -- ####################################################
 -- ###### Care Package Loot
 -- ####################################################

function ENT:Loot_Good( activator, caller ) 

	local RNG_Good = math.random(1, 11)

	if RNG_Good == 1 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Pistol")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_pistol")
	end

	if RNG_Good == 2 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced SMG")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_smg")
	end

	if RNG_Good == 3 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Shotgun")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_shotgun")
	end
	
	if RNG_Good == 4 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Rifle")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_rifle")
	end

	if RNG_Good == 5 then
		activator:ChatPrint("[Care Package] - Good Loot: Advanced Sniper")
		Loot_SpawnThis(self,"weapon_jm_zloot_advanced_sniper")
	end

	if RNG_Good == 6 then
		activator:ChatPrint("[Care Package] - Good Loot: Health Boost")
		activator:SetMaxHealth(activator:GetMaxHealth() + 100)
		activator:SetHealth(activator:GetMaxHealth())
		JM_GiveBuffToThisPlayer("jm_buff_health", activator, self)
	end

	if RNG_Good == 7 then
		activator:ChatPrint("[Care Package] - Good Loot: Speed Boost")
		JM_GiveBuffToThisPlayer("jm_buff_speedboost", activator, self)
	end
	
	if RNG_Good == 8 then
		activator:ChatPrint("[Care Package] - Good Loot: Health Regeneration")
		JM_GiveBuffToThisPlayer("jm_buff_regeneration", activator, self)
	end

	if RNG_Good == 9 then
		activator:ChatPrint("[Care Package] - Good Loot: Mega Frag Grenade")
		Loot_SpawnThis(self,"weapon_jm_zloot_mega_frag")
	end

	if RNG_Good == 10 then
		activator:ChatPrint("[Care Package] - Good Loot: Ninja Blade")
		Loot_SpawnThis(self,"weapon_jm_zloot_ninjablade")
	end

	if RNG_Good == 11 then
		Loot_SpawnThis(self,"npc_pigeon")
		if(activator:IsTraitor() or activator:IsDetective()) then
			activator:ChatPrint("[Care Package] - Good Loot: - Pigeon? (+3 Credits)")
			activator:AddCredits(3)
		else
			activator:ChatPrint("[Care Package] - Good Loot: - Pigeon? (You have been made a Detective!)")
			activator:SetRole(ROLE_DETECTIVE)
		end
	end

 end

function ENT:Loot_Bad( activator, caller ) 

	local RNG_Bad = math.random(1, 6)

	if RNG_Bad == 1 then
		activator:ChatPrint("[Care Package] - Bad Loot: A little Friend")
		Loot_SpawnThis(self,"npc_rollermine")
	end

	if RNG_Bad == 2 then
		activator:ChatPrint("[Care Package] - Bad Loot: Pigeon")
		Loot_SpawnThis(self,"npc_pigeon")
	end

	if RNG_Bad == 3 then
		activator:ChatPrint("[Care Package] - Bad Loot: Gus Adamiw Radio")
		Loot_SpawnThis(self,"ent_jm_zloot_gusradio")
	end

	if RNG_Bad == 4 then
		activator:ChatPrint("[Care Package] - Bad Loot: Mega Tracker")
		for _, ply in ipairs( player.GetAll() ) do
			if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
				JM_GiveBuffToThisPlayer("jm_buff_megatracker",ply,self)
			end
		end
	end

	if RNG_Bad == 5 then
		activator:ChatPrint("[Care Package] - Bad Loot: Godzilla")
		if SERVER then activator:EmitSound(Sound("godzillaroar.wav")) end

		local pushForce = 5000
		local pos = self:GetPos()
		local tpos = activator:LocalToWorld(activator:OBBCenter())
        local dir = (tpos - pos):GetNormal()

		dir.z = math.abs(dir.z) + 1

		local push = dir * pushForce
		local vel = activator:GetVelocity() + push

		activator:SetVelocity(vel)
		

	end

	if RNG_Bad == 6 then
		activator:ChatPrint("[Care Package] - Bad Loot: Tripping Balls")
		JM_GiveBuffToThisPlayer("jm_buff_trippingballs", activator, self)

	end

end