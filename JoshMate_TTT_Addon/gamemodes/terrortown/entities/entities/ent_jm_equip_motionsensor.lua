if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Motion Sensor"
end

ENT.Type = "anim"
ENT.Model = Model("models/props/de_nuke/emergency_lighta.mdl")

ENT.CanHavePrints = false

local motionSensor_TrackRadius		= 180
local motionSensor_TrackDelay		= 1

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_motionsensor",self:GetPos(),0,2)
end

function ENT:OnRemove()

	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

end

function ENT:Think()

	self:MotionSense()

end

function ENT:MotionSense()
	
	if not self:IsValid() then return end

	local r =  motionSensor_TrackRadius * motionSensor_TrackRadius -- square so we can compare with dot product directly
	local center = self:GetPos()

	-- Track Players in radius
	d = 0.0
	diff = nil
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		
		if not ply:Team() == TEAM_TERROR  or not ply:Alive() then continue end

		-- dot of the difference with itself is distance squared
		diff = center - ply:GetPos()
		d = diff:Dot(diff)

		if d >= r then continue end

		-- Give the buff
		if SERVER  and not ply:GetNWBool(JM_Global_Buff_MotionSensorTrack_NWBool)then 
			JM_GiveBuffToThisPlayer("jm_buff_motionsensortrack",ply,self:GetOwner()) 
		end

	end

	

end


