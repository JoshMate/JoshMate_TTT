if SERVER then
	AddCSLuaFile()
else
	-- this entity can be DNA-sampled so we need some display info
	ENT.Icon = "vgui/ttt/icon_radio"
	ENT.PrintName = "Dopamine Button"
end

ENT.Type = "anim"
ENT.Model = Model("models/dav0r/buttons/button.mdl")

ENT.neetsThatPushedTheButton = {}


function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetPos(self:GetPos() + Vector(0, 0, 28))

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	if SERVER then
		JM_Function_Announcement("[Dopamine Button] Come get your dopamine here!")
	end

end


hook.Add( "PreDrawHalos", "Halos_dopamine_button", function()
    halo.Add( ents.FindByClass( "ent_jm_zloot_dopamine_button*" ), Color(143, 19, 70, 255), 5, 5, 2, true, true )
 
end )


function ENT:Use( activator, caller )
	
	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end
	
    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then
		
		local buttonOutcome = self.neetsThatPushedTheButton[activator:Nick()]
		
		--not presed before
		if buttonOutcome == nil then
			
			local roll = math.random(4)
			local killDecision = roll == 1
			self.neetsThatPushedTheButton[activator:Nick()] = killDecision

			if killDecision then

				JM_Function_PrintChat(activator, "Care Package","Dopamine Button grants (+1 Sweet Release of Death)")

				local effect = EffectData()
				effect:SetStart(self:GetPos())
				effect:SetOrigin(self:GetPos())
				util.Effect("Explosion", effect, true, true)
				util.Effect("HelicopterMegaBomb", effect, true, true)

				activator:TakeDamage( 9999, activator, self)
				activator:EmitSound(Sound("npc/assassin/ball_zap1.wav"));


				if SERVER then
					JM_Function_PlaySound("radio_bruh.wav") 
					JM_Function_PrintChat_All("Care Package", "Dopamine Button: " .. tostring(activator:Nick()) .. " has chosen poorly")
				end

			else
				JM_Function_PlaySound("dopamine_button_live.mp3")
				JM_Function_PrintChat(activator, "Care Package","Dopamine Button grants you (+1 Credit)")
				JM_Function_PrintChat_All("Care Package", "Dopamine Button: " .. tostring(activator:Nick()) .. " recieves Dopamine")
				activator:AddCredits(1)
			end

		else
			activator:EmitSound(Sound("dopamine_button_used.mp3"));
			JM_Function_PrintChat(activator, "Care Package","Your fate has already been decided")
		end
	end
end

