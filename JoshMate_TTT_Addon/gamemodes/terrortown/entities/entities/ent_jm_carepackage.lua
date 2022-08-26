AddCSLuaFile()

include('autorun/jm_carepackage_loot.lua')


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
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true, self:EntIndex(), "icon_warn_carepackage", self:GetPos(), 0, 0)

end

function CarePackageUsedEffect(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	
	
	util.Effect("cball_explode", effect, true, true)
end


function ENT:Use( activator, caller )

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() and activator:Alive() then
			
			-- All Care Packages

			self:EmitSound("carepackage_open.wav")
			CarePackageUsedEffect(self)

			-- Handle Loot
			JM_CarePackage_Use_LootMaster(activator,self)
		
			self:Remove()
		end
	end
end

function ENT:Think()
end

-- ESP Halo effect

local JM_CarePackage_Halo_Colour = Color(150,0,255,255)

hook.Add( "PreDrawHalos", "Halos_CarePackage", function()

    halo.Add( ents.FindByClass( "ent_jm_carepackage*" ), JM_CarePackage_Halo_Colour, 2, 2, 3, true, true )
 
end )



function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end