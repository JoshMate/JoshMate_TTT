-- traitor equipment: radio

AddCSLuaFile()

SWEP.HoldType               = "normal"

if CLIENT then
   SWEP.PrintName           = "Money Printer"
   SWEP.Slot                = 7

   SWEP.ViewModelFlip       = false
   SWEP.DrawCrosshair       = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A utility item
	
Once placed, touching bodies against it will give you +1 Credit

DNA and Radar scans will point to this instead of you

Can be destroyed by other players
]]
   };

   function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 25 - ang:Right() * -17 - ang:Up() * 18, ang
	end

   SWEP.Icon                = "vgui/ttt/joshmate/icon_jm_moneyprinter.png" 
end

SWEP.Base                   = "weapon_jm_base_gun"

SWEP.ViewModel              = "models/props_c17/consolebox01a.mdl"
SWEP.WorldModel             = "models/props_c17/consolebox01a.mdl"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay          = 1.0

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 1.0

SWEP.Kind                   = WEAPON_EQUIP2
SWEP.CanBuy                 = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock           = true -- only buyable once
SWEP.WeaponID               = AMMO_RADIO

SWEP.AllowDrop              = false
SWEP.NoSights               = true
SWEP.UseHands 				= false

function SWEP:OnDrop()
   self:Remove()
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:RadioDrop()
end
function SWEP:SecondaryAttack()
   return
end

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

-- c4 plant but different
function SWEP:RadioDrop()
   if SERVER then
      local ply = self:GetOwner()
      if not IsValid(ply) then return end

      if self.Planted then return end

      local vsrc = ply:GetShootPos()
      local vang = ply:GetAimVector()
      local vvel = ply:GetVelocity()
      
      local vthrow = vvel + vang * 200

      local radio = ents.Create("ent_jm_equip_moneyprinter")
      if IsValid(radio) then
         radio:SetPos(vsrc + vang * 10)
         radio:SetOwner(ply)
		   radio:SetNWString("decoy_owner_team", ply:GetTeam())
         radio:Spawn()

         radio:SetColor(Color( 255, 0, 0, 255))

         radio:PhysWake()
         local phys = radio:GetPhysicsObject()
         if IsValid(phys) then
            phys:SetVelocity(vthrow)
         end   
         self:Remove()

         self.Planted = true
         self:GetOwner().decoy = radio
         
      end
   end

   self:EmitSound(throwsound)
end

function SWEP:Reload()
   return false
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
      RunConsoleCommand("lastinv")
   end
end

if CLIENT then
   function SWEP:Initialize()
      self:AddTTT2HUDHelp("Place a Money Printer in front of you", nil, true)

      return self.BaseClass.Initialize(self)
   end

end
-- Invisible, same hacks as holstered weapon


function SWEP:Deploy()
   if SERVER and IsValid(self:GetOwner()) then
      self:GetOwner():DrawViewModel(false)
   end
   return true
end

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

-- add hook that changes all decoys (Merged in from DECOY)
hook.Add("TTT2UpdateTeam", "TTT2DecoyUpdateTeam", function(ply, oldTeam, newTeam)
		if not IsValid(ply.decoy) then return end
      ply.decoy:SetNWString("decoy_owner_team", newTeam)
end)
