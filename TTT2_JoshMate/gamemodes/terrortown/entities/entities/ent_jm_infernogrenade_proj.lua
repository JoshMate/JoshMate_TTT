-- burning nade projectile

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_grenade.mdl")

ENT.Trail_Enabled = 1
ENT.Trail_Colour = Color(255,0,0,150)

local JM_Inferno_Blast_Damage          = 6
local JM_Inferno_Blast_Radius          = 225
local JM_Inferno_Blast_Duration        = 10
local JM_Inferno_Blast_TickDelay       = 0.25

---
-- @param Entity dmgowner
-- @oaram Vector center
-- @param number radius
function Inferno_Sphere(dmgowner, center, radius, damage, anchor)
	-- It seems intuitive to use FindInSphere here, but that will find all ents
	-- in the radius, whereas there exist only ~16 players. Hence it is more
	-- efficient to cycle through all those players and do a Lua-side distance
	-- check.

   if not anchor:IsValid() then return end

	local r = radius * radius -- square so we can compare with dot product directly

	-- pre-declare to avoid realloc
	local d = 0.0
	local diff = nil
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]

		if ply:Team() ~= TEAM_TERROR then continue end

		-- dot of the difference with itself is distance squared
		diff = center - ply:GetPos()
		d = diff:Dot(diff)

		if d >= r then continue end

      

		local dmginfo = DamageInfo()
		dmginfo:SetDamage(damage)
		dmginfo:SetAttacker(dmgowner)
      local inflictor = ents.Create("weapon_jm_equip_inferno")
		dmginfo:SetInflictor(inflictor)
		dmginfo:SetDamageType(DMG_BURN)
		dmginfo:SetDamageForce(center - ply:GetPos())
		dmginfo:SetDamagePosition(ply:GetPos())

		ply:TakeDamageInfo(dmginfo)

	end
end

function ENT:Explode(tr)

   if SERVER then

      self.Entity:EmitSound(Sound("grenade_inferno.wav"))

      self:SetNoDraw(true)
      self:SetSolid(SOLID_NONE)
      
      local pos = self:GetPos()

      local effect = EffectData()
      effect:SetStart(pos)
      effect:SetOrigin(pos)
      util.Effect("Explosion", effect, true, true)

      

      -- Fire
      local fire = ents.Create( "env_fire" )
      fire:SetPhysicsAttacker(self.Owner)
      fire:SetPos( self:GetPos())
      fire:SetKeyValue( "health", JM_Inferno_Blast_Duration )
      fire:SetKeyValue( "firesize", "64" )
      fire:SetKeyValue( "fireattack", "1" )
      fire:SetKeyValue( "damagescale", "0" )
      fire:SetKeyValue( "StartDisabled", "0" )
      fire:SetKeyValue( "firetype", "0" )
      fire:SetKeyValue( "spawnflags", "134" )
      fire:SetKeyValue( "spawnflags", "256" )
      fire:Spawn()
      fire:Fire( "StartFire", "", 0 )

      -- Blast
      local JMThrower = self:GetThrower()
      local timerName = "timer_InfernoEffectTimer_" .. CurTime()
      timer.Create( timerName, JM_Inferno_Blast_TickDelay, JM_Inferno_Blast_Duration*4, function () Inferno_Sphere(JMThrower, pos, JM_Inferno_Blast_Radius, JM_Inferno_Blast_Damage, fire) end )
      
      -- Done
      self:Remove()

   else
      -- Smoke

      local smokeparticles = {
         Model("particle/particle_smokegrenade"),
         Model("particle/particle_noisesphere")
      };

      local center = self:GetPos()
      local em = ParticleEmitter(center)

      for i=1, 8 do
         local prpos = VectorRand()
         prpos.z = prpos.z + 32
         local p = em:Add(table.Random(smokeparticles), center + prpos)
         if p then
            p:SetColor(255, 150, 0)
            p:SetStartAlpha(18)
            p:SetEndAlpha(18)
            p:SetVelocity(VectorRand() * math.Rand(900, 1300))
            p:SetLifeTime(0)
            
            p:SetDieTime(JM_Inferno_Blast_Duration)

            p:SetStartSize(200)
            p:SetEndSize(200)
            p:SetRoll(math.random(-180, 180))
            p:SetRollDelta(math.Rand(-0.1, 0.1))
            p:SetAirResistance(600)

            p:SetCollide(true)
            p:SetBounce(0.4)

            p:SetLighting(false)
         end
      end 
      em:Finish()
   
   end

   
end

function ENT:PhysicsCollide(tr)
	self:SetExplodeTime(CurTime())
end


