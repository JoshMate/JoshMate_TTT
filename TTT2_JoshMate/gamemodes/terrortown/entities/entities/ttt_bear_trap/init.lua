AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

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
	self:SetColor( Color( 255, 255, 255, 50 ) ) 
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



function ENT:Touch(toucher)
	if not IsValid(toucher) or not IsValid(self) or !toucher:IsPlayer() then return end
	if self:GetSequence() ~= 0 and self:GetSequence() ~= 2 then
		self:SetPlaybackRate(1)
		self:SetCycle(0)
		self:SetSequence("Snap")
		self:EmitSound("beartrap.wav")

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

		if toucher:GetNWBool("isBearTrapped") then return end

		toucher:SetNWBool("isBearTrapped", true)
		if IsValid(toucher) then
			
			toucher:Freeze(true)
		end

		if TTT2 then -- add element to HUD if TTT2 is loaded
			STATUS:AddStatus(toucher, "ttt2_beartrap")
		end

		toucher:ChatPrint("[Bear Trap] - You're trapped, Ask for help!")
		self.Owner:ChatPrint("[Bear Trap] - Your trap has caught: " .. toucher:GetName())

		timer.Create("beartrapdmg" .. toucher:EntIndex(), 0.5, 0, function()
			if !IsValid(toucher) then timer.Destroy("beartrapdmg" .. toucher:EntIndex()) return end			

			if not toucher:IsTerror() or not toucher:Alive() or not toucher:GetNWBool("isBearTrapped") or not IsValid(self) then
				timer.Destroy("beartrapdmg" .. toucher:EntIndex())
				toucher:SetNWBool("isBearTrapped", false)
				if (not toucher:GetNWBool("isTased") == true) then toucher:Freeze(false) end 

				if toucher:Health() > 0 then
					toucher:ChatPrint("[Bear Trap] - You've been released from the trap!")
				end

				if TTT2 then -- remove element to HUD if TTT2 is loaded
					STATUS:RemoveStatus(toucher, "ttt2_beartrap")
				end

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
			local inflictor = ents.Create("ttt_bear_trap")
			dmg:SetInflictor(inflictor)
			dmg:SetDamage(3)
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
	if IsValid(act) and act:IsPlayer() and IsValid(self) then

		-- Josh Mate Changes
		if IsValid(self.toucher) then
			if act ~= self.toucher then

				if act:IsTerror() and act:IsTraitor() then
					if !act:HasWeapon("weapon_jm_equip_beartrap") then
						act:Give("weapon_jm_equip_beartrap")
					end
					self:Remove()
					self.Owner:ChatPrint("[Bear Trap] - Your trap has been removed!")
					if IsValid(toucher) then
						timer.Destroy("beartrapdmg" .. toucher:EntIndex())
						toucher:SetNWBool("isBearTrapped", false)
						if (not toucher:GetNWBool("isTased") == true) then toucher:Freeze(false) end 
						toucher:ChatPrint("[Bear Trap] - You've been released from the trap!")
				
						if TTT2 then -- remove element to HUD if TTT2 is loaded
							STATUS:RemoveStatus(toucher, "ttt2_beartrap")
						end
					end
				end

				if act:IsTerror() then
					self:Remove()
					self.Owner:ChatPrint("[Bear Trap] - Your trap has been removed!")
					if IsValid(toucher) then
						timer.Destroy("beartrapdmg" .. toucher:EntIndex())
						toucher:SetNWBool("isBearTrapped", false)
						if (not toucher:GetNWBool("isTased") == true) then toucher:Freeze(false) end 
						toucher:ChatPrint("[Bear Trap] - You've been released from the trap!")
				
						if TTT2 then -- remove element to HUD if TTT2 is loaded
							STATUS:RemoveStatus(toucher, "ttt2_beartrap")
						end
					end
				end
			end
			return
		end

		if act:IsTerror() and act:IsTraitor() then
			if !act:HasWeapon("weapon_jm_equip_beartrap") then
				act:Give("weapon_jm_equip_beartrap")
			end
			self:Remove()
			self.Owner:ChatPrint("[Bear Trap] - Your trap has been removed!")
			self:SendWarn(false)
			return
		end
		if act:IsTerror() then
			self:Remove()
			self.Owner:ChatPrint("[Bear Trap] - Your trap has been removed!")
			self:SendWarn(false)
			return
		end
	end

	-- End of JoshMate Changes
end

function ENT:OnTakeDamage(dmg)
	if not IsValid(self) then return end
	self.dmg = self.dmg + dmg:GetDamage()
	if self.dmg >= 25 then
		if self:GetSequence() ~= 0 and self:GetSequence() ~= 2 then
			self.Owner:ChatPrint("[Bear Trap] - Your trap has been damaged!")
			self:SetPlaybackRate(1)
			self:SetCycle(0)
			self:SetSequence("Snap")
			timer.Simple(0.1, function()
				if not IsValid(self) then return end
				self:SetSequence("ClosedIdle")
			end)
		end
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

