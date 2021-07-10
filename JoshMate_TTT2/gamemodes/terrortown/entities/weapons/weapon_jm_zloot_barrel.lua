AddCSLuaFile()

SWEP.PrintName				= "Barrel Swep"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Leftclick to place an explosive barrel"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel 				= "models/props_c17/oildrum001_explosive.mdl"
SWEP.WorldModel				= "models/props_junk/plasticbucket001a.mdl"
SWEP.HoldType              = "grenade"
SWEP.HoldReady             = "grenade"
SWEP.HoldNormal            = "grenade"
SWEP.UseHands 				= false
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind 					= WEAPON_EQUIP1
SWEP.AutoSpawnable			= false
SWEP.CanBuy 				= {}
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_gun_special.png"
	
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 55 - ang:Right() * -25 - ang:Up() * 55, ang
	end
end

local JM_Trap_WeldRange					= 256
local JM_Trap_PlaceRange				= 64
local JM_Trap_Model						= "models/props_c17/oildrum001_explosive.mdl"

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:TrapWeld()
	
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:TrapPlace()
end

function SWEP:CreateProp(targetPos, model)
	local skull = ents.Create( "prop_physics" )
	skull:SetModel(model)
	-- Add a bit of jitter to spawning
	local newPos = targetPos
	newPos.x = newPos.x + math.Rand( 0, 16 )
	newPos.y = newPos.y + math.Rand( 0, 16 )
	newPos.x = newPos.x - math.Rand( 0, 16 )
	newPos.y = newPos.y - math.Rand( 0, 16 )
	newPos.z = newPos.z + math.Rand( 0, 8 )
	skull:SetPos(newPos)
	skull:PhysicsInit(SOLID_VPHYSICS)
	skull:SetMoveType(MOVETYPE_VPHYSICS)
	skull:SetSolid(SOLID_VPHYSICS)
	skull:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	skull:Spawn()
	skull:SetColor(Color(255, 0, 0, 255) )
	local skullPhysics = skull:GetPhysicsObject()
	if skullPhysics:IsValid() then
	   skullPhysics:Wake()
	end
 end


function SWEP:TrapWeld()

	local tr = util.TraceLine({start = self:GetOwner():GetShootPos(), endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * JM_Trap_WeldRange, filter = self:GetOwner()})
	if (tr.HitWorld or tr.Entity:IsValid() and (tr.Entity:GetClass() == "func_breakable"))then

		self:EmitSound("shoot_barrel.mp3")

		if CLIENT then return end
		
		local dot = vector_up:Dot(tr.HitNormal)
		local ent = ents.Create("prop_physics")
		ent:SetModel(JM_Trap_Model)
		ent:SetPos(tr.HitPos + tr.HitNormal)
		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		ent:SetAngles(ang)
		
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS)
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)

		ent:Spawn()

		ent:GetPhysicsObject():EnableMotion( false )

		ent.fingerprints = self.fingerprints
		self:TakePrimaryAmmo(1)
		if SERVER then
			if self:Clip1() <= 0 then
				self:Remove()
			end
		end
	else
		self:EmitSound("proplauncher_fail.wav")
	end

end

function SWEP:TrapPlace()

	local tr = util.TraceLine({start = self:GetOwner():GetShootPos(), endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * JM_Trap_PlaceRange, filter = self:GetOwner()})
	self:EmitSound("shoot_barrel.mp3")

	if CLIENT then return end
	
	local ent = ents.Create("prop_physics")
	ent:SetModel(JM_Trap_Model)
	ent:SetPos(tr.HitPos + tr.HitNormal)
		
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)

	ent:Spawn()
	ent:GetPhysicsObject():EnableMotion(true)
	ent.fingerprints = self.fingerprints
	self:TakePrimaryAmmo(1)
	if SERVER then
		if self:Clip1() <= 0 then
			self:Remove()
		end
	end
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Weld an explosive barrel", "Place and explosive barrel`", true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self:GetOwner():IsValid() and self:GetOwner():IsTerror() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
--