if SERVER then
	AddCSLuaFile()
else
	-- this entity can be DNA-sampled so we need some display info
	ENT.Icon = "vgui/ttt/icon_radio"
	ENT.PrintName = "Dopamine Button"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_c17/consolebox01a.mdl")

ENT.neetsThatPushedTheButton = {}


function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)


	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	if SERVER then
		JM_Function_Announcement("Get your dopamine here!", 0)
	end

end


hook.Add( "PreDrawHalos", "Halos_dopamine_button", function()
    halo.Add( ents.FindByClass( "ent_atsm_equip_dopamine_button*" ), Color(143, 19, 70, 255), 5, 5, 2, true, true )
 
end )


function ENT:Use( activator, caller )
	
	if CLIENT then return end

	if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then return end
	
    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:Alive() then
		
		local buttonOutcome = self.neetsThatPushedTheButton[activator:Nick()]
		
		--not presed before
		if buttonOutcome == nil then
			
			local roll = math.random(10)
			local killDecision = roll == 1
			self.neetsThatPushedTheButton[activator:Nick()] = killDecision

			if killDecision then

				local effect = EffectData()
				effect:SetStart(self:GetPos())
				effect:SetOrigin(self:GetPos())
				util.Effect("Explosion", effect, true, true)
				util.Effect("HelicopterMegaBomb", effect, true, true)

				activator:TakeDamage( 9999, activator, self)
				sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

				net.Start("JM_Net_Announcement")
				net.WriteString(tostring(activator:Nick()) .. " has chosen poorly")
				net.WriteUInt(0, 16)
				net.Broadcast()

			else
				if roll == 10 then
					activator:AddCredits(1)
					activator:ChatPrint("You received a credit!")
				end

				self.Entity:EmitSound(Sound("dopamine_button_live.mp3"));
			end

		else
			self.Entity:EmitSound(Sound("dopamine_button_used.mp3"));
			activator:ChatPrint("Your fate has already been dicided")
		end
	end
end

