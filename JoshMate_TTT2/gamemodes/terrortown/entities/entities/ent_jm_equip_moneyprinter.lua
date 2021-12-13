if SERVER then
	AddCSLuaFile()
else
	-- this entity can be DNA-sampled so we need some display info
	ENT.Icon = "vgui/ttt/icon_radio"
	ENT.PrintName = "Money Printer"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_c17/consolebox01a.mdl")

ENT.CanHavePrints = false

function ENT:PrintMoney()

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER and self.Time_Count < 3 then
		self:GetOwner():AddCredits(1)
		self:GetOwner():ChatPrint("[Money Printer] - Printing Complete: +1 Credit!")

		if self.Time_Count == 2 then
			self:GetOwner():ChatPrint("[Money Printer] - Max number of Credits printed...")
		else
			self:GetOwner():ChatPrint("[Money Printer] - You may print 1 more credit.")
		end

		
	end


end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	if SERVER then
		self:SetMaxHealth(10)
	end

	self:SetHealth(10)

	self.Time_Count = 0
	self.Time_Last = 0

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then
		self:GetOwner():ChatPrint("[Money Printer] - Feed me bodies!")
	end

	-- Register with owner
	if CLIENT then
		local client = LocalPlayer()

		if client == self:GetOwner() then
			client.radio = self
		end
	end
end

local zapsound = Sound("npc/assassin/ball_zap1.wav")

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	self:SetHealth(self:Health() - dmginfo:GetDamage())

	if self:Health() > 0 then return end

	self:Remove()

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())

	util.Effect("cball_explode", effect)
	sound.Play(zapsound, self:GetPos())

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then
		self:GetOwner():ChatPrint("[Money Printer] - Your Printer has been Destroyed!")
	end
end


function ENT:OnRemove()

	if CLIENT then
	local client = LocalPlayer()

	if client ~= self:GetOwner() then return end

	client.radio = nil
	end

	if not IsValid(self:GetOwner()) then return end
	self:GetOwner().decoy = nil

end

function ENT:Touch(entity)

	if SERVER and entity:GetClass() == "prop_ragdoll" and self.Time_Last + 1  < CurTime() then

		entityPos = entity:GetPos()

		entity:EmitSound("physics/flesh/flesh_bloody_break.wav")
		entity:SetNotSolid(true)
		entity:Remove()

		self:CreateProp(entityPos, "models/gibs/hgibs.mdl")
		self:CreateProp(entityPos, "models/gibs/hgibs_rib.mdl")
		self:CreateProp(entityPos, "models/gibs/hgibs_scapula.mdl")
		self:CreateProp(entityPos, "models/gibs/hgibs_rib.mdl")
		self:CreateProp(entityPos, "models/gibs/hgibs_scapula.mdl")
		self:CreateProp(entityPos, "models/gibs/hgibs_rib.mdl")
		self:CreateProp(entityPos, "models/gibs/hgibs_spine.mdl")

		-- JM Changes Extra Hit Marker
		net.Start( "hitmarker" )
		net.WriteFloat(0)
		net.Send(self:GetOwner())
		-- End Of

		self.Time_Count = self.Time_Count + 1
		self:PrintMoney()

		self.Time_Last = CurTime()

	end

end

function ENT:CreateProp(entityPos, model)
	local skull = ents.Create( "prop_physics" )
	skull:SetModel(model)
	-- Add a bit of jitter to spawning
	local newPos = entityPos
	newPos.x = newPos.x + math.random( 0, 16 )
	newPos.y = newPos.y + math.random( 0, 16 )
	newPos.x = newPos.x - math.random( 0, 16 )
	newPos.y = newPos.y - math.random( 0, 16 )
	newPos.z = newPos.z + math.random( 0, 4  )
	skull:SetPos(newPos)
	skull:PhysicsInit(SOLID_VPHYSICS)
	skull:SetMoveType(MOVETYPE_VPHYSICS)
	skull:SetSolid(SOLID_VPHYSICS)
	skull:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	skull:Spawn()
 
	local skullPhysics = skull:GetPhysicsObject()
	if skullPhysics:IsValid() then
	   skullPhysics:Wake()
	end
 
	local vel = skull:GetPhysicsObject():GetVelocity()
	vel.z = vel.z + math.random( 150, 300 )
	skull:GetPhysicsObject():AddVelocity( vel )
 
 end

function ENT:Think()
end

