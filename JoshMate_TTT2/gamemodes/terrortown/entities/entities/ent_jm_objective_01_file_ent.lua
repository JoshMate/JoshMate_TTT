if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "File"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_lab/filecabinet02.mdl")

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 255, 255, 255, 255))
	
	self.Objective_Server_Press_Count 	= 0
	self.Objective_Server_Press_Max 	= 3
	self.Objective_Server_Press_Colour	= Color( 255, 255, 255, 255)

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

    if ATSM_IsLivingTraitor(activator) and IsValid(self) then

		if activator:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
			self:TakesHit() 
		else
			JM_Function_PrintChat(activator, "Protect The Files", "You need your hands free to do that...")
		end

	end
end


function ENT:TakesHit() 

	if CLIENT then return end

	self.Objective_Server_Press_Count = self.Objective_Server_Press_Count + 1
	self:EmitSound("gamemode/file_hit.mp3")

	self.Objective_Server_Press_Colour = (self.Objective_Server_Press_Count * (255 / self.Objective_Server_Press_Max))
	self.Objective_Server_Press_Colour = Color( 255, 255 - self.Objective_Server_Press_Colour, 255 - self.Objective_Server_Press_Colour, 255)
	self:SetColor(self.Objective_Server_Press_Colour)

	if self.Objective_Server_Press_Count >= self.Objective_Server_Press_Max then

		self:Remove()

		JM_Function_PlaySound("pulsepad_hit.wav")

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("cball_explode", effect)
		sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

		if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

		local listOfObjectives = ents.FindByClass( "ent_jm_objective_01_file_ent" )
		local numberOfFilesLeft = (#listOfObjectives - 2)
		JM_Function_PrintChat_All("Protect The Files", "A File has been destroyed! (" .. tostring(numberOfFilesLeft) .. " Left!)")
		self:SendWarn(false) 

		if #listOfObjectives <= 2 then
			JM_Function_PrintChat_All("Protect The Files", "The Files have been Destroyed! Traitors Win...")
			EndRound("traitors")
			JM_Function_PlaySound("gamemode/file_end.mp3")
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

local JM_Server_Halo_Colour = Color(0,255,0,255)

hook.Add( "PreDrawHalos", "Halos_Files", function()

    halo.Add( ents.FindByClass( "ent_jm_objective_01_file" ), JM_Server_Halo_Colour, 5, 5, 2, true, true )
 
end )