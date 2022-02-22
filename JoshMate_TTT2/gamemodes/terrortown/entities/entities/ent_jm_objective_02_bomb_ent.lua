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
	
	self.Objective_Bomb_Press_Count 	= 0
	self.Objective_Bomb_Press_Max 		= 10
	self.Objective_Bomb_Press_Colour	= Color( 255, 0, 0, 255)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- UI HUD ICON
	if SERVER then self:SendWarn(true) end 
	-- END of 
end

function ENT:Use( activator, caller )

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then

		if activator:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
			self:TakesHit() 
		else
			JM_Function_PrintChat(activator, "Objective", "You need your hands free to do that...")
		end

	end
end

function ENT:TakesHit() 

	if CLIENT then return end

	self.Objective_Bomb_Press_Count = self.Objective_Bomb_Press_Count + 1
	self:EmitSound("gamemode/file_hit.mp3")

	self.Objective_Bomb_Press_Colour = (self.Objective_Bomb_Press_Count * (255 / self.Objective_Bomb_Press_Max))
	self.Objective_Bomb_Press_Colour = Color( 255, 0 + self.Objective_Bomb_Press_Colour, 0 + self.Objective_Bomb_Press_Colour, 255)
	self:SetColor(self.Objective_Bomb_Press_Colour)

	if self.Objective_Bomb_Press_Count >= self.Objective_Bomb_Press_Max then

		self:Remove()

		JM_Function_PlaySound("pulsepad_hit.wav")

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("cball_explode", effect)
		sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

		if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

		local listOfObjectives = ents.FindByClass( "ent_jm_objective_02_bomb_ent" )
		local numberOfFilesLeft = (#listOfObjectives - 1)
		JM_Function_PrintChat_All("Defuse The Bombs", "A Bomb has been defused! (" .. tostring(numberOfFilesLeft) .. " Left!)")
		self:SendWarn(false) 

		if #numberOfFilesLeft <= 0 then

			JM_Function_PrintChat_All("Objective", "All bombs have been defused!")
			JM_Function_PlaySound("gamemode/bomb_alldefused.wav")

		end
	end
end

function ENT:OnRemove()

	if SERVER then self:SendWarn(false) end

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