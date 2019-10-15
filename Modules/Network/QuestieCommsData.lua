QuestieComms.data = {}

--[i_1337][playerName][questId] = objective
local commsTooltipLookup = {}

--[playerName] = {
    --[questId] = {["i_1337"]=true,["o_1338"]=true,}
--}
local playerRegisteredTooltips = {}

function QuestieComms.data:GetTooltip(tooltipKey)
    local tooltipData = {}
    for playerName, questData in pairs(commsTooltipLookup[tooltipKey]) do
        for questId, objectives in pairs(questData) do
            if(not tooltipData[questId]) then
                tooltipData[questId] = {};
            end
            if(not tooltipData[questId][playerName]) then
                tooltipData[questId][playerName] = {};
            end
            for objectiveIndex, objective in pairs(objectives) do
                if(not tooltipData[questId][playerName][objectiveIndex]) then
                    tooltipData[questId][playerName][objectiveIndex] = {};
                end
                local oName = "";
                if((objective.type == "monster" or objective.type == "m") and objective.id) then
                    oName = QuestieDB:GetNPC(objective.id).name;
                elseif((objective.type == "object" or objective.type == "o") and objective.id) then
                    oName = QuestieDB:GetObject(objective.id).name;
                elseif((objective.type == "item" or objective.type == "i") and objective.id) then
                    local item = QuestieDB:GetItem(objective.id);
                    if(item and item.Name) then
                        oName = item.Name;-- this is capital letters for some reason...
                    else
                        oName = nil;
                    end
                end
                tooltipData[questId][playerName][objectiveIndex].text = oName
                tooltipData[questId][playerName][objectiveIndex].fulfilled = objective.fulfilled;
                tooltipData[questId][playerName][objectiveIndex].required = objective.required;
            end
        end
    end
    return tooltipData;
end

function QuestieComms.data:RegisterTooltip(questId, playerName, objectives)
    if(not playerRegisteredTooltips[playerName]) then
        playerRegisteredTooltips[playerName] = {}
    end
    if(not playerRegisteredTooltips[playerName][questId]) then
        playerRegisteredTooltips[playerName][questId] = {}
    end
    for objectiveIndex, objective in pairs(objectives) do
        local lookupKey = objective.type.."_"..objective.id;
        if(not commsTooltipLookup[lookupKey]) then
            commsTooltipLookup[lookupKey] = {}
        end
        if(not commsTooltipLookup[lookupKey][playerName]) then
            commsTooltipLookup[lookupKey][playerName] = {};
        end
        commsTooltipLookup[lookupKey][playerName][questId] = objectives;
    end
end

--Totally removes a player from the tooltip lookups
function QuestieComms.data:RemovePlayer(playerName)
    for questId, tooltipList in pairs(playerRegisteredTooltips[playerName] or {}) do
        QuestieComms.data:RemoveQuestFromPlayer(questId, playerName);
    end
    if(playerRegisteredTooltips[playerName]) then
        playerRegisteredTooltips[playerName] = nil;
    end
end

function QuestieComms.data:RemoveQuestFromPlayer(questId, playerName)
    --First check if the player exists and if it has tooltip related quests.
    if(playerRegisteredTooltips[playerName] and playerRegisteredTooltips[playerName][questId]) then
        --Loop through the tooltips to find which should be removed
        for tooltip, active in pairs(playerRegisteredTooltips[playerName][questId]) do
            --Check if the registered tooltip exists and if the player exists in it.
            if(commsTooltipLookup[tooltip] and commsTooltipLookup[tooltip][playerName]) then
                --Does the questId we want to remove exist?
                if(commsTooltipLookup[tooltip][playerName][questId]) then
                    --Remove questID
                    commsTooltipLookup[tooltip][playerName][questId] = nil;
                    --Do we not have any quests left in the tooltip? If not remove it
                    if(QuestieLib:Count(commsTooltipLookup[tooltip][playerName]) == 0) then
                        commsTooltipLookup[tooltip][playerName] = nil;
                        --Are there any other players with this tooltip registered? If not remove it.
                        if(QuestieLib:Count(commsTooltipLookup[tooltip]) == 0) then
                            commsTooltipLookup[tooltip] = nil;
                        end
                    end
                end
            end
        end
        playerRegisteredTooltips[playerName][questId] = nil;
    end
end