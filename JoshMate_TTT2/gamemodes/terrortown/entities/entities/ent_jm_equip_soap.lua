AddCSLuaFile()

ENT.Type                = "anim"
ENT.PrintName           = "Soap"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Trap"
ENT.Instructions        = "Trap"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false


local JM_Soap_Model                 = "models/soap.mdl"
local JM_Soap_Colour_Active         = Color( 255, 255, 255, 30 )
local JM_Soap_Sound_HitPlayer       = "slip.wav"
local JM_Soap_Sound_Destroyed       = "0_main_click.wav"

local JM_Soap_Velocity_Up 			= 700
local JM_Soap_Velocity_Direction	= 1500

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

function ENT:Initialize()
	self:SetModel(JM_Soap_Model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- JoshMate Changed
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Soap_Colour_Active) 
	self:DrawShadow(false)

	-- Warning
	if SERVER then self:SendWarn(true) end

end

function ENT:Use( activator, caller )

	if CLIENT then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() then
			self.Owner:ChatPrint("[Soap] - Your Soap has been removed!")
            self:Effect_Sparks()
            self:SendWarn(false)
			self:Remove()
		end
		
	end

end

function ENT:Touch(toucher)

	if SERVER then

        if(not toucher:IsValid()) then return end
        if(not toucher:IsPlayer()) then return end
        if(not toucher:IsTerror()) then return end
        if(not toucher:Alive()) then return end
        if(not GAMEMODE:AllowPVP()) then return end

		-- Soap Launch Effect
		self:EmitSound(JM_Soap_Sound_HitPlayer)
		local directionFacing = toucher:GetAimVector()
		local upwards = Vector( 0, 0, JM_Soap_Velocity_Up)
		local directionWithoutY = Vector(directionFacing.x, directionFacing.y, 0)
		local velocity = (directionWithoutY * JM_Soap_Velocity_Direction)  + upwards
		toucher:SetVelocity(velocity);
		-- End Of

        -- JM Changes Extra Hit Marker
        net.Start( "hitmarker" )
        net.WriteFloat(0)
        net.Send(self.Owner)
        -- End Of

        -- HUD Message
        toucher:ChatPrint("[Soap] - You have slipped on some Soap!")
        self.Owner:ChatPrint("[Soap] - " .. toucher:GetName() .. " has slipped on your Soap!" )
        -- End Of

        toucher:EmitSound(JM_Soap_Sound_HitPlayer);
        self:Effect_Sparks()
        self:SendWarn(false)
        self:Remove()
	
	end
end

function ENT:Effect_Sparks()

	if not IsValid(self) then return end
    
    self:EmitSound(JM_Soap_Sound_Destroyed);

	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	
	util.Effect("cball_explode", effect, true, true)

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
