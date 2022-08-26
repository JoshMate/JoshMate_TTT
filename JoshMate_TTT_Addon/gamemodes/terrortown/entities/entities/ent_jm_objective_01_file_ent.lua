if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "File"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_lab/filecabinet02.mdl")

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 0, 255, 0, 255))

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_objective_file",self:GetPos(),0,0)
end

function ENT:Use( activator, caller )

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then

		if activator:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
			self:GrabFile(activator) 
		else
			JM_Function_PrintChat(activator, "Grab The Files", "You need your hands free to do that...")
		end

	end
end


function ENT:GrabFile() 

	if CLIENT then return end

	JM_Function_PlaySound("pulsepad_hit.wav")

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("cball_explode", effect)
	sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

	local listOfObjectives = ents.FindByClass( "ent_jm_objective_01_file_ent" )
	local numberOfFilesLeft = (#listOfObjectives)
	JM_Function_PrintChat_All("Grab The Files", "A File has been grabbed! (" .. tostring(numberOfFilesLeft) .. " Left!)")
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

	if #listOfObjectives <= 0 then

		-- Reveal 1 Traitor
		local nameOfRevealedTraitor = "ERROR"
		local nameOfPersonWhoKnows = activator:Nick()

		-- Build a list of possible targets
		for _,pl in pairs(player.GetAll()) do
			if pl:IsValid() and pl:Alive() and not pl:IsSpec() and pl:IsTerror() and pl:IsTraitor() then 
				nameOfRevealedTraitor = pl:Nick()
				break
			end
		end

		JM_Function_PrintChat_All("Grab The Files", tostring(nameOfPersonWhoKnows) .. " knows who the Traitor is!")
		JM_Function_PrintChat(activator, "Grab The Files", "The Traitor is: " .. tostring(nameOfRevealedTraitor))
		JM_Function_PlaySound("gamemode/file_end.mp3")
	end

	self:Remove()

end

function ENT:OnRemove()
	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())
end

-- ESP Halo effect

local JM_Server_Halo_Colour = Color(0,255,0,255)

hook.Add( "PreDrawHalos", "Halos_Files", function()

    halo.Add( ents.FindByClass( "ent_jm_objective_01_file" ), JM_Server_Halo_Colour, 5, 5, 2, true, true )
 
end )