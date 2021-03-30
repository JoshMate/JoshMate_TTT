if CLIENT then
   SWEP.PrintName          = "Manhack Swarm"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 10
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Summoning Weapon
	
Deploy a swarm of Manhacks where you are looking
   
They will attack ANYONE they see (Including You)
   
They will last for 30 seconds or until destroyed
]]
   };

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_swarm"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.DeploySpeed           = 4
SWEP.Primary.SoundLevel    = 100
SWEP.Primary.Automatic     = false

SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.Sound         = "shoot_swarm.wav"
SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_TRAITOR}
SWEP.LimitedStock          = true
SWEP.WeaponID              = AMMO_SWARM
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel            = "models/weapons/w_crowbar.mdl"
SWEP.HoldType 				   = "normal" 

local deployRange = 650
local deployAmount = 12
local deployLifeTime = 30


function Barrier_Effects_Destroyed(ent)
	if not IsValid(ent) then return end
 
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	util.Effect("TeslaHitboxes", effect, true, true)
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
         npc:SetHealth(1)
         npc:SetMaxHealth(1)
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

-- Hud Help Text
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Deploy a swarm of Manhacks", nil, true)
 
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