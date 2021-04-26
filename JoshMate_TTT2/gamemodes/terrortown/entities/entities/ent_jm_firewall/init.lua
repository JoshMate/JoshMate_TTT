AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

local JM_Barrier_ArmTime			= 10

local JM_Barrier_Colour_Dormant		= Color( 0, 0, 0, 0 )
local JM_Barrier_Colour_Active		= Color( 50, 50, 50, 50 )

local JM_Barrier_Sound_Destroyed	= "firewall_destroy.wav"
local JM_Barrier_Sound_HitPlayer	= "firewall_hit.wav"

ENT.JM_IsLethal					= false

function ENT:Barrier_Effects_Destroyed()
	if not IsValid(self) then return end
 
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	util.Effect("TeslaHitboxes", effect, true, true)
	util.Effect("cball_explode", effect, true, true)

 end

function ENT:Barrier_Arm()
	if SERVER then
		if IsValid(self) then 

			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetColor(JM_Barrier_Colour_Active) 
			self:DrawShadow(false) 

			self.JM_IsLethal = true
		end 
	end
end

function ENT:Barrier_Die()
	if SERVER then
		
		if IsValid(self) then 
			self:SendWarn(false)
			self:Barrier_Effects_Destroyed()
			self:EmitSound(JM_Barrier_Sound_Destroyed);
			self.JM_IsLethal = false	
			self:Remove()		
		end 
		
	end
end

function ENT:Initialize()
	self:SetModel( "models/hunter/plates/plate4x6.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS)
	self:SetSolidFlags( bit.bor( FSOLID_NOT_SOLID, FSOLID_TRIGGER, FSOLID_NOT_STANDABLE ) )
	self.JM_IsLethal = false

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- JoshMate Changed
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Barrier_Colour_Dormant) 
	self:DrawShadow(false)

	-- Timer To arm this Ent
	timer.Simple(JM_Barrier_ArmTime, function() if IsValid(self) then self:Barrier_Arm() end end)

	-- Warning
	self:SendWarn(true)

	

end


function ENT:Use( activator, caller )
end

function ENT:Think()
end

function ENT:Touch(toucher)

	if SERVER then

		if(not self.JM_IsLethal) then return end
		if(not toucher:IsValid()) then return end
		if(not toucher:IsPlayer()) then return end
		if(not toucher:IsTerror()) then return end
		if(not toucher:Alive()) then return end
		if(not GAMEMODE:AllowPVP()) then return end
		if(toucher:GetNWBool(JM_Global_Buff_FireWall_NWBool)) then return end

		

		-- Set Status and print Message
		JM_GiveBuffToThisPlayer("jm_buff_firewall",toucher,self:GetOwner())
		-- End Of

		self:Barrier_Die()
		toucher:EmitSound(JM_Barrier_Sound_HitPlayer);
	
	end

	
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
