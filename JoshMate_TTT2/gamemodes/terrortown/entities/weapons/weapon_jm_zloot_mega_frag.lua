AddCSLuaFile()

if CLIENT then
   SWEP.PrintName       = "Mega Frag Grenade"
   SWEP.Slot            = 3

   SWEP.Icon            = "vgui/ttt/joshmate/icon_jm_gun_special.png"
   SWEP.IconLetter      = "P"

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 17 - ang:Right() * -8 - ang:Up() * 8, ang
	end
end

SWEP.Base               = "weapon_jm_base_grenade"
SWEP.Kind               = WEAPON_NADE
SWEP.WeaponID           = AMMO_NADE_FRAG

SWEP.ViewModel          = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.WorldModel         = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.UseHands 				= false


SWEP.AutoSpawnable      = true
SWEP.Spawnable          = true

SWEP.CanBuy             = {}
SWEP.LimitedStock       = true

SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1

-- JM Changes, Throwing
SWEP.JM_Throw_Power        = 1200
-- End of

function SWEP:GetGrenadeName()
   return "ent_jm_grenade_frag_proj"
end

function SWEP:ProduceMegaFrags(count)

   local ply = self:GetOwner()
   local A_Src = ply:GetShootPos()
   local A_Angle = Angle(0,0,0)
   local A_Vel = ( ply:GetAimVector() * (self.JM_Throw_Power * self.JM_Throw_PowerMult ))
   local A_AngImp = Vector(600, math.random(-1200, 1200), 0)

   self:GetOwner():EmitSound(Sound("grenade_throw.wav"))

   for i=1,count do 
      A_Vel = ply:GetAimVector()
      A_Vel:Add(Vector(math.Rand(-0.1, 0.1), math.Rand(-0.1, 0.1), 0))
      A_Vel = A_Vel * ((self.JM_Throw_Power * self.JM_Throw_PowerMult ) * math.Rand(0.8, 1.2))

      self:CreateGrenade(A_Src, A_Angle, A_Vel, A_AngImp, ply)
   end 

end

function SWEP:Throw()

   if SERVER then
      local ply = self:GetOwner()
      if not IsValid(ply) then return end

      self:ProduceMegaFrags(10)
   
      self:TakePrimaryAmmo(1)
      if self:Clip1() <= 0 then
         self:Remove()
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Full Throw", "Half Throw", true)
 
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

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################