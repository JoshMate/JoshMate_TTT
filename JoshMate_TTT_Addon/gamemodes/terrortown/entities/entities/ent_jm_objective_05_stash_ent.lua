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

end

function ENT:Use( activator, caller )

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:IsTraitor() and activator:Alive() then

		if activator:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
			self:StashCapture() 
		else
			JM_Function_PrintChat(activator, "Stash", "You need your hands free to do that...")
		end

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
