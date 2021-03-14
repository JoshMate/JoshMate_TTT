AddCSLuaFile()

DEFINE_BASECLASS "weapon_tttbase"

SWEP.HoldType               = "physgun"

if CLIENT then
   SWEP.PrintName           = "newton_name"
   SWEP.Slot                = 7

   SWEP.ViewModelFlip       = false
   SWEP.ViewModelFOV        = 54

   SWEP.Icon               = "vgui/ttt/icon_launch"

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A silent utility weapon
	
Creates a physics explosion at your cursor
      
Players and props will be pushed violently
      
Only has two shots
]]

   };
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Damage        = 10
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.Recoil        = 0
SWEP.Primary.ClipSize      = 2
SWEP.Primary.DefaultClip   = 2
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


local function PushPullRadius(pos, pusher)
   local radius = 400
   local phys_force = 3000
   local push_force = 300

   -- pull physics objects and push players
   for k, target in ipairs(ents.FindInSphere(pos, radius)) do
      if IsValid(target) then
         local tpos = target:LocalToWorld(target:OBBCenter())
         local dir = (tpos - pos):GetNormal()
         local phys = target:GetPhysicsObject()

         if target:IsPlayer() and (not target:IsFrozen()) and ((not target.was_pushed) or target.was_pushed.t != CurTime()) then
            
            -- JM Changes Extra Hit Marker
            net.Start( "hitmarker" )
            net.WriteFloat(0)
            net.Send(pusher)
            -- End Of

            -- always need an upwards push to prevent the ground's friction from
            -- stopping nearly all movement
            dir.z = math.abs(dir.z) + 1

            local push = dir * push_force

            -- try to prevent excessive upwards force
            local vel = target:GetVelocity() + push
            vel.z = math.min(vel.z, push_force)

            target:SetVelocity(vel)

            target.was_pushed = {att=pusher, t=CurTime(), wep="weapon_ttt_push"}

         elseif IsValid(phys) then
            phys:ApplyForceCenter(dir * -1 * phys_force)
         end
      end
   end

   local phexp = ents.Create("env_physexplosion")
   if IsValid(phexp) then
      phexp:SetPos(pos)
      phexp:SetKeyValue("magnitude", 150) --max
      phexp:SetKeyValue("radius", radius)
      -- 1 = no dmg, 2 = push ply, 4 = push radial, 8 = los, 16 = viewpunch
      phexp:SetKeyValue("spawnflags", 1 + 2 + 16)
      phexp:Spawn()
      phexp:Fire("Explode", "", 0.2)
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
      util.Effect("TeslaHitboxes", effect, true, true)
      util.Effect("cball_explode", effect, true, true)
      sound.Play(Sound("npc/assassin/ball_zap1.wav"), tr.HitPos, 100, 100)

      PushPullRadius(tr.HitPos, owner)
   end



end



