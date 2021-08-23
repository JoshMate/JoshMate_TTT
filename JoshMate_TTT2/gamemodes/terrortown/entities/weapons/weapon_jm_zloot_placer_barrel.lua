AddCSLuaFile()

SWEP.PrintName				= "Barrel Swep"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Places a certain type of object"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 5
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


-- Placer Style Swep Config
SWEP.JM_Trap_PlaceRange					= 250

SWEP.JM_Trap_Entity_Class				= "prop_physics"
SWEP.JM_Trap_Entity_Colour				= Color( 255, 50, 50, 255)

SWEP.JM_Trap_Prop_True					= true
SWEP.JM_Trap_Prop_Model					= "models/props_c17/oildrum001_explosive.mdl"


if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_gun_special.png"
	
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 55 - ang:Right() * -25 - ang:Up() * 55, ang
	end
end

-- Fix Spawning
local function fixupProp( ply, ent, hitpos, mins, maxs )
	local entPos = ent:GetPos()
	local endposD = ent:LocalToWorld( mins )
	local tr_down = util.TraceLine( {
		start = entPos,
		endpos = endposD,
		filter = { ent, ply }
	} )

	local endposU = ent:LocalToWorld( maxs )
	local tr_up = util.TraceLine( {
		start = entPos,
		endpos = endposU,
		filter = { ent, ply }
	} )

	-- Both traces hit meaning we are probably inside a wall on both sides, do nothing
	if ( tr_up.Hit && tr_down.Hit ) then return end

	if ( tr_down.Hit ) then ent:SetPos( entPos + ( tr_down.HitPos - endposD ) ) end
	if ( tr_up.Hit ) then ent:SetPos( entPos + ( tr_up.HitPos - endposU ) ) end
end

local function TryFixPropPosition( ply, ent, hitpos )
	fixupProp( ply, ent, hitpos, Vector( ent:OBBMins().x, 0, 0 ), Vector( ent:OBBMaxs().x, 0, 0 ) )
	fixupProp( ply, ent, hitpos, Vector( 0, ent:OBBMins().y, 0 ), Vector( 0, ent:OBBMaxs().y, 0 ) )
	fixupProp( ply, ent, hitpos, Vector( 0, 0, ent:OBBMins().z ), Vector( 0, 0, ent:OBBMaxs().z ) )
end
-- End of Fix Spawning

function SWEP:PlaceThing(isWelded)

	local tr = util.TraceLine({start = self:GetOwner():GetShootPos(), endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.JM_Trap_PlaceRange, filter = self:GetOwner()})
	if (tr.Hit) then

		self:EmitSound("shoot_barrel.mp3")

		if CLIENT then return end
		
		local dot = vector_up:Dot(tr.HitNormal)
		local ent = ents.Create(self.JM_Trap_Entity_Class)

		-- If its a prop then set it's model
		if self.JM_Trap_Prop_True == true then ent:SetModel(self.JM_Trap_Prop_Model) end
		
		ent:SetPos(tr.HitPos + tr.HitNormal)
		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		ent:SetAngles(ang)
		
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS)
		ent:SetCollisionGroup(COLLISION_GROUP_NONE)

		ent:Spawn()

		ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
		ent:SetColor(self.JM_Trap_Entity_Colour)

		-- Weld or Place
		if isWelded == true then ent:GetPhysicsObject():EnableMotion( false ) end
		if isWelded == false then ent:GetPhysicsObject():EnableMotion( true ) end

		-- Fix In Wall props
		TryFixPropPosition( self:GetOwner(), ent, tr.HitPos )

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


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:PlaceThing(false)
	
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:PlaceThing(true)
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place in front of you", "Weld to surface", true)
 
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