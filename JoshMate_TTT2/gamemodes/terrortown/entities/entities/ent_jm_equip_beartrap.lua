AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "Josh Mate"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true

local bearTrap_Damage							= 6
local bearTrap_DamageDelay 						= 1
local bearTrap_HoldTime 						= 25
local bearTrap_ReleaseReason_TimeOut 			= "TimeOut"
local bearTrap_ReleaseReason_Destroyed			= "Destroyed"
local bearTrap_ReleaseReason_Killed				= "Killed"

function ENT:Think()
	self:NextThink(CurTime())

	-- Damage
	if (not self.TrappedPerson == nil and beartrapNextDamageTime >= CurTime())

		beartrapNextDamageTime = CurTime() + bearTrap_DamageDelay
		self:DamageTrappedPlayer()

	end

	-- Player Gets Killed
	if (not self.TrappedPerson == nil and self.TrappedPerson:Valid() and self.TrappedPerson:IsPlayer() and self.TrappedPerson:Health <= 0)
		self:ReleasePlayer(bearTrap_ReleaseReason_Killed)
	end

	-- Release player after Delay
	if (not self.TrappedPerson == nil and self.beartrapNextRelease >= CurTime())

		self:ReleasePlayer(bearTrap_ReleaseReason_TimeOut)

	end

	return true
end



if CLIENT then

	function ENT:Draw()
		self:DrawModel()
	end

	-- CLIENT CAN'T GO PAST HERE
	return
end

function ENT:Initialize()
	self:SetModel("models/stiffy360/beartrap.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	if self:GetPhysicsObject():IsValid() then
		self:GetPhysicsObject():EnableMotion(false)
	end
	self:SetSequence("ClosedIdle")
	timer.Simple(2, function()
		if IsValid(self) then
			self:SetSequence("OpenIdle")
		end
	end)
	
	-- Simple Use
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	self.TrappedPerson = nil
	self.dmg = 0

	-- JoshMate Changed
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor( Color( 255, 255, 255, 40 ) ) 
	
	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_beartrap",self:GetPos(),0,true)
end

local function DoBleed(ent)
   if not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror())) then
      return
   end

   local jitter = VectorRand() * 30
   jitter.z = 20

   util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
end


function ENT:HitEffectsInit(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
 end


function ENT:Touch(toucher)

	if not IsValid(toucher) or not IsValid(self) or !toucher:IsPlayer() then return end

	self.TrappedPerson = toucher
	self.beartrapNextDamageTime 	= CurTime()
	self.beartrapNextRelease 		= CurTime() + bearTrap_HoldTime

	if self:GetSequence() ~= 0 and self:GetSequence() ~= 2 then
		self:SetPlaybackRate(1)
		self:SetCycle(0)
		self:SetSequence("Snap")
		self:EmitSound("beartrap.wav")
		self:HitEffectsInit(toucher)

		-- JoshMate Changed
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255, 0, 0, 255 ) ) 

		if not toucher:IsPlayer() then
			timer.Simple(0.1, function()
				if not IsValid(self) then return end
				self:SetSequence("ClosedIdle")
			end)
			return
		end

		if toucher:GetNWBool(JM_Global_Buff_BearTrap_NWBool) then return end

		toucher:SetNWBool(JM_Global_Buff_BearTrap_NWBool, true)
		if IsValid(toucher) then
			toucher:Freeze(true)
		end

		STATUS:AddStatus(toucher, JM_Global_Buff_BearTrap_IconName)

		self.fingerprints = {}

		JM_Function_PrintChat(toucher, "Equipment", "You are stuck in a Bear Trap!")
		JM_Function_PrintChat(self.Owner, "Equipment", "Your Bear Trap has caught: " .. toucher:GetName())

		timer.Simple(0.1, function()
			if not IsValid(self) then return end
			self:SetSequence("ClosedIdle")
		end)
	end
end

function ENT:Use(act)

	if act:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
		
		if IsValid(act) then 
			JM_Function_PrintChat(self.TrappedPerson, "Equipment", "You have been released by: " .. tostring(act:Nick()))
		end
		if not IsValid(act) then 
			JM_Function_PrintChat(self.TrappedPerson, "Equipment", "You have been released by: UNKOWN PLAYER")
		end

		ReleasePlayer(bearTrap_ReleaseReason_Destroyed)
		
	else
		JM_Function_PrintChat(act, "Equipment", "You need your hands free to do that...")
	end

end

function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end

function ENT:DamageTrappedPlayer()

	local dmg = DamageInfo()

	local attacker = nil
	if IsValid(self.Owner) then
		attacker = self.Owner
	else
		attacker = self.TrappedPerson
	end

	dmg:SetAttacker(attacker)
	local inflictor = ents.Create("ent_jm_equip_beartrap")
	dmg:SetInflictor(inflictor)

	if toucher:HasEquipmentItem("item_jm_passive_bombsquad") then 
		dmg:SetDamage(bearTrap_Damage/2) 
	else
		dmg:SetDamage(bearTrap_Damage) 
	end
	
	dmg:SetDamageType(DMG_GENERIC)

	self.TrappedPerson:TakeDamageInfo(dmg)
	DoBleed(self.TrappedPerson)

end

function ENT:ReleasePlayer(releaseReason)

	if self.TrappedPerson:IsValid() then
		self.TrappedPerson:SetNWBool(JM_Global_Buff_BearTrap_NWBool, false)
		self.TrappedPerson:Freeze(false)
		STATUS:RemoveStatus(self.TrappedPerson, JM_Global_Buff_BearTrap_IconName)
	end

	if releaseReason == bearTrap_ReleaseReason_Destroyed then

		if IsValid(self.Owner) then
			JM_Function_PrintChat(self.Owner, "Equipment", "Your Bear Trap has been Destroyed!")
		end

	end
	
	if releaseReason == bearTrap_ReleaseReason_Killed then

		if IsValid(self.Owner) then
			JM_Function_PrintChat(self.Owner, "Equipment", "Your Bear Trap has killed: " .. tostring(TrappedPerson.Nick()))
			JM_Function_PrintChat(self.TrappedPerson, "Equipment", "The beartrap killed you...")
		end

	end

	if releaseReason == bearTrap_ReleaseReason_TimeOut then

		if IsValid(self.Owner) then
			JM_Function_PrintChat(self.Owner, "Equipment", "Your Bear Trap has timed out and failed to kill: " .. tostring(TrappedPerson.Nick()))
			JM_Function_PrintChat(self.TrappedPerson, "Equipment", "The beartrap timed out and released you!")
		end

	end

	self:EmitSound("0_main_click.wav")
	self:HitEffectsInit(self)
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
	self:Remove()

end

