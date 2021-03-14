if CLIENT then
   SWEP.PrintName          = "Manhack Swarm"
   SWEP.Slot               = 6

   SWEP.ViewModelFOV       = 10
   SWEP.ViewModelFlip      = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Lethal Summoning Weapon
	
Deploy a swarm of Manhacks infront of you
   
They will attack ANYONE they see (Including You)
   
They will roam around until destroyed
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
local deployAmount = 9


function SWEP:SecondaryAttack()
end

if SERVER then
	AddCSLuaFile()
   function SWEP:PrimaryAttack()

      self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
      local tr = util.TraceLine({start = self.Owner:GetShootPos(), endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * deployRange, filter = self.Owner})

      local npc = nil
      for i = deployAmount,1,-1 do 
         npc = ents.Create("npc_manhack")
         npc:SetPos(tr.HitPos)
         npc:SetShouldServerRagdoll(false)
         npc:Spawn()
         npc:SetNWEntity("giveHitMarkersTo", self.Owner)
      end

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