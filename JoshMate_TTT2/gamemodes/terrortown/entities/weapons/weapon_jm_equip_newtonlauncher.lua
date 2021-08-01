AddCSLuaFile()

DEFINE_BASECLASS "weapon_jm_base_gun"

SWEP.HoldType               = "physgun"

if CLIENT then
   SWEP.PrintName           = "Newton Launcher"
   SWEP.Slot                = 7

   SWEP.ViewModelFlip       = false
   SWEP.ViewModelFOV        = 54

   SWEP.Icon               = "vgui/ttt/icon_launch"

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A lethal utility weapon
	
Shoot a huge burst of energy at a taget location
      
Players will be pushed away from the blast

They will be dazed and their weapons dropped      
]]

   };
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Damage        = 10
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.Recoil        = 0
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 0

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 50
SWEP.Primary.Automatic     = false

SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.Sound         = "shoot_newton.wav"
SWEP.NoSights              = true


SWEP.Kind                  = WEAPON_EQUIP2
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_PUSH

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_superphyscannon.mdl"
SWEP.WorldModel            = "models/weapons/w_physics.mdl"

-- Newton Specifically



function SWEP:Initialize()
   if SERVER then
      self:SetSkin(1)
   end
   return self.BaseClass.Initialize(self)
end


local function PushPullRadius(pos, pusher, newtonLauncher)
   local radius = 500
   local push_force = 500

   -- push players
   for k, target in ipairs(ents.FindInSphere(pos, radius)) do
      if target:IsValid() and target:IsPlayer() and target:Alive() and target:IsTerror() then
         local tpos = target:LocalToWorld(target:OBBCenter())
         local dir = (tpos - pos):GetNormal()
            
         -- JM Changes Extra Hit Marker
         net.Start( "hitmarker" )
         net.WriteFloat(0)
         net.Send(pusher)
         -- End Of

         -- Drop currently Held Weapon
         local curWep = target:GetActiveWeapon()
         if not curWep == newtonLauncher then 
            if curWep and curWep:IsValid() and (target:GetActiveWeapon():PreDrop()) then target:GetActiveWeapon():PreDrop() end
            if (curWep.AllowDrop) then
               target:DropWeapon()
            end
            target:SelectWeapon("weapon_jm_special_crowbar")
            -- End of Drop
         end

         -- Set Status and print Message
         JM_RemoveBuffFromThisPlayer("jm_buff_newtonlauncher",ent)
         JM_GiveBuffToThisPlayer("jm_buff_newtonlauncher",target,pusher)
         -- End Of

         -- always need an upwards push to prevent the ground's friction from
         -- stopping nearly all movement
         dir.z = math.abs(dir.z) + 1

         local push = dir * push_force

         -- try to prevent excessive upwards force
         local vel = target:GetVelocity() + push
         vel.z = math.min(vel.z, push_force)

         target:SetVelocity(vel)

         target.was_pushed = {att=pusher, t=CurTime(), wep="weapon_jm_equip_newtonlauncher"}

      end
   end
end



function SWEP:PrimaryAttack()
   
   if self.Secondary.IsDelayedByPrimary == 1 then self:SetNextSecondaryFire(CurTime() + self.Primary.Delay) end 
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not self:CanPrimaryAttack() then return end

	if not worldsnd then
		self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
	elseif SERVER then
		sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end

   local cone = self.Primary.Cone
   local num = 1

   local bullet = {}
   bullet.Num    = num
   bullet.Src    = self:GetOwner():GetShootPos()
   bullet.Dir    = self:GetOwner():GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 1
   bullet.Force  = 1
   bullet.Damage = self.Primary.Damage
   bullet.TracerName = "AirboatGunHeavyTracer"

   self:GetOwner():FireBullets( bullet )
   self:TakePrimaryAmmo(1)

   local owner = self:GetOwner()

	if not IsValid(owner) or owner:IsNPC() or not owner.ViewPunch then return end

	owner:ViewPunch(Angle(util.SharedRandom(self:GetClass(), -0.2, -0.1, 0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(), -0.1, 0.1, 1) * self.Primary.Recoil, 0))

   if SERVER then
      local maxShootRange = 5000
      local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * maxShootRange, filter = self.Owner})
      local effect = EffectData()
      effect:SetStart(tr.HitPos)
      effect:SetOrigin(tr.HitPos)
      
      util.Effect("TeslaZap", effect, true, true)
      
      util.Effect("cball_explode", effect, true, true)
      sound.Play(Sound("npc/assassin/ball_zap1.wav"), tr.HitPos, 100, 100)

      PushPullRadius(tr.HitPos, owner, self)
   end

   if SERVER then
      self:Remove()
   end

end



-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Launch a burst of energy", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
-- 