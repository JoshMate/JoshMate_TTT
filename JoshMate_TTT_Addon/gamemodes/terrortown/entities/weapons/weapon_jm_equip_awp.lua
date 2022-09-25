AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "AWP"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_awp_explosive.png"
   SWEP.IconLetter         = "n"

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A loud long range weapon
	
Perfect accuracy and is 1 hit kill
      
Bullets explode on impact dealing splash damage
      
Only has one shot
]]
   };
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.WeaponID              = AMMO_AWP
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once

-- // Gun Stats

SWEP.Primary.Damage        = 5000
SWEP.Primary.NumShots      = 1
SWEP.Primary.Delay         = 1
SWEP.Primary.Cone          = 0.1
SWEP.Primary.Recoil        = 0
SWEP.Primary.Range         = 10000
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 0
SWEP.Primary.SoundLevel    = 90

SWEP.HeadshotMultiplier    = 1
SWEP.BulletForce           = 100
SWEP.Primary.Automatic     = false

-- // End of Gun Stats

SWEP.Secondary.IsDelayedByPrimary = 0
SWEP.IsSilent 			      = false

local JM_Cone_NoScope      = 0.1
local JM_Cone_Scope        = 0
local JM_Shoot_Range       = 10000

local JM_AWP_Blast_Radius  = 350
local JM_AWP_Blast_Damage  = 30

SWEP.Primary.Sound         = "shoot_awp_loud.wav"
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Tracer                = "AR2Tracer"
SWEP.AutoSpawnable         = false
SWEP.Spawnable             = false
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/cstrike/c_snip_awp.mdl")
SWEP.WorldModel            = Model("models/weapons/w_snip_awp.mdl")
SWEP.IronSightsPos         = Vector( 5, -15, -2 )
SWEP.IronSightsAng         = Vector( 2.6, 1.37, 3.5 )

-- JM Changes, Movement Speed
SWEP.MoveMentMultiplier = 0.5
-- End of

function SWEP:SetZoom(state)
   if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
      if state then
         self:GetOwner():SetFOV(10, 0.3)
         self.Primary.Cone = JM_Cone_Scope
      else
         self:GetOwner():SetFOV(0, 0.3)
         self.Primary.Cone = JM_Cone_NoScope
      end
   end
end

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound, 130, 100, 1)
   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
   self:TakePrimaryAmmo( 1 )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
   -- #########

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   -- Hit Direct
   self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())

   -- Explosion
   owner:LagCompensation(true)

   local tr    = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   local pos   = tr.HitPos
   local spos  = tr.HitPos

   if SERVER then
      local effect = EffectData()
      effect:SetStart(pos)
      effect:SetOrigin(pos)
      util.Effect("Explosion", effect, true, true)
      util.Effect("HelicopterMegaBomb", effect, true, true)

      -- Blast
      util.BlastDamage(self, self:GetOwner(), pos, JM_AWP_Blast_Radius, JM_AWP_Blast_Damage)

   else
      util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)      
   end

   owner:LagCompensation(false)

   -- Disorientated Debuff on Explosion
   if (SERVER) then
      JM_GiveBuffToThisPlayer("jm_buff_slowshort",self:GetOwner(),self:GetOwner())
   end

   -- line showing bullet trajectory
   local e = EffectData()
   e:SetStart(tr.StartPos)
   e:SetOrigin(tr.HitPos)
   e:SetMagnitude(tr.HitBox)
   e:SetScale(5)
   util.Effect("traitor_shot_tracer", e)

   -- Remove Ammo

   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end

   -- #########
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

         -- Draw Coloured dot in the middle
         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 0)
         surface.DrawLine(x, y, x + 0, y + 1)
         surface.DrawLine(x, y, x - 1, y - 0)
         surface.DrawLine(x, y, x - 0, y - 1)

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

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Shoot", "Scope In/Out", true)
 
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
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################