-- #############################################
-- Buff Base Class Info
-- #############################################
AddCSLuaFile()
ENT.Type                        = "point"
ENT.Author                      = "Josh Mate"
ENT.Purpose                     = "A Buff Ent that handles buff logic"
ENT.Instructions                = "A Buff Ent that handles buff logic"
ENT.Spawnable                   = false
ENT.AdminSpawnable              = false


-- #############################################
-- Buff Basic Info
-- #############################################

local JM_PrintName              = "BASE BUFF"
local JM_BuffNWBool             = nil
local JM_BuffDuration           = nil
local JM_BuffIconName           = nil
local JM_BuffIconPath           = nil
local JM_BuffIconGoodBad        = nil

-- #############################################
-- Generated Values (important for instances)
-- #############################################

ENT.PrintName                   = JM_PrintName
ENT.BuffNWBool                  = JM_BuffNWBool
ENT.BuffDuration                = JM_BuffDuration
ENT.BuffIconName                = JM_BuffIconName


-- #############################################
-- Do One time only, when the buff is created
-- #############################################
function ENT:Initialize()

        if not self.targetPlayer then
            ErrorNoHalt("[JM Buffs] - Error a buff was created with no target player! - Buff Was: " .. tostring(self.PrintName))
            return 
        end
        
        if not self.timeOfBuffCreation then
            ErrorNoHalt("[JM Buffs] - Error a buff was created with no time of creation! - Buff Was: " .. tostring(self.PrintName))
            return 
        end

        if (not self.targetPlayer:IsValid() or not self.targetPlayer:IsPlayer() or not self.targetPlayer:IsTerror() or not self.targetPlayer:Alive()) then
            ErrorNoHalt("[JM Buffs] - self.targetPlayer was not valid/player/terror/alive at time of buff creation - Buff Was: " .. tostring(self.PrintName))
            return 
        end

        -- Add the Buff Icon to their Screen and send them the NWBool for their client effects
        if (self.BuffDuration > 0) then
            STATUS:AddTimedStatus(self.targetPlayer, self.BuffIconName, self.BuffDuration, 1)
        end
        if (self.BuffDuration <= 0) then
            STATUS:AddStatus(self.targetPlayer, self.BuffIconName)
        end
        
        self.targetPlayer:SetNWBool(self.BuffNWBool, true)
        if SERVER then print("[Buff] - " .. tostring(self.targetPlayer:Nick()) .. " Recieves The Effect: " .. tostring(self.PrintName)) end

end


-- #############################################
-- Do EVERY server frame
-- #############################################

function ENT:Think()

    self.targetPlayer:SetNWBool(self.BuffNWBool, true)

    -- Remove the buff prematurely if any of these conditions are met
    if not self.targetPlayer:IsValid()      then self.targetPlayer:SetNWBool(self.BuffNWBool, false) self:Remove() end
    if not self.targetPlayer:IsPlayer()     then self.targetPlayer:SetNWBool(self.BuffNWBool, false) self:Remove() end
    if not self.targetPlayer:Alive()        then self.targetPlayer:SetNWBool(self.BuffNWBool, false) self:Remove() end
    if not self.targetPlayer:IsTerror()     then self.targetPlayer:SetNWBool(self.BuffNWBool, false) self:Remove() end

    -- When the Buff naturally Expires
    if (self.BuffDuration > 0) then
        if (CurTime() >= (self.timeOfBuffCreation+self.BuffDuration)) then
            self.targetPlayer:SetNWBool(self.BuffNWBool, false) 
            self:Remove()
        end
    end
    
end

-- #############################################
-- Do One time only, when the buff is destroyed
-- #############################################

function ENT:OnRemove()
    if(self.targetPlayer:IsValid() and self.targetPlayer:IsPlayer()) then
	    self.targetPlayer:SetNWBool(self.BuffNWBool, false)
    end
end


