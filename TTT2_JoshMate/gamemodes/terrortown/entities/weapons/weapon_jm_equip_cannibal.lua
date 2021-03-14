
AddCSLuaFile()

if CLIENT then
   SWEP.PrintName          = "Cannibal"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 54
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Utility Weapon
	
Left Click: Consume a Body
   
Consuming a Body grants +25 Max HP
   
Only has 4 uses
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_cannibal.png"
end


SWEP.Base                  = "weapon_tttbase"
SWEP.HoldType              = "normal"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.45
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 4
SWEP.Primary.DefaultClip   = 4
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 10
SWEP.Primary.SoundLevel    = 50
SWEP.Primary.Automatic     = false

SWEP.Primary.Sound         = "weapons/bugbait/bugbait_squeeze1.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_CANNIBAL
SWEP.UseHands              = true
SWEP.IsSilent              = true
SWEP.ViewModel             = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel            = "models/weapons/w_bugbait.mdl"

local Cannibal_Eat_MaxHP      = 25
local Cannibal_Eat_Range      = 125

if TTT2 and CLIENT then
	hook.Add("Initialize", "jm_cannibalInit", function() 
		STATUS:RegisterStatus("jm_cannibal", {
			hud = Material("vgui/ttt/joshmate/hud_health.png"),
			type = "good"
		})
	end)
end


function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
   if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
      self:SetNWFloat( "LastShootTime", CurTime() )
   end
   local ate = false

   -- Consume Corpse
   if SERVER then
      local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * Cannibal_Eat_Range, filter = self.Owner})
      local target = tr.Entity

      if IsValid(target) then
         if target:GetClass() == "prop_ragdoll" then
            self:GetOwner():SetMaxHealth(self:GetOwner():GetMaxHealth() + Cannibal_Eat_MaxHP)
            self:GetOwner():SetHealth(self:GetOwner():Health() + Cannibal_Eat_MaxHP)

            targetPos = target:GetPos()

            target:EmitSound("physics/flesh/flesh_bloody_break.wav")
            target:SetNotSolid(true)
            target:Remove()

            CreateProp(targetPos, "models/gibs/hgibs.mdl")
            CreateProp(targetPos, "models/gibs/hgibs_rib.mdl")
            CreateProp(targetPos, "models/gibs/hgibs_scapula.mdl")
            CreateProp(targetPos, "models/gibs/hgibs_rib.mdl")
            CreateProp(targetPos, "models/gibs/hgibs_scapula.mdl")
            CreateProp(targetPos, "models/gibs/hgibs_rib.mdl")
            CreateProp(targetPos, "models/gibs/hgibs_spine.mdl")

            -- JM Changes Extra Hit Marker
            net.Start( "hitmarker" )
            net.WriteFloat(0)
            net.Send(self:GetOwner())
            -- End Of

            self:TakePrimaryAmmo( 1 )
            ate = true
         end
      end

   end

   if SERVER then
      if ate == false then
         self:GetOwner():ChatPrint("[Cannibal]: You can't eat that...")
      end
      if ate == true then
         self:GetOwner():ChatPrint("[Cannibal]: You have eaten a Body!")
      end
   end

   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end

end

function SWEP:SecondaryAttack()
   return
end

function CreateProp(targetPos, model)
   local skull = ents.Create( "prop_physics" )
   skull:SetModel(model)
   -- Add a bit of jitter to spawning
   local newPos = targetPos
   newPos.x = newPos.x + math.Rand( 0, 16 )
   newPos.y = newPos.y + math.Rand( 0, 16 )
   newPos.x = newPos.x - math.Rand( 0, 16 )
   newPos.y = newPos.y - math.Rand( 0, 16 )
   newPos.z = newPos.z + math.Rand( 0, 8 )
   skull:SetPos(newPos)
   skull:PhysicsInit(SOLID_VPHYSICS)
   skull:SetMoveType(MOVETYPE_VPHYSICS)
   skull:SetSolid(SOLID_VPHYSICS)
   skull:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
   skull:Spawn()
   local skullPhysics = skull:GetPhysicsObject()
   if skullPhysics:IsValid() then
      skullPhysics:Wake()
   end
end

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Eat A corpse", nil, true)
 
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
