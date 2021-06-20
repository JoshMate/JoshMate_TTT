AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = "Josh Mate"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true

function ENT:Think()
	self:NextThink(CurTime())
	return true
end

ENT.TrappedPerson = nil

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
	self:SetUseType(SIMPLE_USE)
	self.dmg = 0

	-- JoshMate Changed
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor( Color( 255, 255, 255, 40 ) ) 
	self:SendWarn(true)
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
	
	util.Effect("TeslaZap", effect, true, true)
	
	util.Effect("cball_explode", effect, true, true)
 end


function ENT:Touch(toucher)

	if not IsValid(toucher) or not IsValid(self) or !toucher:IsPlayer() then return end

	self.TrappedPerson = toucher

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

		if TTT2 then -- add element to HUD if TTT2 is loaded
			STATUS:AddStatus(toucher, JM_Global_Buff_BearTrap_IconName)
		end

		self.fingerprints = {}

		if IsValid(toucher) then toucher:ChatPrint("[Bear Trap] - You're trapped, Ask for help!") end
		if IsValid(self.Owner) then self.Owner:ChatPrint("[Bear Trap] - Your trap has caught: " .. toucher:GetName()) end

		timer.Create("beartrapdmg" .. toucher:EntIndex(), 0.5, 0, function()
			if !IsValid(toucher) then timer.Destroy("beartrapdmg" .. toucher:EntIndex()) return end			

			if not toucher:IsTerror() or not toucher:Alive() or not toucher:GetNWBool(JM_Global_Buff_BearTrap_NWBool) or not IsValid(self) then
				timer.Destroy("beartrapdmg" .. toucher:EntIndex())
				toucher:SetNWBool(JM_Global_Buff_BearTrap_NWBool, false)
				toucher:Freeze(false)
				toucher:ChatPrint("[Bear Trap] - The Trap no longer holds you...")
				STATUS:RemoveStatus(toucher, JM_Global_Buff_BearTrap_IconName)

				return
			end

			local dmg = DamageInfo()

			local attacker = nil
			if IsValid(self.Owner) then
				attacker = self.Owner
			else
				attacker = toucher
			end

			dmg:SetAttacker(attacker)
			local inflictor = ents.Create("ent_jm_equip_beartrap")
			dmg:SetInflictor(inflictor)

			if toucher:HasEquipmentItem("item_jm_passive_bombsquad") then 
				dmg:SetDamage(2) 
			else
				dmg:SetDamage(3) 
			end
			
			dmg:SetDamageType(DMG_GENERIC)

			toucher:TakeDamageInfo(dmg)
			DoBleed(toucher)

		end)

		timer.Simple(0.1, function()
			if not IsValid(self) then return end
			self:SetSequence("ClosedIdle")
		end)
	end
end

function ENT:Use(act)

	if IsValid(self.Owner) then
		self.Owner:ChatPrint("[Bear Trap] - Your trap has been removed!")
	end

	if IsValid(self.TrappedPerson) then
		timer.Destroy("beartrapdmg" .. self.TrappedPerson:EntIndex())
		self.TrappedPerson:SetNWBool(JM_Global_Buff_BearTrap_NWBool, false)
		self.TrappedPerson:Freeze(false)
		if IsValid(act) then self.TrappedPerson:ChatPrint("[Bear Trap] - You have been released by: " .. tostring(act:Nick())) end
		if not IsValid(act) then self.TrappedPerson:ChatPrint("[Bear Trap] - You have been released by: UNKOWN PLAYER") end
		STATUS:RemoveStatus(self.TrappedPerson, JM_Global_Buff_BearTrap_IconName)
	end

	self:EmitSound("0_main_click.wav")
	self:HitEffectsInit(self)
	self:SendWarn(false)
	self:Remove()

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

