AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 10
 end

SWEP.PrintName				= "Fire Wall"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Leftclick to place a Fire Wall"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 3
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel              = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             = "models/weapons/w_crowbar.mdl"
SWEP.HoldType 				= "normal" 
SWEP.UseHands 				= true
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_tttbase"
SWEP.Kind                  	= WEAPON_EQUIP
SWEP.WeaponID              	= AMMO_BARRIER
SWEP.CanBuy                	= {ROLE_TRAITOR}
SWEP.AutoSpawnable			= false
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_firewall.png"
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   name = "Fire Wall",
	   desc = [[Place down a lethal fire wall
	
Left click to place the Fire Wall right in front of you. It will be invisible until it arms

After 15s the barrier will arm, becoming visible and hurting and slowing all who pass through it

It will last for 2 Minutes and has 2 uses
]]
	}
end

local JM_Barrier_PlaceRange				= 64

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	
	if (CLIENT) then return end

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Barrier_PlaceRange, filter = self.Owner})
	local ent = ents.Create("ent_jm_firewall")
	ent:SetPos(tr.HitPos)
	local ang = tr.Normal:Angle()
	ang:RotateAroundAxis(ang:Right(), -90)
	ent:SetAngles(ang)
	ent:Spawn()
	ent.SetOwner(self:GetOwner())
	ent.fingerprints = {}
	ent.JM_Owner = self:GetOwner()
	self:TakePrimaryAmmo(1)
	if SERVER then
		if self:Clip1() <= 0 then
			self:Remove()
		end
	end
	
end

function SWEP:SecondaryAttack()
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a Fire Wall", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
      end
   end
end
-- 

-- Josh Mate No World Model

function SWEP:OnDrop()
	self:Remove()
 end
  
 function SWEP:DrawWorldModel()
	return
 end
 
 function SWEP:DrawWorldModelTranslucent()
	return
 end
 
 -- END of Josh Mate World Model 

