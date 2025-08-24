--[[
	Angeryy05 Icons Module
	Modern icon system with a comprehensive icon library
]]

local Icons = {
	-- Interface Icons
	["home"] = "rbxassetid://10723424505",
	["settings"] = "rbxassetid://10734950309",
	["user"] = "rbxassetid://10734929811",
	["users"] = "rbxassetid://10734929563",
	["search"] = "rbxassetid://10734898308",
	["menu"] = "rbxassetid://10734896952",
	["close"] = "rbxassetid://10747384394",
	["minimize"] = "rbxassetid://10734897406",
	["maximize"] = "rbxassetid://10734896694",
	
	-- Action Icons
	["plus"] = "rbxassetid://10734897263",
	["minus"] = "rbxassetid://10734897004",
	["edit"] = "rbxassetid://10734898214",
	["delete"] = "rbxassetid://10734896849",
	["save"] = "rbxassetid://10734925462",
	["copy"] = "rbxassetid://10734896650",
	["paste"] = "rbxassetid://10734925022",
	["cut"] = "rbxassetid://10734896793",
	["undo"] = "rbxassetid://10734929656",
	["redo"] = "rbxassetid://10734925268",
	
	-- Navigation Icons
	["arrow-left"] = "rbxassetid://10734895983",
	["arrow-right"] = "rbxassetid://10734896090",
	["arrow-up"] = "rbxassetid://10734896197",
	["arrow-down"] = "rbxassetid://10734895894",
	["chevron-left"] = "rbxassetid://10734896432",
	["chevron-right"] = "rbxassetid://10734896523",
	["chevron-up"] = "rbxassetid://10734896611",
	["chevron-down"] = "rbxassetid://10734896344",
	
	-- Status Icons
	["check"] = "rbxassetid://10734896269",
	["x"] = "rbxassetid://10734929764",
	["alert-triangle"] = "rbxassetid://10734895841",
	["alert-circle"] = "rbxassetid://10734895789",
	["info"] = "rbxassetid://10734898155",
	["help-circle"] = "rbxassetid://10734898050",
	
	-- Media Icons
	["play"] = "rbxassetid://10734925180",
	["pause"] = "rbxassetid://10734925025",
	["stop"] = "rbxassetid://10734925681",
	["skip-forward"] = "rbxassetid://10734925462",
	["skip-back"] = "rbxassetid://10734925374",
	["volume"] = "rbxassetid://10734929697",
	["volume-mute"] = "rbxassetid://10734929600",
	
	-- File Icons
	["file"] = "rbxassetid://10734897859",
	["folder"] = "rbxassetid://10734897953",
	["folder-open"] = "rbxassetid://10734898005",
	["download"] = "rbxassetid://10734896926",
	["upload"] = "rbxassetid://10734929811",
	
	-- Communication Icons
	["mail"] = "rbxassetid://10734924985",
	["message-circle"] = "rbxassetid://10734924930",
	["phone"] = "rbxassetid://10734925123",
	["bell"] = "rbxassetid://10734896293",
	
	-- Toggle Icons
	["eye"] = "rbxassetid://10734897698",
	["eye-off"] = "rbxassetid://10734897595",
	["lock"] = "rbxassetid://10734924742",
	["unlock"] = "rbxassetid://10734929811",
	["sun"] = "rbxassetid://10734925751",
	["moon"] = "rbxassetid://10734924970",
	
	-- Modern Icons
	["heart"] = "rbxassetid://10734898098",
	["star"] = "rbxassetid://10734925681",
	["bookmark"] = "rbxassetid://10734896382",
	["share"] = "rbxassetid://10734925336",
	["link"] = "rbxassetid://10734924742",
	["external-link"] = "rbxassetid://10734897536",
	["refresh"] = "rbxassetid://10734925268",
	["rotate"] = "rbxassetid://10734925316",
	
	-- Layout Icons
	["grid"] = "rbxassetid://10734898005",
	["list"] = "rbxassetid://10734924742",
	["layout"] = "rbxassetid://10734924742",
	["sidebar"] = "rbxassetid://10734925462",
	
	-- Utility Icons
	["calendar"] = "rbxassetid://10734896432",
	["clock"] = "rbxassetid://10734896611",
	["map"] = "rbxassetid://10734924930",
	["globe"] = "rbxassetid://10734898005",
	["camera"] = "rbxassetid://10734896432",
	["image"] = "rbxassetid://10734898155",
	["video"] = "rbxassetid://10734929697",
	["music"] = "rbxassetid://10734924985",
	
	-- Gaming Icons
	["gamepad"] = "rbxassetid://10734897953",
	["trophy"] = "rbxassetid://10734929811",
	["target"] = "rbxassetid://10734925751",
	["zap"] = "rbxassetid://10734929764"
}

function Icons.Get(name)
	return Icons[name] or Icons["help-circle"]
end

function Icons.GetAll()
	local iconList = {}
	for name, id in pairs(Icons) do
		if typeof(id) == "string" and name ~= "Get" and name ~= "GetAll" then
			table.insert(iconList, name)
		end
	end
	table.sort(iconList)
	return iconList
end

return Icons
