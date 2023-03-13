if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Antidote"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_lab/crematorcase.mdl")

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(Color( 0, 255, 0, 255))
	
	self.Objective_Antidote_PeopleWhoHaveUsed	= {}

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_objective_antidote",self:GetPos(),0,0)
end

function ENT:Use( activator, caller )

	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then

		if (not table.HasValue(self.Objective_Antidote_PeopleWhoHaveUsed, tostring(activator:Nick()))) then
			JM_Function_PlaySound("grenade_health.wav")
			JM_Function_PrintChat_All("Antidote", tostring(activator:Nick()) .. " has been cured!)")
			JM_RemoveBuffFromThisPlayer("jm_buff_antidotepoison",activator)
			activator:SetHealth(activator:GetMaxHealth())
			table.insert(self.Objective_Antidote_PeopleWhoHaveUsed, tostring(activator:Nick()))
			STATUS:RemoveStatus(activator, JM_Global_Buff_AntidotePoison_IconName)
		end

	end
end

function ENT:OnRemove()

	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

end


-- ESP Halo effect

local JM_Server_Halo_Colour = Color(0,255,0,255)

hook.Add( "PreDrawHalos", "Halos_Antidote", function()

    halo.Add( ents.FindByClass( "ent_jm_objective_07_antidote_ent" ), JM_Server_Halo_Colour, 5, 5, 2, true, true )
 
end )