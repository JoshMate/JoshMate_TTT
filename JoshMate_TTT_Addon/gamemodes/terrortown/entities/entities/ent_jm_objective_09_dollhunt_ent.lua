if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Doll Hunt trade in spot"
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

	self.dollHuntCollect_Radius = 32
	self.dollHuntTotalCollected = 0

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_objective_dollhunt",self:GetPos(),0,0)
end


function ENT:OnRemove()

	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

end

function ENT:Think()

	self:DollHuntDetectDoll()

end

function ENT:DollHuntRemoveEffect(ent)
	if not IsValid(ent) then return end
	local effect = EffectData()
	local ePos = ent:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	util.Effect("cball_explode", effect, true, true)
 end

function ENT:DollHuntDetectDoll()

	if CLIENT then return end

	if not self:IsValid() then return end

	local r = self.dollHuntCollect_Radius * self.dollHuntCollect_Radius -- square so we can compare with dot product directly
	local center = self:GetPos()

	local d = 0.0
	local diff = nil
	local dolls = ents.FindByModel("models/maxofs2d/companion_doll.mdl")
	
	for i = 1, #dolls do
		local doll = dolls[i]

		if not doll:IsValid() then continue end

		diff = center - doll:GetPos()
		d = diff:Dot(diff)

		if d >= (r*2.5)  then continue end

		self.dollHuntTotalCollected = self.dollHuntTotalCollected + 1

		JM_Function_PlaySound("gamemode/dollhunt_bring.mp3")
		JM_Function_PrintChat_All("Doll Hunt", "A doll has been returned! " .. tostring(5-self.dollHuntTotalCollected) .. " left")

		-- Find Innocents
		for _,pl in pairs(player.GetAll()) do

			-- Traitors
			if pl:IsValid() and pl:Alive() and pl:IsTerror() and pl:IsTraitor() then

				pl:SetMaxHealth(pl:GetMaxHealth()-15)
				pl:SetHealth(pl:GetMaxHealth())
				if pl:GetMaxHealth() < 10 then pl:SetMaxHealth(10) end
				if pl:Health() < 10 then pl:SetHealth(10) end
				JM_Function_PrintChat(pl, "Doll Hunt","You Lost 15 Max Health")

			end

			-- Innocents
			if pl:IsValid() and pl:Alive() and pl:IsTerror() and pl:IsInnocent() then

				pl:SetMaxHealth(pl:GetMaxHealth()+30)
				pl:SetHealth(pl:GetMaxHealth())
				if pl:GetMaxHealth() < 10 then pl:SetMaxHealth(10) end
				if pl:Health() < 10 then pl:SetHealth(10) end
				JM_Function_PrintChat(pl, "Doll Hunt","You Gain 30 Max Health")
				JM_Function_Karma_Reward(pl, JM_KARMA_REWARD_ACTION_OBJECTIVE_DOLL, "Doll Returned")

			end

			-- Detectives
			if pl:IsValid() and pl:Alive() and pl:IsTerror() and pl:IsDetective() then

				pl:AddCredits(1)
				pl:SetMaxHealth(pl:GetMaxHealth()+30)
				pl:SetHealth(pl:GetMaxHealth())
				if pl:GetMaxHealth() < 10 then pl:SetMaxHealth(10) end
				if pl:Health() < 10 then pl:SetHealth(10) end
				JM_Function_PrintChat(pl, "Doll Hunt","You Gain 30 Max Health and 1 Credit")
				JM_Function_Karma_Reward(pl, JM_KARMA_REWARD_ACTION_OBJECTIVE_DOLL, "Doll Returned")
				

			end

		end

		self:DollHuntRemoveEffect(doll)
		doll:Remove()

		if self.dollHuntTotalCollected >= 5 then
			self:DollHuntRemoveEffect(self)
			self:Remove()
		end
		
			
	end
end


-- ESP Halo effect

local JM_Server_Halo_Colour = Color(0,255,0,255)

hook.Add( "PreDrawHalos", "Halos_DollHunt", function()

    halo.Add( ents.FindByClass( "ent_jm_objective_09_dollhunt_ent" ), JM_Server_Halo_Colour, 5, 5, 2, true, true )
 
end )