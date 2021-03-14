AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "The Defender"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_defender"
   SWEP.IconLetter         = "n"

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A versatile long range weapon
	
Perfect accuracy and high damage
      
Semi-Automatic and has a scope
      
Uses heavy ammo found around the map
]]
   };

end

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_EQUIP
SWEP.WeaponID              = AMMO_DEFENDER
SWEP.CanBuy                = {ROLE_DETECTIVE}
SWEP.LimitedStock          = true


SWEP.Primary.Damage        = 80
SWEP.Primary.Delay         = 0.40
SWEP.Primary.Cone          = 0
SWEP.Primary.Recoil        = 3
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 10

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = false

-- Josh Mate Changes
SWEP.Secondary.IsDelayedByPrimary = 0

SWEP.Primary.Ammo          = "357"
SWEP.Primary.Sound         = "shoot_defender.wav"
SWEP.Secondary.Sound       = Sound("Default.Zoom")
SWEP.Tracer                = "None"
SWEP.AutoSpawnable         = false
SWEP.Spawnable             = false
SWEP.AmmoEnt               = "item_jm_ammo_heavy"
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/cstrike/c_snip_sg550.mdl")
SWEP.WorldModel            = Model("models/weapons/w_snip_sg550.mdl")
SWEP.IronSightsPos         = Vector( 5, -15, -2 )
SWEP.IronSightsAng         = Vector( 2.6, 1.37, 3.5 )


function SWEP:WasBought(buyer)
   if IsValid(buyer) then
      buyer:GiveAmmo( 5, "357" )
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

function SWEP:PrimaryAttack( worldsnd )
   self.BaseClass.PrimaryAttack( self.Weapon, worldsnd )
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

         surface.SetDrawColor(0, 0, 255, 255)
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
