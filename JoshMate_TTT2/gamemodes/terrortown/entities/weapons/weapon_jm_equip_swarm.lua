if CLIENT then
   SWEP.PrintName          = "Manhack Swarm"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Summoning Weapon
	
Deploy a swarm of Manhacks where you are looking
   
They will attack ANYONE they see (Including You)
   
They will last for 35 seconds or until destroyed
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_swarm"

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() * -20 - ang:Up() * 10, ang
	end

end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.DeploySpeed           = 4
SWEP.Primary.SoundLevel    = 75
SWEP.Primary.Automatic     = false

SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.Sound         = "shoot_swarm.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR}
SWEP.LimitedStock          = true
SWEP.WeaponID              = AMMO_SWARM
SWEP.ViewModel             = "models/manhack.mdl"
SWEP.WorldModel            = "models/manhack.mdl"
SWEP.UseHands              = false
SWEP.HoldType 				   = "normal" 

local deployRange = 9999
local deployAmount = 9
local deployLifeTime = 35


function Barrier_Effects_Destroyed(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	
	
	util.Effect("cball_explode", effect, true, true)
end

function SWEP:SecondaryAttack()
end

if SERVER then
	AddCSLuaFile()
   function SWEP:PrimaryAttack()

      self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
      local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * deployRange, filter = self.Owner})

      local JM_ManHackLifeStart = CurTime()

      local npc = nil
      for i = deployAmount,1,-1 do 
         npc = ents.Create("npc_manhack")
         npc:SetPos(tr.HitPos)
         npc:SetShouldServerRagdoll(false)
         npc:Spawn()
         npc:SetNWEntity("giveHitMarkersTo", self.Owner)
         npc.JM_ManHackLifeStart = JM_ManHackLifeStart         
      end

      timer.Simple(deployLifeTime, function () 

         for k, v in ipairs( ents.FindByClass("npc_manhack") ) do
            if (v.JM_ManHackLifeStart <= CurTime() - (deployLifeTime - 1)) then
               Barrier_Effects_Destroyed(v) 
               v:Remove()
            end
         end

      end)

      self:Remove()
   end
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Deploy a swarm of Manhacks where you are looking", nil, true)
 
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