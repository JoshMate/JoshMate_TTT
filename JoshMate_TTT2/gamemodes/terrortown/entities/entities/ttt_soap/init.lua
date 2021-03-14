AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

resource.AddFile("sound/slip.wav")
resource.AddFile("models/soap.dx80.vtx")
resource.AddFile("models/soap.dx90.vtx")
resource.AddFile("models/soap.mdl")
resource.AddFile("models/soap.sw.vtx")
resource.AddFile("models/soap.vvd")
resource.AddFile("materials/models/soap.vmt")
resource.AddFile("materials/models/soap.vtf")

local JM_Soap_Velocity_Up 			= 700
local JM_Soap_Velocity_Direction	= 1500

function ENT:Initialize()
	self:SetModel("models/soap.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- JoshMate Changed
	self:SendWarn(true)
end

function ENT:Use( activator, caller )

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() then
			self.Owner:ChatPrint("[Soap] - Your Soap has been removed!")
			self:Remove()
    		self:SendWarn(false)
		end
		
	end
	
end

function ENT:Think()
end

function ENT:Touch(toucher)
	if !IsValid(toucher) or !toucher:IsPlayer() or !toucher:Alive() then return end
	if (CLIENT) then return end
	self:EmitSound(Sound("slip.wav"))
	local directionFacing = toucher:GetAimVector()
	local upwards = Vector( 0, 0, JM_Soap_Velocity_Up)
	local directionWithoutY = Vector(directionFacing.x, directionFacing.y, 0)
	local velocity = (directionWithoutY * JM_Soap_Velocity_Direction)  + upwards
	toucher:SetVelocity(velocity);
	

	-- Josh Mate Changes
	-- JM Changes Extra Hit Marker
	net.Start( "hitmarker" )
	net.WriteFloat(0)
	net.Send(self.Owner)
	-- End Of
	toucher:ChatPrint("[Soap] - You have slipped on some Soap!")
	self.Owner:ChatPrint("[Soap] - " .. toucher:GetName() .. " Has slipped on your Soap!" )
	self:Remove()
    self:SendWarn(false)
end

--- Josh Mate Hud Warning
if SERVER then
	function ENT:SendWarn(armed)
		net.Start("TTT_HazardWarn")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteBit(armed)

		if armed then
			net.WriteVector(self:GetPos())
			net.WriteString(TEAM_TRAITOR)
		end

		net.Broadcast()
	end

	function ENT:OnRemove()
		self:SendWarn(false)
	end
end