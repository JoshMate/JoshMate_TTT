AddCSLuaFile()

if CLIENT then
   SWEP.PrintName       = "Healing Grenade"
   SWEP.Slot            = 3

   SWEP.Icon            = "vgui/ttt/joshmate/icon_jm_gun_nade"
   SWEP.IconLetter      = "P"
   
   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() * -12 - ang:Up() * 13, ang
	end
end

SWEP.Base               = "weapon_jm_base_grenade"
SWEP.Kind               = WEAPON_NADE
SWEP.WeaponID           = AMMO_NADE_HEALTH

SWEP.ViewModel          = "models/healthvial.mdl"
SWEP.WorldModel         = "models/healthvial.mdl"
SWEP.UseHands 				= false

SWEP.AutoSpawnable      = true
SWEP.Spawnable          = true

SWEP.CanBuy             = {}
SWEP.LimitedStock       = true

SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1

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
      pl:EmitSound(Sound("grenade_health.wav"))

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
         
         -- Set Status and print Message
         JM_RemoveBuffFromThisPlayer("jm_buff_healthgrenade",pl)
         JM_GiveBuffToThisPlayer("jm_buff_healthgrenade",pl,pl)
         -- End Of

      end

      self:TakePrimaryAmmo(1)
      if self:Clip1() <= 0 then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
         self:Remove()
      end

   end

end

