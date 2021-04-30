AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

local JM_Barrier_ArmTime			= 3
local JM_Barrier_HP					= 650

local JM_Barrier_Colour_PreArm		= Color( 255, 255, 255, 100 )

local JM_Barrier_Sound_Placed		= "weapons/ar2/ar2_reload_rotate.wav"
local JM_Barrier_Sound_Armed		= "weapons/ar2/ar2_reload_push.wav"
local JM_Barrier_Sound_Destroyed	= "weapons/ar2/npc_ar2_altfire.wav"

function ENT:CalculateColour()

	local r = 255 * ( 1 - (self.HP / JM_Barrier_HP))
	local g = 150 * (self.HP / JM_Barrier_HP)
	local b = 255 * (self.HP / JM_Barrier_HP)
	local t = 215
	
	self:SetColor(Color( r, g, b, t))

end

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
			self:EmitSound(JM_Barrier_Sound_Armed);
			self:SetSolid( SOLID_VPHYSICS ) 
			self:Barrier_Effects_Destroyed()
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:CalculateColour()
			self:DrawShadow(false) 


		end 
	end
end

function ENT:Barrier_Die()
	if SERVER then
		
		if IsValid(self) then 
			self:Barrier_Effects_Destroyed()
			self:EmitSound(JM_Barrier_Sound_Destroyed);
			self:Remove()
		end 
		
	end
end

function ENT:Initialize()
	self:SetModel( "models/hunter/plates/plate4x6.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_NONE )
	self.HP = JM_Barrier_HP

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Play Place Sound
	self:EmitSound(JM_Barrier_Sound_Placed);
	self:Barrier_Effects_Destroyed()

	-- JoshMate Changed
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Barrier_Colour_PreArm) 
	self:DrawShadow(false)

	-- Timer To arm this Ent
	timer.Simple(JM_Barrier_ArmTime, function() if IsValid(self) then self:Barrier_Arm() end end)

end

function ENT:OnTakeDamage(dmginfo)

    self.HP = self.HP - dmginfo:GetDamage()

	self:CalculateColour()

    if self.HP <= 0 then
        self:Barrier_Die()
    end
end


function ENT:Use( activator, caller )
end

function ENT:Think()
end

function ENT:Touch(toucher)

end

--- Josh Mate Hud Warning
if SERVER then

end