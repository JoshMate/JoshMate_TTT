AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dopamine button"
ENT.Author = "Simon"
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true
ENT.Model = Model("models/props_lab/filecabinet02.mdl")

ENT.neetsThatPushedTheButton = {}

if CLIENT then

	function ENT:Draw()
		self:DrawModel()
	end

	-- CLIENT CAN'T GO PAST HERE
	return
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetUseType(SIMPLE_USE)
end

function ENT:Use( activator, caller )

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror()  and activator:Alive() then

		local buttonOutcome = neetsThatPushedTheButton[activator:Nick()]

		--not presed before
		if buttonOutcome == nil then
			--random chance to die
			local roll = math.random(10)
			
			local killDecision = roll == 1

			neetsThatPushedTheButton[activator:Nick()] = killDecision

			if killDecision then
				local effect = EffectData()
				effect:SetStart(self:GetPos())
				effect:SetOrigin(self:GetPos())
				util.Effect("Explosion", effect, true, true)
				util.Effect("HelicopterMegaBomb", effect, true, true)

				activator:TakeDamage( 9999, activator, self)
				sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())
			else
				self.Entity:EmitSound(Sound("grenade_glue.wav"));
			end
		else
			self.Entity:EmitSound(Sound("grenade_glue.wav"));
		end

	end
end

