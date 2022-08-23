if SERVER then
	AddCSLuaFile()
else
	-- this entity can be DNA-sampled so we need some display info
	ENT.Icon = "vgui/ttt/icon_radio"
	ENT.PrintName = "Money Printer"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_c17/consolebox01a.mdl")

ENT.CanHavePrints = false

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self.Print_Time_Last 	= CurTime()
	self.Print_Count 		= 0
	self.Print_Count_Max	= 2
	self.Print_Time_Delay	= 30
	self.Print_HP_Bonus		= 25

	-- Set Status and print Message
	if SERVER then JM_GiveBuffToThisPlayer("jm_buff_moneyprinter",self:GetOwner(),self:GetOwner()) end
	-- End Of

	-- Simple Use
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then
		JM_Function_PrintChat(self:GetOwner(), "Equipment", "Money Printing in " .. tostring(self.Print_Time_Delay) .. " Seconds")
	end

	-- Josh Mate New Warning Icon Code
	JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_money",self:GetPos(),0,false)
end

function ENT:PrintMoney()

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then

		JM_Function_PrintChat(self:GetOwner(), "Equipment", "Money Printed (+20 Max HP)")
		self:GetOwner():SetMaxHealth(self:GetOwner():GetMaxHealth() + self.Print_HP_Bonus)
		self:GetOwner():SetHealth(self:GetOwner():Health() + self.Print_HP_Bonus)

		if self.Print_Count < self.Print_Count_Max then
			JM_Function_PrintChat(self:GetOwner(), "Equipment", "Money Printed (+1 Credit)")
			self:GetOwner():AddCredits(1)
		end

		-- Set Status and print Message
		if SERVER then JM_GiveBuffToThisPlayer("jm_buff_moneyprinter",self:GetOwner(),self:GetOwner()) end
		-- End Of

	end
end

function ENT:Use( activator, caller )

	if CLIENT then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:IsTraitor() then

		if IsValid(activator) and activator:Alive() and SERVER then

			if activator:GetActiveWeapon():GetClass() == "weapon_jm_special_hands" then 
				JM_Function_PrintChat(activator, "Equipment", "You looted a Money Printer (+30 Max HP)")
				JM_Function_PrintChat(activator, "Equipment", "You looted a Money Printer (+1 Credit)")
				activator:SetMaxHealth(activator:GetMaxHealth() + 30) 
				activator:SetHealth(activator:Health() + 30) 
				activator:AddCredits(1)
				self:Remove()
			else
				JM_Function_PrintChat(activator, "Equipment", "You need your hands free to do that...")
			end

		end	
		
	end
end


function ENT:OnRemove()

	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then
		JM_Function_PrintChat(self:GetOwner(), "Equipment", "Your Money Printer has been destroyed!")
	end

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("cball_explode", effect)
	if SERVER then sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos()) end

end

function ENT:Think()

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then

		if self.Print_Time_Last + self.Print_Time_Delay < CurTime() then
			self:PrintMoney()
			self.Print_Time_Last 	= CurTime()
			self.Print_Count 		= self.Print_Count + 1
		end
	end
end


