if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Burger"
end

ENT.Type = "anim"
ENT.Model = Model("models/food/burger.mdl")

ENT.CanHavePrints = false

local burger_HealthHealed			= 50
local burger_HealthMaxGained		= 10
local burger_DetectiveMult			= 0.5
local burger_SoundEaten				= "effect_foodbite.mp3"

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	--Prevent holding E
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

end

function ENT:Use( activator, caller )

	self:EmitSound(burger_SoundEaten)

	if activator:IsDetective() then

		JM_Function_PrintChat(activator, "Equipment", "The Burger heals you (Burgers are less effective on Detectives)")
		activator:SetHealth(math.Clamp((activator:Health() + (burger_HealthHealed * burger_DetectiveMult)), 0, activator:GetMaxHealth()))  

	else

		JM_Function_PrintChat(activator, "Equipment", "The Burger heals you and grants you +" .. tostring(burger_HealthMaxGained) .. " max HP!")
		activator:SetMaxHealth(activator:GetMaxHealth() + burger_HealthMaxGained) 
		activator:SetHealth(math.Clamp((activator:Health() + burger_HealthHealed), 0, activator:GetMaxHealth())) 

	end

	self:Remove()

end

-- ESP Halo effect

local JM_Burger_Halo_Colour = Color(0,255,50,255)
hook.Add( "PreDrawHalos", "Halos_Burger", function()
    halo.Add( ents.FindByClass( "ent_jm_equip_burger*" ), JM_Burger_Halo_Colour, 2, 2, 3, true, false )
 
end )
