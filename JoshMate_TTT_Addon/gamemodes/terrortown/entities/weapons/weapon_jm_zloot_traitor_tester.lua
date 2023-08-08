
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
   
Has 2 uses and limited range
]]
};

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_tester.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.75
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 2
SWEP.Primary.DefaultClip   = 2
SWEP.Primary.ClipMax       = 0
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

local JM_Shoot_Range                = 350


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

   if not IsValid(ent)then return end
   self:HitEffectsInit(ent)
   
   if SERVER then

      -- Give a Hit Marker to This Player
		local hitMarkerOwner = self:GetOwner()
		JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

      local sample = ents.Create("ent_jm_equipment_tester_sample")
      local posOfSampleSpawn = ent:GetPos()
      posOfSampleSpawn:Add(Vector(0,0,64))
      sample:SetPos(posOfSampleSpawn)
      sample:Spawn()
      sample.SetOwner(self:GetOwner())
      sample.testerSamplePlayer = ent
   
   end
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
      if SERVER then 
         JM_Function_PrintChat(owner, "Equipment", "No testable target in range...")
      end
   end

   owner:LagCompensation(false)

   -- #########

   if SERVER then 
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end


end




function SWEP:SecondaryAttack()
end

local JM_PortableTester_Halo_Colour = Color(0,80,255,255)

hook.Add( "PreDrawHalos", "Halos_portableTester", function()
    halo.Add( ents.FindByClass( "weapon_jm_zloot_traitor_tester*" ), JM_PortableTester_Halo_Colour, 2, 2, 3, true, true )
 
end )



-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Test a player", nil, true)
 
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

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################
