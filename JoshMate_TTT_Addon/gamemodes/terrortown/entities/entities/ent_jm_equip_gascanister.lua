AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName= "Gas Canister"
ENT.Author= "Josh Mate"
ENT.Purpose= "Gasser"
ENT.Instructions= "Gasser"
ENT.Spawnable = true
ENT.AdminSpawnable = false

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end


local JM_GasCanister_Colour_Dormant			= Color( 255, 255, 255, 10 )
local JM_GasCanister_Colour_Armed			= Color( 60, 255, 60, 255 )

local JM_GasCanister_Damage_Radius			= 600
local JM_GasCanister_Damage_Delay			= 1
local JM_GasCanister_Damage_Amount			= 6
local JM_GasCanister_Damage_LifeTime		= 30

local JM_GasCanister_Arm_Delay				= 5

local JM_GasCanister_Sound_Armed		= "weapons/ar2/ar2_reload_push.wav"
local JM_GasCanister_Sound_Destroyed	= "weapons/ar2/npc_ar2_altfire.wav"


function ENT:GasCanister_Effects_Sparks()
	if not IsValid(self) then return end
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
end

function ENT:GasCanister_Arm()
	if SERVER then
		if IsValid(self) then 

			-- Effects
			self:GasCanister_Effects_Sparks()
			if SERVER then self:EmitSound(JM_GasCanister_Sound_Armed); end
			
			self.isArmed = true
			self:SetColor(JM_GasCanister_Colour_Armed) 
			self.selfDestructTime = CurTime() + JM_GasCanister_Damage_LifeTime
			self.nextGasEmitTime = CurTime() + JM_GasCanister_Damage_Delay

		end 
	end
end

function ENT:GasCanister_Die()
	if SERVER then
		if IsValid(self) then 
			self:GasCanister_Effects_Sparks()
			if SERVER then self:EmitSound(JM_GasCanister_Sound_Destroyed); end
			self:Remove()
		end 
	end
end

function ENT:Initialize()

	-- Collisions and Phyiscs
	self:SetModel( "models/maxofs2d/thruster_propeller.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Visuals
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_GasCanister_Colour_Dormant) 
	self:DrawShadow(false)

	-- Setup stats
	self.isArmed = false
	self.armTime = CurTime() + JM_GasCanister_Arm_Delay 
	self.selfDestructTime = CurTime() + JM_GasCanister_Damage_LifeTime

	--Prevent holding E
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	
end

function ENT:Use( activator, caller )

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then
		self:GasCanister_Die()
		JM_Function_PrintChat(self.Owner, "Equipment","Your Gas Canister has been destroyed!")
	end
	
end

function ENT:GasCanister_EmitGas()

	local center = self:GetPos()

	if CLIENT then
		-- Handle Smoke
		local pos = self:GetPos() -- The origin position of the effect
		
		local emitter = ParticleEmitter( pos ) -- Particle emitter in this position
		
		for i = 0, 100 do -- Do 100 particles
			local part = emitter:Add( "effects/spark", pos ) -- Create a new particle at pos
			if ( part ) then
				part:SetDieTime( 1 ) -- How long the particle should "live"
		
				part:SetStartAlpha( 255 ) -- Starting alpha of the particle
				part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
		
				part:SetStartSize( 5 ) -- Starting size
				part:SetEndSize( 0 ) -- Size when removed
		
				part:SetGravity( Vector( 0, 0, -250 ) ) -- Gravity of the particle
				part:SetVelocity( VectorRand() * 50 ) -- Initial velocity of the particle
			end
		end
		
		emitter:Finish()
	end

	if SERVER then
		-- Handle Damage
		local r = JM_GasCanister_Damage_Radius * JM_GasCanister_Damage_Radius -- square so we can compare with dot product directly

		-- pre-declare to avoid realloc
		local d = 0.0
		local diff = nil
		local dmg = 0
		local plys = player.GetAll()

		for i = 1, #plys do
			local ply = plys[i]

			if ply:Team() ~= TEAM_TERROR then continue end

			-- dot of the difference with itself is distance squared
			local distance = center:Distance(ply:GetPos())
			diff = center - ply:GetPos()
			d = diff:Dot(diff)

			if d >= r then continue end

			dmg = JM_GasCanister_Damage_Amount

			-- Only hurt what they have, more accurate Hit Markers
			if ply:Health() <= dmg then dmg = ply:Health() end

			local dmginfo = DamageInfo()
			dmginfo:SetDamage(dmg)
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(DMG_GENERIC)
			dmginfo:SetDamageForce(center - ply:GetPos())
			dmginfo:SetDamagePosition(ply:GetPos())

			ply:TakeDamageInfo(dmginfo)
		end
	end

end

function ENT:Think()

	if self.isArmed == false and CurTime() >= self.armTime then
		self:GasCanister_Arm()
	end

	if self.isArmed == true and CurTime() >= self.nextGasEmitTime then
		self:GasCanister_EmitGas()
		self.nextGasEmitTime = CurTime() + JM_GasCanister_Damage_Delay
	end
	
	if self.isArmed == true and CurTime() >= self.selfDestructTime then
        self:GasCanister_Die()
    end

end



