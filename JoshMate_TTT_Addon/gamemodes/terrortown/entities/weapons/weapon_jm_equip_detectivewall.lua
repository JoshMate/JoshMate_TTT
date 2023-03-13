AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false
 end

SWEP.PrintName				= "Detective Wall"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Leftclick to place a wall"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.5
SWEP.Secondary.Delay 		= 0.25
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
SWEP.WeaponID              	= AMMO_WALL
SWEP.CanBuy                	= {ROLE_DETECTIVE}
SWEP.AutoSpawnable			= false
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_barrier.png"
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   name = "Detective Wall",
	   desc = [[Place down a defensive barrier
	
Left Click to place a wall in front of you

The wall will block bullets, projectiles and props 

It has 2 uses and they last for 60 seconds
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
	
	-- Place the barrier that belongs to each class
	local ent = ents.Create("ent_jm_barrier_detective")
	
	ent:SetPos(tr.HitPos)
	local ang = tr.Normal:Angle()
	ang:RotateAroundAxis(ang:Right(), -90)
	ent:SetAngles(ang)
	ent:Spawn()
	ent.fingerprints = {}
	self:TakePrimaryAmmo(1)

	-- Remove Weapon When out of Ammo
	if SERVER then
		if self:Clip1() <= 0 then
		   self:Remove()
		end
	 end
	 -- #########
	
end

function SWEP:SecondaryAttack()

end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a Suppression Wall", nil, true)
 
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

