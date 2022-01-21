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
--  Print Chat Function
-----------------------------------------------


function JM_Function_PrintChat(player, prefixMessageString, chatMessageString)

    net.Start("JM_Net_PrintChat")
    net.WriteString(tostring(prefixMessageString))
	net.WriteString(tostring(chatMessageString))
    net.Send(player)

end


-----------------------------------------------
-- End of Print Chat Function
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
	util.AddNetworkString("JM_Net_PrintChat")
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
	local chatMessage = nil

    net.Receive("JM_Net_Announcement", function(_) 
		
        message = net.ReadString()
		messageTime = CurTime()

		surface.PlaySound("0_main_popup.wav")

		chat.AddText( Color( 255, 0, 0 ), "[Announcement] ", Color( 255, 255, 0 ), tostring(message))
    end)

    net.Receive("JM_Net_PlaySound", function(_) 
		
        soundToPlay = net.ReadString()
		surface.PlaySound(soundToPlay)
    end)

	net.Receive("JM_Net_PrintChat", function(_) 
		
        prefixMessage = net.ReadString()
		chatMessage = net.ReadString()

		surface.PlaySound("0_main_slight.wav")
		
        chat.AddText( Color( 255, 100, 0 ), "[".. tostring(prefixMessage) .."] ", Color( 255, 255, 255 ), tostring(chatMessage))
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