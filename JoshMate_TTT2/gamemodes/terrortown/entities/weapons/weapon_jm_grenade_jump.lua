AddCSLuaFile()

if CLIENT then
   SWEP.PrintName       = "Jump Grenade"
   SWEP.Slot            = 3

   SWEP.Icon            = "vgui/ttt/joshmate/icon_jm_gun_nade"
   SWEP.IconLetter      = "P"
   
   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() * -10 - ang:Up() * 11, ang
	end
end

SWEP.Base               = "weapon_jm_base_grenade"
SWEP.Kind               = WEAPON_NADE
SWEP.WeaponID           = AMMO_NADE_PUSH

SWEP.ViewModel          = "models/weapons/w_eq_flashbang.mdl"
SWEP.WorldModel         = "models/weapons/w_eq_flashbang.mdl"
SWEP.UseHands 				= false

SWEP.AutoSpawnable      = true
SWEP.Spawnable          = true

SWEP.CanBuy             = {}
SWEP.LimitedStock       = true

SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1

-- How High should this greande push you?
local JM_Jump_Force        = 500

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   util.Effect("cball_explode", effect, true, true)
end

function SWEP:PrimaryAttack()
   if not self:CanPrimaryAttack() then return end
   self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
   self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

   if GetRoundState() == ROUND_PREP and GetConVar("ttt_no_nade_throw_during_prep"):GetBool() then
      if SERVER then self:GetOwner():ChatPrint("[Grenade] - You can't use that during prep time...") end
      return
   end
   
   -- Use The Grenade

   if (SERVER) then
      local pl = self:GetOwner()
      pl:EmitSound(Sound("grenade_jump.wav"))

      if pl:IsTerror() and pl:Alive() then

         -- Hit Markers
         net.Start( "hitmarker" )
         net.WriteFloat(0)
         net.WriteBool(false)
         net.Send(pl)
         -- End of Hit Markers

         -- Effects
         self:HitEffectsInit(pl)
         -- End of Effects
         
         local vel = pl:GetVelocity()
         vel.z = vel.z + JM_Jump_Force

         pl:SetVelocity(vel)

      end

      self:TakePrimaryAmmo(1)
      if self:Clip1() <= 0 then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
         self:Remove()
      end
   end

end