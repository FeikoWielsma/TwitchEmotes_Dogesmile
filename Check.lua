-- /dogesmile check: shows which online guild members have this addon (and which version).
-- Sends a hidden addon message to the guild; everyone running the addon answers with their version.
local ADDON_NAME = ...
local PREFIX = "Dogesmile"
local WAIT = 6 -- seconds to collect answers (answers are spread over 0-3 s)

local SendAddonMessage = C_ChatInfo and C_ChatInfo.SendAddonMessage or SendAddonMessage
local RegisterPrefix = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix
local GetMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local RequestRoster = C_GuildInfo and C_GuildInfo.GuildRoster or GuildRoster

local VERSION = GetMetadata(ADDON_NAME, "Version") or "?"
if VERSION:find("@", 1, true) then
	VERSION = "dev" -- running from the git repo, not a packaged release
end

local function Print(msg)
	print("|cffe8b04dDogesmile:|r " .. msg)
end

-- Roster and addon-message names are "Name-Realm"; add the realm where it's missing.
local function FullName(name)
	if not name:find("-", 1, true) then
		name = name .. "-" .. (GetNormalizedRealmName() or "")
	end
	return name
end

-- Retail blocks addon messages in some situations (e.g. during encounters).
local function Send(msg)
	if InChatMessagingLockdown and InChatMessagingLockdown() then
		return false
	end
	SendAddonMessage(PREFIX, msg, "GUILD")
	return true
end

local results -- full name -> version while a check is running

local function Report(found)
	local have, missing = {}, {}
	for i = 1, GetNumGuildMembers() do
		local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
		if name and online then
			local full = FullName(name)
			local short = Ambiguate(full, "guild")
			local version = found[full]
			if version then
				have[#have + 1] = version == VERSION and short or (short .. " (" .. version .. ")")
			else
				missing[#missing + 1] = short
			end
		end
	end
	table.sort(have)
	table.sort(missing)
	Print(("%d of %d online guild members have it (you: %s)."):format(#have, #have + #missing, VERSION))
	if #have > 0 then
		Print("|cff40ff40Have it:|r " .. table.concat(have, ", "))
	end
	if #missing > 0 then
		Print("|cffff4040Missing:|r " .. table.concat(missing, ", "))
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(_, _, prefix, msg, _, sender)
	if issecretvalue and (issecretvalue(prefix) or issecretvalue(msg) or issecretvalue(sender)) then
		return
	end
	if prefix ~= PREFIX or not msg or not sender then
		return
	end
	if msg == "Q" then
		-- spread the answers so a big guild doesn't answer all at once
		C_Timer.After(math.random() * 3, function()
			Send("V:" .. VERSION)
		end)
	elseif results and msg:sub(1, 2) == "V:" then
		results[FullName(sender)] = msg:sub(3)
	end
end)
RegisterPrefix(PREFIX)

SLASH_DOGESMILE1 = "/dogesmile"
SlashCmdList.DOGESMILE = function(arg)
	arg = (arg or ""):lower():match("^%s*(.-)%s*$")
	if arg ~= "check" then
		Print("/dogesmile check - show which online guild members have this addon")
		return
	end
	if not IsInGuild() then
		Print("You're not in a guild.")
		return
	end
	if results then
		Print("A check is already running.")
		return
	end
	if not Send("Q") then
		Print("Can't send addon messages right now (combat or instance). Try again later.")
		return
	end
	results = { [FullName(UnitName("player"))] = VERSION }
	if RequestRoster then
		RequestRoster()
	end
	Print("Checking the guild, results in " .. WAIT .. " seconds...")
	C_Timer.After(WAIT, function()
		local found = results
		results = nil
		Report(found)
	end)
end
