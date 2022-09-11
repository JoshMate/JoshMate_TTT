AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Objective Base: Bounty"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Manages Objectives"
ENT.Instructions        = "Manages Objectives"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

function ENT:Initialize()

	JM_GameMode_BountyHunter_Start()

	self.bountyHunter_TargetsSelectedSoFar = 0
	self.bountyHunter_CurrentTarget = 0

end

function ENT:Think()

	if self.bountyHunter_CurrentTarget == -1 then return end

	-- IF the Bounty Target is Fresh and needs to be set
	if self.bountyHunter_CurrentTarget == 0 then
		self:BountyHunter_Select_NewTarget() 
		return
	end

	-- If they DC, Glitch or Die
	if not self.bountyHunter_CurrentTarget:IsValid() or not self.bountyHunter_CurrentTarget:Alive() or not self.bountyHunter_CurrentTarget:IsTerror() then
		self:BountyHunter_Select_NewTarget()
		return
	end

	-- If they Become a Traitor Half Way through the round
	if self.bountyHunter_CurrentTarget:IsTraitor() then
		self.bountyHunter_CurrentTarget:SetNWBool("BountyHunterIsTarget", false)
		self:BountyHunter_Select_NewTarget()
	end

end


function ENT:BountyHunter_Select_NewTarget() 

	local tableOfPossibleTargets = {}

	-- Build a list of possible targets
	for _,pl in pairs(player.GetAll()) do
		if pl:IsValid() and pl:Alive() and not pl:IsSpec() and not pl:IsTraitor() then 
			table.insert(tableOfPossibleTargets, pl)
		end
	end

	if #tableOfPossibleTargets > 0 then 
		-- Randomly select from the table of targets
		self.bountyHunter_CurrentTarget = tableOfPossibleTargets[math.random( #tableOfPossibleTargets )]

		-- Set NWBool to make them a target
		self.bountyHunter_CurrentTarget:SetNWBool("BountyHunterIsTarget", true)

		-- Inform the traitors of the new target

		if self.bountyHunter_TargetsSelectedSoFar > 0 then
			for _,pl in pairs(player.GetAll()) do
				if pl:IsValid() and pl:IsTraitor() then 

					if SERVER then 
						JM_Function_PrintChat(pl, "Bounty Hunter", "Your Target is: " .. tostring(self.bountyHunter_CurrentTarget:Nick())) 
						JM_Function_PrintChat(pl, "Bounty Hunter", "Traitors gain 1 Credit") 
						pl:AddCredits(1)
					end

				end
			end
		end

		self.bountyHunter_TargetsSelectedSoFar = self.bountyHunter_TargetsSelectedSoFar + 1

	else
		self.bountyHunter_CurrentTarget = -1
		JM_Function_PrintChat_All("Bounty Hunter", "All targets are dead, Traitors win!")
		JM_Function_PlaySound("gamemode/file_end.mp3")		
	end

	

end



function JM_GameMode_BountyHunter_Start()

	-- Validation Checks
	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	-- Announce the Goal
	JM_Function_Announcement("[Bounty Hunter] Traitors deal x2 damage to their targets, and recieve credits for killing them!", 0)

	-- Play the Sound
	JM_Function_PlaySound("gamemode/bounty_start.mp3")


end


-- Only Damage Target
hook.Add("EntityTakeDamage", "BountyHunter_TargetDamage", function(target, dmginfo)

	local listOfObjectives = ents.FindByClass( "ent_jm_objective_03_bounty_base" )
	if #listOfObjectives <= 0 then return end

	if not IsValid(target) or not target:IsPlayer() then return end

	if not dmginfo:GetAttacker():IsValid() or not dmginfo:GetAttacker():IsPlayer() then return end

	if not dmginfo:GetAttacker():IsTerror() or not dmginfo:GetAttacker():IsTraitor() then return end

	if target:GetNWBool("BountyHunterIsTarget") == true then
		dmginfo:SetDamage(dmginfo:GetDamage() * 2)
	else
		dmginfo:SetDamage(dmginfo:GetDamage())
	end

end)


-- ESP Halo effect
local JM_Server_Halo_Colour = Color(0,255,0,255)

hook.Add( "PreDrawHalos", "Halos_BountyTarget", function()

	local players = {}
	local count = 0
	local locpl = LocalPlayer()

	if locpl:IsTraitor() or not locpl:Alive() then 

		for _,pl in pairs(player.GetAll()) do
			if pl:IsValid() and pl:Alive() and pl:GetNWBool("BountyHunterIsTarget") == true then 
				count = count + 1
				players[ count ] = pl
			end
		end
	end

	halo.Add( players, JM_Server_Halo_Colour, 2, 2, 3, true, true )

end )


-- Function To Reset Target Data
function JM_ResetBountyHunterData()

	-- Build a list of possible targets
	for _,pl in pairs(player.GetAll()) do
		if pl:IsValid() then 
			pl:SetNWBool("BountyHunterIsTarget", false)
		end
	end

end

--- Josh Mate Reset Gravity Etc...
if SERVER then

	hook.Add("TTTEndRound", "JM_End_Reset_CVars_ForBounty", function() JM_ResetBountyHunterData() end)
	hook.Add("TTTPrepareRound", "JM_Prep_Reset_CVars_ForBounty", function() JM_ResetBountyHunterData() end)

end
