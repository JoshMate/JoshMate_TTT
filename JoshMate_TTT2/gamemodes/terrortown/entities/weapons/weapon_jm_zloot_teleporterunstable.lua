AddCSLuaFile()

SWEP.PrintName				= "Unstable Teleporter"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Teleport someplace random"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel 				= "models/props_lab/reciever01c.mdl"
SWEP.WorldModel				= "models/props_lab/reciever01c.mdl"
SWEP.HoldType              = "normal"
SWEP.HoldReady             = "normal"
SWEP.HoldNormal            = "normal"
SWEP.UseHands 				= false
SWEP.AllowDrop 				= true

-- TTT Customisation
SWEP.Base 					= "weapon_jm_base_gun"
SWEP.Kind 					= WEAPON_EQUIP1
SWEP.AutoSpawnable			= false
SWEP.CanBuy 				= {}
SWEP.LimitedStock 			= true


-- Swep Config

if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_gun_special.png"
	
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 20 - ang:Right() * -15 - ang:Up() * 12, ang
	end
end

function JMTeleportEffectsInit(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("cball_explode", effect, true, true)
 end


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	if CLIENT then return end
	-- Teleport
	JMTeleportEffectsInit(self:GetOwner())
	JM_Function_TeleportPlayerToARandomPlace(self:GetOwner())
	sound.Play("teleport_unstable_use.mp3", self:GetOwner():GetPos(), 150, 100)
	JMTeleportEffectsInit(self:GetOwner())
	self:Remove()

end

function SWEP:SecondaryAttack()
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Teleport to a RANDOM location", nil, true)
 
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

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################