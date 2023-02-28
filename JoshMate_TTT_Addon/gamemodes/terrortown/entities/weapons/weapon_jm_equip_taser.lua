
AddCSLuaFile()

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Taser"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Non-Lethal Weapon
	
Prevents the target from moving for 15 seconds
   
The target will be stripped of all non-special weapons
   
Has 2 uses, perfect acccuracy and long range
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_usp"
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
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_taser.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_TASER
SWEP.Tracer                = "AR2Tracer"
SWEP.UseHands              = true
SWEP.ViewModel             = Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel            = Model("models/weapons/w_pistol.mdl")

local JM_Shoot_Range         = 10000

function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   
   
   util.Effect("cball_explode", effect, true, true)
end

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent) then return end
   self:HitEffectsInit(ent)
   
   if SERVER then
      
      -- Give a Hit Marker to This Player
      local hitMarkerOwner = self:GetOwner()
      JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      -- Set Status and print Message
      JM_Function_PrintChat(weaponOwner, "Equipment", ent:Nick() .. " has been Tased!" )
      JM_RemoveBuffFromThisPlayer("jm_buff_taser",ent)
      JM_GiveBuffToThisPlayer("jm_buff_taser",ent,self:GetOwner())
      -- End Of

      -- JM New Was Pushed Attribution System
      newWasPushedContract = ents.Create("ent_jm_equip_waspushed")
      newWasPushedContract.pusher = weaponOwner
      newWasPushedContract.target = ent
      newWasPushedContract.weapon = self:GetClass()
      newWasPushedContract:Spawn()
      ent.was_pushed = newWasPushedContract
      --

      -- Drop weapon on the floor
      if ent:GetActiveWeapon().AllowDrop == true then
         ent:DropWeapon( nil, self:GetOwner():GetPos())
      end
      ent:SelectWeapon("weapon_jm_special_crowbar")

      
   end
end

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   -- #########

   -- Fire Shot and apply on hit effects (Now with lag compensation to prevent whiffing)
   
   local owner = self:GetOwner()
   if not IsValid(owner) then return end

   if isfunction(owner.LagCompensation) then -- for some reason not always true
      owner:LagCompensation(true)
   end
   
   local tr = util.TraceLine({start = owner:GetShootPos(), endpos = owner:GetShootPos() + owner:GetAimVector() * JM_Shoot_Range, filter = owner})
   if (tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.Entity:IsTerror() and tr.Entity:Alive())then

      self:EmitSound( self.Primary.Sound )
      self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
      self:TakePrimaryAmmo( 1 )
      if IsValid(self:GetOwner()) then
         self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
      end


      self:ApplyEffect(tr.Entity, owner)

      -- Remove Weapon When out of Ammo
      if SERVER then
         if self:Clip1() <= 0 then
            self:Remove()
         end
      end
      -- #########
   else

      if CLIENT then surface.PlaySound("proplauncher_fail.wav") end

   end

   owner:LagCompensation(false)

   -- #########

   

end




function SWEP:SecondaryAttack()
end




-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Tase a player at range", nil, true)
 
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
