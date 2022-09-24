AddCSLuaFile()

SWEP.PrintName				= "Motion Sensor"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Places a certain type of object"
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = [[A Utility Item

Once placed, any player that walks by one will be tracked for the detectives
 
You get 2 of them and they are hard to see and cannot be destroyed
]]
 };
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel 				= "models/props/de_nuke/emergency_lighta.mdl"
SWEP.WorldModel				= "models/props/de_nuke/emergency_lighta.mdl"
SWEP.HoldType              = "normal"
SWEP.HoldReady             = "normal"
SWEP.HoldNormal            = "normal"
SWEP.UseHands 				= false
SWEP.AllowDrop 				= true


-- TTT Customisation
SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind 					= WEAPON_EQUIP1
SWEP.AutoSpawnable			= false
SWEP.CanBuy 				= {ROLE_DETECTIVE}
SWEP.LimitedStock 			= true


-- Placer Style Swep Config
SWEP.JM_Trap_PlaceRange					= 150

SWEP.JM_Trap_Entity_Class				= "ent_jm_equip_motionsensor"
SWEP.JM_Trap_Entity_Colour				= Color( 255, 255, 255, 25)


if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_motionsensor.png"
	
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() * -20 - ang:Up() * 10, ang
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

function SWEP:PlaceThing()

	local tr = util.TraceLine({start = self:GetOwner():GetShootPos(), endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.JM_Trap_PlaceRange, filter = self:GetOwner()})
	if (tr.Hit) then

		if CLIENT then return end

		self:GetOwner():EmitSound("shoot_barrel.mp3")
		
		local dot = vector_up:Dot(tr.HitNormal)
		local ent = ents.Create(self.JM_Trap_Entity_Class)
		
		ent:SetPos(tr.HitPos + tr.HitNormal)
		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		ent:SetAngles(ang)
		ent:SetOwner(self:GetOwner())
		ent.owner = self:GetOwner()

		ent:Spawn()

		ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
		ent:SetColor(self.JM_Trap_Entity_Colour)

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
	self:PlaceThing()
	
end

function SWEP:SecondaryAttack()
	return
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Weld to a surface", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
-- Equip Bare Hands on Remove
if SERVER then
   function SWEP:OnRemove()
      if self:GetOwner():IsValid() and self:GetOwner():IsTerror() and self:GetOwner():Alive() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
-- Hide World Model when Equipped
function SWEP:DrawWorldModel()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
function SWEP:DrawWorldModelTranslucent()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
-- Delete on Drop
function SWEP:OnDrop() 
	self:Remove()
 end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################