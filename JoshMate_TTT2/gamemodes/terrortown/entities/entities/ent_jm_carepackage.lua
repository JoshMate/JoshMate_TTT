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

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	if SERVER then self:SendWarn(true) end 

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
			JM_CarePackage_Use_LootMaster(activator,self,0,0)
		
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


--- Josh Mate Hud Warning
if SERVER then
	function ENT:SendWarn(armed)
		net.Start("TTT_LootWarn")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteBit(armed)

		if armed then
			net.WriteVector(self:GetPos())
		end

		net.Broadcast()
	end

	function ENT:OnRemove()
		self:SendWarn(false)
	end
end