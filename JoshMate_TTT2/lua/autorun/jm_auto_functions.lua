-- Give these files out
AddCSLuaFile()

-----------------------------------------------
--  Play Sound Function
-----------------------------------------------


function JM_Function_PlaySound(soundStringToPlay)

    net.Start("JM_Net_PlaySound")
    net.WriteString(tostring(soundStringToPlay))
    net.Broadcast()

end


-----------------------------------------------
-- End of Play Sound Function
-----------------------------------------------


-----------------------------------------------
-- Announcement Function
-----------------------------------------------

function JM_Function_Announcement(messageToDisplay, messageExtraType)

    net.Start("JM_Net_Announcement")
    net.WriteString(messageToDisplay)
    net.WriteUInt(messageExtraType, 16)
    net.Broadcast()

end

-- Extra
if SERVER then
	util.AddNetworkString("JM_Net_Announcement")
    util.AddNetworkString("JM_Net_PlaySound")
end

if CLIENT then

	surface.CreateFont( "JoshMateFont_Announcements", {
		font = "Calibri", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 48,
		weight = 300,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = true,
	} )

	local message = nil
	local messageTime = 0
    local soundToPlay = nil

    net.Receive("JM_Net_Announcement", function(_) 
		
        message = net.ReadString()
		messageType = net.ReadUInt(16)
		messageTime = CurTime()

		surface.PlaySound("0_main_popup.wav")

		if messageType == 1 then JM_Function_PlaySound("0_main_suddendeath.mp3") end
		if messageType == 2 then JM_Function_PlaySound("ping_jake.wav") end
		if messageType == 3 then JM_Function_PlaySound("0_proximity_voice_toggle.wav") end
		
        chat.AddText( Color( 255, 0, 0 ), "[Announcement] - ", Color( 255, 255, 0 ), tostring(message))
    end)

    net.Receive("JM_Net_PlaySound", function(_) 
		
        soundToPlay = net.ReadString()
		surface.PlaySound(soundToPlay)
    end)

	hook.Add( "HUDPaint", "JM_HOOK_DRAWANNOUNCEMENTTEXT", function()

		if not message then return end
		if messageTime < (CurTime() - 10) then message = nil return end

		draw.DrawText(tostring(message), "JoshMateFont_Announcements", (ScrW()/2), (ScrH()/4), Color(255,255,0,255), TEXT_ALIGN_CENTER)
	end )
end

-----------------------------------------------
-- End of Announcement Function
-----------------------------------------------