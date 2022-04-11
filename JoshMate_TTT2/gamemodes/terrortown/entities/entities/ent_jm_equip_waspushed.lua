AddCSLuaFile()

ENT.Type                = "point"
ENT.PrintName           = "Push Timer"
ENT.Author              = "Josh Mate"
ENT.Purpose             = "Contract"
ENT.Instructions        = "Contract"
ENT.Spawnable           = false
ENT.AdminSpawnable      = false

if CLIENT then return end

ENT.wasPushed_Attribution_LingerTime			= 1
ENT.wasPushed_TimeofPush						= nil

function ENT:Initialize()

	print("[Push Contract] - Started - (" .. tostring(self.pusher:Nick()) .. ") pushed (" .. tostring(self.target:Nick()) .. ") with a (" .. tostring(self.weapon) .. ")")
	self.wasPushed_TimeofPush = CurTime()

end

function ENT:Think()

	-- Valdiation
	if not self.target:IsValid() or not self.pusher:IsValid() or not self.target:IsPlayer() or not self.target:IsTerror() or not self.pusher:IsPlayer() or not self.pusher:IsTerror() then
		print("[Push Contract] - Not Valid - (" .. tostring(self.pusher:Nick()) .. ") pushed (" .. tostring(self.target:Nick()) .. ") with a (" .. tostring(self.weapon) .. ")")
		self:Remove()
		return
	end

	-- Delete old push contracts
	if self.target.was_pushed.wasPushed_TimeofPush > self.wasPushed_TimeofPush then 
		print("[Push Contract] - Overwritten - (" .. tostring(self.pusher:Nick()) .. ") pushed (" .. tostring(self.target:Nick()) .. ") with a (" .. tostring(self.weapon) .. ")")
		self:Remove() 
		return
	end

	-- Delete if timed out and not grounded or in water
	if CurTime() >= (self.wasPushed_TimeofPush + self.wasPushed_Attribution_LingerTime) and (self.target:OnGround() or not self.target:WaterLevel() == 0) then
		print("[Push Contract] - Expired - (" .. tostring(self.pusher:Nick()) .. ") pushed (" .. tostring(self.target:Nick()) .. ") with a (" .. tostring(self.weapon) .. ")")
		self.target.was_pushed = nil
		self:Remove()
		return
	end

end


