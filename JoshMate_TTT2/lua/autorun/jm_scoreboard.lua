-- Give these files out
AddCSLuaFile()

if engine.ActiveGamemode() ~= "terrortown" then return end

local karmacolors = {
	K_Max     	 	= Color(0, 255, 255),
	K_1200      	= Color(0, 250, 150),
	K_1100       	= Color(0, 220, 130),
	K_1001       	= Color(0, 200, 120),
	K_1000       	= Color(0, 180, 100),
	K_900         	= Color(200, 200, 0),
	K_700    		= Color(255, 255, 0), 
	K_500    		= Color(255, 150, 0), 
	K_Zero      	= Color(200, 0, 0),
	K_Neg     		= Color(255, 30, 255),
	K_Default     	= Color(255, 255, 255),
};

hook.Add("TTTScoreboardColumns", "JM_ScoreBoard_ColouredKarma", function (panel)
	if KARMA.IsEnabled() then
		panel:AddColumn( "Karma", function(ply, lbl)
			
			local karma = math.Round(ply:GetBaseKarma())			
            local color = karmacolors.K_Default 


			if karma >= 1300 then
				color = karmacolors.K_Max
			elseif karma >= 1200 then
				color = karmacolors.K_1200
			elseif karma >= 1100 then
				color = karmacolors.K_1100
			elseif karma >= 1001 then
				color = karmacolors.K_1001
			elseif karma >= 1000 then
				color = karmacolors.K_1000
			elseif karma >= 900 then
				color = karmacolors.K_900
			elseif karma >= 700 then
				color = karmacolors.K_700
			elseif karma >= 500 then
				color = karmacolors.K_500
			elseif karma >= 0 then
				color = karmacolors.K_Zero
			elseif karma < 0 then
				color = karmacolors.K_Neg
			end
			
			lbl:SetText(karma)
			lbl:SetTextColor(color)
			
			return karma
		end, 75)
	end
end)