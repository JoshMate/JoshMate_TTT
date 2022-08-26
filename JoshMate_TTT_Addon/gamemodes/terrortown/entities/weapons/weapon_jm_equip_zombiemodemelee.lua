if SERVER then
	AddCSLuaFile()

end

SWEP.HoldType = "melee"

if CLIENT then
	SWEP.PrintName = "Zombie Blade"
	SWEP.Slot = 7

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = [[A Lethal Melee Weapon
	  
The Weapon that you use when you are in Zombie Mode
]]
	 };

	SWEP.DrawCrosshair = false
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54

	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_gun_special.png"

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 1 - ang:Right() * 1 - ang:Up() * -1, ang
	end
end

local ZombieBlade_Range	= 100

SWEP.Base = "weapon_jm_base_gun"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage = 35
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.40
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 2

SWEP.Kind = WEAPON_EQUIP1
SWEP.WeaponID = AMMO_ZombieBlade

SWEP.NoSights = true
SWEP.IsSilent = true

SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.AutoSpawnable 			= false

SWEP.AllowDrop 				= false
SWEP.CanBuy 				= {}
SWEP.LimitedStock 			= true

-- JM Changes, Movement Speed
SWEP.MoveMentMultiplier = 1.2
-- End of

local sound_single = Sound("Weapon_Knife.Slash")


function SWEP:PrimaryAttack()
	-- Rapid Fire Changes
	local owner = self:GetOwner()
	if (not owner:GetNWBool(JM_Global_Buff_Care_RapidFire_NWBool)) then self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	else self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay*0.70)) end
	-- End of Rapid Fire Changes

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if isfunction(owner.LagCompensation) then -- for some reason not always true
		owner:LagCompensation(true)
	end

	local spos = owner:GetShootPos()
	local sdest = spos + owner:GetAimVector() * ZombieBlade_Range

	local tr_main = util.TraceLine({
		start = spos,
		endpos = sdest,
		filter = owner,
		mask = MASK_SHOT_HULL
	})

	local hitEnt = tr_main.Entity

	self:EmitSound(sound_single)

	if IsValid(hitEnt) or tr_main.HitWorld then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

		if SERVER or IsFirstTimePredicted() then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			edata:SetDamageType(DMG_SLASH)
			edata:SetEntity(hitEnt)

			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
				util.Effect("BloodImpact", edata)

				-- does not work on players rah
				--util.Decal("Blood", tr_main.HitPos + tr_main.HitNormal, tr_main.HitPos - tr_main.HitNormal)

				-- do a bullet just to make blood decals work sanely
				-- need to disable lagcomp because firebullets does its own
				owner:LagCompensation(false)
				owner:FireBullets({
					Num = 1,
					Src = spos,
					Dir = owner:GetAimVector(),
					Spread = Vector(0, 0, 0),
					Tracer = 0,
					Force = 1,
					Damage = 0
				})
			else
				util.Effect("Impact", edata)
			end

		end
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end

	if SERVER then

		-- Do another trace that sees nodraw stuff like func_button
		local tr_all = util.TraceLine({
			start = spos,
			endpos = sdest,
			filter = owner
		})

		local trEnt = tr_all.Entity

		owner:SetAnimation(PLAYER_ATTACK1)

		if IsValid(hitEnt) then

			local dmg = DamageInfo()
			if hitEnt:IsTerror() and hitEnt:IsTraitor() then
				dmg:SetDamage(0)
			else
				dmg:SetDamage(self.Primary.Damage)
			end
			dmg:SetAttacker(owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(owner:GetAimVector() * 1)
			dmg:SetDamagePosition(owner:GetPos())
			dmg:SetDamageType(DMG_SLASH)

			hitEnt:DispatchTraceAttack(dmg, spos + owner:GetAimVector() * 3, sdest)
		end
	end

	if isfunction(owner.LagCompensation) then
		owner:LagCompensation(false)
	end
end

function SWEP:SecondaryAttack()

	return

end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:OnHolster()
	if ply:IsValid() and ply:Alive() and ply:IsTerror() then
		self:GetOwner():SelectWeapon("weapon_jm_equip_zombiemodemelee")
	end
	return
end

-- Stop Player Switching
hook.Add( "PlayerSwitchWeapon", "ZombieBladeCantSwitchWeapon", function( ply, oldWeapon, newWeapon )

	if ply:IsValid() and ply:Alive() and ply:IsTerror() then
		if ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == "weapon_jm_equip_zombiemodemelee" then
			JM_Function_PrintChat(ply, "Equipment","A magical force prevents you from switching weapons" )
			return true
		end
	end
end )

-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Melee Attack", nil, true)
 
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
