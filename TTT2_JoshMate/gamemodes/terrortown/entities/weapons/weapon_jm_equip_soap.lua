AddCSLuaFile()

SWEP.PrintName				= "Soap"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Leftclick to place soap"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 3
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel 				= "models/soap.mdl"
SWEP.WorldModel				= "models/soap.mdl"
SWEP.HoldType 				= "normal" 
SWEP.UseHands 				= false
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_tttbase"
SWEP.Kind 					= WEAPON_EQUIP1
SWEP.AutoSpawnable			= false
SWEP.CanBuy 				= { ROLE_TRAITOR}
SWEP.LimitedStock 			= true

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_soap.png"
 
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   name = "Soap",
	   desc = [[Place down a soapy trap!
	
Any one who touches it will slip

Slipping players are launched in the direction they are moving

Your traps will show up to other Traitors

Each soap can slip one person (You get 2 soaps)
]]
	}
	
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 10 - ang:Right() * 8 - ang:Up() * 6, ang
	end
end


if SERVER then
	resource.AddFile("sound/slip.wav")
	resource.AddFile("models/soap.dx80.vtx")
	resource.AddFile("models/soap.dx90.vtx")
	resource.AddFile("models/soap.mdl")
	resource.AddFile("models/soap.sw.vtx")
	resource.AddFile("models/soap.vvd")
	resource.AddFile("materials/models/soap.vmt")
	resource.AddFile("materials/models/soap.vtf")	
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound( self.Primary.Sound )
	self:ThrowSoap("models/soap.mdl")
	
end

function SWEP:SecondaryAttack()
end

function SWEP:ThrowSoap( model_file )
	if (CLIENT) then return end

	local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100, filter = self.Owner})
	if (tr.HitWorld or tr.Entity:IsValid() and (tr.Entity:GetClass() == "func_breakable"))then
		local dot = vector_up:Dot(tr.HitNormal)
		if dot > 0.55 and dot <= 1 then
			local ent = ents.Create("ttt_soap")
			ent:SetModel( model_file )
			ent:SetPos(tr.HitPos + tr.HitNormal)
			local ang = tr.HitNormal:Angle()
			ang:RotateAroundAxis(ang:Right(), -90)
			ent:SetAngles(ang)
			ent:Spawn()
			ent.Owner = self.Owner
			ent.fingerprints = self.fingerprints
			self:TakePrimaryAmmo(1)
			if SERVER then
				if self:Clip1() <= 0 then
					self:Remove()
				end
			end
		end
	end
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Place a Soap", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_ttt_unarmed")
      end
   end
end
--

-- Josh Mate No World Model

function SWEP:OnDrop()
	self:Remove()
 end
  
 function SWEP:DrawWorldModel()
	return
 end
 
 function SWEP:DrawWorldModelTranslucent()
	return
 end
 
 -- END of Josh Mate World Model 