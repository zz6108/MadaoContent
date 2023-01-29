MadaoKDFStore = {}
MadaoSessionInit = false

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


RegisterEventHandler('Gameloop.Update',
function()
	if not GetGameState() == FFXIV.GAMESTATE.INGAME then return end
	if MadaoSessionInit == true then return end
	
	if not MadaoSchedule2.running then return end
	
	--make sure we're not in duty, and just stop
	if table.valid(KitanoiFuncs) and not KitanoiFuncs.InDuty() and KitanoiFuncs.AreKitanoiAddonsRunning("KDF") then
			d("disabling DF?")
			KitanoiFuncs.EnableAddon('dungeon framework',false)
			KitanoiFuncs.RunCounter = 0
			KitanoiFuncs.StopNav() --facepalm, why
	end
end, "KDF2 loginfix")


RegisterEventHandler('Module.Initalize', 
function()

	KitanoiFuncs.EnableAddon('dungeon framework',false)
	d("------------------- kitanoi ups?", table.valid(Kitanois_Dungeon_Framework))
	if FileExists(string.format("%s/zzzPatchCutscene/settings-%s-%s.lua", GetLuaModsPath(), Player.Name, GetUUID())) then
		MadaoKDFStore = FileLoad(string.format("%s/zzzPatchCutscene/settings-%s-%s.lua", GetLuaModsPath(), Player.Name, GetUUID()))
	end
	
	
	Settings.Global.MadaoPlanTaskAPI["KDF2"] = 
	{
		category = "Kitanoi's Addons",
		is_can_swap = "",
		is_hidden = "return false",
		is_stop = 
		[[
			return not KitanoiFuncs.AreKitanoiAddonsRunning("KDF") or KitanoiFuncs.RunCounter == 0
		]],
		is_valid = 
		[[
			return table.valid(Kitanois_Dungeon_Framework)
		]],
		start = 
		[[
			local loadSettings = function()
				return FileLoad(string.format("%s/zzzPatchCutscene/settings-%s-%s.lua", GetLuaModsPath(), Player.Name, GetUUID()))
			end
			
			MadaoSessionInit = true
			
			settings = loadSettings()
			
			SendTextCommand(string.format("/gearset equip %d", settings.GearSet));
			gSkillProfile = "xxx MCR xxx"
			gSkillProfileIndex = GetKeyByValue(gSkillProfile,SkillMgr.profiles)
			
			
			gBotMode = "Assist"
            gBotModeIndex = GetKeyByValue(gBotMode, gBotModeList)
			ml_global_information:ToggleRun()
			
			KitanoiSettings.SingleOrQueue = 1 
			KitanoiFuncs.DFSelectedDungeon = settings.data 
			KitanoiFuncs.RunCounter = settings.RunCounter
			KitanoiFuncs.EnableAddon('dungeon framework',true) 	
			
			return true
		]],
		stop = 
		[[
		
			if not KitanoiFuncs.InDuty() and not KitanoiFuncs.AreKitanoiAddonsRunning("KDF") then
				KitanoiFuncs.EnableAddon("dungeon framework",false)
				MadaoSessionInit = false
			end
			
		]],
		
		ui = 
		[[
			local saveSettings = function(inp)
				FileSave(string.format("%s/zzzPatchCutscene/settings-%s-%s.lua", GetLuaModsPath(), Player.Name, GetUUID()), inp)
			end
			local uniqueid = tostring(SettingsUUID.MadaoSchedule.nowFileName)..tostring(plate.stamp) 
			KitanoiFuncs.MaAPISelectedStamp = uniqueid 
			
			gsblank = Player:GetGearSetList()
			gsUi = {}
			
			for k, v in ipairs(gsblank) do
				gsUi[k] = v.name
			end
			
			
			if MadaoKDFStore.GearSet == nil then MadaoKDFStore.GearSet = 1 end
			
			local val, chg = GUI:Combo("gsname##mdUI", MadaoKDFStore.GearSet, gsUi);
			if chg then
				MadaoKDFStore.GearSet = val
				saveSettings(MadaoKDFStore)
			end
			if (KitanoiFuncs.MaAPI[uniqueid]==nil) then 
				d("Create blank dungeon task") 
				KitanoiFuncs.MaAPI[uniqueid]= {data = {name="none",},runcounter=0,} 
			end 
			
			if (KitanoiFuncs.MaAPI[uniqueid]~=nil) then 
				KitanoiFuncs.MaAPI[uniqueid].runcounter,changed = GUI:InputInt(GetString('Run Counter')..'##RunCounterMAPI'.. uniqueid, MadaoKDFStore.RunCounter or KitanoiFuncs.MaAPI[uniqueid].runcounter) 
				if KitanoiFuncs.MaAPI[uniqueid] ~= nil and KitanoiFuncs.MaAPI[uniqueid].data ~= nil and ( MadaoKDFStore.data == nil or KitanoiFuncs.MaAPI[uniqueid].data.name ~= MadaoKDFStore.data.name )then
					MadaoKDFStore.data = KitanoiFuncs.MaAPI[uniqueid].data
				end
				if changed then 
					kIO.save('mrcchange') 
					MadaoKDFStore.RunCounter = KitanoiFuncs.MaAPI[uniqueid].runcounter
					
					saveSettings(MadaoKDFStore)
				end 
				
				if (MadaoKDFStore.data~=nil and MadaoKDFStore.data.name ~= nil) then 
					GUI:Text('Dungeon Selected for Task:') 
					GUI:NewLine() 
					GUI:Text(MadaoKDFStore.data.name.. '(' .. MadaoKDFStore.RunCounter or 0 .. ')')
					
					
					MadaoKDFStore.data = KitanoiFuncs.MaAPI[uniqueid].data
					saveSettings(MadaoKDFStore)
					
				end 
				GUI:NewLine() 
				KitanoiFuncs.MAPIDKDF() 
			end
		]]
	}
end
, 'KDF2 init')