AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Music Radio"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Ent"
ENT.Instructions                = "Ent"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

local JM_Radio_Radius				= 164
local JM_Radio_Heal_Amount			= 1
local JM_Radio_Heal_Delay			= 0.4

function ENT:Initialize()
	self:SetModel("models/props/cs_office/radio.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	-- Timers
	self.radioLastHealed = CurTime()

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end
	if SERVER then

		-- Josh Mate New Warning Icon Code
		JM_Function_SendHUDWarning(true,self:EntIndex(),"icon_warn_radio",self:GetPos(),0,0)
		

		self.radioChosenSongPath = nil
		self.radioChosenSongText = "Nothing"
		self.randomChoice = math.random(1, 5)

		if self.randomChoice == 1 then
			self.radioChosenSongPath = "radio_birdflewin.mp3"
			self.radioChosenSongText = "A Bird Flew In"
		end
		if self.randomChoice == 2 then
			self.radioChosenSongPath = "radio_troubleinthistown.mp3"
			self.radioChosenSongText = "Trouble in This Town"
		end
		if self.randomChoice == 3 then
			self.radioChosenSongPath = "Yeah_Gus_Is_My_Name.mp3"
			self.radioChosenSongText = "Gus is My Name"
		end
		if self.randomChoice == 4 then
			self.radioChosenSongPath = "radio_builtdifferently.mp3"
			self.radioChosenSongText = "Built Differently"
		end
		if self.randomChoice == 5 then
			self.radioChosenSongPath = "radio_shoebodybop.mp3"
			self.radioChosenSongText = "Shoebody Bop"
		end

		self:SetNWString("radioSongName", self.radioChosenSongText)

		self:EmitSound(self.radioChosenSongPath, 120, 100, 1, CHAN_AUTO)
	end

end

function radioHealSphere(ent)

	if CLIENT then return end
	if not ent:IsValid() then return end

	local r = JM_Radio_Radius * JM_Radio_Radius -- square so we can compare with dot product directly
	local center = ent:GetPos()

	-- Heal Players in radius
	d = 0.0
	diff = nil
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]
		
		if not ply:Team() == TEAM_TERROR  or not ply:Alive() then continue end

		-- dot of the difference with itself is distance squared
		diff = center - ply:GetPos()
		d = diff:Dot(diff)

		if d >= r then continue end

		if(ply:Health() >= ply:GetMaxHealth()) then continue end
		
		if ((ply:Health() + JM_Radio_Heal_Amount) > ply:GetMaxHealth()) then
			ply:SetHealth(ply:GetMaxHealth())
		else
			ply:SetHealth(ply:Health() + JM_Radio_Heal_Amount)
		end
	end
end


function ENT:Use( activator, caller )
end

function ENT:Think()

	-- Heal tick
	if CurTime() >= (self.radioLastHealed + JM_Radio_Heal_Delay) then
		radioHealSphere(self)
		self.radioLastHealed	= CurTime()
	end

end


hook.Add("PostDrawOpaqueRenderables", "drawRadioText", function()

	listofRadios = ents.FindByClass( "ent_jm_zloot_radio_music*" )

	-- Set all players Vars
	for i = 1, #listofRadios do
		local radio = listofRadios[i]
		if (radio:IsValid()) then
				-- Draw Song Name above radio in 3D space
				local pos = radio:GetPos()
				
				-- Get the game's camera angles
				local angle = EyeAngles()

				-- Only use the Yaw component of the angle
				angle = Angle( 0, angle.y, 0 )

				-- Apply some animation to the angle
				angle.x = angle.x + math.sin( CurTime() ) * 12
				angle.y = angle.y + math.sin( CurTime() ) * 12
				angle.z = angle.z + math.sin( CurTime() ) * 12

				-- Correct the angle so it points at the camera
				-- This is usually done by trial and error using Up(), Right() and Forward() axes
				angle:RotateAroundAxis( angle:Up(), -90 )
				angle:RotateAroundAxis( angle:Forward(), 90 )

				cam.Start3D2D(pos, angle, 0.3)
				draw.SimpleTextOutlined(radio:GetNWString("radioSongName", "Music"), "DermaLarge", 0, -64, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0,255))
				cam.End3D2D()
		end
	end	
end)

function ENT:OnRemove()

	-- When removing this ent, also remove the HUD icon, by changing isEnabled to false
	JM_Function_SendHUDWarning(false,self:EntIndex())

end

local JM_Radio_Halo_Colour = Color(200,0,255,255)
hook.Add( "PreDrawHalos", "Halos_radio", function()
    halo.Add( ents.FindByClass( "ent_jm_zloot_radio_music*" ), JM_Radio_Halo_Colour, 2, 2, 3, true, false )
 
end )