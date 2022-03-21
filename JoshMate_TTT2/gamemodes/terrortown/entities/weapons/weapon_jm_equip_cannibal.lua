
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
   
Consuming a Body grants +25 Max HP and heals 75
   
Only has 6 uses
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_cannibal.png"
end


SWEP.Base                  = "weapon_jm_base_gun"
SWEP.HoldType              = "normal"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 0.45
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 6
SWEP.Primary.DefaultClip   = 6
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

local Cannibal_Eat_MaxHP      = 30
local Cannibal_Eat_Range      = 150

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

            local own = self:GetOwner()

            own:SetMaxHealth(own:GetMaxHealth() + Cannibal_Eat_MaxHP)
            own:SetHealth(own:Health() + (Cannibal_Eat_MaxHP * 3))

            own:SetHealth(math.Clamp(own:Health(), 0, own:GetMaxHealth()))
            
            targetPos = target:GetPos()

            target:EmitSound("physics/flesh/flesh_bloody_break.wav")
            target:SetNotSolid(true)
            target:Remove()

            self:CreateProp(targetPos, "models/gibs/hgibs.mdl")
            self:CreateProp(targetPos, "models/gibs/hgibs_rib.mdl")
            self:CreateProp(targetPos, "models/gibs/hgibs_scapula.mdl")
            self:CreateProp(targetPos, "models/gibs/hgibs_rib.mdl")
            self:CreateProp(targetPos, "models/gibs/hgibs_scapula.mdl")
            self:CreateProp(targetPos, "models/gibs/hgibs_rib.mdl")
            self:CreateProp(targetPos, "models/gibs/hgibs_spine.mdl")

            -- Give a Hit Marker to This Player
		         local hitMarkerOwner = self:GetOwner()
		         JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)

            self:TakePrimaryAmmo( 1 )
            ate = true
         end
      end

   end

   if SERVER then
      if ate == false then
         JM_Function_PrintChat(self:GetOwner(), "Equipment","You can't eat that with Cannibal..." )
      end
      if ate == true then
         JM_Function_PrintChat(self:GetOwner(), "Equipment","Body Eaten (" .. tostring(Cannibal_Eat_MaxHP) .. ")" )
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

function SWEP:CreateProp(targetPos, model)
   local skull = ents.Create( "prop_physics" )
   skull:SetModel(model)
   -- Add a bit of jitter to spawning
   local newPos = targetPos
   newPos.x = newPos.x + math.random( 0, 16 )
   newPos.y = newPos.y + math.random( 0, 16 )
   newPos.x = newPos.x - math.random( 0, 16 )
   newPos.y = newPos.y - math.random( 0, 16 )
   newPos.z = newPos.z + math.random( 0, 4  )
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

   local vel = skull:GetPhysicsObject():GetVelocity()
   vel.z = vel.z + math.random( 150, 300 )
   skull:GetPhysicsObject():AddVelocity( vel )

end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Consume a dead body", nil, true)
 
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
