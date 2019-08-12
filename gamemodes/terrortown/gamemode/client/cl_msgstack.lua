---
-- @class MSTACK
-- @author saibotk
-- @desc HUD stuff similar to weapon/ammo pickups but for game status messages

MSTACK = {}
MSTACK.msgs = {}
MSTACK.last = 0

-- Localise some libs
local table = table
local surface = surface
local net = net
local ipairs = ipairs

local traitor_msg_bg = Color(255, 0, 0, 255)

---
-- Adds a colored message into the message stack
-- @param string text
-- @param Color c
-- @realm client
function MSTACK:AddColoredMessage(text, c)
	local item = {}
	item.text = text
	item.col = c

	self:AddMessageEx(item)
end

---
-- Adds a message with a colored background into the message stack
-- @param string text
-- @param Color bg_clr
-- @realm client
function MSTACK:AddColoredBgMessage(text, bg_clr)
	local item = {}
	item.text = text
	item.bg = bg_clr

	self:AddMessageEx(item)
end

---
-- Adds a message with an image into the message stack
-- @param string text
-- @param Material image
-- @param string title
-- @realm client
function MSTACK:AddImagedMessage(text, image, title)
	local item = {}
	item.text = text
	item.title = title
	item.image = image

	self:AddMessageEx(item)
end

---
-- Adds a message with an image into the message stack
-- @param string text
-- @param Color bg_clr
-- @param Material image
-- @param string title
-- @realm client
function MSTACK:AddColoredImagedMessage(text, bg_clr, image, title)
	local item = {}
	item.text = text
	item.title = title
	item.bg = bg_clr
	item.image = image

	self:AddMessageEx(item)
end

---
-- Adds a custom styled message into the message stack
-- @param table item
-- @realm client
-- @internal
-- @todo add table structure
function MSTACK:AddMessageEx(item)
	item.time = CurTime()
	item.sounded = false

	-- Stagger the fading a bit
	if self.last > item.time - 1 then
		item.time = self.last + 1
	end

	-- Insert at the top
	table.insert(self.msgs, 1, item)

	self.last = item.time
end

---
-- Add a given message to the stack, will be rendered in a different color if it
-- is a special traitor-only message that traitors should pay attention to.
-- Use the newer AddColoredMessage if you want special colours.
-- @param string text
-- @param boolean traitor_only
-- @realm client
function MSTACK:AddMessage(text, traitor_only)
	if traitor_only then
		self:AddColoredBgMessage(text, traitor_msg_bg)
	else
		self:AddColoredMessage(text)
	end
end

---
-- Returns a list of lines to wrap the text matching the given width
-- @param string text
-- @param number width
-- @param string font
-- @return table
-- @realm client
function MSTACK:WrapText(text, width, font)
	-- Oh joy, I get to write my own wrapping function. Thanks Lua!
	-- Splits a string into a table of strings that are under the given width.

	surface.SetFont(font or "DefaultBold")

	-- Any wrapping required?
	local w = surface.GetTextSize(text)

	if w <= width then
		return {text} -- Nope, but wrap in table for uniformity
	end

	local words = string.Explode(" ", text) -- No spaces means you're screwed
	local lines = {""}

	for i, wrd in ipairs(words) do
		if i == 1 then
			-- add the first word whether or not it matches the size to prevent
			-- weird empty first lines and ' ' in front of the first line
			lines[1] = wrd

			continue
		end

		local l = #lines
		local added = lines[l] .. " " .. wrd

		w = surface.GetTextSize(added)

		if w > width then
			table.insert(lines, wrd) -- New line needed
		else
			lines[l] = added -- Safe to tack it on
		end
	end

	return lines
end

-- Game state message channel
local function ReceiveGameMsg()
	local text = net.ReadString()
	local special = net.ReadBit() == 1

	print(text)

	MSTACK:AddMessage(text, special)
end
net.Receive("TTT_GameMsg", ReceiveGameMsg)

local function ReceiveCustomMsg()
	local text = net.ReadString()
	local c = Color(255, 255, 255)

	c.r = net.ReadUInt(8)
	c.g = net.ReadUInt(8)
	c.b = net.ReadUInt(8)

	print(text)

	MSTACK:AddColoredMessage(text, c)
end
net.Receive("TTT_GameMsgColor", ReceiveCustomMsg)
