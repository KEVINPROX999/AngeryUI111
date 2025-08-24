--[[
	Angeryy05 UI Library - Compiled Release
	Version: 1.0.0
	Author: Angeryy05
	
	Compiled build for easy distribution
	GitHub: https://github.com/KEVINPROX999/AngeryUI111
	
	Usage:
	local Angeryy05 = loadstring(game:HttpGet("https://github.com/KEVINPROX999/AngeryUI111/releases/latest/download/Angeryy05.luau"))()
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ============================================================================
-- SIGNAL MODULE (INLINE)
-- ============================================================================

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_connections = {}
	}, Signal)
end

function Signal:Connect(callback)
	assert(typeof(callback) == "function", "Callback must be a function")
	
	local connection = {
		Connected = true,
		_callback = callback,
		_signal = self
	}
	
	function connection:Disconnect()
		if self.Connected then
			self.Connected = false
			local index = table.find(self._signal._connections, self)
			if index then
				table.remove(self._signal._connections, index)
			end
		end
	end
	
	table.insert(self._connections, connection)
	return connection
end

function Signal:Fire(...)
	local connections = table.clone(self._connections)
	for _, connection in ipairs(connections) do
		if connection.Connected then
			task.spawn(connection._callback, ...)
		end
	end
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:DisconnectAll()
	for _, connection in ipairs(self._connections) do
		connection.Connected = false
	end
	table.clear(self._connections)
end

-- ============================================================================
-- TWEEN MODULE (INLINE)
-- ============================================================================

local Tween = {}

Tween.EasingStyles = {
	Linear = Enum.EasingStyle.Linear,
	Quad = Enum.EasingStyle.Quad,
	Cubic = Enum.EasingStyle.Cubic,
	Quart = Enum.EasingStyle.Quart,
	Quint = Enum.EasingStyle.Quint,
	Sine = Enum.EasingStyle.Sine,
	Expo = Enum.EasingStyle.Exponential,
	Circ = Enum.EasingStyle.Circular,
	Back = Enum.EasingStyle.Back,
	Elastic = Enum.EasingStyle.Elastic,
	Bounce = Enum.EasingStyle.Bounce
}

function Tween:Create(instance, duration, properties, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or 0.3,
		easingStyle or Enum.EasingStyle.Quart,
		easingDirection or Enum.EasingDirection.Out
	)
	
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function Tween:Smooth(instance, duration, properties, callback)
	local tween = self:Create(instance, duration, properties, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	return tween
end

function Tween:Spring(instance, duration, properties, callback)
	local tween = self:Create(instance, duration, properties, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	return tween
end

function Tween:Bounce(instance, duration, properties, callback)
	local tween = self:Create(instance, duration, properties, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	return tween
end

-- ============================================================================
-- ICONS MODULE (INLINE)
-- ============================================================================

local Icons = {
	["home"] = "rbxassetid://10723424505",
	["settings"] = "rbxassetid://10734950309",
	["user"] = "rbxassetid://10734929811",
	["users"] = "rbxassetid://10734929563",
	["search"] = "rbxassetid://10734898308",
	["menu"] = "rbxassetid://10734896952",
	["close"] = "rbxassetid://10747384394",
	["minimize"] = "rbxassetid://10734897406",
	["maximize"] = "rbxassetid://10734896694",
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
	["arrow-left"] = "rbxassetid://10734895983",
	["arrow-right"] = "rbxassetid://10734896090",
	["arrow-up"] = "rbxassetid://10734896197",
	["arrow-down"] = "rbxassetid://10734895894",
	["chevron-left"] = "rbxassetid://10734896432",
	["chevron-right"] = "rbxassetid://10734896523",
	["chevron-up"] = "rbxassetid://10734896611",
	["chevron-down"] = "rbxassetid://10734896344",
	["check"] = "rbxassetid://10734896269",
	["x"] = "rbxassetid://10734929764",
	["alert-triangle"] = "rbxassetid://10734895841",
	["alert-circle"] = "rbxassetid://10734895789",
	["info"] = "rbxassetid://10734898155",
	["help-circle"] = "rbxassetid://10734898050",
	["play"] = "rbxassetid://10734925180",
	["pause"] = "rbxassetid://10734925025",
	["stop"] = "rbxassetid://10734925681",
	["skip-forward"] = "rbxassetid://10734925462",
	["skip-back"] = "rbxassetid://10734925374",
	["volume"] = "rbxassetid://10734929697",
	["volume-mute"] = "rbxassetid://10734929600",
	["file"] = "rbxassetid://10734897859",
	["folder"] = "rbxassetid://10734897953",
	["folder-open"] = "rbxassetid://10734898005",
	["download"] = "rbxassetid://10734896926",
	["upload"] = "rbxassetid://10734929811",
	["mail"] = "rbxassetid://10734924985",
	["message-circle"] = "rbxassetid://10734924930",
	["phone"] = "rbxassetid://10734925123",
	["bell"] = "rbxassetid://10734896293",
	["eye"] = "rbxassetid://10734897698",
	["eye-off"] = "rbxassetid://10734897595",
	["lock"] = "rbxassetid://10734924742",
	["unlock"] = "rbxassetid://10734929811",
	["sun"] = "rbxassetid://10734925751",
	["moon"] = "rbxassetid://10734924970",
	["heart"] = "rbxassetid://10734898098",
	["star"] = "rbxassetid://10734925681",
	["bookmark"] = "rbxassetid://10734896382",
	["share"] = "rbxassetid://10734925336",
	["link"] = "rbxassetid://10734924742",
	["external-link"] = "rbxassetid://10734897536",
	["refresh"] = "rbxassetid://10734925268",
	["rotate"] = "rbxassetid://10734925316",
	["grid"] = "rbxassetid://10734898005",
	["list"] = "rbxassetid://10734924742",
	["layout"] = "rbxassetid://10734924742",
	["sidebar"] = "rbxassetid://10734925462",
	["calendar"] = "rbxassetid://10734896432",
	["clock"] = "rbxassetid://10734896611",
	["map"] = "rbxassetid://10734924930",
	["globe"] = "rbxassetid://10734898005",
	["camera"] = "rbxassetid://10734896432",
	["image"] = "rbxassetid://10734898155",
	["video"] = "rbxassetid://10734929697",
	["music"] = "rbxassetid://10734924985",
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

-- ============================================================================
-- THEMES (INLINE)
-- ============================================================================

local Themes = {
	Names = {"Angeryy05Dark", "Angeryy05Light", "CyberPunk", "Gradient", "Minimalist"},
	Current = "Angeryy05Dark",
	
	-- Theme data
	ThemeData = {
		Angeryy05Dark = {
			Accent = Color3.fromRGB(138, 43, 226),
			AccentHover = Color3.fromRGB(155, 89, 232),
			Background = Color3.fromRGB(18, 18, 18),
			BackgroundSecondary = Color3.fromRGB(25, 25, 25),
			BackgroundTertiary = Color3.fromRGB(32, 32, 32),
			WindowBackground = Color3.fromRGB(22, 22, 22),
			WindowBorder = Color3.fromRGB(45, 45, 45),
			TitleBar = Color3.fromRGB(28, 28, 28),
			TitleBarLine = Color3.fromRGB(50, 50, 50),
			Tab = Color3.fromRGB(35, 35, 35),
			TabHover = Color3.fromRGB(40, 40, 40),
			TabActive = Color3.fromRGB(138, 43, 226),
			TabText = Color3.fromRGB(200, 200, 200),
			TabTextActive = Color3.fromRGB(255, 255, 255),
			Element = Color3.fromRGB(40, 40, 40),
			ElementBorder = Color3.fromRGB(55, 55, 55),
			ElementHover = Color3.fromRGB(50, 50, 50),
			ElementActive = Color3.fromRGB(138, 43, 226),
			ElementTransparency = 0.05,
			Button = Color3.fromRGB(45, 45, 45),
			ButtonHover = Color3.fromRGB(55, 55, 55),
			ButtonActive = Color3.fromRGB(138, 43, 226),
			ButtonBorder = Color3.fromRGB(70, 70, 70),
			Input = Color3.fromRGB(40, 40, 40),
			InputFocused = Color3.fromRGB(50, 50, 50),
			InputBorder = Color3.fromRGB(60, 60, 60),
			InputBorderFocused = Color3.fromRGB(138, 43, 226),
			Toggle = Color3.fromRGB(60, 60, 60),
			ToggleActive = Color3.fromRGB(138, 43, 226),
			ToggleSlider = Color3.fromRGB(200, 200, 200),
			Slider = Color3.fromRGB(60, 60, 60),
			SliderActive = Color3.fromRGB(138, 43, 226),
			SliderRail = Color3.fromRGB(50, 50, 50),
			Dropdown = Color3.fromRGB(40, 40, 40),
			DropdownHover = Color3.fromRGB(50, 50, 50),
			DropdownActive = Color3.fromRGB(138, 43, 226),
			DropdownBorder = Color3.fromRGB(60, 60, 60),
			DropdownOption = Color3.fromRGB(45, 45, 45),
			DropdownOptionHover = Color3.fromRGB(55, 55, 55),
			Text = Color3.fromRGB(255, 255, 255),
			TextSecondary = Color3.fromRGB(180, 180, 180),
			TextMuted = Color3.fromRGB(140, 140, 140),
			TextDisabled = Color3.fromRGB(100, 100, 100),
			Success = Color3.fromRGB(34, 197, 94),
			Warning = Color3.fromRGB(251, 191, 36),
			Error = Color3.fromRGB(239, 68, 68),
			Info = Color3.fromRGB(59, 130, 246),
			Dialog = Color3.fromRGB(30, 30, 30),
			DialogBorder = Color3.fromRGB(60, 60, 60),
			DialogButton = Color3.fromRGB(45, 45, 45),
			DialogButtonHover = Color3.fromRGB(55, 55, 55),
			Notification = Color3.fromRGB(35, 35, 35),
			NotificationBorder = Color3.fromRGB(70, 70, 70),
			Glass = Color3.fromRGB(30, 30, 30),
			GlassBorder = Color3.fromRGB(80, 80, 80),
			Shadow = Color3.fromRGB(0, 0, 0),
			HoverIntensity = 0.1,
		},
		
		Angeryy05Light = {
			Accent = Color3.fromRGB(138, 43, 226),
			AccentHover = Color3.fromRGB(155, 89, 232),
			Background = Color3.fromRGB(250, 250, 250),
			BackgroundSecondary = Color3.fromRGB(245, 245, 245),
			BackgroundTertiary = Color3.fromRGB(240, 240, 240),
			WindowBackground = Color3.fromRGB(255, 255, 255),
			WindowBorder = Color3.fromRGB(220, 220, 220),
			TitleBar = Color3.fromRGB(248, 248, 248),
			TitleBarLine = Color3.fromRGB(230, 230, 230),
			Tab = Color3.fromRGB(240, 240, 240),
			TabHover = Color3.fromRGB(235, 235, 235),
			TabActive = Color3.fromRGB(138, 43, 226),
			TabText = Color3.fromRGB(80, 80, 80),
			TabTextActive = Color3.fromRGB(255, 255, 255),
			Element = Color3.fromRGB(248, 248, 248),
			ElementBorder = Color3.fromRGB(220, 220, 220),
			ElementHover = Color3.fromRGB(240, 240, 240),
			ElementActive = Color3.fromRGB(138, 43, 226),
			ElementTransparency = 0.05,
			Button = Color3.fromRGB(245, 245, 245),
			ButtonHover = Color3.fromRGB(235, 235, 235),
			ButtonActive = Color3.fromRGB(138, 43, 226),
			ButtonBorder = Color3.fromRGB(200, 200, 200),
			Input = Color3.fromRGB(250, 250, 250),
			InputFocused = Color3.fromRGB(255, 255, 255),
			InputBorder = Color3.fromRGB(220, 220, 220),
			InputBorderFocused = Color3.fromRGB(138, 43, 226),
			Toggle = Color3.fromRGB(220, 220, 220),
			ToggleActive = Color3.fromRGB(138, 43, 226),
			ToggleSlider = Color3.fromRGB(255, 255, 255),
			Slider = Color3.fromRGB(220, 220, 220),
			SliderActive = Color3.fromRGB(138, 43, 226),
			SliderRail = Color3.fromRGB(230, 230, 230),
			Dropdown = Color3.fromRGB(250, 250, 250),
			DropdownHover = Color3.fromRGB(240, 240, 240),
			DropdownActive = Color3.fromRGB(138, 43, 226),
			DropdownBorder = Color3.fromRGB(220, 220, 220),
			DropdownOption = Color3.fromRGB(245, 245, 245),
			DropdownOptionHover = Color3.fromRGB(235, 235, 235),
			Text = Color3.fromRGB(30, 30, 30),
			TextSecondary = Color3.fromRGB(80, 80, 80),
			TextMuted = Color3.fromRGB(120, 120, 120),
			TextDisabled = Color3.fromRGB(160, 160, 160),
			Success = Color3.fromRGB(34, 197, 94),
			Warning = Color3.fromRGB(251, 191, 36),
			Error = Color3.fromRGB(239, 68, 68),
			Info = Color3.fromRGB(59, 130, 246),
			Dialog = Color3.fromRGB(255, 255, 255),
			DialogBorder = Color3.fromRGB(220, 220, 220),
			DialogButton = Color3.fromRGB(245, 245, 245),
			DialogButtonHover = Color3.fromRGB(235, 235, 235),
			Notification = Color3.fromRGB(255, 255, 255),
			NotificationBorder = Color3.fromRGB(220, 220, 220),
			Glass = Color3.fromRGB(255, 255, 255),
			GlassBorder = Color3.fromRGB(200, 200, 200),
			Shadow = Color3.fromRGB(0, 0, 0),
			HoverIntensity = 0.05,
		},
		
		CyberPunk = {
			Accent = Color3.fromRGB(0, 255, 255),
			AccentHover = Color3.fromRGB(64, 255, 255),
			Background = Color3.fromRGB(8, 8, 20),
			BackgroundSecondary = Color3.fromRGB(15, 15, 30),
			BackgroundTertiary = Color3.fromRGB(20, 20, 40),
			WindowBackground = Color3.fromRGB(12, 12, 25),
			WindowBorder = Color3.fromRGB(0, 255, 255),
			TitleBar = Color3.fromRGB(18, 18, 35),
			TitleBarLine = Color3.fromRGB(0, 200, 200),
			Tab = Color3.fromRGB(25, 25, 45),
			TabHover = Color3.fromRGB(35, 35, 55),
			TabActive = Color3.fromRGB(0, 255, 255),
			TabText = Color3.fromRGB(150, 255, 255),
			TabTextActive = Color3.fromRGB(0, 0, 0),
			Element = Color3.fromRGB(30, 30, 50),
			ElementBorder = Color3.fromRGB(0, 180, 180),
			ElementHover = Color3.fromRGB(40, 40, 60),
			ElementActive = Color3.fromRGB(0, 255, 255),
			ElementTransparency = 0.1,
			Button = Color3.fromRGB(35, 35, 55),
			ButtonHover = Color3.fromRGB(45, 45, 65),
			ButtonActive = Color3.fromRGB(0, 255, 255),
			ButtonBorder = Color3.fromRGB(0, 200, 200),
			Input = Color3.fromRGB(25, 25, 45),
			InputFocused = Color3.fromRGB(30, 30, 50),
			InputBorder = Color3.fromRGB(0, 150, 150),
			InputBorderFocused = Color3.fromRGB(0, 255, 255),
			Toggle = Color3.fromRGB(40, 40, 60),
			ToggleActive = Color3.fromRGB(0, 255, 255),
			ToggleSlider = Color3.fromRGB(150, 255, 255),
			Slider = Color3.fromRGB(40, 40, 60),
			SliderActive = Color3.fromRGB(0, 255, 255),
			SliderRail = Color3.fromRGB(30, 30, 50),
			Dropdown = Color3.fromRGB(25, 25, 45),
			DropdownHover = Color3.fromRGB(35, 35, 55),
			DropdownActive = Color3.fromRGB(0, 255, 255),
			DropdownBorder = Color3.fromRGB(0, 180, 180),
			DropdownOption = Color3.fromRGB(30, 30, 50),
			DropdownOptionHover = Color3.fromRGB(40, 40, 60),
			Text = Color3.fromRGB(200, 255, 255),
			TextSecondary = Color3.fromRGB(150, 220, 220),
			TextMuted = Color3.fromRGB(100, 180, 180),
			TextDisabled = Color3.fromRGB(80, 120, 120),
			Success = Color3.fromRGB(0, 255, 128),
			Warning = Color3.fromRGB(255, 255, 0),
			Error = Color3.fromRGB(255, 0, 128),
			Info = Color3.fromRGB(0, 200, 255),
			Dialog = Color3.fromRGB(18, 18, 35),
			DialogBorder = Color3.fromRGB(0, 200, 200),
			DialogButton = Color3.fromRGB(35, 35, 55),
			DialogButtonHover = Color3.fromRGB(45, 45, 65),
			Notification = Color3.fromRGB(20, 20, 40),
			NotificationBorder = Color3.fromRGB(0, 255, 255),
			Glass = Color3.fromRGB(20, 20, 40),
			GlassBorder = Color3.fromRGB(0, 180, 180),
			Shadow = Color3.fromRGB(0, 50, 50),
			HoverIntensity = 0.15,
		}
	}
}

function Themes.GetTheme(name)
	local themeName = name or Themes.Current
	return Themes.ThemeData[themeName] or Themes.ThemeData["Angeryy05Dark"]
end

function Themes.SetTheme(name)
	if Themes.ThemeData[name] then
		Themes.Current = name
		return true
	end
	return false
end

function Themes.GetThemeNames()
	return Themes.Names
end

-- ============================================================================
-- CREATOR MODULE (INLINE)
-- ============================================================================

local Creator = {
	Registry = {},
	Connections = {},
	
	New = function(className, properties)
		local instance = Instance.new(className)
		
		-- Default properties
		local defaults = {
			Frame = {BorderSizePixel = 0},
			TextLabel = {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				RichText = true
			},
			TextButton = {
				AutoButtonColor = false,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				RichText = true
			},
			UICorner = {CornerRadius = UDim.new(0, 8)},
			UIStroke = {Thickness = 1}
		}
		
		-- Apply defaults
		if defaults[className] then
			for prop, value in pairs(defaults[className]) do
				instance[prop] = value
			end
		end
		
		-- Apply custom properties
		if properties then
			for prop, value in pairs(properties) do
				if prop == "Parent" then
					continue -- Set parent last
				elseif prop:sub(1, 2) == "On" and instance[prop:sub(3)] then
					local connection = instance[prop:sub(3)]:Connect(value)
					table.insert(Creator.Connections, connection)
				else
					instance[prop] = value
				end
			end
			
			if properties.Parent then
				instance.Parent = properties.Parent
			end
		end
		
		table.insert(Creator.Registry, instance)
		return instance
	end,
	
	CreateButton = function(properties)
		local button = Creator.New("TextButton", properties)
		local corner = Creator.New("UICorner", {
			CornerRadius = UDim.new(0, properties.CornerRadius or 8),
			Parent = button
		})
		return button
	end,
	
	Disconnect = function()
		for _, connection in ipairs(Creator.Connections) do
			if connection.Connected then
				connection:Disconnect()
			end
		end
		table.clear(Creator.Connections)
		table.clear(Creator.Registry)
	end
}

-- ============================================================================
-- MAIN LIBRARY
-- ============================================================================

-- Constants
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Get proper GUI parent
local function GetGUIParent()
	local success, result = pcall(function()
		return gethui and gethui() or get_hidden_ui and get_hidden_ui()
	end)
	
	if success and result then
		return result
	end
	
	success, result = pcall(function()
		CoreGui:GetFullName()
		return CoreGui
	end)
	
	if success and result then
		return result
	end
	
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- Main ScreenGui container
local MainGui = Creator.New("ScreenGui", {
	Name = "Angeryy05_" .. HttpService:GenerateGUID(false):sub(1, 8),
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	Parent = GetGUIParent()
})

-- Main Library
local Angeryy05 = {
	Version = "1.0.0",
	Author = "Angeryy05",
	
	-- Core properties
	WindowCount = 0,
	OpenWindows = {},
	Options = {},
	Themes = Themes.Names,
	
	-- Events
	OnUnload = Signal.new(),
	ThemeChanged = Signal.new(),
	WindowCreated = Signal.new(),
	
	-- Settings
	CurrentTheme = "Angeryy05Dark",
	UseModernAnimations = true,
	GlobalCornerRadius = 12,
	AnimationSpeed = 0.3,
	
	-- Utilities
	Utilities = {
		Creator = Creator,
		Icons = Icons,
		Themes = Themes,
		Tween = Tween,
		Signal = Signal
	},
	
	-- Internal
	Connections = {},
	Loaded = true,
	Unloaded = false
}

-- Utility functions
function Angeryy05.Utilities:GetScreenSize()
	return Camera.ViewportSize
end

function Angeryy05.Utilities:CreateRipple(button, rippleColor)
	rippleColor = rippleColor or Color3.fromRGB(255, 255, 255)
	
	button.ClipsDescendants = true
	
	button.MouseButton1Down:Connect(function()
		local ripple = Creator.New("Frame", {
			Name = "Ripple",
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.fromOffset(Mouse.X - button.AbsolutePosition.X, Mouse.Y - button.AbsolutePosition.Y),
			BackgroundColor3 = rippleColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			Parent = button
		})
		
		Creator.New("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = ripple
		})
		
		local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
		
		TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(size, size),
			Position = UDim2.fromOffset((Mouse.X - button.AbsolutePosition.X) - size/2, (Mouse.Y - button.AbsolutePosition.Y) - size/2),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.6)
		ripple:Destroy()
	end)
end

-- Safe callback execution
function Angeryy05:SafeCallback(callback, ...)
	if typeof(callback) == "function" then
		local success, result = pcall(callback, ...)
		if not success then
			warn("Angeryy05 Callback Error:", result)
		end
		return success, result
	end
	return false, "Invalid callback"
end

-- Window creation
function Angeryy05:CreateWindow(config)
	config = config or {}
	
	-- Get theme
	local theme = Themes.GetTheme(config.Theme or Angeryy05.CurrentTheme)
	
	-- Create main window frame
	local WindowFrame = Creator.New("Frame", {
		Name = "Angeryy05Window",
		Size = config.Size or UDim2.fromOffset(600, 400),
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = config.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.WindowBackground,
		Parent = MainGui
	})
	
	local WindowCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = WindowFrame
	})
	
	local WindowBorder = Creator.New("UIStroke", {
		Color = theme.WindowBorder,
		Thickness = 1,
		Parent = WindowFrame
	})
	
	-- Title bar
	local TitleBar = Creator.New("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = theme.TitleBar,
		Parent = WindowFrame
	})
	
	local TitleBarCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = TitleBar
	})
	
	-- Window title
	local WindowTitle = Creator.New("TextLabel", {
		Name = "WindowTitle",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.fromOffset(15, 0),
		Text = config.Title or "Angeryy05 Window",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})
	
	-- Close button
	local CloseButton = Creator.CreateButton({
		Name = "CloseButton",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = theme.Error,
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Parent = TitleBar
	})
	
	-- Content area
	local ContentArea = Creator.New("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -20, 1, -60),
		Position = UDim2.fromOffset(10, 50),
		BackgroundColor3 = theme.Background,
		Parent = WindowFrame
	})
	
	local ContentCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = ContentArea
	})
	
	-- Tab container
	local TabContainer = Creator.New("Frame", {
		Name = "TabContainer",
		Size = UDim2.new(0, 180, 1, 0),
		BackgroundColor3 = theme.BackgroundSecondary,
		Parent = ContentArea
	})
	
	local TabContainerCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = TabContainer
	})
	
	-- Tab list
	local TabList = Creator.New("ScrollingFrame", {
		Name = "TabList",
		Size = UDim2.new(1, 0, 1, -10),
		Position = UDim2.fromOffset(0, 5),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		Parent = TabContainer
	})
	
	local TabListLayout = Creator.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5),
		Parent = TabList
	})
	
	-- Content container
	local TabContentContainer = Creator.New("Frame", {
		Name = "TabContentContainer",
		Size = UDim2.new(1, -190, 1, 0),
		Position = UDim2.fromOffset(190, 0),
		BackgroundTransparency = 1,
		Parent = ContentArea
	})
	
	-- Window object
	local Window = {
		Title = config.Title or "Angeryy05 Window",
		Frame = WindowFrame,
		TitleBar = TitleBar,
		ContentArea = ContentArea,
		TabContainer = TabContainer,
		TabContentContainer = TabContentContainer,
		Tabs = {},
		CurrentTab = nil
	}
	
	-- Window dragging
	local dragging = false
	local dragInput = nil
	local mousePos = nil
	local framePos = nil
	
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = WindowFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			WindowFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
	
	-- Close button
	CloseButton.MouseButton1Click:Connect(function()
		TweenService:Create(WindowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.3)
		WindowFrame:Destroy()
	end)
	
	-- Tab creation
	function Window:CreateTab(tabConfig)
		tabConfig = tabConfig or {}
		
		local theme = Themes.GetTheme(Angeryy05.CurrentTheme)
		
		-- Create tab button
		local TabButton = Creator.CreateButton({
			Name = "TabButton",
			Size = UDim2.new(1, -10, 0, 35),
			BackgroundColor3 = theme.Tab,
			Text = tabConfig.Title or "Tab",
			TextColor3 = theme.TabText,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			Parent = TabList
		})
		
		-- Create tab content
		local TabContent = Creator.New("ScrollingFrame", {
			Name = "TabContent",
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.fromOffset(5, 5),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.fromOffset(0, 0),
			Visible = false,
			Parent = TabContentContainer
		})
		
		local TabContentLayout = Creator.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			Parent = TabContent
		})
		
		-- Tab object
		local Tab = {
			Title = tabConfig.Title or "Tab",
			Button = TabButton,
			Content = TabContent,
			Active = false,
			Elements = {}
		}
		
		-- Tab activation
		function Tab:Activate()
			-- Deactivate other tabs
			for _, otherTab in pairs(Window.Tabs) do
				if otherTab ~= Tab then
					otherTab.Active = false
					otherTab.Content.Visible = false
					TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {
						BackgroundColor3 = theme.Tab
					}):Play()
				end
			end
			
			Tab.Active = true
			Tab.Content.Visible = true
			Window.CurrentTab = Tab
			
			TweenService:Create(TabButton, TweenInfo.new(0.2), {
				BackgroundColor3 = theme.TabActive
			}):Play()
		end
		
		-- Tab click
		TabButton.MouseButton1Click:Connect(function()
			Tab:Activate()
		end)
		
		-- Element creation functions...
		function Tab:CreateButton(buttonConfig)
			buttonConfig = buttonConfig or {}
			
			local ButtonFrame = Creator.CreateButton({
				Name = "ButtonFrame",
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = theme.Button,
				Text = buttonConfig.Title or "Button",
				TextColor3 = theme.Text,
				Font = Enum.Font.GothamMedium,
				Parent = TabContent
			})
			
			if buttonConfig.Callback then
				ButtonFrame.MouseButton1Click:Connect(function()
					Angeryy05:SafeCallback(buttonConfig.Callback)
				end)
			end
			
			-- Update canvas size
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
			
			return {
				Frame = ButtonFrame,
				SetTitle = function(self, title)
					ButtonFrame.Text = title
				end
			}
		end
		
		function Tab:CreateToggle(toggleConfig)
			toggleConfig = toggleConfig or {}
			
			local ToggleFrame = Creator.New("Frame", {
				Name = "ToggleFrame",
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = theme.Element,
				Parent = TabContent
			})
			
			local ToggleCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(0, 8),
				Parent = ToggleFrame
			})
			
			local ToggleTitle = Creator.New("TextLabel", {
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.fromOffset(10, 0),
				Text = toggleConfig.Title or "Toggle",
				TextColor3 = theme.Text,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ToggleFrame
			})
			
			local ToggleSwitch = Creator.New("Frame", {
				Size = UDim2.fromOffset(40, 20),
				Position = UDim2.new(1, -50, 0.5, -10),
				BackgroundColor3 = theme.Toggle,
				Parent = ToggleFrame
			})
			
			local ToggleSwitchCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = ToggleSwitch
			})
			
			local ToggleSlider = Creator.New("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromOffset(2, 2),
				BackgroundColor3 = theme.ToggleSlider,
				Parent = ToggleSwitch
			})
			
			local ToggleSliderCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = ToggleSlider
			})
			
			local Toggle = {
				Value = toggleConfig.Default or false,
				Callback = toggleConfig.Callback
			}
			
			function Toggle:SetValue(value)
				Toggle.Value = value
				
				if value then
					TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
						BackgroundColor3 = theme.ToggleActive
					}):Play()
					TweenService:Create(ToggleSlider, TweenInfo.new(0.2), {
						Position = UDim2.fromOffset(22, 2)
					}):Play()
				else
					TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
						BackgroundColor3 = theme.Toggle
					}):Play()
					TweenService:Create(ToggleSlider, TweenInfo.new(0.2), {
						Position = UDim2.fromOffset(2, 2)
					}):Play()
				end
				
				if Toggle.Callback then
					Angeryy05:SafeCallback(Toggle.Callback, value)
				end
			end
			
			function Toggle:GetValue()
				return Toggle.Value
			end
			
			-- Initial state
			Toggle:SetValue(Toggle.Value)
			
			-- Click handler
			ToggleFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Toggle:SetValue(not Toggle.Value)
				end
			end)
			
			-- Update canvas size
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
			
			return Toggle
		end
		
		function Tab:CreateParagraph(paragraphConfig)
			paragraphConfig = paragraphConfig or {}
			
			local ParagraphFrame = Creator.New("Frame", {
				Name = "ParagraphFrame",
				Size = UDim2.new(1, 0, 0, 60),
				BackgroundColor3 = theme.Element,
				Parent = TabContent
			})
			
			local ParagraphCorner = Creator.New("UICorner", {
				CornerRadius = UDim.new(0, 8),
				Parent = ParagraphFrame
			})
			
			if paragraphConfig.Title then
				local ParagraphTitle = Creator.New("TextLabel", {
					Size = UDim2.new(1, -20, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					Text = paragraphConfig.Title,
					TextColor3 = theme.Text,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = ParagraphFrame
				})
			end
			
			local ParagraphContent = Creator.New("TextLabel", {
				Size = UDim2.new(1, -20, 0, 30),
				Position = UDim2.fromOffset(10, paragraphConfig.Title and 25 or 10),
				Text = paragraphConfig.Content or "Paragraph content",
				TextColor3 = theme.TextSecondary,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = ParagraphFrame
			})
			
			-- Update canvas size
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
			
			return {
				Frame = ParagraphFrame,
				SetContent = function(self, content)
					ParagraphContent.Text = content
				end
			}
		end
		
		-- Update canvas size when layout changes
		TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContent.CanvasSize = UDim2.fromOffset(0, TabContentLayout.AbsoluteContentSize.Y)
		end)
		
		-- Add to window
		table.insert(Window.Tabs, Tab)
		
		-- Auto-activate first tab
		if #Window.Tabs == 1 then
			Tab:Activate()
		end
		
		-- Update tab list canvas
		TabList.CanvasSize = UDim2.fromOffset(0, TabListLayout.AbsoluteContentSize.Y)
		
		return Tab
	end
	
	-- Window functions
	function Window:SetTitle(title)
		Window.Title = title
		WindowTitle.Text = title
	end
	
	function Window:Close()
		WindowFrame:Destroy()
	end
	
	-- Add to library
	Angeryy05.WindowCount = Angeryy05.WindowCount + 1
	table.insert(Angeryy05.OpenWindows, Window)
	Angeryy05.WindowCreated:Fire(Window)
	
	return Window
end

-- Notification system
function Angeryy05:Notify(config)
	config = config or {}
	
	local theme = Themes.GetTheme(Angeryy05.CurrentTheme)
	
	-- Type colors
	local typeColors = {
		info = theme.Info,
		success = theme.Success,
		warning = theme.Warning,
		error = theme.Error
	}
	
	-- Create notification
	local NotificationFrame = Creator.New("Frame", {
		Name = "Notification",
		Size = UDim2.fromOffset(300, 70),
		Position = UDim2.new(1, -320, 0, 20),
		BackgroundColor3 = theme.Notification,
		Parent = MainGui
	})
	
	local NotificationCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = NotificationFrame
	})
	
	local NotificationBorder = Creator.New("UIStroke", {
		Color = theme.NotificationBorder,
		Thickness = 1,
		Parent = NotificationFrame
	})
	
	-- Accent bar
	local AccentBar = Creator.New("Frame", {
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = typeColors[config.Type] or theme.Info,
		Parent = NotificationFrame
	})
	
	local AccentBarCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 2),
		Parent = AccentBar
	})
	
	-- Title
	local NotificationTitle = Creator.New("TextLabel", {
		Size = UDim2.new(1, -50, 0, 20),
		Position = UDim2.fromOffset(15, 10),
		Text = config.Title or "Notification",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = NotificationFrame
	})
	
	-- Content
	local NotificationContent = Creator.New("TextLabel", {
		Size = UDim2.new(1, -50, 0, 30),
		Position = UDim2.fromOffset(15, 30),
		Text = config.Content or "Notification content",
		TextColor3 = theme.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = NotificationFrame
	})
	
	-- Close button
	local CloseButton = Creator.CreateButton({
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -25, 0, 5),
		BackgroundColor3 = Color3.fromRGB(255, 60, 60),
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12,
		Parent = NotificationFrame
	})
	
	-- Animate in
	NotificationFrame.Position = UDim2.new(1, 20, 0, 20)
	TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(1, -320, 0, 20)
	}):Play()
	
	-- Auto close
	local function closeNotification()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(1, 20, 0, 20),
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.3)
		NotificationFrame:Destroy()
	end
	
	CloseButton.MouseButton1Click:Connect(closeNotification)
	
	if config.Duration then
		task.delay(config.Duration, closeNotification)
	end
	
	return {
		Frame = NotificationFrame,
		Close = closeNotification
	}
end

-- Theme management
function Angeryy05:SetTheme(themeName)
	if table.find(self.Themes, themeName) then
		self.CurrentTheme = themeName
		Themes.SetTheme(themeName)
		self.ThemeChanged:Fire(themeName)
		return true
	end
	return false
end

function Angeryy05:GetTheme()
	return self.CurrentTheme
end

function Angeryy05:GetAvailableThemes()
	return self.Themes
end

-- Destroy library
function Angeryy05:Destroy()
	if not self.Unloaded then
		self.Unloaded = true
		self.Loaded = false
		
		self.OnUnload:Fire()
		
		Creator.Disconnect()
		
		TweenService:Create(MainGui, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.5)
		MainGui:Destroy()
	end
end

-- Initialize
Angeryy05:SetTheme(Angeryy05.CurrentTheme)

-- Console info
print("🎉 Angeryy05 UI Library v" .. Angeryy05.Version .. " loaded successfully!")
print("📝 GitHub: https://github.com/KEVINPROX999/AngeryUI111")
print("👤 Author: " .. Angeryy05.Author)

return Angeryy05
