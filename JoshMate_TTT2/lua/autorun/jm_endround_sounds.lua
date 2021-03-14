-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

function JM_EndOfRound_Sound_Init()

    if SERVER then
        util.AddNetworkString("JMPlayThisVictorySound")

        hook.Add("TTTEndRound", "JMEndRoundSounds", function(result)

            local trackPath = "victory_innocents_01.wav"

            local JMTracks_I = {}
            table.insert(JMTracks_I, "victory_innocents_01.wav")
            local JMTracks_I_Size = #JMTracks_I
            
            local JMTracks_T = {}
            table.insert(JMTracks_T, "victory_traitors_01.wav")
            local JMTracks_T_Size = #JMTracks_T

    
            if tostring(result) == "traitors" then
                trackPath = JMTracks_T[math.random(JMTracks_T_Size)]
            elseif tostring(result) == "innocents" then
                trackPath = JMTracks_I[math.random(JMTracks_I_Size)]
            end

            net.Start("JMPlayThisVictorySound")
            net.WriteString(trackPath)
            net.Broadcast()

        end)
    end

    if CLIENT then
        net.Receive("JMPlayThisVictorySound", function(_)
            local soundPath = net.ReadString()
            surface.PlaySound(soundPath)
        end)
    end

    
end

hook.Add("Initialize", "JMEndRoundSoundsInit", JM_EndOfRound_Sound_Init)