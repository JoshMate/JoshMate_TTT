AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

local JM_Barrier_LifeTime			= 120
local JM_Barrier_ArmTime			= 15

local JM_Barrier_Colour_PreArm		= Color( 0, 0, 0, 0 )
local JM_Barrier_Colour_Dormant		= Color( 0, 0, 0, 0 )

local JM_Barrier_Sound_Placed		= "firewall_place.wav"
local JM_Barrier_Sound_Armed		= "firewall_arm.wav"
local JM_Barrier_Sound_Destroyed	= "firewall_destroy.wav"
local JM_Barrier_Sound_HitPlayer	= "firewall_hit.wav"

local JM_FireWall_Damage_Amount		= 3
local JM_FireWall_Damage_Delay		= 0.20
local JM_FireWall_Damage_Duration	= 5

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
			
			-- Play Place Sound
			self:EmitSound(JM_Barrier_Sound_Placed);
			self:EmitSound(JM_Barrier_Sound_Armed)

			self:SetMaterial("models/props_combine/tprings_globe")
			self:SetRenderMode( RENDERMODE_NORMAL )
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
			self:Extinguish()
			self:SetMaterial("joshmate/barrier")
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetColor(JM_Barrier_Colour_Dormant) 
			self.JM_IsLethal = false
			-- We go dormant until all players are no longer on fire (For hitmarkers / damage ownership reasons)
			timer.Simple(JM_FireWall_Damage_Duration, function () self:Remove() end)
			
		end 
		
	end
end

function ENT:Initialize()
	self:SetModel( "models/hunter/plates/plate3x5.mdl" )
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
	self:SetColor(JM_Barrier_Colour_PreArm) 
	self:DrawShadow(false)

	-- Timer To arm this Ent
	timer.Simple(JM_Barrier_ArmTime, function() if IsValid(self) then self:Barrier_Arm() end end)

	-- Timer To Delete this Ent
	timer.Simple(JM_Barrier_LifeTime, function() if IsValid(self) then  self:Barrier_Die() end end)

	-- Warning
	self:SendWarn(true)

	

end


function FireWallEffect_Tick(ent, attacker, timerName)
	if SERVER then
	   if not IsValid(ent) then
		  timer.Remove(timerName)
		  return
	   end
	   if not ent:GetNWBool("isFireWalled") then
		  timer.Remove(timerName)
		  return
	   end
	   if not ent:Alive() then 
		  timer.Remove(timerName)
		  return 
	   end
 
	   local dmginfo = DamageInfo()
	   dmginfo:SetDamage(JM_FireWall_Damage_Amount)

	   dmginfo:SetAttacker(attacker)

	   local inflictor = ents.Create("weapon_jm_equip_firewall")
	   dmginfo:SetInflictor(inflictor)
	   dmginfo:SetDamageType(DMG_BURN)
	   dmginfo:SetDamagePosition(ent:GetPos())
	   ent:TakeDamageInfo(dmginfo)
 
	end
 
end

function RemoveFireWall(ent)
	
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
		if(toucher:GetNWBool("isFireWalled")) then return end

		toucher:SetNWBool("isFireWalled", true)
		STATUS:AddTimedStatus(toucher, "jm_firewall", JM_FireWall_Damage_Duration, 1)
		toucher:EmitSound(JM_Barrier_Sound_HitPlayer);
	
		-- Remove the existing Timer then reset it (To prevent Duplication)
		if(timer.Exists(("timer_FireWall_Damage_" .. toucher:SteamID64()))) then timer.Remove(("timer_FireWall_Damage_" .. toucher:SteamID64())) end
		timer.Create( ("timer_FireWall_Damage_" .. toucher:SteamID64()), JM_FireWall_Damage_Delay, JM_FireWall_Damage_Duration * 5, function ()
			  if (not toucher:IsValid() or not toucher:IsPlayer()) then timer.Remove(("timer_FireWall_Damage_" .. toucher:SteamID64())) return end
			  FireWallEffect_Tick(toucher, self.JM_Owner, timerName )
		end )

		-- Remove the existing Timer then reset it (To prevent Duplication) 
		if(timer.Exists(("timer_FireWall_Remove_" .. toucher:SteamID64()))) then timer.Remove(("timer_FireWall_Remove_" .. toucher:SteamID64())) end
		timer.Create( ("timer_FireWall_Remove_" .. toucher:SteamID64()), JM_FireWall_Damage_Duration, 1, function ()
			  if (not ent:IsValid() or not ent:IsPlayer()) then timer.Remove(("timer_FireWall_Remove_" .. toucher:SteamID64())) return end
			  STATUS:RemoveStatus(toucher, "jm_firewall")
			  toucher:SetNWBool("isFireWalled", false)
		end )

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