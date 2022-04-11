
AddCSLuaFile()

if CLIENT then
   SWEP.PrintName          = "UAV"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Set-Up Weapon
	
Reveals all players (tracks them) for 8 seconds

Also gives the user useful intel like players left alive

Single use item and announces to the server it has been used
]]
};
   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_uav.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.1
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 1
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 75
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = nil
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE}
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_UAV
SWEP.UseHands              = false
SWEP.ViewModel             = "models/props/cs_office/computer_mouse.mdl"
SWEP.WorldModel            = "models/props/cs_office/computer_mouse.mdl"




function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   
   if SERVER then

      

      -- Give a Hit Marker to This Player
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      -- Gather Stats
      local uavStatAlive   = 0
      local uavStatDead    = 0

      for _, ply in ipairs( player.GetAll() ) do

         if (ply:IsValid() and not ply:IsSpec() and ply:IsTerror() and ply:Alive()) then
            uavStatAlive = uavStatAlive + 1
         else
            uavStatDead = uavStatDead + 1
         end
     end

      -- Set Status and print Message
      JM_Function_PrintChat(weaponOwner, "Equipment","Your UAV shows: " .. tostring(uavStatDead) .. " Dead / Spectating")
      JM_Function_PrintChat(weaponOwner, "Equipment","Your UAV shows: " .. tostring(uavStatAlive) .. " Alive")
      -- End Of

      -- Make you and the target Agents
      JM_RemoveBuffFromThisPlayer("jm_buff_uav",self:GetOwner())
      JM_GiveBuffToThisPlayer("jm_buff_uav",self:GetOwner(),self:GetOwner())

      -- Play Sound to ALL
      JM_Function_PlaySound("shoot_uav_online.mp3") 

   end
end

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   -- ####

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   self:ApplyEffect(self:GetOwner(), self:GetOwner())
   -- #########

   -- Remove the Weapon
   if SERVER then self:Remove() end

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
      local viewModelPos  = Vector(-5, -15,-5)
      local viewModelAng  = Vector(3,180, 0)

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
	   self:AddTTT2HUDHelp("Use UAV", nil, true)
 
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
