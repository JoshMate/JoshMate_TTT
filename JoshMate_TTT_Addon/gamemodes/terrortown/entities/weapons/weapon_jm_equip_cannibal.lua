
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
   
Consuming a body heals the user and increases their Maximum HP
   
Only has 5 uses and makes a sound
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_cannibal.png"
end


SWEP.Base                  = "weapon_jm_base_gun"
SWEP.HoldType              = "normal"

SWEP.Primary.Recoil        = 0
SWEP.Primary.Damage        = 0
SWEP.HeadshotMultiplier    = 0
SWEP.Primary.Delay         = 1
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 0
SWEP.DeploySpeed           = 4
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

local Cannibal_Eat_MaxHP      = 10
local Cannibal_Eat_Range      = 75
local Cannibal_Eat_Delay      = 4
local Cannibal_Eat_StayRange  = 100
local Cannibal_Eat_Sound      = "cannibal_eating_delay_withcough.mp3"

SWEP.Cannibal_CorpseThatIsBeingEaten            = "None"
SWEP.Cannibal_CorpseEatenAtThisTime             = 0


if TTT2 and CLIENT then
	hook.Add("Initialize", "jm_cannibalInit", function() 
		STATUS:RegisterStatus("jm_cannibal", {
			hud = Material("vgui/ttt/joshmate/hud_health.png"),
			type = "good"
		})
	end)
end


function SWEP:PrimaryAttack()
   
   -- Fire a trace to find a suitable eatable
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound( self.Primary.Sound )
   self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
   if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
      self:SetNWFloat( "LastShootTime", CurTime() )
   end

   -- Consume Corpse
   if SERVER then
      local tr = util.TraceLine({start = self:GetOwner():GetShootPos(), endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * Cannibal_Eat_Range, filter = self:GetOwner()})
      local target = tr.Entity

      if IsValid(target) then
         if target:GetClass() == "prop_ragdoll" or target:GetClass() == "npc_pigeon" or target:GetClass() == "npc_crow" or target:GetClass() == "npc_seagull" then
            self.Cannibal_CorpseThatIsBeingEaten = target
            self.Cannibal_CorpseEatenAtThisTime = CurTime() + Cannibal_Eat_Delay
            self:GetOwner():EmitSound( Cannibal_Eat_Sound, 85, 100, 1, CHAN_REPLACE )
            JM_Function_PrintChat(self:GetOwner(), "Equipment","You begin to feast... (Stay close)" )
            -- Give a Hit Marker to This Player
            local hitMarkerOwner = self:GetOwner()
            JM_Function_GiveHitMarkerToPlayer(hitMarkerOwner, 0, false)
         end
      end

   end
end

function SWEP:SecondaryAttack()
   return
end

-- Handle The Delay when eating corpses
function SWEP:Think()

   if CLIENT then return end
   if self.Cannibal_CorpseThatIsBeingEaten == "None" then return end

   local r = Cannibal_Eat_StayRange * Cannibal_Eat_StayRange -- square so we can compare with dot product directly
   local center = self.Cannibal_CorpseThatIsBeingEaten:GetPos()
   local d = 0.0
   local diff = nil

   -- dot of the difference with itself is distance squared
   diff = center - self:GetOwner():GetPos()
   d = diff:Dot(diff)

   if d >= r then 
      self.Cannibal_CorpseThatIsBeingEaten = "None"
      self:GetOwner():StopSound(Cannibal_Eat_Sound)
      JM_Function_PrintChat(self:GetOwner(), "Equipment","Eating Cancelled. You were too far away..." )
   end

   -- Eat the body after a delay
   if CurTime() >= self.Cannibal_CorpseEatenAtThisTime then
      self:CannibaliseCorpse()
   end


end

-- Remove Eating effect if weapon switched away
function SWEP:Holster( wep )
	
   if self.Cannibal_CorpseThatIsBeingEaten == "None" then
      return self.BaseClass.Holster(self)
	end

   self.Cannibal_CorpseThatIsBeingEaten = "None"
   self:GetOwner():StopSound(Cannibal_Eat_Sound)
   JM_Function_PrintChat(self:GetOwner(), "Equipment","Eating Cancelled. You changed weapons..." )
	return self.BaseClass.Holster(self)

end

function SWEP:CannibaliseCorpse()

   if not self.Cannibal_CorpseThatIsBeingEaten:IsValid() then return end

   local own = self:GetOwner()
   self.CannibalMaxHPGained = (Cannibal_Eat_MaxHP)
   own:SetMaxHealth(own:GetMaxHealth() + self.CannibalMaxHPGained)

   -- Set Status and print Message
   JM_GiveBuffToThisPlayer("jm_buff_cannibalheal",own,own)
   -- End Of

   local target = self.Cannibal_CorpseThatIsBeingEaten
   
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
   JM_Function_PrintChat(self:GetOwner(), "Equipment","Body Eaten (+" .. tostring(self.CannibalMaxHPGained) .. " Max HP)" )

   self.Cannibal_CorpseThatIsBeingEaten            = "None"

   if SERVER then
      if self:Clip1() <= 0 then
         self:Remove()
      end
   end

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
