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


function ENT:Use( activator, caller )

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() and activator:Alive() then
			
			self:EmitSound("carepackage_open.wav")
			activator:ChatPrint("[Care Package] - You have looted a care package!")

			if(activator:IsDetective() or activator:IsTraitor()) then
				activator:ChatPrint("[Care Package] - Loot: +1 Credit")
				activator:AddCredits(1)
			end
			

			local randomLootChoice = math.random(1, 7)

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
				activator:ChatPrint("[Care Package] - Loot: +50 Max HP and a Full Heal")
				activator:SetMaxHealth(activator:GetMaxHealth() + 50)
				activator:SetHealth(activator:GetMaxHealth())
			end

			if randomLootChoice == 7 then
				activator:ChatPrint("[Care Package] - Loot: Gus Adamiw")
				Loot_SpawnThis(self,"ent_jm_zloot_gusradio")
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