
AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "Poison Dart Gun"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Weapon

Steals 60 HP from the target over 15 seconds

Targets flinch while they are poisoned
   
Has 3 uses, silent, perfect acccuracy and long range
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_poisondart.png"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 2
SWEP.Primary.SoundLevel    = 40
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_poisondart.wav"
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_POISONDART
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/cstrike/c_rif_aug.mdl")
SWEP.WorldModel            = Model("models/weapons/w_rif_aug.mdl")
SWEP.IronSightsPos         = Vector( 5, -15, -2 )
SWEP.IronSightsAng         = Vector( 2.6, 1.37, 3.5 )

local Poison_Duration               = 15
local Poison_Damage_Delay           = 1
local Poison_Damage_Amount          = 5
local JM_Shoot_Range                = 10000


function PoisonEffect_Tick(ent, attacker)
   if SERVER then
      
      if(not ent:IsValid() or not ent:IsPlayer() or not ent:Alive()) then return end

      local dmginfo = DamageInfo()
      dmginfo:SetDamage(Poison_Damage_Amount)
      dmginfo:SetAttacker(attacker)
      local inflictor = ents.Create("weapon_jm_equip_poisondart")
		dmginfo:SetInflictor(inflictor)
      dmginfo:SetDamageType(DMG_GENERIC)
      dmginfo:SetDamagePosition(ent:GetPos())
      ent:TakeDamageInfo(dmginfo)

      if(not attacker:IsValid() or not attacker:IsPlayer() or not attacker:Alive()) then return end

      -- Heal the User
      if (attacker:Health()+ Poison_Damage_Amount) <= attacker:GetMaxHealth() then
      attacker:SetHealth(attacker:Health() + Poison_Damage_Amount)
      end
   end

end

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   util.Effect("TeslaZap", effect, true, true)
   util.Effect("TeslaHitboxes", effect, true, true)
   util.Effect("cball_explode", effect, true, true)
end

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   self:HitEffectsInit(ent)
   
   if SERVER then
      
      -- Remove the existing Timer then reset it (To prevent Duplication)
      timerName = "timer_PoisonEndTimer_" .. ent:SteamID64()
      if(timer.Exists(timerName)) then timer.Remove(timerName) end
      timer.Create( timerName, Poison_Duration, 1, function ()
         if(ent:IsValid() and ent:IsPlayer()) then
            ent:SetNWBool("isPoisonDarted", false)
            STATUS:RemoveStatus(ent, "jm_poisondart")
         end 
      end )

      -- Remove the existing Timer then reset it (To prevent Duplication)
      timerName = "timer_PoisonTickTimer_" .. ent:SteamID64()
      if(timer.Exists(timerName)) then timer.Remove(timerName) end
      timer.Create( timerName, Poison_Damage_Delay, Poison_Duration, function () PoisonEffect_Tick(ent,weaponOwner) end )

      -- JM Changes Extra Hit Marker
      net.Start( "hitmarker" )
      net.WriteFloat(0)
      net.Send(weaponOwner)
      -- End Of

      -- Set Status and print Message
      STATUS:AddTimedStatus(ent, "jm_poisondart", Poison_Duration, 1)
      ent:SetNWBool("isPoisonDarted", true)
      ent:ChatPrint("[Poison Dart]: You have been poisoned!")
      weaponOwner:ChatPrint("[Poison Dart]: You have hit someone!")
      -- End Of
   end
end

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
   self:TakePrimaryAmmo( 1 )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
   -- #########

   -- New Direct Effect Code (Cuts out all the bullet callback code)
   if SERVER then
      local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * JM_Shoot_Range, filter = self.Owner})
      if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
         self:ApplyEffect(tr.Entity, self:GetOwner())
      end
   end
   -- #########

   -- Remove Weapon When out of Ammo
   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
   -- #########

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
