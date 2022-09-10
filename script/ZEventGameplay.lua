-- by: iElden

ExposedMembers.LuaEvents = LuaEvents

function GP_Disaster(kEvent)
    print(tostring(kEvent.EventType) .. "_" .. tostring(kEvent.Location));
    GameRandomEvents.ApplyEvent(kEvent);
end

function GP_Scout()
    local pAllPlayerIDs = PlayerManager.GetAliveIDs();
    for _, iPlayerID in ipairs(pAllPlayerIDs) do
        local pPlayer = Players[iPlayerID];
        print("scout PLID", iPlayerID);
        if pPlayer:IsMajor() == true then
            print("PLID is Major");
            local pVis = PlayersVisibility[iPlayerID];
            for iPlotIndex = 0, Map.GetPlotCount() - 1, 1 do
                pVis:ChangeVisibilityCount(iPlotIndex, 0);
            end
        end
    end
end

function Initialize()
    print("Init ZEvent Gameplay")
    LuaEvents.ZE_Disaster.Add(GP_Disaster);
    LuaEvents.ZE_Scout.Add(GP_Scout);
end

Initialize();