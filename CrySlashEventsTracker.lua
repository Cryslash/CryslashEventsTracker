--local playername = UnitName("player");
--message("Hello " .. playername);
local _, L = ...
CryslashEventsTrackerSaved = CryslashEventsTrackerSaved or {}

SLASH_CEVENTSTRACKER1 = "/cet"
SLASH_CEVENTSTRACKER2 = "/eventstracker"
SlashCmdList["CEVENTSTRACKER"] = function (msg, editbox)
    ShowUIPanel(CEventsTracker)
end

local events = {
    [1] = { name = L["Community feast"],
        icon = "MajorFactions_MapIcons_Tuskarr64",
        regionOffset = {
            [1] = 52,	-- us
            [2] = 52,	-- kr
            [3] = 52,	-- eu
            [4] = 52,	-- tw
            [5] = 52,},	-- ch	
        duration = 900,
        interval = 5400,
        questIDs = {70893},
        gps = {2024, 13.4, 48.4}
    },
    [2] = {name = L["Researchers under fire"],
        icon = "MajorFactions_MapIcons_Niffen64",
        regionOffset = {
            [1] = 1800,
            [2] = 1800,
            [3] = 1800,
            [4] = 1800,
            [5] = 1800,},
        duration = 1500,
        interval = 3600,
        questIDs = {75627, 75628, 75629, 75630},
        gps = {2133, 47.6, 56.7}
    },
    [3] = {name = L["Dragonbane Keep"],
        icon = "MajorFactions_MapIcons_Expedition64",
        regionOffset = {
            [1] = 100,
			[2] = 100,
			[3] = 100,
			[4] = 100,
			[5] = 100,},
        duration = 3600,
        interval = 7200,
        questIDs = {70866},
        gps = {2022, 30.48, 78.20}
    },
    [4] = {name = L["Time rift"],
        icon = "interface/targetingframe/unitframeicons.blp",
        regionOffset = {
            [1] = 20,
            [2] = 20,
            [3] = 20,
            [4] = 20,
            [5] = 20,},
        duration = 900,
        interval = 3600,
        questIDs = {77836},
        gps = {2025, 51, 57}},
    [5] = {name = L["Dreamsurge"],
        icon = "dreamsurge_hub-icon",
        regionOffset = {
            [1] = 19,
            [2] = 19,
            [3] = 19,
            [4] = 19,
            [5] = 19,},
        duration = 1800,
        interval = 1800,
        questIDs = {77251},
        gps = {},
        findEventOnMap = {2022, 2023, 2024, 2025},
    },
    [6] = {name = L["Storm's Fury"],
        icon = "ElementalStorm-Boss-Water",
        regionOffset = {
            [1] = 1670338860 + 3600,
            [2] = 1670698860,
            [3] = 1674763260,
            [4] = 1670698860,
            [5] = 1670677260,},
        duration = 7200,
        interval = 18000,
        questIDs = {74378},
        gps = {2025, 59.84, 82.29}
    },
    [7] = {name = L["Elemental Storm"],
        icon = "ElementalStorm-Lesser-Earth",
        regionOffset = {
            [1] = 30,
            [2] = 30,
            [3] = 30,
            [4] = 30,
            [5] = 30,},
        duration = 7200,
        interval = 10800,
        questIDs = {},
        achiveIDs = {16468,16484,16476,16489},
        gps = {},
        findEventOnMap = {2022, 2023, 2024, 2025},
    },
    [8] ={name = L["Superbloom"],
        icon = "MajorFactions_MapIcons_Dream64",
        regionOffset = {
            [1] = 11,
            [2] = 11,
            [3] = 11,
            [4] = 11,
            [5] = 11,},
        duration = 1040,
        interval = 3600,
        questIDs = {78319},
        gps = {2200, 51.39, 59.71}
    },
    [9] = {name = L["The Big Dig"],
        icon = "interface/archeology/arch-icon-marker.blp",
        regionOffset = {
            [1] = 1836,
            [2] = 1836,
            [3] = 1836,
            [4] = 1836,	
            [5] = 1836,},
        duration = 552,
        interval = 3600,
        questIDs = {79226},
        gps = {2024, 26.96, 46.46}
    }
}

function MakeMovable(frame)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

local function SecondsToEventTime(seconds)
	local units = ConvertSecondsToUnits(seconds);
	if units.hours > 0 then
		return format("%dh%.2d", units.hours, units.minutes);
	else
		return format(MINUTES_SECONDS, units.minutes, units.seconds);
	end
end

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

function CEventsTrack_Onload(self)
UIPanelWindows["CEventsTracker"] = {
    area = "left",
    pushable = 3,
    whileDead = 1,
}

local serverResetTime = GetServerTime() - (604800 - C_DateAndTime.GetSecondsUntilWeeklyReset());
local region = GetCurrentRegion();
-- ptr
if not region or region > 5 then
    region = 1;
end

-- function ShowEventTooltip(title, status)
--     GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
--     if status then
--         status = string.format("|cff00ff00%s|r",L["Event_is_Active"])
--     else
--         status = string.format("|cffffffff%s|r",L["Event_is_Waiting"])
--     end
--     GameTooltip:SetText(string.format("%s\n".."\n%s",title,status))
--     -- ShowUIPanel(ItemRefTooltip)
--     ShowUIPanel(GameTooltip)
-- end

self.frames = {}
    for i = 1, 9 do
        local frame = CreateFrame("Frame", "Event"..i, self, "CryslashEventsTrackerTemplate")   -- UIPanelScrollFrameTemplate CryslashEventsTrackerTemplate

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
        frame.icon:SetTexture(events[i]["icon"])
        frame.icon:SetAtlas(events[i]["icon"])
        frame.tooltipTitle = events[i].name
        frame.questIDs = events[i].questIDs

        frame.initComplete = false
        frame.notification = false
        frame.isEventActive = nil
        frame.timeTmp = nil
        frame.eventNewRegionOffset = events[i].regionOffset [region] > 1600000000 and events[i].regionOffset [region] or (serverResetTime + events[i].regionOffset [region]);
        
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT") --ANCHOR_CURSOR_RIGHT
            local status
            local iscompleted = nil
            if self.isEventActive then
               status = string.format("|cffffff00%s|r",L["Event_is_Active"]) --amarelo
            else
               status = string.format("|cffffffff%s|r",L["Event_is_Waiting"])
            end
            iscompleted = IsQuestCompleted(self.questIDs)
            if iscompleted then
                --GameTooltip:SetText(string.format("%s\n\n |cffff0000Completo Nesse Char|r".."\n\n%s",self.tooltipTitle,status))
                GameTooltip:SetText(string.format("|cff00ffff%s|r",self.tooltipTitle))
                GameTooltip:AddLine("\n|cff00ff00Concluído|r") --verde
            else
                --GameTooltip:SetText(string.format("%s\n\n |cff00ff00Disponível Nesse Char|r".."\n\n%s",self.tooltipTitle,status))
                GameTooltip:SetText(string.format("|cff00ffff%s|r",self.tooltipTitle))
                GameTooltip:AddLine("\n|cffff0000Não concluído|r")
            end            
            GameTooltip:AddLine(status)
            GameTooltip:Show()
            ShowUIPanel(GameTooltip)
            end
        )

        frame:SetScript("OnUpdate", function(self, elapsed)
		if self.initComplete then
			self.elapsed = (self.elapsed or 1) + elapsed;
			if self.elapsed < 1 then return end
			self.elapsed = 0;
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
                --self.timer:SetTextColor(0, 1, 0);  --(0, 1, 0) verde
                self.timer:SetTextColor(1, 1, 0);
                if self.anim and not self.icon.Anim:IsPlaying() then
                    self.icon.Anim:Play();
                end
            end
            if self.initComplete then
               --C_VoiceChat.SpeakText(0, events[i].name.." iniciou.", 1, 0, 50);
               PlaySound(32585, "Master");
            end
            self.isEventActive = true;
            --self.timer:SetTextColor(0, 1, 0);  --(0, 1, 0) verde
            self.timer:SetTextColor(1, 1, 0);
            if self.anim and not self.icon.Anim:IsPlaying() then
                self.icon.Anim:Play();
            end
        
        -- elseif not isEventActive then
        --     if showedTime < 300 and not self.timeTmp then
        --         if not self.notification then
        --             if self.initComplete then
        --                 PlaySound(32585, "Master");
        --             end
        --             if self.initComplete then 
        --                 --C_VoiceChat.SpeakText(0, events[i].name.." event will start in a moment.", 1, 0, 50);
        --                 C_VoiceChat.SpeakText(0, events[i].name.." começará em breve.", 1, 0, 70);
        --             end
        --             -- if self.anim and not self.icon.Anim:IsPlaying() then
        --             --     self.icon.Anim:Play();
        --             -- end
        --             --self.timer:SetTextColor(.1, .6, .8); -- (1, 1, 0) amarelo
        --             self.timer:SetTextColor(.9, .9, .9); -- (1, 1, 0) amarelo
        --             self.notification = true;
        --         end
        --     elseif self.notification then
        --         self.notification = false;
        --     end
        end
        self.timer:SetText(SecondsToEventTime(showedTime))
        self.initComplete = true
    end)
    end
    MakeMovable(CEventsTracker)
end