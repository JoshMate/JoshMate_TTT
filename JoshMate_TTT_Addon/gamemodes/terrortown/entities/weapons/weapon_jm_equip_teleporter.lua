-- traitor equipment: teleporter

AddCSLuaFile()

SWEP.HoldType              = "normal"

if CLIENT then
   SWEP.PrintName          = "Teleporter"
   SWEP.Slot               = 7

   SWEP.ViewModelFlip      = false
   SWEP.DrawCrosshair      = false
   SWEP.CSMuzzleFlashes    = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A Utility Weapon
	
Left-Click: Teleport to your marked location
      
Right-Click: Mark a location in the map
      
5 uses and teleporting is instant
]]
};

   function SWEP:GetViewModelPosition(pos, ang)
      return pos + ang:Forward() * 15 - ang:Right() *-15 - ang:Up() * 28, ang
   end

   SWEP.Icon               = "vgui/ttt/joshmate/icon_jm_teleporter.png"
end

SWEP.Base                  = "weapon_jm_base_gun"

SWEP.ViewModel             = "models/props_trainstation/payphone_reciever001a.mdl"
SWEP.WorldModel            = "models/props_trainstation/payphone_reciever001a.mdl"
SWEP.UseHands              = false

SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.ClipMax       = 0
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "None"
SWEP.Primary.Delay         = 0.5


SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay       = 0.5

SWEP.Kind                  = WEAPON_EQUIP2
SWEP.CanBuy                = {ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.LimitedStock          = true -- only buyable once
SWEP.WeaponID              = AMMO_TELEPORT

SWEP.AllowDrop             = true
SWEP.NoSights              = true
SWEP.DeploySpeed           = 4

SWEP.ttt_telefrags         = false


function JMTeleportEffectsInit(ent)
   if not IsValid(ent) then return end

   local effect = EffectData()
   local ePos = ent:GetPos()
   if ent:IsPlayer() then ePos:Add(Vector(0,0,40))end
   effect:SetStart(ePos)
   effect:SetOrigin(ePos)
   
   
   
   util.Effect("cball_explode", effect, true, true)
end






function SWEP:SetTeleportMark(pos, ang)
   self.teleport = {pos = pos, ang = ang}
end

function SWEP:GetTeleportMark() return self.teleport end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end

   if self:Clip1() <= 0 then
      self:DryFire(self.SetNextSecondaryFire)
      return
   end

   if SERVER then
      self:TeleportRecall()
   end

   -- Remove Weapon When out of Ammo
	 if SERVER then
		if self:Clip1() <= 0 then
		   	self:Remove()
		end
	 end
	 -- #########
end

function SWEP:SecondaryAttack()
   self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   if not self:CanSecondaryAttack() then return end

   if SERVER then
      self:TeleportStore()
      self.ttt_telefrags = false
      timer.Simple(5,
      function()
         if IsValid(self) then
            self.ttt_telefrags = true
         end
      end)
   else
      surface.PlaySound("teleport_mark.wav")
   end

   if SERVER  and self:GetOwner():IsDetective() then

      for _, v in ipairs(ents.FindByClass("ent_jm_equip_cctv")) do
          if v:GetNWEntity("JM_Camera_PlayerOwner")  == self:GetOwner() then
              v:Remove() -- if the player already has a camera, remove it
          end
      end

      local camera = ents.Create("ent_jm_equip_cctv")
      camera:SetPos(self:GetOwner():EyePos())
      camera:SetAngles(self:GetOwner():EyeAngles())
      camera:Spawn()
      camera:Activate()
      camera:SetNetworkedEntity("JM_Camera_PlayerOwner", self:GetOwner())
  end

   
end

local function Telefrag(victim, attacker, weapon)
   if not IsValid(victim) then return end

   local dmginfo = DamageInfo()
   dmginfo:SetDamage(5000)
   dmginfo:SetDamageType(DMG_SONIC)
   dmginfo:SetAttacker(attacker)
   dmginfo:SetInflictor(weapon)
   dmginfo:SetDamageForce(Vector(0,0,10))
   dmginfo:SetDamagePosition(attacker:GetPos())

   victim:TakeDamageInfo(dmginfo)
end


local function ShouldCollide(ent)
   local g = ent:GetCollisionGroup()
   return (g != COLLISION_GROUP_WEAPON and
           g != COLLISION_GROUP_DEBRIS and
           g != COLLISION_GROUP_DEBRIS_TRIGGER and
           g != COLLISION_GROUP_INTERACTIVE_DEBRIS)
end

-- Teleport a player to a {pos, ang}
local function TeleportPlayer(ply, teleport)
   local oldpos = ply:GetPos()
   local pos = teleport.pos
   local ang = teleport.ang

   -- print decal on destination
   util.PaintDown(pos + Vector(0,0,25), "GlassBreak", ply)


   -- perform teleport
   ply:SetPos(pos)
   ply:SetEyeAngles(ang)

   -- print decal on source now that we're gone, because else it will refuse
   -- to draw for some reason
   util.PaintDown(oldpos + Vector(0,0,25), "GlassBreak", ply)
end

-- Checks teleport destination. Returns bool and table, if bool is true then
-- location is blocked by world or prop. If table is non-nil it contains a list
-- of blocking players.
local function CanTeleportToPos(ply, pos)
   -- first check if we can teleport here at all, because any solid object or
   -- brush will make us stuck and therefore kills/blocks us instead, so the
   -- trace checks for anything solid to players that isn't a player
   local tr = nil
   local tres = {start=pos, endpos=pos, mask=MASK_PLAYERSOLID, filter=player.GetAll()}
   local collide = false

   -- This thing is unnecessary if we can supply a collision group to trace
   -- functions, like we can in source and sanity suggests we should be able
   -- to do so, but I have not found a way to do so yet. Until then, re-trace
   -- while extending our filter whenever we hit something we don't want to
   -- hit (like weapons or ragdolls).
   repeat
      tr = util.TraceEntity(tres, ply)

      if tr.HitWorld then
         collide = true
      elseif IsValid(tr.Entity) then
         if ShouldCollide(tr.Entity) then
            collide = true
         else
            table.insert(tres.filter, tr.Entity)
         end
      end
   until (not tr.Hit) or collide

   if collide then
      --Telefrag(ply, ply)
      return true, nil
   else

      -- find all players in the place where we will be and telefrag them
      local blockers = ents.FindInBox(pos + Vector(-16, -16, 0),
                                      pos + Vector(16, 16, 64))

      local blocking_plys = {}

      for _, block in ipairs(blockers) do
         if IsValid(block) then
            if block:IsPlayer() and block != ply then
               if block:IsTerror() and block:Alive() then
                  table.insert(blocking_plys, block)
                  -- telefrag blocker
                  --Telefrag(block, ply)
               end
            end
         end
      end

      return false, blocking_plys
   end

   return false, nil
end

local function DoTeleport(ply, teleport, weapon)
   if IsValid(ply) and ply:IsTerror() and teleport then
      local fail = false

      local block_world, block_plys = CanTeleportToPos(ply, teleport.pos)

      if block_world then
         -- if blocked by prop/world, always fail
         fail = true
         JM_Function_PrintChat(ply, "Equipment", "Teleport Failed... (A solid is blocking you)")
      elseif block_plys and #block_plys > 0 then
         -- if blocked by player, maybe telefrag
         if weapon.ttt_telefrags then
            for _, p in ipairs(block_plys) do
               Telefrag(p, ply, weapon)
            end
         else
            fail = true
            JM_Function_PrintChat(ply, "Equipment", "Teleport Failed... (A player is blocking you)")
         end
      end

      if not fail then
         -- Play Tele sound to world
         weapon:TakePrimaryAmmo(1)
         ply:EmitSound("teleport_recall.wav")
         JMTeleportEffectsInit(ply)
         TeleportPlayer(ply, teleport)
      end
   end
end

local function StartTeleport(ply, teleport, weapon)
   if (not IsValid(ply)) or (not ply:IsTerror()) or (not teleport) then
      return end

   teleport.ang = ply:EyeAngles()

   DoTeleport(ply, teleport, weapon)
   

   
end

function SWEP:TeleportRecall()
   local ply = self:GetOwner()
   if IsValid(ply) and ply:IsTerror() then
      local mark = self:GetTeleportMark()
      if mark then

         

         StartTeleport(ply, mark, self) 
      else
         JM_Function_PrintChat(ply, "Equipment", "Teleport Failed... (You must mark a location first)")
      end
   end
end

local function CanStoreTeleportPos(ply, pos)
   local g = ply:GetGroundEntity()
   if ply:Crouching() then
      return false, "tele_no_mark_crouch"
   end

   return true, nil
end

function SWEP:TeleportStore()
   local ply = self:GetOwner()
   if IsValid(ply) and ply:IsTerror() then

      local allow, msg = CanStoreTeleportPos(ply, self:GetPos())
      if not allow then
         JM_Function_PrintChat(ply, "Equipment", "Mark Failed... (You can't mark while crouching)")
         return
      end

      self:SetTeleportMark(ply:GetPos(), ply:EyeAngles())
      JM_Function_PrintChat(ply, "Equipment", "Teleport Location Marked!")
   end
end



function SWEP:Reload()
   return false
end


function SWEP:Deploy()
   if SERVER and IsValid(self:GetOwner()) then
      self:GetOwner():DrawViewModel(false)
   end

   return true
end

function SWEP:ShootEffects() end


-- ##############################################
-- Josh Mate Various SWEP Quirks
-- ##############################################

-- HUD Controls Information
if CLIENT then
	function SWEP:Initialize()
	   self:AddTTT2HUDHelp("Teleport to a marked location", "Mark a location", true)
 
	   return self.BaseClass.Initialize(self)
	end
end
-- Equip Bare Hands on Remove
if SERVER then
   function SWEP:OnRemove()
      if self:GetOwner():IsValid() and self:GetOwner():IsTerror() and self:GetOwner():Alive() then
         self:GetOwner():SelectWeapon("weapon_jm_special_hands")
         if self:GetOwner():IsDetective() then

            for _, v in ipairs(ents.FindByClass("ent_jm_equip_cctv")) do
                if v:GetNWEntity("JM_Camera_PlayerOwner")  == self:GetOwner() then
                    v:Remove() -- if the player already has a camera, remove it
                end
            end
         end
      end
   end
end
-- Hide World Model when Equipped
function SWEP:DrawWorldModel()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
function SWEP:DrawWorldModelTranslucent()
   if IsValid(self:GetOwner()) then return end
   self:DrawModel()
end
-- Delete on Drop
function SWEP:OnDrop() 
   self:Remove()
end

-- ##############################################
-- End of Josh Mate Various SWEP Quirks
-- ##############################################

