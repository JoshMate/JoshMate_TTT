AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Visualiser"
ENT.Author                      = "Seb"
ENT.Purpose                     = "Drops Visualiser"
ENT.Instructions                = "Drops Visualiser"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

ENT.Model 						= Model("models/Items/battery.mdl")
ENT.RenderGroup 				= RENDERGROUP_BOTH

ENT.Range 						= 128
ENT.MaxScenesPerPulse 			= 6
ENT.SceneDuration 				= 5
ENT.PulseDelay    				= 1

ENT.visualiserLifeTime			= 20
ENT.karmaRewardClaimed 			= false

function ENT:Initialize()
	self:SetModel("models/Items/battery.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	-- Start up scan timer
	self.visualiserNextScanTime 	= CurTime() + self.PulseDelay
	self.visualiserNextDieTime		= CurTime() + self.visualiserLifeTime

end

function ENT:GetNearbyCorpses()
	local pos = self:GetPos()
 
	local near = ents.FindInSphere(pos, self.Range)
	if not near then return end
 
	local near_corpses = {}
 
	local ent = nil
	for i=1, #near do
	   ent = near[i]
	   if IsValid(ent) and ent.player_ragdoll and ent.scene then
		  table.insert(near_corpses, {ent=ent, dist=pos:LengthSqr()})
	   end
	end
 
	return near_corpses
 end


 local zapsound = Sound("npc/assassin/ball_zap1.wav")

function ENT:OnTakeDamage(dmginfo)
	if SERVER then self:Remove() end
end

local dummy_keys = {"victim", "killer"}
function ENT:ShowSceneForCorpse(corpse)
   local scene = corpse.scene
   local hit = scene.hit_trace
   local dur = self.SceneDuration

   if hit then
		-- line showing bullet trajectory
		local e = EffectData()
		e:SetEntity(corpse)
		e:SetStart(hit.StartPos)
		e:SetOrigin(hit.HitPos)
		e:SetMagnitude(hit.HitBox)
		e:SetScale(dur)
		util.Effect("crimescene_shot", e)


		-- Attacker Effect
		local vPoint = Vector( hit.StartPos)
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		util.Effect( "StunstickImpact", effectdata )


		-- Victim Effect
		local vPoint2 = Vector( hit.HitPos)
		local effectdata2 = EffectData()
		effectdata2:SetOrigin( vPoint2 )
		util.Effect( "BloodImpact", effectdata )

		-- Josh Mate Karma Reward Code
		if self.karmaRewardClaimed == false then
			self.karmaRewardClaimed = true
			JM_Function_Karma_Reward(self.Owner, JM_KARMA_REWARD_ACTION_VISUALISER, "Visualised")
		end
		-- End of Karma Reward Code
		
   end

   if not scene then return end
   for _, dummy_key in ipairs(dummy_keys) do
      local dummy = scene[dummy_key]

      if dummy then
         -- Horrible sins committed here to get all the data we need over the
         -- wire, the pose parameters are going to be truncated etc. but
         -- everything sort of works out. If you know a better way to get this
         -- much data to an effect, let me know.
         local e = EffectData()
         e:SetEntity(corpse)
         e:SetOrigin(dummy.pos)
         e:SetAngles(dummy.ang)
         e:SetColor(dummy.sequence)
         e:SetScale(dummy.cycle)
         e:SetStart(Vector(dummy.aim_yaw, dummy.aim_pitch, dummy.move_yaw))
         e:SetRadius(dur)

      end
   end
end

local scanloop = Sound("weapons/gauss/chargeloop.wav")

function ENT:StartScanSound()
   if not self.ScanSound then
      self.ScanSound = CreateSound(self, scanloop)
   end

   if not self.ScanSound:IsPlaying() then
      self.ScanSound:PlayEx(0.5, 100)
   end
end

function ENT:StopScanSound(force)
	if self.ScanSound and self.ScanSound:IsPlaying() then
	   self.ScanSound:FadeOut(0.5)
	end
 
	if self.ScanSound and force then
	   self.ScanSound:Stop()
	end
 end

if CLIENT then
	local glow = Material("sprites/blueglow2")
	function ENT:DrawTranslucent()
	   render.SetMaterial(glow)
	   render.DrawSprite(self:LocalToWorld(self:OBBCenter()), 64, 64, COLOR_WHITE)	   
	end
end

function ENT:Think()

	if CurTime() >= self.visualiserNextScanTime then

		-- Start up scan timer
		self.visualiserNextScanTime = CurTime() + self.PulseDelay

		if SERVER then
	
			-- prevent starting effects when round is about to restart
			if GetRoundState() == ROUND_POST then return end
	
			local corpses = self:GetNearbyCorpses()
			if #corpses > self.MaxScenesPerPulse then
			table.SortByMember(corpses, "dist", function(a, b) return a > b end)
			end
	
			local e = EffectData()
			e:SetOrigin(self:GetPos())
			e:SetRadius(128)
			e:SetMagnitude(0.2)
			e:SetScale(4)
			util.Effect("pulse_sphere", e)
	
			-- show scenes for nearest corpses
			for i=1, self.MaxScenesPerPulse do
			local corpse = corpses[i]
			if corpse and IsValid(corpse.ent) then
				self:ShowSceneForCorpse(corpse.ent)
			end
			end
	
			if #corpses > 0 then
			self:StartScanSound()
			else
			self:StopScanSound()
			end
	
		end
	end

	if CurTime() >= self.visualiserNextDieTime then
		if SERVER then self:Remove() end
	end 

end

function ENT:OnRemove()
	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("cball_explode", effect)
	sound.Play(zapsound, self:GetPos())
	self:StopScanSound(true)
end