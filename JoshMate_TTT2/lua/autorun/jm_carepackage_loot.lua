if engine.ActiveGamemode() ~= "terrortown" then return end


local JM_CarePackageLoot_Chance_Rare = 25

-- Master Loot Table that decides on Rare or Normal loot
function JM_CarePackage_Use_LootMaster(activator,caller,forcedLootType,forcedLootIndex)

    if SERVER then

        -- Random Roller
        local RNG_Roll = math.random(1, 100)

        -- Rolls a High Number (Normal Roll)
        if (RNG_Roll > JM_CarePackageLoot_Chance_Rare or forcedLootType == 1) then 
            JM_CarePackage_Use_LootNormal( activator, caller, forcedLootIndex )
            return
        end

        -- Rolls a low number (Rare Roll)
        if (RNG_Roll <= JM_CarePackageLoot_Chance_Rare or forcedLootType == 2) then 
            JM_CarePackage_Use_LootRare( activator, caller, forcedLootIndex ) 
            return 
        end
    
    end
end

-- Normal Loot Table
function JM_CarePackage_Use_LootNormal( activator, caller, forcedLootIndex)

    local RNG_Roll_Normal = math.random(1, 26)

    -- Optional Override of loot outcome for debug / fun
    if not forcedLootIndex == 0 then RNG_Roll_Normal = forcedLootIndex end

    if RNG_Roll_Normal == 1     then JM_CarePackage_Loot_Normal_01( activator, caller ) end
    if RNG_Roll_Normal == 2     then JM_CarePackage_Loot_Normal_02( activator, caller ) end
    if RNG_Roll_Normal == 3     then JM_CarePackage_Loot_Normal_03( activator, caller ) end
    if RNG_Roll_Normal == 4     then JM_CarePackage_Loot_Normal_04( activator, caller ) end
    if RNG_Roll_Normal == 5     then JM_CarePackage_Loot_Normal_05( activator, caller ) end
    if RNG_Roll_Normal == 6     then JM_CarePackage_Loot_Normal_06( activator, caller ) end
    if RNG_Roll_Normal == 7     then JM_CarePackage_Loot_Normal_07( activator, caller ) end
    if RNG_Roll_Normal == 8     then JM_CarePackage_Loot_Normal_08( activator, caller ) end
    if RNG_Roll_Normal == 9     then JM_CarePackage_Loot_Normal_09( activator, caller ) end
    if RNG_Roll_Normal == 10    then JM_CarePackage_Loot_Normal_10( activator, caller ) end
    if RNG_Roll_Normal == 11    then JM_CarePackage_Loot_Normal_11( activator, caller ) end
    if RNG_Roll_Normal == 12    then JM_CarePackage_Loot_Normal_12( activator, caller ) end
    if RNG_Roll_Normal == 13    then JM_CarePackage_Loot_Normal_13( activator, caller ) end
    if RNG_Roll_Normal == 14    then JM_CarePackage_Loot_Normal_14( activator, caller ) end
    if RNG_Roll_Normal == 15    then JM_CarePackage_Loot_Normal_15( activator, caller ) end
    if RNG_Roll_Normal == 16    then JM_CarePackage_Loot_Normal_16( activator, caller ) end
    if RNG_Roll_Normal == 17    then JM_CarePackage_Loot_Normal_17( activator, caller ) end
    if RNG_Roll_Normal == 18    then JM_CarePackage_Loot_Normal_18( activator, caller ) end
    if RNG_Roll_Normal == 19    then JM_CarePackage_Loot_Normal_19( activator, caller ) end
    if RNG_Roll_Normal == 20    then JM_CarePackage_Loot_Normal_20( activator, caller ) end
    if RNG_Roll_Normal == 21    then JM_CarePackage_Loot_Normal_21( activator, caller ) end
    if RNG_Roll_Normal == 22    then JM_CarePackage_Loot_Normal_22( activator, caller ) end
    if RNG_Roll_Normal == 23    then JM_CarePackage_Loot_Normal_23( activator, caller ) end
    if RNG_Roll_Normal == 24    then JM_CarePackage_Loot_Normal_24( activator, caller ) end
    if RNG_Roll_Normal == 25    then JM_CarePackage_Loot_Normal_25( activator, caller ) end
    if RNG_Roll_Normal == 26    then JM_CarePackage_Loot_Normal_26( activator, caller ) end

end

-- Rare Loot Table
function JM_CarePackage_Use_LootRare( activator, caller, forcedLootIndex) 

    local RNG_Roll_Rare = math.random(1, 19)

    -- Optional Override of loot outcome for debug / fun
    if not forcedLootIndex == 0 then RNG_Roll_Rare = forcedLootIndex end

    if RNG_Roll_Rare == 1     then JM_CarePackage_Loot_Rare_01( activator, caller ) end
    if RNG_Roll_Rare == 2     then JM_CarePackage_Loot_Rare_02( activator, caller ) end
    if RNG_Roll_Rare == 3     then JM_CarePackage_Loot_Rare_03( activator, caller ) end
    if RNG_Roll_Rare == 4     then JM_CarePackage_Loot_Rare_04( activator, caller ) end
    if RNG_Roll_Rare == 5     then JM_CarePackage_Loot_Rare_05( activator, caller ) end
    if RNG_Roll_Rare == 6     then JM_CarePackage_Loot_Rare_06( activator, caller ) end
    if RNG_Roll_Rare == 7     then JM_CarePackage_Loot_Rare_07( activator, caller ) end
    if RNG_Roll_Rare == 8     then JM_CarePackage_Loot_Rare_08( activator, caller ) end
    if RNG_Roll_Rare == 9     then JM_CarePackage_Loot_Rare_09( activator, caller ) end
    if RNG_Roll_Rare == 10    then JM_CarePackage_Loot_Rare_10( activator, caller ) end
    if RNG_Roll_Rare == 11    then JM_CarePackage_Loot_Rare_11( activator, caller ) end
    if RNG_Roll_Rare == 12    then JM_CarePackage_Loot_Rare_12( activator, caller ) end
    if RNG_Roll_Rare == 13    then JM_CarePackage_Loot_Rare_13( activator, caller ) end
    if RNG_Roll_Rare == 14    then JM_CarePackage_Loot_Rare_14( activator, caller ) end
    if RNG_Roll_Rare == 15    then JM_CarePackage_Loot_Rare_15( activator, caller ) end
    if RNG_Roll_Rare == 16    then JM_CarePackage_Loot_Rare_16( activator, caller ) end
    if RNG_Roll_Rare == 17    then JM_CarePackage_Loot_Rare_17( activator, caller ) end
    if RNG_Roll_Rare == 18    then JM_CarePackage_Loot_Rare_18( activator, caller ) end
    if RNG_Roll_Rare == 19    then JM_CarePackage_Loot_Rare_19( activator, caller ) end

end

-------------------------------------------------
-- Table of Normal Loots
-------------------------------------------------

function JM_CarePackage_Loot_Normal_01( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Pistol")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_pistol")
end

function JM_CarePackage_Loot_Normal_02( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced SMG")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_smg")
end

function JM_CarePackage_Loot_Normal_03( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Shotgun")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_shotgun")
end

function JM_CarePackage_Loot_Normal_04( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Rifle")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_rifle")
end

function JM_CarePackage_Loot_Normal_05( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Sniper")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_sniper")
end

function JM_CarePackage_Loot_Normal_06( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Health Boost")
    activator:SetMaxHealth(activator:GetMaxHealth() + 100)
    JM_GiveBuffToThisPlayer("jm_buff_regeneration", activator, caller)
end

function JM_CarePackage_Loot_Normal_07( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Speed Boost")
    JM_GiveBuffToThisPlayer("jm_buff_speedboost", activator, caller)
end

function JM_CarePackage_Loot_Normal_08( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Frag Grenade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_frag")
end

function JM_CarePackage_Loot_Normal_09( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Ninja Blade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_ninjablade")
end

function JM_CarePackage_Loot_Normal_10( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Prop Launcher")
    Loot_SpawnThis(caller,"weapon_jm_zloot_prop_launcher")
end

function JM_CarePackage_Loot_Normal_11( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Rapid Fire")
    JM_GiveBuffToThisPlayer("jm_buff_rapidfire", activator, caller)
end

function JM_CarePackage_Loot_Normal_12( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Portable Tester")
    Loot_SpawnThis(caller,"weapon_jm_zloot_traitor_tester")
end

function JM_CarePackage_Loot_Normal_13( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Big Boy")
    Loot_SpawnThis(caller,"weapon_jm_zloot_explosive_gun")
end

function JM_CarePackage_Loot_Normal_14( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Shredder")
    Loot_SpawnThis(caller,"weapon_jm_zloot_shredder")
end

function JM_CarePackage_Loot_Normal_15( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Crate Swep")
    Loot_SpawnThis(caller,"weapon_jm_zloot_placer_crate")
end

function JM_CarePackage_Loot_Normal_16( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Medkit Swep")
    Loot_SpawnThis(caller,"weapon_jm_zloot_placer_medkit")
end

function JM_CarePackage_Loot_Normal_17( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Slo-Mo Clock")
    Loot_SpawnThis(caller,"weapon_jm_zloot_slomo_clock")
end

function JM_CarePackage_Loot_Normal_18( activator, caller )
    Loot_SpawnThis(caller,"npc_pigeon")
    if(activator:IsTraitor() or activator:IsDetective()) then
        JM_Function_PrintChat(activator, "Care Package","Role Change Blue (+1 Credit)")
        activator:AddCredits(1)
    else
        JM_Function_PrintChat(activator, "Care Package","Role Change Blue (You are now a Detective!)")
        activator:SetRole(ROLE_DETECTIVE)
        SendFullStateUpdate()
        activator:AddCredits(2)
    end
end

function JM_CarePackage_Loot_Normal_19( activator, caller )
    Loot_SpawnThis(caller,"npc_pigeon")
    if(activator:IsTraitor() or activator:IsDetective()) then
        JM_Function_PrintChat(activator, "Care Package","Role Change Red (+1 Credit)")
        activator:AddCredits(1)
    else
        JM_Function_PrintChat(activator, "Care Package","Role Change Red (You are now a Traitor!)")
        activator:SetRole(ROLE_TRAITOR)
        SendFullStateUpdate()
        activator:AddCredits(2)
    end
end

function JM_CarePackage_Loot_Normal_20( activator, caller )
    Loot_SpawnThis(caller,"npc_pigeon")
    JM_Function_PrintChat(activator, "Care Package","Extra Credit (+3 Credits)")
    activator:AddCredits(3)
end

function JM_CarePackage_Loot_Normal_21( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Gus Radio")
    Loot_SpawnThis(caller,"ent_jm_zloot_radio_gus")
end

function JM_CarePackage_Loot_Normal_22( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Rooty Tooty Point and Shooty")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_shotgun")
end

function JM_CarePackage_Loot_Normal_23( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Tag Grenade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_tag")
end

function JM_CarePackage_Loot_Normal_24( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Glue Grenade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_glue")
end

function JM_CarePackage_Loot_Normal_25( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Jump Grenade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_jump")
end

function JM_CarePackage_Loot_Normal_26( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Lucker & Fenner")
    Loot_SpawnThis(caller,"weapon_jm_zloot_dual_pistols")
end




-------------------------------------------------
-- End of Table of Normal Loots
-------------------------------------------------

-------------------------------------------------
-- Table of Rare Loots
-------------------------------------------------

function JM_CarePackage_Loot_Rare_01( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Best Friend")
    Loot_SpawnThis(caller,"npc_rollermine")
end

function JM_CarePackage_Loot_Rare_02( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Tracker")
		
    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: You are all being tracked!")
    net.WriteUInt(0, 16)
    net.Broadcast()

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            if SERVER then ply:EmitSound(Sound("ping_jake.wav")) end
            JM_GiveBuffToThisPlayer("jm_buff_megatracker",ply,caller)
        end
    end
end

function JM_CarePackage_Loot_Rare_03( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Godzilla")
    if SERVER then activator:EmitSound(Sound("godzillaroar.wav")) end

    local pushForce = 10000
    local pos = caller:GetPos()
    local tpos = activator:LocalToWorld(activator:OBBCenter())
    local dir = (tpos - pos):GetNormal()

    local push = dir * pushForce
    local vel = activator:GetVelocity() + push

    activator:SetVelocity(vel)
end

function JM_CarePackage_Loot_Rare_04( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Tripping Balls")
    JM_GiveBuffToThisPlayer("jm_buff_trippingballs", activator, caller)
end

function JM_CarePackage_Loot_Rare_05( activator, caller )
    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: Gravity is now much weaker!")
    net.WriteUInt(0, 16)
    net.Broadcast()

    JM_Function_PrintChat(activator, "Care Package","Low Gravity")
    RunConsoleCommand("sv_gravity", 100)
    RunConsoleCommand("sv_airaccelerate", 12)
    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            if SERVER then ply:EmitSound(Sound("effect_low_gravity.mp3")) end
        end
    end
end

function JM_CarePackage_Loot_Rare_06( activator, caller )
    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: The floors are now slippery!")
    net.WriteUInt(0, 16)
    net.Broadcast()

    JM_Function_PrintChat(activator, "Care Package","Slippery Floors")
    RunConsoleCommand("sv_friction", 0)
    RunConsoleCommand("sv_accelerate", 5)
    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            if SERVER then ply:EmitSound(Sound("effect_slippery_floors.mp3")) end
        end
    end
end

function JM_CarePackage_Loot_Rare_07( activator, caller )
    local PossibleVictims = {}

    -- Find out who is eligible to be swapped

    for _, ply in ipairs( player.GetAll() ) do

        if (ply:IsValid() and ply:IsTerror() and ply:Alive() and not ply:Crouching()) then

            if ply:GetPos():Distance(activator:GetPos()) >= 32  then
                PossibleVictims[#PossibleVictims+1] = ply
            end				
        end
        
    end

    -- Work out who the victim is

    local Victim = nil

    if #PossibleVictims < 1 then 

        JM_Function_PrintChat(activator, "Care Package","Teleportation (Random Place)")
        local possibleSpawns = ents.FindByClass( "info_player_start" )
        Victim = table.Random(possibleSpawns)
        -- Perform the actual swap
        local PosActivator 	= activator:GetPos()
        local PosVictim 	= Victim:GetPos()
        activator:SetPos(PosVictim)
        if SERVER then activator:EmitSound(Sound("effect_swapping_places.mp3")) end
        
    else

        JM_Function_PrintChat(activator, "Care Package","Teleportation (Swapped with another player)")
        Victim = PossibleVictims[ math.random( #PossibleVictims ) ]
        -- Perform the actual swap
        local PosActivator = activator:GetPos()
        local PosVictim = Victim:GetPos()
        activator:SetPos(PosVictim)
        Victim:SetPos(PosActivator)
        if SERVER then activator:EmitSound(Sound("effect_swapping_places.mp3")) end
        if SERVER then Victim:EmitSound(Sound("effect_swapping_places.mp3")) end
        Victim:ChatPrint("Teleportation (Swapped with another player)")

    end
end

function JM_CarePackage_Loot_Rare_08( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Ticking Time Bomb")
    Loot_SpawnThis(caller,"ent_jm_zloot_timebomb")
end

function JM_CarePackage_Loot_Rare_09( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","1 HP")
    activator:SetHealth(1)
end

function JM_CarePackage_Loot_Rare_10( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mass HP Buff")
		
    JM_Function_Announcement("Care Package: You all gain +50 Max HP", 0)

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            ply:SetMaxHealth(ply:GetMaxHealth() + 30)
        end
    end
end

function JM_CarePackage_Loot_Rare_11( activator, caller )
    activator:StripWeapons()
		
    if(activator:IsTraitor() or activator:IsDetective()) then
        JM_Function_PrintChat(activator, "Care Package","Stripped of your weapons (Also + 2 Credits)")
        activator:AddCredits(2)
    else
        JM_Function_PrintChat(activator, "Care Package","Stripped of your weapons")
    end

    -- Give them back their Bare Hands

    local ent = ents.Create("weapon_jm_special_hands")
    if ent:IsValid() then
        ent:SetPos(activator:GetPos())
        ent:Spawn()
    end

    activator:SelectWeapon("weapon_jm_special_hands")
end

function JM_CarePackage_Loot_Rare_12( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Best Friend Apocalypse")

    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: Best Friend Apocalypse!")
    net.WriteUInt(0, 16)
    net.Broadcast()

    -- Spawn this thing randomly across the map
    local ThingToSpawn = "npc_rollermine"
    local NumberToSpawn = 20
    JM_GameMode_Function_SpawnThisThingRandomly(thingToSpawn, numberOfTimes)
    
end

function JM_CarePackage_Loot_Rare_13( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Zombie Apocalypse")

    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: Zombie Apocalypse!")
    net.WriteUInt(0, 16)
    net.Broadcast()    

    local NumberToSpawn = 20
    local possibleSpawns = ents.FindByClass( "info_player_start" )
    table.Add(possibleSpawns, ents.FindByClass( "ent_jm_carepackage_spawn" ))
    
    for i=1,NumberToSpawn do 

        if #possibleSpawns > 0 then
            local randomChoice = math.random(1, #possibleSpawns)
            local spawn = possibleSpawns[randomChoice]
            table.remove( possibleSpawns, randomChoice )
            

            local RandChoice = math.random( 0, 14 )
            if (RandChoice == 0) then RandZombie = "npc_zombie" end
            if (RandChoice == 1) then RandZombie = "npc_zombie" end
            if (RandChoice == 2) then RandZombie = "npc_zombie" end
            if (RandChoice == 3) then RandZombie = "npc_zombie" end
            if (RandChoice == 4) then RandZombie = "npc_zombie" end
            if (RandChoice == 5) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 6) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 7) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 8) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 9) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 10) then RandZombie = "npc_headcrab" end
            if (RandChoice == 11) then RandZombie = "npc_headcrab" end
            if (RandChoice == 12) then RandZombie = "npc_headcrab_fast" end
            if (RandChoice == 13) then RandZombie = "npc_headcrab_fast" end
            if (RandChoice == 14) then RandZombie = "npc_poisonzombie" end

            local ent = ents.Create(RandZombie)
            ent:SetPos(spawn:GetPos())
            ent:Spawn()  
        end

    end
end

function JM_CarePackage_Loot_Rare_14( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Antlion Infestation")

    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: Antlion Infestation!")
    net.WriteUInt(0, 16)
    net.Broadcast()

    -- Spawn this thing randomly across the map
    local ThingToSpawn = "npc_antlion"
    local NumberToSpawn = 20
    JM_GameMode_Function_SpawnThisThingRandomly(thingToSpawn, numberOfTimes)

end

function JM_CarePackage_Loot_Rare_15( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","The Flames of Hell")

    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: The Flames of Hell!")
    net.WriteUInt(0, 16)
    net.Broadcast()

    local NumberToSpawn = 50
    local possibleSpawns = ents.FindByClass( "info_player_start" )
    table.Add(possibleSpawns, ents.FindByClass( "ent_jm_carepackage_spawn" ))
    table.Add(possibleSpawns, player.GetAll())
    
    for i=1,NumberToSpawn do 

        if #possibleSpawns > 0 then
            local randomChoice = math.random(1, #possibleSpawns)
            local spawn = possibleSpawns[randomChoice]
            table.remove( possibleSpawns, randomChoice )
            
            local ent = ents.Create("ent_jm_base_fire")
            ent:SetPos(spawn:GetPos())
            ent:Spawn()  
        end

    end
end

function JM_CarePackage_Loot_Rare_16( activator, caller )
    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: " .. tostring(activator:Nick()) .. "'s role is [" .. tostring(activator:GetRoleStringRaw()) .. "]")
    net.WriteUInt(0, 16)
    net.Broadcast()

    JM_Function_PrintChat(activator, "Care Package","Your role has been revealed to all")
    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            if SERVER then ply:EmitSound(Sound("effect_dogbark.mp3")) end
        end
    end
end

function JM_CarePackage_Loot_Rare_17( activator, caller )
    net.Start("JM_Net_Announcement")
    net.WriteString("What the dog doin?")
    net.WriteUInt(0, 16)
    net.Broadcast()

    JM_Function_PrintChat(activator, "Care Package","What the dog doin?")
    JM_Function_PlaySound("whatthedogdoing.mp3") 
end

function JM_CarePackage_Loot_Rare_18( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Everyone is fully healed")
		
    net.Start("JM_Net_Announcement")
    net.WriteString("Care Package: Everyone is fully healed!")
    net.WriteUInt(0, 16)
    net.Broadcast()

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            ply:SetHealth(ply:GetMaxHealth())
        end
    end
end

function JM_CarePackage_Loot_Rare_19( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Godzilla")
    
    JM_Function_Announcement("Care Package: Mega Godzilla", 0)

    JM_Function_PlaySound("godzillaroar.wav") 

    local pushForce = 10000
    local pos = caller:GetPos()
    local tpos = activator:LocalToWorld(activator:OBBCenter())
    local dir = (tpos - pos):GetNormal()

    local push = dir * pushForce
    local vel = activator:GetVelocity() + push

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            ply:SetVelocity(vel)
        end
    end

end



-------------------------------------------------
-- End of Table of Rare Loots
-------------------------------------------------


-------------------------------------------------
-- Shared Functions
-------------------------------------------------
function Loot_SpawnThis(carepackage,thingToSpawn)
	local ent = ents.Create(thingToSpawn)
	ent:SetPos(carepackage:GetPos())
    ent:Spawn()
end
-------------------------------------------------
-- End of Shared Functions
-------------------------------------------------