if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Arms Deal"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_junk/MetalBucket02a.mdl")

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 0, 255, 0, 255))
	
	self.Objective_ArmsDeal_Score		= 0
	self.Objective_ArmsDeal_Goal		= 50
	self.Objective_ArmsDeal_Radius		= 24

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_objective_armsdeal",self:GetPos(),0,0)
end


function ENT:OnRemove()

	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

end

function ENT:Think()

	self:ArmsDealDetectWeapon()

end

function ENT:ArmsDealRemoveEffect(ent)
	if not IsValid(ent) then return end
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
 end

function ENT:ArmsDealDetectWeapon()

	if CLIENT then return end

	if not self:IsValid() then return end

	local r = self.Objective_ArmsDeal_Radius * self.Objective_ArmsDeal_Radius -- square so we can compare with dot product directly
	local center = self:GetPos()

	-- Destroy other trees to prevent stacking
	local d = 0.0
	local diff = nil
	local weapons = ents.FindByClass( "weapon_*" )
	
	for i = 1, #weapons do
		local weapon = weapons[i]

		if not weapon:IsValid() then continue end

		diff = center - weapon:GetPos()
		d = diff:Dot(diff)

		if d >= (r*2.5)  then continue end

		if weapon.IsOnFloor == false then continue end

		-- Process the weapon as it is in range
		local scoreGiven = 0

		if weapon:GetClass() == "weapon_jm_primary_lmg" then scoreGiven = 8 end
		if weapon:GetClass() == "weapon_jm_primary_sniper" then scoreGiven = 5 end
		if weapon:GetClass() == "weapon_jm_primary_rifle" then scoreGiven = 4 end
		if weapon:GetClass() == "weapon_jm_primary_smg" then scoreGiven = 4 end
		if weapon:GetClass() == "weapon_jm_primary_shotgun" then scoreGiven = 4 end
		if weapon:GetClass() == "weapon_jm_secondary_heavy" then scoreGiven = 3 end
		if weapon:GetClass() == "weapon_jm_secondary_auto" then scoreGiven = 3 end
		if weapon:GetClass() == "weapon_jm_secondary_light" then scoreGiven = 2 end
		if weapon:GetClass() == "weapon_jm_grenade_frag" then scoreGiven = 3 end
		if weapon:GetClass() == "weapon_jm_grenade_glue" then scoreGiven = 4 end
		if weapon:GetClass() == "weapon_jm_grenade_health" then scoreGiven = 3 end
		if weapon:GetClass() == "weapon_jm_grenade_jump" then scoreGiven = 4 end
		if weapon:GetClass() == "weapon_jm_grenade_tag" then scoreGiven = 2 end

		if scoreGiven == 0 then continue end

		self.Objective_ArmsDeal_Score = self.Objective_ArmsDeal_Score + scoreGiven
		JM_Function_PrintChat_All("Arms Deal", "Weapon Given, New Score: " .. tostring(self.Objective_ArmsDeal_Score) .. "/" .. tostring(self.Objective_ArmsDeal_Goal))

		self:ArmsDealRemoveEffect(weapon)

		JM_Function_Karma_Reward(weapon:GetOwner(), JM_KARMA_REWARD_ACTION_OBJECTIVE_ARMS, "Weapon Donated")

		weapon:Remove()

		if self.Objective_ArmsDeal_Score >= self.Objective_ArmsDeal_Goal then 

			-- Reveal 1 Traitor
			local nameOfRevealedTraitor = "ERROR"
			local nameOfPersonWhoKnows = "ERROR"

			-- Build a list of possible targets
			
			local listOfPlayers = player.GetAll()
			table.Shuffle(listOfPlayers)

			for _,pl in pairs(listOfPlayers) do
				if pl:IsValid() and pl:Alive() and not pl:IsSpec() and pl:IsTerror() and pl:IsTraitor() then 
					nameOfRevealedTraitor = pl
					break
				end
			end

			listOfPlayers = player.GetAll()
			table.Shuffle(listOfPlayers)

			-- Build a list of possible Knowers
			for _,pl in pairs(listOfPlayers) do
				if pl:IsValid() and pl:Alive() and not pl:IsSpec() and pl:IsTerror() then 
					nameOfPersonWhoKnows = pl
					break
				end
			end

			if nameOfPersonWhoKnows == "ERROR" or nameOfRevealedTraitor == "ERROR" then 

				JM_Function_PrintChat_All("Arms Deal", "Error working out who the Traitor Is...")

			else

				JM_Function_PrintChat_All("Arms Deal", tostring(nameOfPersonWhoKnows:Nick()) .. " knows who the Traitor is!")
				JM_Function_PrintChat(nameOfPersonWhoKnows, "Arms Deal", "The Traitor is: " .. tostring(nameOfRevealedTraitor:Nick()))

			end
			
			
			
			JM_Function_PlaySound("gamemode/file_end.mp3")

			self:Remove()

			break
		end
			

	end
end


-- ESP Halo effect

local JM_Server_Halo_Colour = Color(0,255,0,255)

hook.Add( "PreDrawHalos", "Halos_ArmsDeal", function()

    halo.Add( ents.FindByClass( "ent_jm_objective_08_armsdeal_ent" ), JM_Server_Halo_Colour, 5, 5, 2, true, true )
 
end )