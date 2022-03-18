AddCSLuaFile()

SWEP.HoldType              = "smg1"

if CLIENT then
   SWEP.PrintName          = "Shredder"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Weapon

An extremely powerful machine gun

Clicking will begin the spin process
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
end

SWEP.Base                  = "weapon_jm_base_gun"
SWEP.CanBuy                = {}

SWEP.Spawnable             = true
SWEP.AutoSpawnable         = true

SWEP.Kind                  = WEAPON_EQUIP
SWEP.WeaponID              = AMMO_SHREDDER

-- // Gun Stats

SWEP.Primary.Damage        = 30
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 0.05
SWEP.Primary.Cone          = 0.020
SWEP.Primary.Recoil        = 0.25
SWEP.Primary.Range         = 1200
SWEP.Primary.ClipSize      = 500
SWEP.Primary.DefaultClip   = 500
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 75

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.BulletForce           = 20
SWEP.Primary.Automatic     = true

-- // End of Gun Stats

SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.Sound         = "shoot_shredder.wav"
SWEP.Tracer                = "AR2Tracer"
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_smg1.mdl"
SWEP.WorldModel            = "models/weapons/w_smg1.mdl"

SWEP.Shredder_Spinup_Enabled        = false
SWEP.Shredder_Spinup_Time           = 0

function SWEP:Shredder_SelfDestruct()
   
   self:StopSound("shoot_shredder_spinup.wav")

   if SERVER then
      local pos = self:GetOwner():GetPos()
      local effect = EffectData()
      effect:SetStart(pos)
      effect:SetOrigin(pos)
      util.Effect("Explosion", effect, true, true)
      util.Effect("HelicopterMegaBomb", effect, true, true)

      -- Blast
      local JMThrower = game.GetWorld()
      util.BlastDamage(self, JMThrower, pos, 350, 10)

      self:Remove()   
   end

end

function SWEP:PrimaryAttack()

   if self.Shredder_Spinup_Enabled == false then

      self:EmitSound("shoot_shredder_spinup.wav", 100)
      self.Shredder_Spinup_Enabled = true
      self.Shredder_Spinup_Time = CurTime()

   end
	
end

function SWEP:Think()
   self:CalcViewModel()


      if self.Shredder_Spinup_Enabled == true and self.Shredder_Spinup_Time <= CurTime() - 5 then

         self:Shredder_ShootBullet()

         if self:Clip1() <= 0 then
            
            self:Shredder_SelfDestruct()
            
         end
   
      end


end

function SWEP:Shredder_ShootBullet()

   if self.Secondary.IsDelayedByPrimary == 1 then self:SetNextSecondaryFire(CurTime() + self.Primary.Delay) end 

	-- Rapid Fire Changes
	local owner = self:GetOwner()
	if (not owner:GetNWBool(JM_Global_Buff_Care_RapidFire_NWBool)) then self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	else self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay*0.70)) end
	-- End of Rapid Fire Changes


	if not self:CanPrimaryAttack() then return end

	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)

	self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())
	self:TakePrimaryAmmo(1)

	

	if not IsValid(owner) or owner:IsNPC() or not owner.ViewPunch then return end

	owner:ViewPunch(Angle(util.SharedRandom(self:GetClass(), -0.2, -0.1, 0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(), -0.1, 0.1, 1) * self.Primary.Recoil, 0))

end


function SWEP:OnDrop()
   self:StopSound("shoot_shredder_spinup.wav")
   self:Remove()
end

function SWEP:Holster()
   if self.Shredder_Spinup_Enabled == true then  return false end
   return true
end



-- No Iron Sights
function SWEP:SecondaryAttack()
   return
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Spin UP!", nil, true)
 
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

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################