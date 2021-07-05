AddCSLuaFile()

ENT.Type                = "anim"
ENT.PrintName           = "Pulse Pad"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Trap"
ENT.Instructions        = "Trap"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false


local JM_PulsePad_Model                 = "models/props_junk/sawblade001a.mdl"
local JM_PulsePad_Colour_Dormant        = Color( 0, 0, 255, 200 )
local JM_PulsePad_Colour_Armed          = Color( 0, 0, 255, 25 )
local JM_PulsePad_Sound_HitPlayer       = "pulsepad_hit.wav"
local JM_PulsePad_Sound_Destroyed       = "0_main_click.wav"
local JM_PulsePad_ArmTime				= 0.8

ENT.isArmed								= false

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

function ENT:Initialize()
	self:SetModel(JM_PulsePad_Model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	-- JoshMate Changed
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor(JM_PulsePad_Colour_Dormant) 
	self:DrawShadow(false)

	-- Timer To arm this Ent
	timer.Simple(JM_PulsePad_ArmTime, function()

		 if IsValid(self) then 
			self.isArmed = true	
			self:SetColor(JM_PulsePad_Colour_Armed)  
		end 

	end)


end

function ENT:Use( activator, caller )

    if CLIENT then return end

    if IsValid(activator) and activator:IsPlayer() and IsValid(self) then

		if activator:IsTerror() then
			self.Owner:ChatPrint("[Pulse Pad] - Your Pulse Pad has been removed!")
            self:Effect_Sparks()
			self:Remove()
		end
		
	end

end

function ENT:Touch(toucher)

	if SERVER then
		if(not self.isArmed) then return end
        if(not toucher:IsValid()) then return end
        if(not toucher:IsPlayer()) then return end
        if(not toucher:IsTerror()) then return end
        if(not toucher:Alive()) then return end
        if(not GAMEMODE:AllowPVP()) then return end
        if(toucher:GetNWBool(JM_Global_Buff_PulsePad_NWBool)) then return end

		if(toucher == self.Owner) then return end

        -- Give Buff
        JM_GiveBuffToThisPlayer("jm_buff_pulsepad",toucher,self.Owner)
        -- End Of

        -- JM Changes Extra Hit Marker
        net.Start( "hitmarker" )
        net.WriteFloat(0)
        net.Send(self.Owner)
        -- End Of

        -- HUD Message
        toucher:ChatPrint("[Pulse Pad] - You have stepped on a Pulse Pad!")
        self.Owner:ChatPrint("[Pulse Pad] - Somone has stepped on your Pulse Pad!" )
        -- End Of

        toucher:EmitSound(JM_PulsePad_Sound_HitPlayer);
        self:Effect_Sparks()
        self:Remove()
	
	end
end

function ENT:Effect_Sparks()

	if not IsValid(self) then return end
    
    self:EmitSound(JM_PulsePad_Sound_Destroyed);

	local effect = EffectData()
	local ePos = self:GetPos()
	effect:SetStart(ePos)
	effect:SetOrigin(ePos)
	
	util.Effect("TeslaZap", effect, true, true)
	
	util.Effect("cball_explode", effect, true, true)

end

