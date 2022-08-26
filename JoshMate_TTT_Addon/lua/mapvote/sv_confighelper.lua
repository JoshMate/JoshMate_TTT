ConfigHelper = {}


function ConfigHelper:ReadConfig(configFile) 
    local jsonString = file.Read("jm_mapvote/" .. configFile .. ".txt", "DATA")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WriteConfig(configFile, config) 
    local configString = util.TableToJSON(config, true) -- true = prettyPrint
    file.Write("jm_mapvote/" .. configFile .. ".txt", configString)
end


-- Handle No Repeats of maps
function ConfigHelper:ReadPlayedMaps() 
    local jsonString = file.Read("jm_mapvote/playedmaps.txt", "DATA")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WritePlayedMaps(playedMaps) 
    local playedMapsString = util.TableToJSON(playedMaps, true) -- true = prettyPrint
    file.Write("jm_mapvote/playedmaps.txt",  playedMapsString)
end

function ConfigHelper:CreateConfigFolderIfNotExists()
    if not file.Exists("jm_mapvote", "DATA") then
        file.CreateDir("jm_mapvote")
        ConfigHelper:WritePlayedMaps({}) 
    end
end