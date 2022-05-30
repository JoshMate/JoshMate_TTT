AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false
 end

SWEP.PrintName				= "Barrier"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Leftclick to place a barrier"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel              = "models/props/cs_office/TV_plasma.mdl"
SWEP.WorldModel             = "models/props/cs_office/TV_plasma.mdl"
SWEP.HoldType 				= "normal" 
SWEP.UseHands               = false
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind                  	= WEAPON_EQUIP
SWEP.WeaponID              	= AMMO_BARRIER
SWEP.CanBuy                	= {ROLE_DETECTIVE}
SWEP.AutoSpawnable			= false
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_barrier.png"
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   name = "Barrier",
	   desc = [[Place down a defensive barrier
	
Left click to place a projectile blocking barrier

It has 2 uses
]]
	}

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 55 - ang:Right() * -25 - ang:Up() * 55, ang
	 end
end

local JM_Barrier_PlaceRange				= 64

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	
	if (CLIENT) then return end

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Barrier_PlaceRange, filter = self.Owner})
	local ent = ents.Create("ent_jm_barrier")
	ent:SetPos(tr.HitPos)
	local ang = tr.Normal:Angle()
	ang:RotateAroundAxis(ang:Right(), -90)
	ent:SetAngles(ang)
	ent:Spawn()
	ent.fingerprints = self.fingerprints
	self:TakePrimaryAmmo(1)
	if SERVER then
		if self:Clip1() <= 0 then
			self:Remove()
		end
	end
	
end

function SWEP:SecondaryAttack()
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a Barrier", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
-- Equip Bare Hands on Remove
if SERVER then
   function SWEP:OnRemove()
      if self:GetOwner():IsValid() and self:GetOwner():IsTerror() and self:GetOwner():Alive() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
-- Hide World Model when Equipped
function SWEP:DrawWorldModel()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
function SWEP:DrawWorldModelTranslucent()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################

