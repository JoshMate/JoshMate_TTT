
AddCSLuaFile()

SWEP.HoldType              = "ar2"

if CLIENT then
   SWEP.PrintName          = "Portable Tester"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Non-Lethal Weapon
	
Shoot someone to find out if they are a traitor!
   
Has a single use and limited range
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_gun_special.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 1
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 3
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 1
SWEP.Primary.SoundLevel    = 75
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "shoot_portable_tester_fire.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_PORTABLETESTER
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_irifle.mdl"
SWEP.WorldModel            = "models/weapons/w_irifle.mdl"

SWEP.ScannedRole           = "Unkown"
SWEP.ScanTime              = 0
SWEP.ScanPhase             = 0
SWEP.ScanTarget            = nil
SWEP.ScanOwner             = nil

local JM_Shoot_Range                = 300


function SWEP:HitEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   util.Effect("TeslaZap", effect, true, true)
   
   util.Effect("cball_explode", effect, true, true)
end

function SWEP:ApplyEffect(ent,weaponOwner)

   if not IsValid(ent)then return end
   self:HitEffectsInit(ent)
   
   if SERVER then

      -- JM Changes Extra Hit Marker
      net.Start( "hitmarker" )
      net.WriteFloat(0)
      net.Send(weaponOwner)
      -- End Of

      -- Set Status and print Message
      self.ScanTarget = ent
      self.ScanOwner = weaponOwner 
      self.ScanOwner:ChatPrint("[Portable Tester]: Scanning " .. tostring(self.ScanTarget:Nick()) .. " (10 seconds)")
      self.ScanTarget:ChatPrint("[Portable Tester]: " .. tostring(self.ScanOwner:Nick()) .. " is revealing your role in (10 seconds)")
      self.ScanTarget:EmitSound("shoot_portable_tester_scan.wav")
      self.ScanTime = CurTime()
      self.ScanPhase = 1

   end
end

function SWEP:Think()

   self:CalcViewModel()

   if SERVER then

      if self.ScanPhase == 0 then return end

      if self.ScanTime <= CurTime() -5 and self.ScanPhase == 1 then

         if self.ScanOwner:IsValid() and self.ScanTarget:IsValid() then
            self.ScanOwner:ChatPrint("[Portable Tester]: Scanning " .. tostring(self.ScanTarget:Nick()) .. " (5 seconds)")
            self.ScanTarget:ChatPrint("[Portable Tester]: " .. tostring(self.ScanOwner:Nick()) .. " is revealing your role in (5 seconds)")
         end  
         self.ScanPhase = 2
      end

      if self.ScanTime <= CurTime() -10 and self.ScanPhase == 2 then

         if self.ScanOwner:IsValid() and self.ScanTarget:IsValid() then
            self:HitEffectsInit(self.ScanTarget)
            self.ScanOwner:EmitSound("shoot_portable_tester_done.wav")
            self.ScanOwner:ChatPrint("[Portable Tester]: " .. tostring(self.ScanTarget:Nick()) .. " is a " .. tostring(self.ScanTarget:GetRoleStringRaw()))
            self.ScanTarget:ChatPrint("[Portable Tester]: " .. tostring(self.ScanOwner:Nick()) .. " has revealed you as: " .. tostring(self.ScanTarget:GetRoleStringRaw()))
            self.ScanTarget:EmitSound("shoot_portable_tester_done.wav")
         end  
         if self:Clip1() <= 0 then
            self:Remove()
         end
      end
   end

end

function SWEP:OnDrop()
	self:Remove()
 end

function SWEP:PrimaryAttack()

   -- Weapon Animation, Sound and Cycle data
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( self.PrimaryAnim )
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
      self:ApplyEffect(tr.Entity, owner)
      self:TakePrimaryAmmo( 1 )
   else
      if SERVER then owner:ChatPrint("[Portable Tester]: No testable target in range...") end
   end

   owner:LagCompensation(false)

   -- #########

end




function SWEP:SecondaryAttack()
end




-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Shoot a Player to test them (Must be holding to complete the test)", nil, true)
 
	   return self.BaseClass.Initialize(self)
	end
end
if SERVER then
   function SWEP:OnRemove()
      if self.Owner:IsValid() and self.Owner:IsTerror() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
      end
   end
end
--
