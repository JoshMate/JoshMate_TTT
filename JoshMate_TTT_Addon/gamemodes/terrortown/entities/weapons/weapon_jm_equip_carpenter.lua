AddCSLuaFile()

if CLIENT then
	SWEP.Slot      = 7
 
	SWEP.ViewModelFlip		= false
 end

SWEP.PrintName				= "Carpenter"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Leftclick to place a Pallet"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.5
SWEP.Secondary.Delay 		= 0.5
SWEP.Primary.ClipSize		= 15
SWEP.Primary.DefaultClip	= 15
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel              = "models/props_junk/wood_pallet001a.mdl"
SWEP.WorldModel             = "models/props_junk/wood_pallet001a.mdl"
SWEP.HoldType 				= "normal" 
SWEP.UseHands               = false
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind                  	= WEAPON_EQUIP
SWEP.WeaponID              	= AMMO_CARPENTER
SWEP.CanBuy                	= {ROLE_DETECTIVE}
SWEP.AutoSpawnable			= false
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_pallet.png"
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   name = "Carpenter",
	   desc = [[Build with wood
	
Left Click to place a wooden pallet in front of you

It is breakable, but will otherwise block players

It has 15 uses and they last until broken
]]
	}

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 60 - ang:Right() * -35 - ang:Up() * 45, ang
	end
end

local JM_Barrier_PlaceRange				= 64

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	
	if (CLIENT) then return end

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Barrier_PlaceRange, filter = self.Owner})
	
	-- Place the barrier that belongs to each class
	local ent = ents.Create("prop_physics")
	ent:SetModel("models/props_junk/wood_pallet001a.mdl")
	ent:SetColor(Color( 0, 80, 255, 255))
	ent:SetPos(tr.HitPos)
	local ang = tr.Normal:Angle()
	ang:RotateAroundAxis(ang:Right(), -90)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:GetPhysicsObject():EnableMotion( false )
	ent.fingerprints = self.fingerprints

	ent:SetMaxHealth(125)
	ent:SetHealth(125)

	self:GetOwner():EmitSound("shoot_barrel.mp3")
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

	if not self:CanSecondaryAttack() then return end
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	
	if (CLIENT) then return end

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Barrier_PlaceRange, filter = self.Owner})
	
	-- Place the barrier that belongs to each class
	local ent = ents.Create("prop_physics")
	ent:SetModel("models/props_junk/wood_pallet001a.mdl")
	ent:SetColor(Color( 0, 80, 255, 255))
	ent:SetPos(tr.HitPos)
	local ang = tr.Normal:Angle()
	ang:RotateAroundAxis(ang:Right(), 0)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:GetPhysicsObject():EnableMotion( false )
	ent.fingerprints = self.fingerprints

	ent:SetMaxHealth(125)
	ent:SetHealth(125)

	self:GetOwner():EmitSound("shoot_barrel.mp3")
	self:TakePrimaryAmmo(1)

	-- Remove Weapon When out of Ammo
	if SERVER then
		if self:Clip1() <= 0 then
		   self:Remove()
		end
	 end
	 -- #########

end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place Upright", "Place Flat", true)
 
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

