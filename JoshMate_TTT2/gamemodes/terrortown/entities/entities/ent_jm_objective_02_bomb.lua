if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Bomb"
end

ENT.Type = "anim"
ENT.Model = Model("models/Combine_Helicopter/helicopter_bomb01.mdl")

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 255, 0, 0, 255))
	
	self.Objective_Server_Press_Count 	= 0
	self.Objective_Server_Press_Max 	= 6
	self.Objective_Server_Press_Colour	= Color( 255, 0, 0, 255)

	self.Objective_Bomb_Time_Fuse		= 60
	self.Objective_Bomb_Time_Spawn		= CurTime()
	self.Objective_Bomb_Time_Detonate   = self.Objective_Bomb_Time_Spawn + self.Objective_Bomb_Time_Fuse

	self.Objective_Bomb_HasWarned_Half		= false
	self.Objective_Bomb_HasWarned_Close		= false
	self.Objective_Bomb_HasWarned_Detonate	= false

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- UI HUD ICON
	if SERVER then self:SendWarn(true) end 
	-- END of 
end

function ENT:TakesHit() 

	if CLIENT then return end

	self.Objective_Server_Press_Count = self.Objective_Server_Press_Count + 1
	self:EmitSound("effect_objective_hit.mp3")

	self.Objective_Server_Press_Colour = (self.Objective_Server_Press_Count * (255 / self.Objective_Server_Press_Max))
	self.Objective_Server_Press_Colour = Color( 255, 0 + self.Objective_Server_Press_Colour, 0 + self.Objective_Server_Press_Colour, 255)
	self:SetColor(self.Objective_Server_Press_Colour)

	if self.Objective_Server_Press_Count >= self.Objective_Server_Press_Max then

		self:Remove()

		JM_Function_PlaySound("pulsepad_hit.wav")

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("cball_explode", effect)
		sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

		if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

		local listOfObjectives = ents.FindByClass( "ent_jm_objective_02_bomb" )
		local numberOfFilesLeft = (#listOfObjectives - 1)
		JM_Function_PrintChat_All("Objective", "A Bomb has been defused! (" .. tostring(numberOfFilesLeft) .. " Left!)")
		self:SendWarn(false) 

		if #listOfObjectives <= 0 then

			JM_Function_PrintChat_All("Objective", "All bombs have been defused!")
			JM_Function_PlaySound("gamemode/bomb_alldefused.wav")

		end
	end
end

function ENT:OnTakeDamage(dmginfo)

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	local activator = dmginfo:GetAttacker()	

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then

		local weaponUsed = dmginfo:GetInflictor()

		if weaponUsed:GetClass() == "weapon_jm_special_crowbar" then
			self:TakesHit() 
		end

	end

end

function ENT:OnRemove()

	if SERVER then self:SendWarn(false) end

end

function ENT:Think()

	if CLIENT then return end

	-- Half Time Left
	if (CurTime() + (self.Objective_Bomb_Time_Fuse/2)) >= self.Objective_Bomb_Time_Detonate and not self.Objective_Bomb_HasWarned_Half then

		local timeLeftOnTimer = self.Objective_Bomb_Time_Detonate - CurTime()

		self.Objective_Bomb_HasWarned_Half = true

		JM_Function_PrintChat_All("Objective", "Bomb Timer: 30 Seconds!")
		JM_Function_PlaySound("gamemode/bomb_half.wav")

	end

	-- 10 Seconds Left
	if (CurTime() + 10) >= self.Objective_Bomb_Time_Detonate and not self.Objective_Bomb_HasWarned_Close then

		self.Objective_Bomb_HasWarned_Close = true
		local timeLeftOnTimer = self.Objective_Bomb_Time_Detonate - CurTime()
		JM_Function_PrintChat_All("Objective", "Bomb Timer: 10 Seconds!")
		JM_Function_PlaySound("gamemode/bomb_close.wav")

	end

	-- DETONATE!
	if CurTime() >= self.Objective_Bomb_Time_Detonate and not self.Objective_Bomb_HasWarned_Detonate then

		self.Objective_Bomb_HasWarned_Detonate = true
		JM_Function_PrintChat_All("Objective", "The Bombs have Detonated! Traitors Win...")
		JM_Function_PlaySound("c4_huge_boom.wav")

		for _, ply in ipairs( player.GetAll() ) do
			if (ply:IsValid() and ply:IsTerror() and ply:Alive()) and not ply:IsTraitor() then

				local effect = EffectData()
				effect:SetStart(ply:GetPos())
				effect:SetOrigin(ply:GetPos())
				util.Effect("Explosion", effect, true, true)
				util.Effect("HelicopterMegaBomb", effect, true, true)

				ply:TakeDamage( 9999, ply, self)
			end
		end

	end

end

--- Josh Mate Hud Warning
if SERVER then
	function ENT:SendWarn(armed)
		net.Start("TTT_ObjectiveWarn")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteBit(armed)

		if armed then
			net.WriteVector(self:GetPos())
		end

		net.Broadcast()
	end
end


-- ESP Halo effect

local JM_Server_Halo_Colour = Color(255,0,0,255)

hook.Add( "PreDrawHalos", "Halos_Bombs", function()

    halo.Add( ents.FindByClass( "ent_jm_objective_02_bomb" ), JM_Server_Halo_Colour, 5, 5, 2, true, true )
 
end )