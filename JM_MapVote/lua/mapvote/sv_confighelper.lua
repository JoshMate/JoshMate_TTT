ConfigHelper = {}

function ConfigHelper:CreateConfigFolderIfNotExists()
    if not file.Exists("JM_mapvote", "DATA") then
        file.CreateDir("JM_mapvote")
    end
end

function ConfigHelper:ReadConfig(configFile) 
    local jsonString = file.Read("JM_mapvote/" .. configFile .. ".txt", "DATA")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WriteConfig(configFile, config) 
    local configString = util.TableToJSON(config, true) -- true = prettyPrint
    file.Write("JM_mapvote/" .. configFile .. ".txt", configString)
end