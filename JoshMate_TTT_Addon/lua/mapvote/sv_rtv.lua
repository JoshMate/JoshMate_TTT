util.AddNetworkString("RTV_DoVote")

RTV = {}

RTV.rtv_votes = {}

hook.Add("PlayerSay", "JM_chat_rtv", function(ply, text, public)
	text = string.lower(text)
    text = string.Trim(text)

	if text == "!rtv" then
		ply:ConCommand("rtv")
	end
    
end)

concommand.Add("rtv", function(ply, cmd, args)
    if !IsValid(ply) then return end
    
    JM_Function_PrintChat(ply, "Admin", "Use !skip instead")
end)

hook.Add("PlayerSay", "JM_chat_skip", function(ply, text, public)
	text = string.lower(text)
    text = string.Trim(text)

	if text == "!skip" then
		ply:ConCommand("skip")
	end
    
end)

concommand.Add("skip", function(ply, cmd, args)
    if !IsValid(ply) then return end
    
    if not RTV:ExistsInTable(ply) then
        RTV:AddVote(ply)
        local roundsLeft = GetGlobalInt("ttt_rounds_left", 6)
        if roundsLeft > 2 then 
            JM_Function_RemoveRounds(1) 
            local roundsLeft = GetGlobalInt("ttt_rounds_left", 6)
            msg = tostring(ply:Nick()) .. " has skipped. (Rounds Left: " .. tostring(roundsLeft) .. ")"
            JM_Function_PrintChat_All("Admin", msg)   
        else
            JM_Function_PrintChat(ply, "Admin", "You can't skip when there are only " .. tostring(roundsLeft) .. " rounds left...")
        end
            
    else
        JM_Function_PrintChat(ply, "Admin", "You have already voted during this map...")
    end
end)

hook.Add("PlayerSay", "JM_chat_extend", function(ply, text, public)
	text = string.lower(text)
    text = string.Trim(text)

	if text == "!extend" then
		ply:ConCommand("extend")
	end
    
end)

concommand.Add("extend", function(ply, cmd, args)
    if !IsValid(ply) then return end
    
    JM_Function_PrintChat(ply, "Admin", "!extend has been removed. You may now only !skip")
end)

function RTV:ExistsInTable(ply)
    if !IsValid(ply) then return end

    for k,v in pairs(self.rtv_votes) do
        if v == ply then
            return true
        end
    end

    return false
end

function RTV:AddVote(ply) 
    if !IsValid(ply) then return end

    table.insert(RTV.rtv_votes, ply)
end

function RTV:CountVotes()
    local c = 0

    for k,ply in pairs(self.rtv_votes) do
        if IsValid(ply) then
            c = c + 1
        end
    end

    return c
end

function RTV:Reset()
    self.rtv_votes = {}
end