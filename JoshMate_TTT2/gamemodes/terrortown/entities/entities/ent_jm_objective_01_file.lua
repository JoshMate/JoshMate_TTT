if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Objective: Server"
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
	self.Objective_Server_Press_Max 	= 10
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

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:IsTraitor() then

		if IsValid(activator) and activator:Alive() and SERVER then
			
			self.Objective_Server_Press_Count = self.Objective_Server_Press_Count + 1
			self:EmitSound("effect_objective_hit.mp3")

			self.Objective_Server_Press_Colour = (self.Objective_Server_Press_Count * (255 / self.Objective_Server_Press_Max))
			self.Objective_Server_Press_Colour = Color( 255 - self.Objective_Server_Press_Colour, 255 - self.Objective_Server_Press_Colour, 255 - self.Objective_Server_Press_Colour, 255)
			self:SetColor(self.Objective_Server_Press_Colour)

			if self.Objective_Server_Press_Count >= self.Objective_Server_Press_Max then

				self:Remove()

			end
		end	
	end
end


function ENT:OnRemove()

	if SERVER then self:SendWarn(false) end

	if SERVER then
		JM_Function_PlaySound("pulsepad_hit.wav")

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("cball_explode", effect)
		sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

		local listOfObjectives = ents.FindByClass( "ent_jm_objective_01_file" )
		if #listOfObjectives <= 1 then
			EndRound("traitors")
			JM_Function_PlaySound("effect_objective_end.mp3")
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

local JM_Server_Halo_Colour = Color(0,255,0,255)

hook.Add( "PreDrawHalos", "Halos_Servers", function()

    halo.Add( ents.FindByClass( "ent_jm_0_obj_server" ), JM_Server_Halo_Colour, 5, 5, 2, true, true )
 
end )