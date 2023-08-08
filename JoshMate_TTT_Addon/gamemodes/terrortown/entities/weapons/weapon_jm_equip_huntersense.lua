AddCSLuaFile()

if CLIENT then
   SWEP.PrintName          = "Hunter Sense"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[An Intel Weapon
	
Reveals all players location real time to the traitors

It also distorts their vision and prevents them seeing player names

Lasts for 12 seconds

Has 1 Use
]]
};
   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_jammer.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.5
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 1
SWEP.DeploySpeed           = 4
SWEP.Primary.SoundLevel    = 75
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = nil
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR}
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_JAMMER
SWEP.UseHands              = false
SWEP.ViewModel             = "models/props_rooftop/roof_dish001.mdl"
SWEP.WorldModel            = "models/props_rooftop/roof_dish001.mdl"

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   -- ####

   -- Play the Sound
   JM_Function_PlaySound("effect_huntersense_activate.mp3")

   if SERVER then
         for _, ply in ipairs( player.GetAll() ) do
            if (ply:IsValid() and not ply:IsSpec() and ply:IsTerror() and ply:Alive() and not ply:IsTraitor()) then
                  JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)
                  JM_GiveBuffToThisPlayer("jm_buff_huntersense",ply,self:GetOwner())
            end
      end
   end

   self:TakePrimaryAmmo(1)

   if SERVER then
		if self:Clip1() <= 0 then
		   self:Remove()
		end
	end

end


function SWEP:SecondaryAttack()
   return
end


-- ##############################################
-- Josh Mate View Model Overide
-- ##############################################
SWEP.HoldType              = "normal" 
if CLIENT then

   -- Adjust these variables to move the viewmodel's position
   function SWEP:GetViewModelPosition(EyePos, EyeAng)

      -- Change the pos and ang
      local viewModelPos  = Vector(-40, -100,-80)
      local viewModelAng  = Vector(1,180, 0)

      EyeAng = EyeAng * 1
      EyeAng:RotateAroundAxis(EyeAng:Right(), 	viewModelAng.x)
      EyeAng:RotateAroundAxis(EyeAng:Up(), 		viewModelAng.y)
      EyeAng:RotateAroundAxis(EyeAng:Forward(), viewModelAng.z)

      local Right 	= EyeAng:Right()
      local Up 		= EyeAng:Up()
      local Forward 	= EyeAng:Forward()

      EyePos = EyePos + viewModelPos.x * Right
      EyePos = EyePos + viewModelPos.y * Forward
      EyePos = EyePos + viewModelPos.z * Up
   
      return EyePos, EyeAng
   end

end
-- ##############################################
-- End of Josh Mate View Model Overide
-- ##############################################


-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Activate Hunter Sense", nil, true)
 
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
