AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName= "Barrier"
ENT.Author= "Josh Mate"
ENT.Purpose= "Blocker"
ENT.Instructions= "Blocker"
ENT.Spawnable = true
ENT.AdminSpawnable = false

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

local JM_Barrier_LifeTime			= 120
local JM_Barrier_Recharge			= 1.5
local JM_Barrier_HP					= 1000
local JM_Barrier_HP_PerPress		= 50

local JM_Barrier_Colour_PreArm		= Color( 255, 255, 255, 100 )

local JM_Barrier_Sound_Placed		= "weapons/ar2/ar2_reload_rotate.wav"
local JM_Barrier_Sound_Armed		= "weapons/ar2/ar2_reload_push.wav"
local JM_Barrier_Sound_Destroyed	= "weapons/ar2/npc_ar2_altfire.wav"

function ENT:CalculateColour()

	local r = 255 * ( 1 - (self.HP / JM_Barrier_HP))
	local g = 150 * (self.HP / JM_Barrier_HP)
	local b = 255 * (self.HP / JM_Barrier_HP)
	local t = 220
	
	if self.isArmed == false then
		self:SetColor(JM_Barrier_Colour_PreArm)
	end

	if self.isArmed == true then
		self:SetColor(Color( r, g, b, t))
	end

end

function ENT:Barrier_Effects_Sparks()
	if not IsValid(self) then return end
	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
 end

function ENT:Barrier_Arm()
	if SERVER then
		if IsValid(self) then 
			if SERVER then self:EmitSound(JM_Barrier_Sound_Armed); end
			self.isArmed = true
			self:CalculateColour()
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
		end 
	end
end

function ENT:Barrier_Die()
	if SERVER then
		if IsValid(self) then 
			self:Barrier_Effects_Sparks()
			if SERVER then self:EmitSound(JM_Barrier_Sound_Destroyed); end
			self:Remove()
		end 
	end
end

function ENT:Initialize()

	-- Collisions and Phyiscs
	self:SetModel( "models/hunter/plates/plate4x6.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- Visuals
	self:SetMaterial("joshmate/barrier")
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_Barrier_Colour_PreArm) 
	self:DrawShadow(false)

	-- Setup stats
	self.HP = JM_Barrier_HP
	self.armTime = CurTime() + JM_Barrier_Recharge
	self.isArmed = false
	self.nextDamageTick = CurTime() + 1

	--Prevent holding E
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- Play Place Sound
	if SERVER then self:EmitSound(JM_Barrier_Sound_Placed); end
	
end

function ENT:BarrierUse()

	if SERVER then self:EmitSound("gamemode/file_hit.mp3") end
	self:Barrier_Effects_Sparks()
	self.HP = self.HP - JM_Barrier_HP_PerPress
	self:CalculateColour()
end

function ENT:BarrierDecay()

	self.nextDamageTick = CurTime() + 1
	self.HP = self.HP - math.Round((JM_Barrier_HP / JM_Barrier_LifeTime))
	self:CalculateColour() 
	JM_Function_PrintChat(self.Owner, "Equipment", "Your Barrier has timed out...")
end

function ENT:BarrierTouch(toucher)
	if self.isArmed == true and IsValid(toucher) and toucher:IsPlayer() and IsValid(self) and toucher:IsTerror() and toucher:Alive() then
		if SERVER then self:EmitSound("barrier_trip.mp3") end
		self.isArmed = false
	
		self:CalculateColour() 

		-- Set Status and print Message
		JM_GiveBuffToThisPlayer("jm_buff_barrierslow",toucher,self:GetOwner())
		-- End Of

		JM_Function_PrintChat(self.Owner, "Equipment", "Your Barrier has been triggered!")

		-- Remove the barrier
		self:Barrier_Die()

	end
end


function ENT:Use( activator, caller )

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and (activator:IsTraitor() or activator:IsDetective()) and activator:Alive() then
		self:BarrierUse()
	end
	
end


function ENT:Think()

	if self.isArmed == false and CurTime() >= self.armTime then
		self:Barrier_Arm()
	end

	if self.isArmed and CurTime() >= self.nextDamageTick then
		self:BarrierDecay()
	end
	
	if self.HP <= 0 then
		JM_Function_PrintChat(self.Owner, "Equipment", "Your Barrier has benn destroyed.")
        self:Barrier_Die()
    end

end

function ENT:Touch(toucher)
	self:BarrierTouch(toucher)
end


