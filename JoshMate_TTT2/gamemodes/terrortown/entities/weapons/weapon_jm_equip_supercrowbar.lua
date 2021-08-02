local cv_crowbar_unlocks
local cv_crowbar_pushforce = 2000

if SERVER then
	AddCSLuaFile()

	cv_crowbar_unlocks = CreateConVar("ttt_crowbar_unlocks", "0", FCVAR_ARCHIVE)
end

SWEP.HoldType = "melee"

if CLIENT then
	SWEP.PrintName = "Super Crowbar"
	SWEP.Slot = 7

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = [[A Lethal Melee Weapon
	  
A regular looking crowbar that has stronger stats
	
	+ 2x Melee Damage
	+ 4x Push Force
	+ Faster Pushing
	+ Instantly Destroys D Barriers
]]
	 };

	SWEP.DrawCrosshair = false
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54

	SWEP.Icon = "vgui/ttt/joshmate/icon_jm_supercrowbar.png"

	function SWEP:GetViewModelPosition(pos, ang)
		return pos + ang:Forward() * 5 - ang:Right() * -5 - ang:Up() * -10, ang
	end
end

local SuperCrowbar_Range	= 200

SWEP.Base = "weapon_jm_base_gun"

SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.Primary.Damage = 45
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.4
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 2

SWEP.Kind = WEAPON_EQUIP1
SWEP.WeaponID = AMMO_SUPERCROWBAR

SWEP.NoSights = true
SWEP.IsSilent = true

SWEP.Weight					= 5
SWEP.Slot			    	= 7
SWEP.AutoSpawnable = false

SWEP.AllowDrop = true
SWEP.CanBuy 				= { ROLE_TRAITOR}
SWEP.LimitedStock 			= true

local sound_single = Sound("Weapon_Crowbar.Single")

-- only open things that have a name (and are therefore likely to be meant to
-- open) and are the right class. Opening behaviour also differs per class, so
-- return one of the OPEN_ values
local pmnc_tbl = {
	prop_door_rotating = OPEN_ROT,
	func_door = OPEN_DOOR,
	func_door_rotating = OPEN_DOOR,
	func_button = OPEN_BUT,
	func_movelinear = OPEN_NOTOGGLE
}

local function OpenableEnt(ent)
	return pmnc_tbl[ent:GetClass()] or OPEN_NO
end

local function CrowbarCanUnlock(t)
	return not GAMEMODE.crowbar_unlocks or GAMEMODE.crowbar_unlocks[t]
end

---
-- Will open door AND return what it did
-- @param Entity hitEnt
-- @return number Entity types a crowbar might open
function SWEP:OpenEnt(hitEnt)
	-- Get ready for some prototype-quality code, all ye who read this
	if SERVER and cv_crowbar_unlocks:GetBool() then
		local openable = OpenableEnt(hitEnt)

		if openable == OPEN_DOOR or openable == OPEN_ROT then
			local unlock = CrowbarCanUnlock(openable)
			if unlock then
				hitEnt:Fire("Unlock", nil, 0)
			end

			if unlock or hitEnt:HasSpawnFlags(SF_NPC_LONG_RANGE) then -- Long Visibility/Shoot
				if openable == OPEN_ROT then
					hitEnt:Fire("OpenAwayFrom", self:GetOwner(), 0)
				end

				hitEnt:Fire("Toggle", nil, 0)
			else
				return OPEN_NO
			end
		elseif openable == OPEN_BUT then
			if CrowbarCanUnlock(openable) then
				hitEnt:Fire("Unlock", nil, 0)
				hitEnt:Fire("Press", nil, 0)
			else
				return OPEN_NO
			end
		elseif openable == OPEN_NOTOGGLE then
			if CrowbarCanUnlock(openable) then
				hitEnt:Fire("Open", nil, 0)
			else
				return OPEN_NO
			end
		end

		return openable
	else
		return OPEN_NO
	end
end

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
	local sdest = spos + owner:GetAimVector() * SuperCrowbar_Range

	local tr_main = util.TraceLine({
		start = spos,
		endpos = sdest,
		filter = owner,
		mask = MASK_SHOT_HULL
	})

	local hitEnt = tr_main.Entity

	self:EmitSound(sound_single)

	if IsValid(hitEnt) or tr_main.HitWorld then
		self:SendWeaponAnim(ACT_VM_HITCENTER)

		if SERVER or IsFirstTimePredicted() then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			--edata:SetDamageType(DMG_CLUB)
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
			if self:OpenEnt(hitEnt) == OPEN_NO and IsValid(trEnt) then
				self:OpenEnt(trEnt) -- See if there's a nodraw thing we should open
			end

			local dmg = DamageInfo()
			if hitEnt:GetClass() == "ent_jm_barrier" then
				dmg:SetDamage(self.Primary.Damage * 100)
			else
				dmg:SetDamage(self.Primary.Damage)
			end
			dmg:SetAttacker(owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(owner:GetAimVector() * 1500)
			dmg:SetDamagePosition(owner:GetPos())
			dmg:SetDamageType(DMG_CLUB)

			hitEnt:DispatchTraceAttack(dmg, spos + owner:GetAimVector() * 3, sdest)
		elseif IsValid(trEnt) then -- See if our nodraw trace got the goods
			self:OpenEnt(trEnt)
		end
	end

	if isfunction(owner.LagCompensation) then
		owner:LagCompensation(false)
	end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + 0.1)

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if isfunction(owner.LagCompensation) then
		owner:LagCompensation(true)
	end

	local tr = owner:GetEyeTrace(MASK_SHOT)
	local ply = tr.Entity

	if tr.Hit and IsValid(ply) and ply:IsPlayer() and (owner:EyePos() - tr.HitPos):Length() < SuperCrowbar_Range then
		if SERVER and not ply:IsFrozen() and not hook.Run("TTT2PlayerPreventPush", owner, ply) then
			local pushvel = tr.Normal * cv_crowbar_pushforce
			pushvel.z = math.Clamp(pushvel.z, 50, 100) -- limit the upward force to prevent launching

			ply:SetVelocity(ply:GetVelocity() + pushvel)
			owner:SetAnimation(PLAYER_ATTACK1)

			 -- JM Changes Extra Hit Marker
			 net.Start( "hitmarker" )
			 net.WriteFloat(0)
			 net.Send(owner)
			 -- End Of

			ply.was_pushed = {
				att = owner,
				t = CurTime(),
				wep = self:GetClass(),
				-- infl = self
			}
		end

		self:EmitSound(sound_single)
		self:SendWeaponAnim(ACT_VM_HITCENTER)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	end

	if isfunction(owner.LagCompensation) then
		owner:LagCompensation(false)
	end
end

function SWEP:OnDrop()
	self:Remove()
end