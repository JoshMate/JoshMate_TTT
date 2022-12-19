AddCSLuaFile()

if CLIENT then
   SWEP.PrintName          = "Informer"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[An Intel Weapon
	
Tells the Detective important information on use

3 uses
]]
};
   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_informer.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.5
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 3
SWEP.DeploySpeed           = 4
SWEP.Primary.SoundLevel    = 75
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = nil
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE}
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_INFORMER
SWEP.UseHands              = false
SWEP.ViewModel             = "models/props/cs_office/computer_mouse.mdl"
SWEP.WorldModel            = "models/props/cs_office/computer_mouse.mdl"

SWEP.informerScansPerformed = 0




function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   
   if SERVER then

      -- Make sound
      weaponOwner:EmitSound("informer_use.wav")

      -- Gather Stats
      local informerStatAlive   = 0
      local informerStatDead    = 0
      local informerStatNear    = 0

      for _, ply in ipairs( player.GetAll() ) do

         if (ply:IsValid() and not ply:IsSpec() and ply:IsTerror() and ply:Alive()) then
            informerStatAlive = informerStatAlive + 1

            if (self:GetOwner():GetPos():Distance(ply:GetPos()) <= 800) then 
               informerStatNear = informerStatNear +1
            end

         else
            informerStatDead = informerStatDead + 1
         end
     end

     -- The user is always nearby, so remove them
     informerStatNear = informerStatNear -1

     self.informerScansPerformed = self.informerScansPerformed + 1

      -- Set Status and print Message
      JM_Function_PrintChat(weaponOwner, "Equipment","--- Scan: " .. tostring(self.informerScansPerformed) .. " ---")
      JM_Function_PrintChat(weaponOwner, "Equipment","Informer: " .. tostring(informerStatDead) .. " Dead / Spectating")
      JM_Function_PrintChat(weaponOwner, "Equipment","Informer: " .. tostring(informerStatAlive) .. " Alive")
      JM_Function_PrintChat(weaponOwner, "Equipment","Informer: " .. tostring(informerStatNear) .. " Nearby Players")
      -- End Of

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
	   self:AddTTT2HUDHelp("Use Informer", nil, true)
 
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
