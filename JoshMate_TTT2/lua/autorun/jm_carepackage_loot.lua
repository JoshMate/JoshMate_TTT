if engine.ActiveGamemode() ~= "terrortown" then return end

local lootTable = {
    normal = {
        JM_CarePackage_Loot_Advanced_Pistol,
        JM_CarePackage_Loot_Advanced_Smg,
        JM_CarePackage_Loot_Advanced_Shotgun,
        JM_CarePackage_Loot_Advanced_Rifle,
        JM_CarePackage_Loot_Advanced_Sniper,
        JM_CarePackage_Loot_Health_Boost,
        JM_CarePackage_Loot_Speed_Boost,
        JM_CarePackage_Loot_Mega_Frag,
        JM_CarePackage_Loot_Ninja_Blade,
        JM_CarePackage_Loot_Prop_Launcher,
        JM_CarePackage_Loot_Rapid_Fire,
        JM_CarePackage_Loot_Portable_Tester,
        JM_CarePackage_Loot_Big_Boy,
        JM_CarePackage_Loot_Shredder,
        JM_CarePackage_Loot_Crate_Swep,
        JM_CarePackage_Loot_Medkit_Swep,
        JM_CarePackage_Loot_Slow_Mo_Clock,
        JM_CarePackage_Loot_Become_Detective,
        JM_CarePackage_Loot_Become_Traitor,
        JM_CarePackage_Loot_Pigeon,
        JM_CarePackage_Loot_Rooty_Tooty,
        JM_CarePackage_Loot_Mega_Glue,
        JM_CarePackage_Loot_Mega_Jump,
        JM_CarePackage_Loot_GlueGun
    },
    rare = {
        JM_CarePackage_Loot_Best_Friend,
        JM_CarePackage_Loot_Mega_Tracker,
        JM_CarePackage_Loot_Godzilla,
        JM_CarePackage_Loot_Tripping_Balls,
        JM_CarePackage_Loot_Low_Gravity,
        JM_CarePackage_Loot_Slippery_Floors,
        JM_CarePackage_Loot_Swap,
        JM_CarePackage_Loot_Time_Bomb,
        JM_CarePackage_Loot_1_HP,
        JM_CarePackage_Loot_Mass_HP_Buff,
        JM_CarePackage_Loot_Strip_Weapons,
        JM_CarePackage_Loot_Best_Friend_Apocalypse,
        JM_CarePackage_Loot_Zombie_Apocalypse,
        JM_CarePackage_Loot_Antlion_Apocalypse,
        JM_CarePackage_Loot_Hell_Fire,
        JM_CarePackage_Loot_Reveal_Role,
        JM_CarePackage_Loot_What_The_Dog_Doin,
        JM_CarePackage_Loot_Mass_Heal,
        JM_CarePackage_Loot_Mega_Godzilla,
        JM_CarePackage_Loot_Man_Hack_Apocalypse,
        JM_CarePackage_Loot_Mass_Teleport,
        JM_CarePackage_Loot_Dopamine_Button,
        JM_CarePackage_Loot_Gus_Radio,
        JM_CarePackage_Loot_Built_Differently_Radio,
        JM_CarePackage_Loot_A_Bird_Flew_In_Radio,
        JM_CarePackage_Loot_Glue,
        JM_CarePackage_Loot_Mass_Glue,
        JM_CarePackage_Loot_Manual_Breathing,
        JM_CarePackage_Loot_Rob_From_TTT,
        JM_CarePackage_Loot_RandomMap,
        JM_CarePackage_Loot_Combine_Apocalypse,
        JM_CarePackage_Loot_Soap_Apocalypse,
        JM_CarePackage_Loot_Landmine_Apocalypse
    }
}

-------------------------------------------------
-- Master Loot Table (Normal Or Rare)
-------------------------------------------------

local JM_CarePackageLoot_Chance_Rare = 25

function JM_CarePackage_Use_LootMaster(activator, caller)

    if SERVER then

        -- Random Roller
        local lootTypeRoll = math.random(1, 100)
        
        local slectedLootTable
        if lootTypeRoll > JM_CarePackageLoot_Chance_Rare then
            -- Rolls a High Number (Normal Roll)
            slectedLootTable = lootTable["normal"]

        else
            -- Rolls a low number (Rare Roll)
            slectedLootTable = lootTable["rare"]
        end

        local lootRoll = math.random(1, table.getn(slectedLootTable))

        slectedLootTable[lootRoll](activator, caller)
    end
end

-------------------------------------------------
-- Table of Normal Loots
-------------------------------------------------

function JM_CarePackage_Loot_Advanced_Pistol( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Pistol")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_pistol")
end

function JM_CarePackage_Loot_Advanced_Smg( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced SMG")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_smg")
end

function JM_CarePackage_Loot_Advanced_Shotgun( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Shotgun")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_shotgun")
end

function JM_CarePackage_Loot_Advanced_Rifle( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Rifle")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_rifle")
end

function JM_CarePackage_Loot_Advanced_Sniper( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Advanced Sniper")
    Loot_SpawnThis(caller,"weapon_jm_zloot_advanced_sniper")
end

function JM_CarePackage_Loot_Health_Boost( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Health Boost")
    activator:SetMaxHealth(activator:GetMaxHealth() + 100)
    JM_GiveBuffToThisPlayer("jm_buff_regeneration", activator, caller)
end

function JM_CarePackage_Loot_Speed_Boost( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Speed Boost")
    JM_GiveBuffToThisPlayer("jm_buff_speedboost", activator, caller)
end

function JM_CarePackage_Loot_Mega_Frag( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Frag Grenade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_frag")
end

function JM_CarePackage_Loot_Ninja_Blade( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Ninja Blade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_ninjablade")
end

function JM_CarePackage_Loot_Prop_Launcher( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Prop Launcher")
    Loot_SpawnThis(caller,"weapon_jm_zloot_prop_launcher")
end

function JM_CarePackage_Loot_Rapid_Fire( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Rapid Fire")
    JM_GiveBuffToThisPlayer("jm_buff_rapidfire", activator, caller)
end

function JM_CarePackage_Loot_Portable_Tester( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Portable Tester")
    Loot_SpawnThis(caller,"weapon_jm_zloot_traitor_tester")
end

function JM_CarePackage_Loot_Big_Boy( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Big Boy")
    Loot_SpawnThis(caller,"weapon_jm_zloot_explosive_gun")
end

function JM_CarePackage_Loot_Shredder( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Shredder")
    Loot_SpawnThis(caller,"weapon_jm_zloot_shredder")
end

function JM_CarePackage_Loot_Crate_Swep( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Crate Swep")
    Loot_SpawnThis(caller,"weapon_jm_zloot_placer_crate")
end

function JM_CarePackage_Loot_Medkit_Swep( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Medkit Swep")
    Loot_SpawnThis(caller,"weapon_jm_zloot_placer_medkit")
end

function JM_CarePackage_Loot_Slow_Mo_Clock( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Slo-Mo Clock")
    Loot_SpawnThis(caller,"weapon_jm_zloot_slomo_clock")
end

function JM_CarePackage_Loot_Become_Detective( activator, caller )
    Loot_SpawnThis(caller,"npc_pigeon")
    if(activator:IsTraitor() or activator:IsDetective()) then
        JM_Function_PrintChat(activator, "Care Package","Role Change Blue (+1 Credit)")
        activator:AddCredits(1)
    else
        JM_Function_PrintChat(activator, "Care Package","Role Change Blue (You are now a Detective!)")
        activator:SetRole(ROLE_DETECTIVE)
        activator:SetModel( "models/player/police.mdl" )
        activator:SetColor(Color( 0, 50, 255 ))
        SendFullStateUpdate()
        activator:AddCredits(2)
    end
end

function JM_CarePackage_Loot_Become_Traitor( activator, caller )
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

function JM_CarePackage_Loot_Pigeon( activator, caller )
    Loot_SpawnThis(caller,"npc_pigeon")
    JM_Function_PrintChat(activator, "Care Package","Role Change Grey (+1 Credits)")
    activator:AddCredits(1)
end

function JM_CarePackage_Loot_Gus_Radio( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Gus Radio")
    Loot_SpawnThis(caller,"ent_jm_zloot_radio_gus")
end

function JM_CarePackage_Loot_Rooty_Tooty( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Rooty Tooty Point and Shooty")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_shotgun")
end

function JM_CarePackage_Loot_Mega_Glue( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Glue Grenade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_glue")
end

function JM_CarePackage_Loot_Mega_Jump( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mega Jump Grenade")
    Loot_SpawnThis(caller,"weapon_jm_zloot_mega_jump")
end

function JM_CarePackage_Loot_Built_Differently_Radio( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Built Differently Radio")
    Loot_SpawnThis(caller,"ent_jm_zloot_radio_builtdifferently")
end

function JM_CarePackage_Loot_A_Bird_Flew_In_Radio( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","A Bird Flew In Radio")
    Loot_SpawnThis(caller,"ent_jm_zloot_radio_birdflewin")
end

function JM_CarePackage_Loot_GlueGun( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Glue Gun")
    Loot_SpawnThis(caller,"weapon_jm_zloot_gluegun")
end

-------------------------------------------------
-- End of Table of Normal Loots
-------------------------------------------------



-------------------------------------------------
-- Table of Rare Loots
-------------------------------------------------

function JM_CarePackage_Loot_Best_Friend( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Best Friend")
    Loot_SpawnThis(caller,"npc_rollermine")
end

function JM_CarePackage_Loot_Mega_Tracker( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Mega Tracker")
    JM_Function_Announcement("[Care Package] You are all being tracked!")

    JM_Function_PlaySound("ping_jake.wav") 

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            JM_GiveBuffToThisPlayer("jm_buff_megatracker",ply,caller)
        end
    end
end

function JM_CarePackage_Loot_Godzilla( activator, caller )
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

function JM_CarePackage_Loot_Tripping_Balls( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Tripping Balls")
    JM_GiveBuffToThisPlayer("jm_buff_trippingballs", activator, caller)
end

function JM_CarePackage_Loot_Low_Gravity( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Low Gravity")
    JM_Function_Announcement("[Care Package] Gravity is now much weaker!")
    
    RunConsoleCommand("sv_gravity", 100)
    RunConsoleCommand("sv_airaccelerate", 12)

    JM_Function_PlaySound("effect_low_gravity.mp3")

end

function JM_CarePackage_Loot_Slippery_Floors( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Slippery Floors")
    JM_Function_Announcement("[Care Package] The floors are now slippery!")

    RunConsoleCommand("sv_friction", 0)
    RunConsoleCommand("sv_accelerate", 5)

    JM_Function_PlaySound("effect_slippery_floors.mp3")
end

function JM_CarePackage_Loot_Swap( activator, caller )
    
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
        JM_Function_PrintChat(Victim, "Care Package", "You have switched places with another player!")

    end
end

function JM_CarePackage_Loot_Time_Bomb( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Ticking Time Bomb")
    Loot_SpawnThis(caller,"ent_jm_zloot_timebomb")
end

function JM_CarePackage_Loot_1_HP( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","1 HP")
    activator:SetHealth(1)
end

function JM_CarePackage_Loot_Mass_HP_Buff( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Mass HP Buff")
		
    JM_Function_Announcement("Care Package: You all gain +50 Max HP", 0)

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            ply:SetMaxHealth(ply:GetMaxHealth() + 30)
        end
    end
end

function JM_CarePackage_Loot_Strip_Weapons( activator, caller )
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

function JM_CarePackage_Loot_Best_Friend_Apocalypse( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Best Friend Apocalypse")
    JM_Function_Announcement("[Care Package] Best Friend Apocalypse!")

    -- Spawn this thing randomly across the map
    local ThingToSpawn = "npc_rollermine"
    local NumberToSpawn = 25
    JM_Function_SpawnThisThingInRandomPlaces(ThingToSpawn, NumberToSpawn)
    
end

function JM_CarePackage_Loot_Zombie_Apocalypse( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Zombie Apocalypse")
    JM_Function_Announcement("[Care Package] Zombie Apocalypse!")  

    local NumberToSpawn = 25
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
            if (RandChoice == 5) then RandZombie = "npc_zombie" end
            if (RandChoice == 6) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 7) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 8) then RandZombie = "npc_fastzombie" end
            if (RandChoice == 9) then RandZombie = "npc_headcrab" end
            if (RandChoice == 10) then RandZombie = "npc_headcrab" end
            if (RandChoice == 11) then RandZombie = "npc_headcrab_fast" end
            if (RandChoice == 12) then RandZombie = "npc_headcrab_fast" end
            if (RandChoice == 13) then RandZombie = "npc_poisonzombie" end

            local ent = ents.Create(RandZombie)
            ent:SetPos(spawn:GetPos())
            ent:Spawn()  
        end

    end
end

function JM_CarePackage_Loot_Antlion_Apocalypse( activator, caller )
    
    JM_Function_PrintChat(activator, "Care Package","Antlion Apocalypse")
    JM_Function_Announcement("[Care Package] Antlion Apocalypse!")  

    -- Spawn this thing randomly across the map
    local ThingToSpawn = "npc_antlion"
    local NumberToSpawn = 25
    JM_Function_SpawnThisThingInRandomPlaces(ThingToSpawn, NumberToSpawn)

end

function JM_CarePackage_Loot_Hell_Fire( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","The Flames of Hell")
    JM_Function_Announcement("[Care Package] The Flames of Hell!") 

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

function JM_CarePackage_Loot_Reveal_Role( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Your role has been revealed to all")
    JM_Function_Announcement("[Care Package] " .. tostring(activator:Nick()) .. "'s role is [" .. tostring(activator:GetRoleStringRaw()) .. "]") 

    JM_Function_PlaySound("effect_dogbark.mp3") 
    
end

function JM_CarePackage_Loot_What_The_Dog_Doin( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","What the dog doin?")
    JM_Function_Announcement("[Care Package] What the dog doin?") 

    -- Spawn this thing randomly across the map
    local ThingToSpawn = "npc_antlionguard"
    local NumberToSpawn = 1
    JM_Function_SpawnThisThingInRandomPlaces(ThingToSpawn, NumberToSpawn)

    JM_Function_PlaySound("whatthedogdoing.mp3") 
end

function JM_CarePackage_Loot_Mass_Heal( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Everyone is fully healed")
	JM_Function_Announcement("[Care Package] Everyone is fully healed!") 

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then
            ply:SetHealth(ply:GetMaxHealth())
        end
    end
end

function JM_CarePackage_Loot_Mega_Godzilla( activator, caller )
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

function JM_CarePackage_Loot_Man_Hack_Apocalypse( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Man Hack Apocalypse")
    JM_Function_Announcement("[Care Package] Man Hack Apocalypse!")

    -- Spawn this thing randomly across the map
    local ThingToSpawn = "npc_manhack"
    local NumberToSpawn = 25
    JM_Function_SpawnThisThingInRandomPlaces(ThingToSpawn, NumberToSpawn)
    
end

function JM_CarePackage_Loot_Mass_Teleport( activator, caller )

    JM_Function_Announcement("[Care Package] Mass Teleportation!")

    for _, plyBase in ipairs( player.GetAll() ) do

        if (plyBase:IsValid() and plyBase:IsTerror() and plyBase:Alive() and not plyBase:Crouching()) then

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
        
                JM_Function_PrintChat(plyBase, "Care Package","Mass Teleportation (Random Place)")
                local possibleSpawns = ents.FindByClass( "info_player_start" )
                Victim = table.Random(possibleSpawns)
                -- Perform the actual swap
                local PosActivator 	= plyBase:GetPos()
                local PosVictim 	= Victim:GetPos()
                plyBase:SetPos(PosVictim)
                if SERVER then plyBase:EmitSound(Sound("effect_swapping_places.mp3")) end
                
            else
        
                JM_Function_PrintChat(plyBase, "Care Package","Mass Teleportation (Swapped with another player)")
                Victim = PossibleVictims[ math.random( #PossibleVictims ) ]
                -- Perform the actual swap
                local PosActivator = plyBase:GetPos()
                local PosVictim = Victim:GetPos()
                plyBase:SetPos(PosVictim)
                Victim:SetPos(PosActivator)
                if SERVER then plyBase:EmitSound(Sound("effect_swapping_places.mp3")) end
                if SERVER then Victim:EmitSound(Sound("effect_swapping_places.mp3")) end
                JM_Function_PrintChat(Victim, "Care Package", "Mass Teleportation (Swapped with another player)")
        
            end
        end
    end
    

end

function JM_CarePackage_Loot_Dopamine_Button( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Dopamine Button")
    Loot_SpawnThis(caller,"ent_jm_zloot_dopamine_button")
end

function JM_CarePackage_Loot_Glue( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Glue")
    if SERVER then activator:EmitSound(Sound("effect_getglued.wav")) end

    if (activator:IsValid() and activator:IsTerror() and activator:Alive()) then

        -- Add the Buff
        JM_GiveBuffToThisPlayer("jm_buff_glue",activator,caller)

        -- Do the Glue Effects
        local effect = EffectData()
        local ePos = activator:GetPos()
        if activator:IsPlayer() then ePos:Add(Vector(0,0,40))end
        effect:SetStart(ePos)
        effect:SetOrigin(ePos)
        util.Effect("AntlionGib", effect, true, true)
    end
end

function JM_CarePackage_Loot_Mass_Glue( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Mass Glue")
    JM_Function_Announcement("[Care Package] Mass Glue")
    JM_Function_PlaySound("effect_getglued.wav") 

    for _, ply in ipairs( player.GetAll() ) do
        if (ply:IsValid() and ply:IsTerror() and ply:Alive()) then

            -- Add the Buff
            JM_GiveBuffToThisPlayer("jm_buff_glue",ply,caller)

            -- Do the Glue Effects
            local effect = EffectData()
            local ePos = ply:GetPos()
            if ply:IsPlayer() then ePos:Add(Vector(0,0,40))end
            effect:SetStart(ePos)
            effect:SetOrigin(ePos)
            util.Effect("AntlionGib", effect, true, true)
        end
    end
end

function JM_CarePackage_Loot_Manual_Breathing( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Manual Breathing Mode")
    JM_Function_Announcement("[Care Package] You are all now in Manual Breathing Mode!")
    JM_Function_PlaySound("radio_kingdomlaugh.wav") 
end

function JM_CarePackage_Loot_Rob_From_TTT( activator, caller )
    JM_Function_PrintChat(activator, "Care Package","Rob from TTT")
    JM_Function_Announcement("[Care Package] It's Rob from TTT!")
    JM_Function_PlaySound("npc/zombie/zombie_voice_idle1.wav") 
    Loot_SpawnThis(caller,"ent_jm_zloot_robfromttt")
end

function JM_CarePackage_Loot_RandomMap( activator, caller )
    JM_Function_Announcement("[Care Package] The next map will be random!")
	JM_Global_MapVote_NextWillBeRandom = true
end

function JM_CarePackage_Loot_Combine_Apocalypse( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Combine Apocalypse")
    JM_Function_Announcement("[Care Package] Combine Apocalypse!")  

    local NumberToSpawn = 15
    local possibleSpawns = ents.FindByClass( "info_player_start" )
    table.Add(possibleSpawns, ents.FindByClass( "ent_jm_carepackage_spawn" ))
    
    for i=1,NumberToSpawn do 

        if #possibleSpawns > 0 then
            local randomChoice = math.random(1, #possibleSpawns)
            local spawn = possibleSpawns[randomChoice]
            table.remove( possibleSpawns, randomChoice )

            local ent = ents.Create("npc_combine_s")
            ent:Give("weapon_smg1")
            ent:SetMaxHealth(100)
            ent:SetHealth(100)
            ent:SetKeyValue( "spawnflags", bit.bor( SF_NPC_NO_WEAPON_DROP, SF_NPC_DROP_HEALTHKIT ) )
            ent:SetPos(spawn:GetPos())
            ent:Spawn()  
        end

    end
end

function JM_CarePackage_Loot_Soap_Apocalypse( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Soap Apocalypse")
    JM_Function_Announcement("[Care Package] Soap Apocalypse!")

    local NumberToSpawn = 20
    local possibleSpawns = ents.FindByClass( "info_player_start" )
    table.Add(possibleSpawns, ents.FindByClass( "ent_jm_carepackage_spawn" ))
    
    for i=1,NumberToSpawn do 

        if #possibleSpawns > 0 then
            local randomChoice = math.random(1, #possibleSpawns)
            local spawn = possibleSpawns[randomChoice]
            table.remove( possibleSpawns, randomChoice )

            local ent = ents.Create("ent_jm_equip_soap")
            ent.Owner = nil
	        ent.fingerprints = {}
            ent:SetPos(spawn:GetPos())
            ent:Spawn()  
        end

    end
    
end

function JM_CarePackage_Loot_Landmine_Apocalypse( activator, caller )

    JM_Function_PrintChat(activator, "Care Package","Landmine Apocalypse")
    JM_Function_Announcement("[Care Package] Landmine Apocalypse!")

    local NumberToSpawn = 10
    local possibleSpawns = ents.FindByClass( "info_player_start" )
    table.Add(possibleSpawns, ents.FindByClass( "ent_jm_carepackage_spawn" ))
    
    for i=1,NumberToSpawn do 

        if #possibleSpawns > 0 then
            local randomChoice = math.random(1, #possibleSpawns)
            local spawn = possibleSpawns[randomChoice]
            table.remove( possibleSpawns, randomChoice )

            local ent = ents.Create("ent_jm_equip_landmine")
            ent.Owner = nil
	        ent.fingerprints = {}
            ent:SetPos(spawn:GetPos())
            ent:Spawn()  
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