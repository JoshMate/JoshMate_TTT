
AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "Swapper"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Set-Up Weapon
	
Left Click: Swap HP with another player

Right Click: Swap positions on the map

Has 2 uses (Can use each function once)
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_healthswapper.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 2
SWEP.Primary.DefaultClip   = 2
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 20
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = Sound( "Weapon_USP.SilencedShot" )
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_SWAPPER
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_tmp.mdl"

local JM_Shoot_Range                = 10000

SWEP.JM_Swapper_Max_Use_HP         = 1
SWEP.JM_Swapper_Max_Use_Location   = 1

SWEP.Swapper_Use_Count_HP           = 0
SWEP.Swapper_Use_Count_Location     = 0

function SWEP:ApplyEffect(ent,weaponOwner,secondaryAttack)

   if not IsValid(ent) then return end
   
   if SERVER then

      -- Give a Hit Marker to This Player
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      if not ent:IsTerror() or not ent:Alive() then return end

      -- Swap
      if secondaryAttack == false then

         self.Swapper_Use_Count_HP = self.Swapper_Use_Count_HP + 1

         self.Swapper_TempHP_Yours_Cur       = self:GetOwner():Health()
         self.Swapper_TempHP_Theirs_Cur      = ent:Health()

         if self.Swapper_TempHP_Theirs_Cur > self.Swapper_TempHP_Yours_Cur then
            weaponOwner:ChatPrint("[Swapper]: Good Trade! (" .. ent:Nick() .. ") [" .. tostring(self.Swapper_TempHP_Theirs_Cur) .. " for your " .. tostring(self.Swapper_TempHP_Yours_Cur) .. "]")
         else
            weaponOwner:ChatPrint("[Swapper]: Bad Trade! (" .. ent:Nick() .. ") [" .. tostring(self.Swapper_TempHP_Theirs_Cur) .. " for your " .. tostring(self.Swapper_TempHP_Yours_Cur) .. "]")
         end
         
         ent:ChatPrint("[Swapper] - Someone has swapped HP with you!")

         ent:SetHealth(self.Swapper_TempHP_Yours_Cur)
         self:GetOwner():SetHealth(self.Swapper_TempHP_Theirs_Cur)

      else

         self.Swapper_Use_Count_Location = self.Swapper_Use_Count_Location + 1

         activator = self:GetOwner()
         Victim = ent

         -- Perform the actual swap
			local PosActivator = activator:GetPos()
			local PosVictim = Victim:GetPos()
			activator:SetPos(PosVictim)
			Victim:SetPos(PosActivator)
			if SERVER then Victim:EmitSound(Sound("effect_swapping_places.mp3")) end
			Victim:ChatPrint("[Swapper] - Someone has swapped Places with you!")
         activator:ChatPrint("[Swapper] - You have swapped places with: " .. tostring(Victim:Nick()))

      end
      -- End of
         

   end
end

function SWEP:PrimaryAttack()

   -- Check for Use Counters
   if self.Swapper_Use_Count_HP >= self.JM_Swapper_Max_Use_HP then 

      self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
      if not self:CanPrimaryAttack() then return end

      if SERVER then  self:GetOwner():ChatPrint("[Swapper] - You have already swapped HP the maximum amount of times") end
      return
   end
   -- #########

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( self.PrimaryAnim )
   self:TakePrimaryAmmo( 1 )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
   -- #########

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
      self:ApplyEffect(tr.Entity, owner,false)
   end

   owner:LagCompensation(false)

   -- #########

   -- Remove Weapon When out of Ammo
   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
   -- #########

end


function SWEP:SecondaryAttack()

   -- Check for Use Counters
   if self.Swapper_Use_Count_Location >= self.JM_Swapper_Max_Use_Location then 

      self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
      if not self:CanSecondaryAttack() then return end

      self:GetOwner():ChatPrint("[Swapper] - You have already swapped Places the maximum amount of times")
      return
   end
   
   -- #########

   -- Check for crouching user

   if self:GetOwner():Crouching() then

      self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
      if not self:CanSecondaryAttack() then return end

      if SERVER then self:GetOwner():ChatPrint("[Swapper] - You can't swap places with someone while you are crouching!") end

      return
   end
   -- #########

   -- Weapon Animation, Sound and Cycle data
   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   if not self:CanSecondaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( self.PrimaryAnim )
   self:TakePrimaryAmmo( 1 )
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
   -- #########

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then
      self:ApplyEffect(tr.Entity, owner,true)
   end

   owner:LagCompensation(false)

   -- #########

   -- Remove Weapon When out of Ammo
   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end
   -- #########
end



-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Swap HP", "Swap Places", true)
 
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
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################
