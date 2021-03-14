
AddCSLuaFile()

SWEP.HoldType            = "ar2"

if CLIENT then
   SWEP.PrintName          = "Poison Dart"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Silent Long-Range Weapon
	
Poisons the target for 30 seconds
   
Steals the HP of the target over time

Targets flinch while they are poisoned
   
Only has 5 uses (Repeat shots reset the timer)
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_poisondart.png"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Recoil        = 3
SWEP.Primary.Damage        = 1
SWEP.HeadshotMultiplier    = 1
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 50
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_poisondart.wav"
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Tracer                = "None"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_POISONDART
SWEP.UseHands              = true
SWEP.IsSilent              = true
SWEP.ViewModel             = Model("models/weapons/cstrike/c_rif_aug.mdl")
SWEP.WorldModel            = Model("models/weapons/w_rif_aug.mdl")
SWEP.IronSightsPos         = Vector( 5, -15, -2 )
SWEP.IronSightsAng         = Vector( 2.6, 1.37, 3.5 )

local Poison_Duration            = 30
local Poison_Damage_Delay        = 0.5
local Poison_Damage_Amount       = 1


function PoisonEffect_Tick(ent, attacker, weaponInflictor, timerName)
   if SERVER then
      if not IsValid(ent) then
         return
      end
      if not ent:GetNWBool("isPoisonDarted") then
         timer.Remove(timerName)
         return
      end
      if not ent:Alive() then 
         timer.Remove(timerName)
         return 
      end

      local dmginfo = DamageInfo()
      dmginfo:SetDamage(Poison_Damage_Amount)
      dmginfo:SetAttacker(attacker)
		dmginfo:SetInflictor(weaponInflictor)
      dmginfo:SetDamageType(DMG_GENERIC)
      dmginfo:SetDamagePosition(ent:GetPos())
      ent:TakeDamageInfo(dmginfo)

      -- Heal the User
      if (attacker:Health()+ Poison_Damage_Amount) <= attacker:GetMaxHealth() then
      attacker:SetHealth(attacker:Health() + Poison_Damage_Amount)
      end
   end

end


function RemovePoison(ent)
      STATUS:RemoveStatus(ent, "jm_poisondart")
      ent:SetNWBool("isPoisonDarted", false)
end


function PoisonTarget(att, path, dmginfo)
   local ent = path.Entity
   if not IsValid(ent) or not IsPlayer(ent) then return end

   STATUS:AddTimedStatus(ent, "jm_poisondart", Poison_Duration, 1)
   
   if SERVER then
   -- Only works on players and only outside of post and prep
   if (not ent:IsPlayer()) or (not GAMEMODE:AllowPVP()) then return end
      
   weaponInflictor = dmginfo:GetInflictor()
   timerName = "timer_PoisonEffectTimer_" .. ent:EntIndex()
   timer.Create( timerName, Poison_Damage_Delay, Poison_Duration*2, function () if ent:IsPlayer() and ent:Alive() then PoisonEffect_Tick(ent, att, weaponInflictor, timerName ) end end )
   timerName = "timer_PoisonRemoveTimer_" .. ent:EntIndex()
   timer.Create( timerName, Poison_Duration, 1, function () if ent:IsPlayer() and ent:Alive() then RemovePoison(ent) end end )
   
   ent:ChatPrint("[Poison]: You have been poisoned!")
   ent:SetNWBool("isPoisonDarted", true)

   end
end



function SWEP:ShootPoisonShot()
   local cone = self.Primary.Cone
   local bullet = {}
   bullet.Num       = 1
   bullet.Src       = self:GetOwner():GetShootPos()
   bullet.Dir       = self:GetOwner():GetAimVector()
   bullet.Spread    = Vector( cone, cone, 0 )
   bullet.Tracer    = 9999
   bullet.Force     = 1
   bullet.Damage    = self.Primary.Damage
   bullet.TracerName = self.Tracer
   bullet.Callback = PoisonTarget

   self:GetOwner():FireBullets( bullet )
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end

   self:EmitSound( self.Primary.Sound )

   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

   self:ShootPoisonShot()

   self:TakePrimaryAmmo( 1 )

   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

      self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
   end

   if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
      self:SetNWFloat( "LastShootTime", CurTime() )
   end

   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
end

function SWEP:SetZoom(state)
   if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
      if state then
         self:GetOwner():SetFOV(10, 0.3)
      else
         self:GetOwner():SetFOV(0, 0.3)
      end
   end
end


-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   self:SetZoom(bIronsights)
   if (CLIENT) then
      self:EmitSound(self.Secondary.Sound)
   end

end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if ( self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
   self:DefaultReload( ACT_VM_RELOAD )
   self:SetIronsights( false )
   self:SetZoom( false )
end


function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)
         
         -- cover gaps on top and bottom of screen
         surface.DrawLine( 0, 0, scrW, 0 )
         surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )

         surface.SetDrawColor(0, 255, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end


-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Poison an enemy", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      self:PreDrop()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
      end
   end
end
-- 