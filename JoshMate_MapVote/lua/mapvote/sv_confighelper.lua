ConfigHelper = {}


function ConfigHelper:ReadConfig(configFile) 
    local jsonString = file.Read("JM_mapvote/" .. configFile .. ".txt", "DATA")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WriteConfig(configFile, config) 
    local configString = util.TableToJSON(config, true) -- true = prettyPrint
    file.Write("JM_mapvote/" .. configFile .. ".txt", configString)
end


-- Handle No Repeats of maps
function ConfigHelper:ReadPlayedMaps() 
    local jsonString = file.Read("JM_mapvote/playedmaps.txt", "DATA")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WritePlayedMaps(playedMaps) 
    local playedMapsString = util.TableToJSON(playedMaps, true) -- true = prettyPrint
    file.Write("JM_mapvote/playedmaps.txt",  playedMapsString)
end

function ConfigHelper:CreateConfigFolderIfNotExists()
    if not file.Exists("JM_mapvote", "DATA") then
        file.CreateDir("JM_mapvote")
        ConfigHelper:WritePlayedMaps({}) 
    end
end