AddCSLuaFile()

SWEP.PrintName				= "Slo-Mo Clock"
SWEP.Author			    	= "Josh Mate"
SWEP.Instructions			= "Slows down time for 20 sconds"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true
SWEP.Primary.Delay 			= 0.3
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.ViewModel 				= "models/props/de_nuke/clock.mdl"
SWEP.WorldModel				= "models/props/de_inferno/clock01.mdl"
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
local JM_SlowMo_Clock_Duration = 10



if CLIENT then
	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_gun_special.png"
	
	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 35 - ang:Right() * -32 - ang:Up() * 15, ang
	end
end


function SWEP:SlowDownTime()

	if SERVER then
		game.SetTimeScale(0.35)

		-- Timer To set time back to normal (Or it happens at the start of next round)
		if timer.Exists("Timer_SloMo_Clock") then timer.Destroy("Timer_SloMo_Clock") end
		timer.Create( "Timer_SloMo_Clock", JM_SlowMo_Clock_Duration, 1, function() game.SetTimeScale(1) end )

		sound.Play("effect_slowmo_start.mp3", self:GetOwner():GetPos(), 150, 100)

		self:Remove()
	end


end


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SlowDownTime()
end

function SWEP:SecondaryAttack()
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Slow down time", nil, true)
 
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