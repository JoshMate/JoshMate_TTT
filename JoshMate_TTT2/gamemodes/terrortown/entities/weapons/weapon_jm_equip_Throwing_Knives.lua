if SERVER then
	AddCSLuaFile()
end

SWEP.HoldType = "knife"

if CLIENT then
	SWEP.PrintName = "Throwing Knives"
	SWEP.Slot = 6

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
	SWEP.DrawCrosshair = false

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = [[A silent ranged weapon
	
	Throwing knives that deal more damge the further they travel
	
	They are silent but leave a faint trail
	
	You get 3 knives
	]]
	}

	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_throwing_knife.png"
	SWEP.IconLetter = "j"
end

SWEP.Base = "weapon_jm_base_gun"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage = 5000
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo = "none"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_THROWINGKNIFE

SWEP.IsSilent 				= true
SWEP.DeploySpeed         	= 2

-- JM Changes, Throwing
SWEP.JM_Throw_Power        = 1000
SWEP.JM_Throw_PowerMult    = 1
-- End of


function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not self:CanPrimaryAttack() then return end

	self:SendWeaponAnim(ACT_VM_DRAW)
	self:TakePrimaryAmmo( 1 )
	if IsValid(self:GetOwner()) then
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	end

	if CLIENT then return end

	local ply = self:GetOwner()

	if not IsValid(ply) then return end

	ply:SetAnimation(PLAYER_ATTACK1)

	-- Josh Mate Changes = Massively Simplified this for ease of use
	local A_Src = ply:GetShootPos()
	local A_Angle = Angle(-28, 0, 0) + ply:EyeAngles()
	A_Angle:RotateAroundAxis(A_Angle:Right(), -90)
	local A_Vel = ( ply:GetAimVector() * (self.JM_Throw_Power * self.JM_Throw_PowerMult ))
	local A_AngImp = Vector(0, 2000, 0)

	local knife = ents.Create("ent_jm_equip_throwing_knife")
	if not IsValid(knife) then return end

	knife:SetPos(A_Src)
	knife:SetAngles(A_Angle)
	knife:Spawn()
	knife:SetOwner(ply)
	knife.fingerprints = self.fingerprints

	local phys = knife:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetVelocity(A_Vel)
		phys:AddAngleVelocity(A_AngImp)
		phys:Wake()
	end

	-- Remove Ammo

	if SERVER then
		if self:Clip1() <= 0 then
		   self:Remove()
		end
	 end
  
	 -- #########
end



function SWEP:SecondaryAttack()
	return
end

function SWEP:PreDrop()
	-- for consistency, dropped knife should not have DNA/prints
	self.fingerprints = {}
end

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Throw Knife", nil, true)
 
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
