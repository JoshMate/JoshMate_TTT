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

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then
		self:GetOwner():ChatPrint("[Money Printer] - Active and Printing in: " .. tostring(self.Print_Time_Delay) .. " Seconds")
	end

	-- UI HUD ICON
	if SERVER then self:SendWarn(true) end 
	-- END of 
end

function ENT:PrintMoney()

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then

		self:GetOwner():ChatPrint("[Money Printer] - You Printed: +20 Max HP")
		self:GetOwner():SetMaxHealth(self:GetOwner():GetMaxHealth() + self.Print_HP_Bonus)
		self:GetOwner():SetHealth(self:GetOwner():Health() + self.Print_HP_Bonus)

		if self.Print_Count < self.Print_Count_Max then
			self:GetOwner():ChatPrint("[Money Printer] - You Printed: +1 Credits")
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
			activator:ChatPrint("[Money Printer] - You Looted: 1 Credit")
			activator:ChatPrint("[Money Printer] - You Looted: +25 Max HP")
			activator:SetMaxHealth(activator:GetMaxHealth() + 25) 
			activator:SetHealth(activator:Health() + 25) 
			activator:AddCredits(1)
		end	
		self:Remove()
	end
end


function ENT:OnRemove()

	if SERVER then self:SendWarn(false) end

	if IsValid(self:GetOwner()) and self:GetOwner():Alive() and SERVER then
		self:GetOwner():ChatPrint("[Money Printer] - Your Printer has been Destroyed!")
	end

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("cball_explode", effect)
	sound.Play(Sound("npc/assassin/ball_zap1.wav"), self:GetPos())

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

--- Josh Mate Hud Warning
if SERVER then
	function ENT:SendWarn(armed)
		net.Start("TTT_MoneyWarn")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteBit(armed)

		if armed then
			net.WriteVector(self:GetPos())
		end

		net.Broadcast()
	end
end
