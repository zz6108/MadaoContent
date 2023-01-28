function c_skipcutscene:evaluate()
	local noskip = {
		[0] = true,
	}
	if noskip[Player.localmapid] then
		return false
	end
	c_skipcutscene.togglehack = true
	Hacks:SkipCutscene(true)
	if Player.onlinestatus == 15 then
		if (not IsControlOpen("NowLoading") and not IsControlOpen("Snipe") and not IsControlOpen("JournalResult") and TimeSince(c_skipcutscene.lastSkip) > 1500) then
			if (IsControlOpen("SelectString") or IsControlOpen("SelectIconString") or IsControlOpen("CutSceneSelectString")) then
				local convoList = GetConversationList()
				if (table.valid(convoList)) then
					SelectConversationIndex(1)
				end
			else
				PressKey(27) 
			end
			return true
		end
	end
	return false
end



function Mount()
Player:Stop()
	local action = ActionList:Get(5,9)
	if ( action and action:IsReady() ) then
		action:Cast(Player)
		lastaction = Now()
	end		
end