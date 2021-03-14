AddCSLuaFile()

if CLIENT then
	SWEP.PrintName          = "Tree of Life"
	SWEP.Slot               = 6
 
	SWEP.ViewModelFOV       = 10
	SWEP.ViewModelFlip      = false
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   desc = [[A Utility Weapon
	 
 Left Click: Place down a TOL
	
 Heals all players who stand nearby

 Must be placed of flat ground away from other TOLs
	
 3 uses and each tree lasts for (30 seconds)
 ]]
	};
 
	SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_tree.png"
end

SWEP.Base                  = "weapon_tttbase"
SWEP.HoldType              = "normal"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.45
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 10
SWEP.Primary.SoundLevel    = 75
SWEP.Primary.Automatic     = false

SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_TREE
SWEP.UseHands              = true
SWEP.IsSilent              = true
SWEP.ViewModel             = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel            = "models/weapons/w_crowbar.mdl"

local JM_Tree_Place_Range		= 200




function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound( self.Primary.Sound )

	if (CLIENT) then return end

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Tree_Place_Range, filter = self.Owner})
	if (tr.HitWorld or (tr.Entity:GetClass() == "func_breakable"))then
		local dot = vector_up:Dot(tr.HitNormal)
		if dot > 0.55 and dot <= 1 then
			local ent = ents.Create("ent_jm_tree")
			ent:SetPos(tr.HitPos + tr.HitNormal)
			local ang = tr.HitNormal:Angle()
			ang:RotateAroundAxis(ang:Right(), -90)
			ent:SetAngles(ang)
			ent:Spawn()
			ent.SetOwner(self:GetOwner())
			ent.fingerprints = self.fingerprints
			self:TakePrimaryAmmo(1)
			if SERVER then
				if self:Clip1() <= 0 then
					self:Remove()
				end
			end
		end
	end	
end

function SWEP:SecondaryAttack()
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a Tree of Life", nil, true)
 
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