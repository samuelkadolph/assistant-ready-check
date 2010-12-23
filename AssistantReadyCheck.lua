AssistantReadyCheck = CreateFrame("Frame");
AssistantReadyCheck:RegisterEvent("READY_CHECK");
AssistantReadyCheck:RegisterEvent("READY_CHECK_CONFIRM");
AssistantReadyCheck:RegisterEvent("READY_CHECK_FINISHED");

local readyCheckPlayers, readyCheckAllReady;

AssistantReadyCheck:SetScript("OnEvent", function(self, event, ...)
	if GetNumRaidMembers() > 0 and not IsRaidOfficer() then return; end

	if event == "READY_CHECK" then
		self:OnReadyCheck(...);
	elseif event == "READY_CHECK_CONFIRM" then
		self:OnPlayerConfirm(...);
	elseif event == "READY_CHECK_FINISHED" then
		self:OnReadyCheckFinished();
	end
end);

function AssistantReadyCheck:OnReadyCheck(name, time)
	if name == UnitName("player") then return; end;

	readyCheckPlayers, readyCheckAllReady = { [name] = true }, true;
end

function AssistantReadyCheck:OnPlayerConfirm(unit, ready)
	if not readyCheckPlayers then return; end;
	if unit == "player" then return; end;

	local name = UnitName(unit);
	readyCheckPlayers[name] = ready;

	if not ready then
		readyCheckAllReady = false;
		self:Print(RAID_MEMBER_NOT_READY, name);
	end
end

function AssistantReadyCheck:OnReadyCheckFinished(preempted)
	if not readyCheckPlayers then return; end;
	if preempted then return; end;			-- ignore Blizzard's bad design

	local numberAFK, afkNames = self:GetAFKPlayers();

	if numberAFK > 0 then
		self:Print(RAID_MEMBERS_AFK, afkNames);
	elseif not readyCheckAllReady then
		self:Print(READY_CHECK_FINISHED);
	else
		self:Print(READY_CHECK_ALL_READY);
	end

	readyCheckPlayers, readyCheckAllReady = nil, nil;
end

function AssistantReadyCheck:GetAFKPlayers()
	local number, names, spacer = 0, "", "";

	for index = 1, 40 do
		local name = UnitName("raid" .. index);

		if not name then
			-- empty raid slot
		elseif readyCheckPlayers[name] == nil then
			number = number + 1;
			names = names .. spacer .. name;
			spacer = ", ";
		else
			-- player is ready
		end
	end

	return number, names;
end

function AssistantReadyCheck:Print(message, name)
	local info = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(format(message, name), info.r, info.g, info.b, info.id);
end
