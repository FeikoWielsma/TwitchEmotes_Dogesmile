-- Adds the :dogesmile Discord emotes to TwitchEmotes. Type them as :name: in chat.
local ADDON_NAME = ...
local BASE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Emotes\\"
local CATEGORY = "dogesmile"

local function Register()
	local names = {}
	for _, entry in ipairs(Dogesmile_EmoteData) do
		local name, file, anim = entry[1], entry[2], entry[3]
		local key = ":" .. name .. ":"
		local path = BASE .. file .. ".tga"
		if anim then
			TwitchEmotes_animation_metadata[path] = anim
			TwitchEmotes:AddEmote(key, key, path)
		else
			TwitchEmotes:AddEmote(key, key, path .. ":28:28")
		end
		names[#names + 1] = key
	end

	-- Split into dropdown submenus (the menu gets unwieldy with too many entries)
	local per = Dogesmile_PerMenu
	local pages = math.ceil(#names / per)
	for p = 1, pages do
		local chunk = {}
		for i = (p - 1) * per + 1, math.min(p * per, #names) do
			chunk[#chunk + 1] = names[i]
		end
		TwitchEmotes:AddCategory(pages > 1 and (CATEGORY .. " " .. p) or CATEGORY, chunk)
	end

	-- TwitchEmotes builds its autocomplete list before we load, so add ours to it
	if AllTwitchEmoteNames and #AllTwitchEmoteNames > 0 then
		for _, key in ipairs(names) do
			AllTwitchEmoteNames[#AllTwitchEmoteNames + 1] = key
		end
		table.sort(AllTwitchEmoteNames)
	end
end

-- TwitchEmotes only animates textures inside its own folder; animate ours too.
local function escpattern(s)
	return (s:gsub("[%%%^%$%(%)%.%[%]%*%+%-%?]", "%%%0"))
end
local PATTERN = "(|T" .. escpattern(BASE) .. ".-|t)"
local PATH_PATTERN = "|T(" .. escpattern(BASE) .. ".-%.tga).-|t"

local function Animate(fontstring, w, h)
	local txt = fontstring:GetText()
	if txt == nil or (issecretvalue and issecretvalue(txt)) then
		return
	end
	for texstr in txt:gmatch(PATTERN) do
		local path = texstr:match(PATH_PATTERN)
		local animdata = path and TwitchEmotes_animation_metadata[path]
		if animdata then
			local frame = TwitchEmotes_GetCurrentFrameNum(animdata)
			local new
			if w or h then
				new = TwitchEmotes_BuildEmoteFrameStringWithDimensions(path, animdata, frame, w, h)
			else
				new = TwitchEmotes_BuildEmoteFrameString(path, animdata, frame)
			end
			local nTxt = txt:gsub(escpattern(texstr), (new:gsub("%%", "%%%%")))
			if fontstring.messageInfo ~= nil then
				fontstring.messageInfo.message = nTxt
			end
			fontstring:SetText(nTxt)
			txt = nTxt
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, name)
	if name ~= ADDON_NAME then
		return
	end
	self:UnregisterEvent("ADDON_LOADED")
	Register()
	hooksecurefunc("TwitchEmotesAnimator_UpdateEmoteInFontString", Animate)
end)
