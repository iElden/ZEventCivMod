include("InstanceManager");

LuaEvents = ExposedMembers.LuaEvents

ze_selectedEvent = -1
ze_selectedRiver = -1
ze_selectedVolcano = -1
ze_selectedUPlayer = nil;
ze_selectedUnit = nil

function str_split(s, sep)
    if sep == nil then
        sep = "%s";
    end
    local t = {}
    for str in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, str);
    end
    return t;
end

function OnHide()
    ContextPtr:SetHide(true)
end

function OnShow()
    ContextPtr:SetHide(false)
end

function OnSelectDisaster(index, name)
    print("OnSelect " .. tostring(index));
    local randomEvent = GameInfo.RandomEvents();
    Controls.DisasterTypeSelector:GetButton():SetText(name);
    ze_selectedEvent = index;
    if string.sub(name, 1, 6) == "FLOOD_" then
        PopulateRiverTypeList();
        Controls.SpecialFeaturePullDown:GetButton():SetText("[COLOR_RED]Select River[ENDCOLOR]");
    elseif string.sub(name, 1, 8) == "VOLCANO_" then
        PopulateVolcanoTypeList();
        Controls.SpecialFeaturePullDown:GetButton():SetText("[COLOR_RED]Select Volcano[ENDCOLOR]");
    else
        Controls.SpecialFeaturePullDown:ClearEntries();
        Controls.SpecialFeaturePullDown:CalculateInternals();
        Controls.SpecialFeaturePullDown:GetButton():SetText("[COLOR_GREEN]Fill in TileID[ENDCOLOR]");
    end
end

function OnSelectRiver(name)
    local selectionKey = "NAMED_RIVER_" .. tostring(name);

    local definition = GameInfo.NamedRivers[selectionKey];
    if (definition ~= nil) then
        ze_selectedRiver = definition.Index;
        Controls.SpecialFeaturePullDown:GetButton():SetText(name);
    else
        ze_selectedRiver = -1;
        Controls.SpecialFeaturePullDown:GetButton():SetText("[COLOR_RED]ERROR[ENDCOLOR]");
    end
end

function OnSelectVolcano(name)
    local selectionKey = "NAMED_VOLCANO_" .. tostring(name);

    local definition = GameInfo.NamedVolcanoes[selectionKey];
    if (definition ~= nil) then
        ze_selectedVolcano = definition.Index;
        Controls.SpecialFeaturePullDown:GetButton():SetText(name);
    else
        ze_selectedVolcano = -1;
        Controls.SpecialFeaturePullDown:GetButton():SetText("[COLOR_RED]ERROR[ENDCOLOR]");
    end
end

function OnSelectUnit(name)
    ze_selectedUnit = name;
    Controls.UnitTypeSelector:GetButton():SetText(name);
end

function OnSelectUPlayer(player_id)
    ze_selectedUPlayer = player_id;
    local pPlayerConfig = PlayerConfigurations[player_id];
    local strPlrName = pPlayerConfig:GetNickName();
    if ( #strPlrName == 0 ) then
        strPlrName = Locale.Lookup(pPlayerConfig:GetCivilizationShortDescription()):upper();
        strPlrName = strPlrName:gsub("LOC_CIVILIZATION_", "");
    end
    Controls.PlayerTypeSelector:GetButton():SetText(strPlrName);
end

function PopulateUnitTypeList()
    local comboBox = Controls.UnitTypeSelector;
	for unit in GameInfo.Units() do
		local name = string.gsub( unit.UnitType, "UNIT_", "" );
        local controlTable = {};
        comboBox:BuildEntry("InstanceOne", controlTable);
        controlTable.Button:SetText(name);
        controlTable.Button:RegisterCallback(Mouse.eLClick, function()
            OnSelectUnit(name);
        end);
	end
    comboBox:CalculateInternals();
end

function PopulatePlayerUnitList()
    local comboBox = Controls.PlayerTypeSelector;
	local aPlayers = PlayerManager.GetAlive();
	for _, pPlayer in ipairs(aPlayers) do
        local controlTable = {};
		local pPlayerConfig = PlayerConfigurations[pPlayer:GetID()];
		local strPlrName = pPlayerConfig:GetNickName();
		if ( #strPlrName == 0 ) then
			strPlrName = Locale.Lookup(pPlayerConfig:GetCivilizationShortDescription()):upper();
			strPlrName = strPlrName:gsub("LOC_CIVILIZATION_", "");
		end
        comboBox:BuildEntry("InstanceOne", controlTable);
        controlTable.Button:SetText(strPlrName);
        controlTable.Button:RegisterCallback(Mouse.eLClick, function()
            OnSelectUPlayer(pPlayer:GetID());
        end);
	end
    comboBox:CalculateInternals();
end

function PopulateDisasterTypeList()
    local comboBox = Controls.DisasterTypeSelector;
    local i = 0;
    comboBox:ClearEntries();

    for randomEvent in GameInfo.RandomEvents() do
        local controlTable = {};
        local j = i;
        comboBox:BuildEntry("InstanceOne", controlTable);
        local name = string.sub(randomEvent.RandomEventType, 14);
        controlTable.Button:SetText(name);
        controlTable.Button:RegisterCallback(Mouse.eLClick, function()
            OnSelectDisaster(j, name);
        end);
        i = i + 1;
    end
    comboBox:CalculateInternals();
end

function PopulateRiverTypeList()
    local comboBox = Controls.SpecialFeaturePullDown;
    local i = 0;
    comboBox:ClearEntries();

    for z = 0, RiverManager.GetNumRivers() - 1, 1 do
        local eRiverType = RiverManager.GetRiverTypeAtIndex(z);
        local namedRiver = GameInfo.NamedRivers[eRiverType];
        if namedRiver ~= nil then
            local controlTable = {};
            local name = string.gsub(namedRiver.NamedRiverType, "NAMED_RIVER_", "" )
            comboBox:BuildEntry("InstanceOne", controlTable);
            controlTable.Button:SetText(name);
            controlTable.Button:RegisterCallback(Mouse.eLClick, function()
                OnSelectRiver(name);
            end);
            i = i + 1;
        end
    end
    comboBox:CalculateInternals();
end

function PopulateVolcanoTypeList()
    local comboBox = Controls.SpecialFeaturePullDown;
    local i = 0;
    comboBox:ClearEntries();

    for z = 0, MapFeatureManager.GetNumVolcanoes() - 1, 1 do
        local eVolcanoType = MapFeatureManager.GetVolcanoTypeAtIndex(z);
        local namedVolcano = GameInfo.NamedVolcanoes[eVolcanoType];
        print(eVolcanoType, namedVolcano);
        if namedVolcano ~= nil then
            local controlTable = {};
            local name = string.gsub(namedVolcano.NamedVolcanoType, "NAMED_VOLCANO_", "" )
            comboBox:BuildEntry("InstanceOne", controlTable);
            controlTable.Button:SetText(name);
            controlTable.Button:RegisterCallback(Mouse.eLClick, function()
                OnSelectVolcano(name);
            end);
            i = i + 1;
        end
    end
    comboBox:CalculateInternals();
end

function OnFireButton()
    local tileTargetID = Controls.TileTargetIDDisaster:GetText();
    Network.SendChat("mph_zedisaster_"..tostring(ze_selectedEvent).."_"..tostring(tileTargetID).."_"..tostring(ze_selectedRiver).."_"..tostring(ze_selectedVolcano));
    Network.SendChat(".mph_zedisaster_" .. tostring(ze_selectedEvent) .. "_" .. tostring(tileTargetID) .. "_" .. tostring(ze_selectedRiver) .. "_" .. tostring(ze_selectedVolcano));
end

function OnSpawnUnitButton()
    local futureOwner = tostring(ze_selectedUPlayer);
    local unitType = "UNIT_"..ze_selectedUnit;
    local targetX = Controls.TileTargetXUnit:GetText();
    local targetY = Controls.TileTargetYUnit:GetText();
    Network.SendChat("mph_zespawnunit;"..futureOwner..";"..unitType..";"..targetX..";"..targetY);
end

function OnKillAllBarbsButton()
    Network.SendChat("mph_zekillallbarbs");
end

function OnMultiplayerChat(fromPlayer, toPlayer, text, eTargetType)
    local is_author = false;
    if fromPlayer == Network.GetLocalPlayerID() then
        is_author = true;
    end

    if string.lower(text) == ".mph_zeshow" then
        if is_author then
            OnShow();
        end
    end

    if string.lower(text) == ".mph_zehide" then
        if is_author then
            OnHide();
        end
    end

    if string.sub(text, 1, 16) == ".mph_zedisaster_" then
        if is_author then
            Network.SendChat("[COLOR_GREEN]déclanche une catastrophe naturelle.[ENDCOLOR]", -2, -1);
        end
        args = str_split(string.sub(text, 17), "_");
        if GameRandomEvents ~= nil then
            local kEvent = {};
            kEvent.EventType = tonumber(args[1]);
            kEvent.NamedRiver = tonumber(args[3]);
            kEvent.NamedVolcano = tonumber(args[4]);
            local location = tonumber(args[2]);
            local kEventDef = GameInfo.RandomEvents[kEvent.EventType];
            if kEventDef ~= nil then
                if kEventDef.NaturalWonder ~= nil and kEventDef.NaturalWonder ~= "" then
                    kEvent.FeatureType = kEventDef.NaturalWonder;
                end

                if location ~= nil and location >= 0 then
                    kEvent.Location = location;
                end

                if kEventDef.EffectOperatorType ~= nil and kEventDef.EffectOperatorType == "NUCLEAR_ACCIDENT" then
                    if g_Selected.ReactorIndex ~= nil then
                        local reactor = Game.GetFalloutManager():GetReactorByIndex(g_Selected.ReactorIndex - 1);
                        if reactor ~= nil then
                            kEvent.Location = reactor.PlotIndex;
                        end
                    end
                end
            end
            LuaEvents.ZE_Disaster(kEvent);
        end
    end

    -- Explore all for player
    if string.lower(text) == ".mph_zescout" then
        if is_author then
            Network.SendChat("[COLOR_GREEN]révéle la carte.[ENDCOLOR]", -2, -1);
        end
        LuaEvents.ZE_Scout();
    end
end

function onTabSelected(tab)
    Controls.Tab0:SetHide(tab~=0);
    Controls.Tab1:SetHide(tab~=1);
    Controls.Tab2:SetHide(tab~=2);
    Controls.Tab3:SetHide(tab~=3);
end

function InitPanel()
    PopulateDisasterTypeList();
    PopulateUnitTypeList();
    PopulatePlayerUnitList();
    Controls.ButtonFire:RegisterCallback(Mouse.eLClick, OnFireButton);
    Controls.ButtonSpawn:RegisterCallback(Mouse.eLClick, OnSpawnUnitButton);
    Controls.ButtonKillBarbarian:RegisterCallback(Mouse.eLClick, OnKillAllBarbsButton);
    Controls.BackToMenu1:RegisterCallback(Mouse.eLClick,function()
        onTabSelected(0);
    end);
    Controls.BackToMenu2:RegisterCallback(Mouse.eLClick,function()
        onTabSelected(0);
    end);
    Controls.BackToMenu3:RegisterCallback(Mouse.eLClick,function()
        onTabSelected(0);
    end);
    Controls.ButtonCat1:RegisterCallback(Mouse.eLClick,function()
        onTabSelected(1);
    end);
    Controls.ButtonCat2:RegisterCallback(Mouse.eLClick,function()
        onTabSelected(2);
    end);
    Controls.ButtonCat3:RegisterCallback(Mouse.eLClick,function()
        onTabSelected(3);
    end);
    -- default Select
    OnSelectUPlayer(63); -- Barbarians
    OnSelectUnit("WARRIOR"); -- Warrior
    Controls.TileTargetIDDisaster:SetText("-1"); -- Default target
    Controls.TileTargetXUnit:SetText("0"); -- Default Units X
    Controls.TileTargetYUnit:SetText("0"); -- Default Units Y
end

function Initialize()
    print("Initialize DisasterPanel");
    Events.MultiplayerChat.Add(OnMultiplayerChat);
    InitPanel();
    OnShow();
end

Initialize();
