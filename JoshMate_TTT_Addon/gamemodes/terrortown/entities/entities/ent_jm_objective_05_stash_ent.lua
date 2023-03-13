if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Stash"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_lab/partsbin01.mdl")

local GameMode_Stash_Traitor_Reward_HP				= 50
local GameMode_Stash_Traitor_Reward_Credits			= 2

local GameMode_Stash_Innocent_HealthLostMult		= 0.5

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 255, 255, 0, 255))

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_objective_stash",self:GetPos(),0,2)

	self.stashHasSpawned = false
	self.stashTimeToSpawn = CurTime() + 90

end

function ENT:Use( activator, caller )

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:IsTraitor() and activator:Alive() then

		self:StashCapture() 

	end
end


function ENT:StashCapture() 

	if CLIENT then return end

	self:EmitSound("gamemode/file_hit.mp3")
	JM_Function_PlaySound("pulsepad_hit.wav")
	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("cball_explode", effect)
	sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

	-- Build a list of possible targets
	for _,pl in pairs(player.GetAll()) do

		-- Traitors
		if pl:IsValid() and pl:Alive() and pl:IsTerror() and pl:IsTraitor() then

			pl:AddCredits(GameMode_Stash_Traitor_Reward_Credits)
			pl:SetMaxHealth(pl:GetMaxHealth()+GameMode_Stash_Traitor_Reward_HP)
			pl:SetHealth(math.Clamp(pl:Health()+GameMode_Stash_Traitor_Reward_HP, 1, pl:GetMaxHealth()))

		end
		-- Innocents
		if pl:IsValid() and pl:Alive() and pl:IsTerror() and pl:IsInnocent() or pl:IsDetective() then

			pl:SetMaxHealth(pl:GetMaxHealth()*GameMode_Stash_Innocent_HealthLostMult)
			pl:SetHealth(math.Clamp(pl:Health(), 1, pl:GetMaxHealth()))

		end

	end


	JM_Function_PrintChat_All("Stash", "The Stash has been captured!")
	JM_Function_PrintChat_All("Stash", "Innocents lose 50% of their max HP")
	JM_Function_PrintChat_All("Stash", "Traitors gain 50 Max HP and 2 Credits")
	self:Remove()

end

function ENT:Think()

	if self.stashHasSpawned == false and CurTime() >= self.stashTimeToSpawn then

		self.stashHasSpawned = true
		if SERVER then
			local ent = ents.Create("weapon_jm_zloot_traitor_tester")
			ent:SetPos(self:GetPos())
			ent:Spawn()
			JM_Function_PrintChat_All("Stash", "A portable tester has spawned near the stash!")
		end

	end

end

function ENT:OnRemove()

	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

end
