AddCSLuaFile()

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

ENT.Type                        = "anim"
ENT.PrintName                   = "Tester Sample"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "Ent"
ENT.Instructions                = "Ent"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false

local JM_TesterSample_TestDelay		= 20

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_plasticbottle003a.mdl") 
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	-- Timers
	self.testerSampleTimeToFinish = CurTime() + JM_TesterSample_TestDelay
	self.testerSampleHasCompleted = false

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		self:GetPhysicsObject():EnableMotion(true)
	end

	self:PhysWake()

	if SERVER then
		self:EmitSound("shoot_portable_tester_scan.wav")		
	end
	

end

function ENT:sampleUpdateText()

	if SERVER then
		if self.testerSamplePlayer:IsValid() and self.testerSamplePlayer:IsPlayer() then
			self:SetNWString("testerSampleNWSTR_Name", self.testerSamplePlayer:Nick())
		else
			self:SetNWString("testerSampleNWSTR_Name", "???")
		end
		
		self:SetNWString("testerSampleNWSTR_Status", self.radioChosenSongTextStatus)
	end

end



function ENT:Use( activator, caller )

	if IsValid(activator) and activator:IsPlayer() and IsValid(self) and activator:IsTerror() and activator:IsTraitor() and activator:Alive() then

		activator:AddCredits(1)
		JM_Function_PrintChat(activator, "Equipment", "You destroyed the sample and gained +1 Credit")
		self:Remove()

	end

end

function ENT:Think()

	if CLIENT then return end

	-- Timer
	if self.testerSampleHasCompleted == false then

		if CurTime() >= (self.testerSampleTimeToFinish) then

			self.testerSampleHasCompleted = true

			if self.testerSamplePlayer:IsValid() then

				if self.testerSamplePlayer:IsTraitor() then
					self.radioChosenSongTextStatus = "Traitor"
				else
					self.radioChosenSongTextStatus = "Innocent"
				end

				self:EmitSound("shoot_portable_tester_done.wav")
				self:sampleUpdateText()

			end

		else

			self.radioChosenSongTextStatus = tostring(math.Round((self.testerSampleTimeToFinish - CurTime())), 0)
			self:sampleUpdateText()

		end

	end

end


hook.Add("PostDrawOpaqueRenderables", "drawTesterSampleText", function()

	listofSamples = ents.FindByClass( "ent_jm_equipment_tester_sample*" )

	-- Set all players Vars
	for i = 1, #listofSamples do
		local sample = listofSamples[i]
		if (sample:IsValid()) then
				-- Draw Song Name above radio in 3D space
				local pos = sample:GetPos()
				
				-- Get the game's camera angles
				local angle = EyeAngles()

				-- Only use the Yaw component of the angle
				angle = Angle( 0, angle.y, 0 )

				-- Correct the angle so it points at the camera
				-- This is usually done by trial and error using Up(), Right() and Forward() axes
				angle:RotateAroundAxis( angle:Up(), -90 )
				angle:RotateAroundAxis( angle:Forward(), 90 )

				cam.Start3D2D(pos, angle, 0.3)

				-- Decide font colours
				local testerSampleStatusColour = Color(255,255,255,255)
				if sample:GetNWString("testerSampleNWSTR_Status", "Status") == "Innocent" then
					testerSampleStatusColour = Color(0,255,0,255)
				end
				if sample:GetNWString("testerSampleNWSTR_Status", "Status") == "Traitor" then
					testerSampleStatusColour = Color(255,0,0,255)
				end

				draw.SimpleTextOutlined(sample:GetNWString("testerSampleNWSTR_Name", "Name"), "DermaLarge", 0, -96, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0,255))
				draw.SimpleTextOutlined(sample:GetNWString("testerSampleNWSTR_Status", "Status"), "DermaLarge", 0, -64, testerSampleStatusColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0,0,0,255))
				cam.End3D2D()
		end
	end	
end)

function ENT:OnRemove()

	self:EmitSound("0_main_click.wav")

end

local JM_TestSample_Halo_Colour = Color(0,80,255,255)

hook.Add( "PreDrawHalos", "Halos_testSample", function()
    halo.Add( ents.FindByClass( "ent_jm_equipment_tester_sample*" ), JM_TestSample_Halo_Colour, 2, 2, 3, true, false )
 
end )