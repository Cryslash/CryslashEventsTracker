local _, L = ...
local charName

SLASH_CEVENTSTRACKER1 = "/cet"
SLASH_CEVENTSTRACKER2 = "/eventstracker"
SlashCmdList["CEVENTSTRACKER"] = function (msg, editbox)
    ShowUIPanel(CEventsTracker)
end

local events = {
    [1] = {name = L["Dragonbane Keep"],
        icon = "MajorFactions_MapIcons_Expedition64",
        regionOffset = {[1] = 100, [2] = 100, [3] = 100, [4] = 100, [5] = 100,},
        duration = 3600,
        interval = 7200,
        questIDs = {70866},
        gps = {2022, 30.48, 78.20}
    },
    [2] = { name = L["Community feast"],
        icon = "MajorFactions_MapIcons_Tuskarr64",
        regionOffset = {[1] = 52, [2] = 52, [3] = 52, [4] = 52, [5] = 52,},	-- us -- kr -- eu -- tw -- ch	
        duration = 900,
        interval = 5400,
        questIDs = {70893},
        gps = {2024, 13.4, 48.4}
    },
    [3] = { name = L["Grand Hunt"],
        icon = "MajorFactions_MapIcons_Centaur64",
        regionOffset = {[1] = 20, [2] = 20, [3] = 20, [4] = 20, [5] = 20,},
        duration = 7200,
        interval = 7200,
        questIDs = {},
        eventMaps = {2022, 2023, 2024, 2025},--2130
        gps={}
    },
    [4] = {name = L["Time rift"],
        icon = "interface/targetingframe/unitframeicons.blp",
        regionOffset = {[1] = 20, [2] = 20, [3] = 20, [4] = 20, [5] = 20,},
        duration = 900,
        interval = 3600,
        questIDs = {77836},
        gps = {2025, 51, 57}},
    [5] = {name = L["Storm's Fury"],
        icon = "ElementalStorm-Boss-Water",
        regionOffset = {[1] = 1670338860 + 3600, [2] = 1670698860, [3] = 1674763260, [4] = 1670698860, [5] = 1670677260,},
        duration = 7200,
        interval = 18000,
        questIDs = {74378},
        gps = {2025, 59.84, 82.29}
    },
    [6] = {name = L["Elemental Storm"],
        icon = "ElementalStorm-Lesser-Earth",
        regionOffset = {[1] = 30, [2] = 30, [3] = 30, [4] = 30, [5] = 30,},
        duration = 7200,
        interval = 10800,
        questIDs = {},
        achiveIDs = {16468,16484,16476,16489},
        gps = {},
        eventMaps = {2022, 2023, 2024, 2025},
    },
    [7] = {name = L["The Big Dig"],
        icon = "interface/archeology/arch-icon-marker.blp",
        regionOffset = {[1] = 1836, [2] = 1836, [3] = 1836, [4] = 1836, [5] = 1836,},
        duration = 552,
        interval = 3600,
        questIDs = {79226},
        gps = {2024, 26.96, 46.46}
    },
    [8] = {name = L["Researchers under fire"],
        icon = "MajorFactions_MapIcons_Niffen64",
        regionOffset = {[1] = 1800, [2] = 1800, [3] = 1800, [4] = 1800, [5] = 1800,},
        duration = 1500,
        interval = 3600,
        questIDs = {75627, 75628, 75629, 75630},
        gps = {2133, 47.6, 56.7}
    },
    [9] = {name = L["Dreamsurge"],
        icon = "dreamsurge_hub-icon",
        regionOffset = {[1] = 19, [2] = 19, [3] = 19, [4] = 19, [5] = 19,},
        duration = 1800,
        interval = 1800,
        questIDs = {77251},
        gps = {},
        eventMaps = {2022, 2023, 2024, 2025},
    },
    [10] ={name = L["Superbloom"],
        icon = "MajorFactions_MapIcons_Dream64",
        regionOffset = {[1] = 11, [2] = 11, [3] = 11, [4] = 11, [5] = 11,},
        duration = 1040,
        interval = 3600,
        questIDs = {78319},
        gps = {2200, 51.39, 59.71}
    }
}

local function SecondsToEventTime(seconds)
	local units = ConvertSecondsToUnits(seconds);
	if units.hours > 0 then
		return format("%dh%.2d", units.hours, units.minutes);
	else
		return format(MINUTES_SECONDS, units.minutes, units.seconds);
	end
end
--event completed check
local function IsQuestCompleted(questIds)
    local completed = 0
    local isCompleted
    if questIds then
        for _, questId in pairs(questIds) do
            if (C_QuestLog.IsOnQuest(questId)) then
				isCompleted = C_QuestLog.IsComplete(questId)
			else
				isCompleted = C_QuestLog.IsQuestFlaggedCompleted(questId)
			end

            if isCompleted then
                completed = completed + 1
            end
        end
    end
    return (completed > 0)
end

local function ScanBagForItem()
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 0, C_Container.GetContainerNumSlots(bag) do
            local table = C_Container.GetContainerItemInfo(bag, slot)
            if table then
                if table.itemID == 200468 or table.itemID == 200513 or table.itemID == 200515 or table.itemID == 200516 then
                   --print(string.format("você looteou %s",table.itemName))
                    CryslashEventsTrackerSaved[charName].events[3] = 1
                end
            end
        end
    end
end

local function isBlp(str)
    return str:sub(-4) ==".blp"
end

local function WeeklyResetEvents()
    if CryslashEventsTrackerSavedSettings.resetTime == nil then
        CryslashEventsTrackerSavedSettings.resetTime = GetServerTime() + C_DateAndTime.GetSecondsUntilWeeklyReset()
    end
    
    if CryslashEventsTrackerSavedSettings.resetTime then
        if CryslashEventsTrackerSavedSettings.resetTime < GetServerTime() then
            for _, charData in pairs(CryslashEventsTrackerSaved) do
                if charData.events then
                    for i in ipairs(charData.events) do
                        charData.events[i] = 0
                    end
                end
            end
            CryslashEventsTrackerSavedSettings.resetTime = GetServerTime() + C_DateAndTime.GetSecondsUntilWeeklyReset()
        print("|cffffff00Cryslash-EventsTracker:|r Os eventos foram resetados!!")
        end
    end
end

local function SearchEventsOnMaps(i)
    local eventName = events[i].name
    local lookingForMaps = events[i].eventMaps
    local changedName,atlasName, x, y, findMapID
    local toolTip = ""

    for _, mapID in next, lookingForMaps do
        local mapName = C_Map.GetMapInfo(mapID).name or UNKNOWN
        local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(mapID)
        for _, ids in pairs(areaPoiIDs) do
            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, ids)
            if poiInfo.isPrimaryMapForPOI and
            ((eventName == L["Dreamsurge"] and poiInfo.atlasName == "dreamsurge_hub-icon") or (eventName == L["Elemental Storm"] and string.find(poiInfo.atlasName, "ElementalStorm"))
            or (eventName == L["Grand Hunt"] and poiInfo.name == L["Grand Hunt Party"])) then
            --or (eventName == L["Grand Hunt"] and poiInfo.atlasName == "minimap-genericevent-hornicon" )) then
                if eventName ~= L["Grand Hunt"] then
                    atlasName = poiInfo.atlasName
                else
                    atlasName = events[i].icon
                end
                if atlasName == "ElementalStorm-Lesser-Water" then
                    changedName = L["Snowstorms"]
                elseif atlasName == "ElementalStorm-Lesser-Fire" then
                    changedName = L["Firestorms"]
                elseif atlasName == "ElementalStorm-Lesser-Air" then
                    changedName = L["Thunderstorms"]
                elseif atlasName == "ElementalStorm-Lesser-Earth" then
                    changedName = L["Sandstorms"]
                end

                toolTip = toolTip.."|A:"..atlasName..":24:24|a".." "..(changedName and changedName or eventName).." "..L["in"].." "..mapName.."\n"
                findMapID = mapID
                x, y = poiInfo.position:GetXY()
            end
        end
    end
    if findMapID then
		return findMapID, x*100, y*100, atlasName, toolTip
	end
end

function CEventsTrack_Onload(self)
UIPanelWindows["CEventsTracker"] = {
    area = "left",
    pushable = 1,
    whileDead = 1,
}

local serverResetTime = GetServerTime() - (604800 - C_DateAndTime.GetSecondsUntilWeeklyReset())

local region = GetCurrentRegion()
-- ptr
if not region or region > 5 then
    region = 1;
end

self.frames = {}
  for i = 1, #events do
    --Creating template frames
    local frame = CreateFrame("Button", "Event"..i, self, "CryslashEventsTrackerTemplate")   -- UIPanelScrollFrameTemplate CryslashEventsTrackerTemplate

    --Anchoring frames
    self.frames[i] = frame
    if i == 1 then
        frame:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -95)
    elseif i == 6 then
        frame:SetPoint("TOPLEFT", self.frames[1], "BOTTOMLEFT", 0, -10)
    elseif i == 11 then
        frame:SetPoint("TOPLEFT", self.frames[i-5],"BOTTOMLEFT", 0, 0)
    else
        frame:SetPoint("TOPLEFT", self.frames[i-1], "TOPRIGHT", 12, 0)
    end

    --Setting frames variables
    local mapId, coorX, coorY, atlasName, tooltip
    frame.icon:SetTexture(events[i]["icon"])
    frame.icon:SetAtlas(events[i]["icon"])
    
    frame.tooltipTitle = events[i].name
    frame.questIDs = events[i].questIDs
    frame.initComplete = false
    frame.notification = false
    frame.isEventActive = nil
    frame.timeTmp = nil
    frame.eventNewRegionOffset = events[i].regionOffset [region] > 1600000000 and events[i].regionOffset [region] or (serverResetTime + events[i].regionOffset [region]);

    --Setting Scripts Events
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT") --ANCHOR_CURSOR_RIGHT
        local status
        local iscompleted = nil

        if tooltip then
           GameTooltip:SetText(string.format("|cffffffff%s|r",tooltip))
        else
            if isBlp(events[i]["icon"]) then
                GameTooltip:SetText(CreateTextureMarkup(events[i]["icon"], 24, 24, 24, 24, 1, 0, 1, 0)..string.format("|cffffffff %s|r\n",self.tooltipTitle))
            else
                GameTooltip:SetText(CreateAtlasMarkup(events[i]["icon"], 24, 24)..string.format("|cffffffff %s|r\n",self.tooltipTitle))  --|cff00ffff
            end
        end
        if self.isEventActive then
            status = string.format("|cffffff00%s|r",L["Event_is_Active"]) --amarelo
        else
            status = string.format("|cffffffff%s|r",L["Event_is_Waiting"])
        end
        iscompleted = IsQuestCompleted(self.questIDs)
        if events[i].name == L["Grand Hunt"] and CryslashEventsTrackerSaved[charName].events[3] == 1 then
            GameTooltip:AddLine(string.format("|cff00ff00%s|r",charName)) --verde
        end
        if iscompleted then
            CryslashEventsTrackerSaved[charName].events[i] = 1
            GameTooltip:AddLine(string.format("|cff00ff00%s|r",charName)) --verde
        else
            if events[i].name ~= L["Grand Hunt"] or CryslashEventsTrackerSaved[charName].events[3] == 0 or CryslashEventsTrackerSaved[charName].events[3] == nil  then
                CryslashEventsTrackerSaved[charName].events[i] = 0
                GameTooltip:AddLine(string.format("|cffff0000%s|r",charName)) --vermelho
            end
        end

        for char in pairs(CryslashEventsTrackerSaved) do
            if char ~= charName then
                if CryslashEventsTrackerSaved[char].events[i] == 1 then
                    GameTooltip:AddLine(string.format("|cff00ff00%s|r",char)) --verde
                elseif CryslashEventsTrackerSaved[char].events[i] == 0 or CryslashEventsTrackerSaved[char].events[i] == nil then
                    GameTooltip:AddLine(string.format("|cffff0000%s|r",char)) -- vermelho
                end
            end
        end

        GameTooltip:AddLine("\n"..status)
        GameTooltip:AddDoubleLine("\n"..CreateAtlasMarkup("NPE_LeftClick",18,18)..L["Way_Point"],"\n"..CreateAtlasMarkup("NPE_RightClick",18,18)..L["Show_in_Map"],0,1,0.5,0,1,0.5)
        GameTooltip:Show()
        ShowUIPanel(GameTooltip)
    end)

    frame:SetScript("OnUpdate", function(self, elapsed)
	if self.initComplete then
		self.elapsed = (self.elapsed or 1) + elapsed;
		if self.elapsed < 1 then return end
		self.elapsed = 0;
	end
    WeeklyResetEvents()

    if events[i].eventMaps then
        mapId, coorX, coorY, atlasName, tooltip =  SearchEventsOnMaps(i)
        local gps ={mapId, coorX, coorY}
        frame.gps = gps
    else
        frame.gps = events[i].gps
    end
    if atlasName then
        frame.icon:SetTexture(atlasName)
        frame.icon:SetAtlas(atlasName)
    end
    if not self:IsShown() then return end
        local timeFromFirstStart = GetServerTime() - self.eventNewRegionOffset;
        local timeToNextEvent = (events[i].interval - timeFromFirstStart % events[i].interval) + (self.timeTmp and self.timeTmp or 0);
        local timeActiveEvent = self.timeTmp and timeToNextEvent or events[i].duration - (events[i].interval - timeToNextEvent);
        local isEventActive = (events[i].interval + (self.timeTmp and self.timeTmp or 0)) - timeToNextEvent <= events[i].duration;
        local showedTime = isEventActive and timeActiveEvent or timeToNextEvent;

        if not self.initComplete or (self.isEventActive and not isEventActive) then
            if (self.isEventActive and not isEventActive) then self.isEventActive = false end
            self.timer:SetTextColor(.9, .9, .9); --(.9, .9, .9)  branco
            self.timeTmp = nil;
        end
        if not self.isEventActive and isEventActive then
            if self.timeTmp and self.timeTmp > 0 then
                self.timeTmp = self.timeTmp - events[i].interval;
                self.timer:SetTextColor(1, 1, 0);
                if self.anim and not self.icon.Anim:IsPlaying() then
                    self.icon.Anim:Play();
                end
            end
            if self.initComplete then
               PlaySound(32585, "Master");
            end
            self.isEventActive = true;
            self.timer:SetTextColor(1, 1, 0);
            if self.anim and not self.icon.Anim:IsPlaying() then
                self.icon.Anim:Play();
            end
        end
        self.timer:SetText(SecondsToEventTime(showedTime))
        self.initComplete = true
    end)

    frame:SetScript("OnClick", function(self, button)
        --if button == "LeftButton" and next(self.gps) then
        if next(self.gps) then
            C_Map.ClearUserWaypoint()
            C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(self.gps[1], self.gps[2]/100, self.gps[3]/100, 0))
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
        --if IsModifierKeyDown() then
        if button =="RightButton" and next(self.gps) then
            ToggleWorldMap();
			if WorldMapFrame:IsVisible() then
				WorldMapFrame:SetMapID(self.gps[1]);
			end;
        end
    end)
end
    self:RegisterEvent("ADDON_LOADED", CEventsTracker_OnEvent)
end

function CEventsTracker_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "CrySlash_EventsTracker" then
	    charName = string.format("%s - %s",UnitName("player"), GetRealmName());
		if CryslashEventsTrackerSaved == nil then
            CryslashEventsTrackerSaved = {}
        end
		if CryslashEventsTrackerSaved[charName] == nil then
			CryslashEventsTrackerSaved[charName] = {}
			CryslashEventsTrackerSaved[charName].class = select(2, UnitClass("player"))
			CryslashEventsTrackerSaved[charName].events = {}
		end
        if CryslashEventsTrackerSavedSettings == nil then
            CryslashEventsTrackerSavedSettings = {}
        end
        self:UnregisterEvent("ADDON_LOADED")
        self:RegisterEvent("BAG_UPDATE")
    elseif event == "BAG_UPDATE" then
        ScanBagForItem()
    elseif event == "PLAYER_ENTERING_WORLD" then
        CryslashEventsTrackerSaved = CryslashEventsTrackerSaved or 0
        --CryslashEventsTrackerSavedSettings = CryslashEventsTrackerSavedSettings or 0
    end
end