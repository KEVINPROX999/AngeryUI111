--[[
	Angeryy05 Themes System
	Modern theme management for Angeryy05 UI Library
]]

local Themes = {
	Current = "Angeryy05Dark",
	Names = {}
}

-- Theme files
local ThemeModules = {
	["Angeryy05Dark"] = require(script["Angeryy05Dark"]),
	["Angeryy05Light"] = require(script["Angeryy05Light"]),
	["CyberPunk"] = require(script["CyberPunk"]),
	["Gradient"] = require(script["Gradient"]),
	["Minimalist"] = require(script["Minimalist"])
}

-- Populate theme names
for name, _ in pairs(ThemeModules) do
	table.insert(Themes.Names, name)
end
table.sort(Themes.Names)

function Themes.GetTheme(name)
	local themeName = name or Themes.Current
	return ThemeModules[themeName] or ThemeModules["Angeryy05Dark"]
end

function Themes.SetTheme(name)
	if ThemeModules[name] then
		Themes.Current = name
		return true
	end
	return false
end

function Themes.GetThemeNames()
	return Themes.Names
end

return Themes
