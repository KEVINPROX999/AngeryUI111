-- Fluent Renewed UI Library - Combined Single File
-- Original by ActualMasterOogway
-- Combined by AI Assistant for loadstring usage

local FluentRenewed = {}

-- Clone function for security
local function Clone<Original>(ToClone: any & Original): (Original, boolean)
	local Type = typeof(ToClone)

	if Type == "function" and (clonefunc or clonefunction) then
		return (clonefunc or clonefunction)(ToClone), true
	elseif Type == "Instance" and (cloneref or clonereference) then
		return (cloneref or clonereference)(ToClone), true
	elseif Type == "table" then
		local function deepcopy(orig, copies: { [any]: any }?)
			local Copies = copies or {}
			local orig_type, copy = typeof(orig), nil

			if orig_type == 'table' then
				if Copies[orig] then
					copy = Copies[orig]
				else	
					copy = {}
					Copies[orig] = copy

					for orig_key, orig_value in next, orig, nil do
						copy[deepcopy(orig_key, Copies)] = deepcopy(orig_value, Copies)
					end

					(setrawmetatable or setmetatable)(copy, deepcopy((getrawmetatable or getmetatable)(orig), Copies))
				end
			elseif orig_type == 'Instance' or orig_type == 'function' then
				copy = Clone(orig)
			else
				copy = orig
			end

			return copy
		end

		return deepcopy(ToClone), true
	else
		return ToClone, false
	end
end

-- Proper GUI Parent Detection
local function GetProperParent()
	local success, result = pcall(function()
		return (gethui or get_hidden_ui)()
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		local CoreGui = game:GetService("CoreGui")
		CoreGui:GetFullName()
		return CoreGui
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		return (game:IsLoaded() or game.Loaded:Wait() or true) and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		local StarterGui = game:GetService("StarterGui")
		StarterGui:GetFullName()
		return StarterGui
	end)

	if success and result then
		return result
	end

	return error("Seriously bad engine. Can't find a place to store the GUI. Robust code can't help this much incompetence.", 0)
end

-- Services with Clone protection
local MarketplaceService = Clone(game:GetService("MarketplaceService"))
local TweenService = Clone(game:GetService("TweenService"))
local Camera = Clone(game:GetService("Workspace")).CurrentCamera
local Players = Clone(game:GetService("Players"))
local UserInputService = Clone(game:GetService("UserInputService"))
local RunService = Clone(game:GetService("RunService"))
local HttpService = Clone(game:GetService("HttpService"))
local GuiService = Clone(game:GetService("GuiService"))

-- Shared table
local SharedTable = shared or _G or (getgenv and getgenv()) or getfenv(1)
SharedTable.FluentRenewed = SharedTable.FluentRenewed or {}

-- Dependencies: Simplified versions of Flipper, Signal, Ripple
local Flipper = {}
do
	local Spring = {}
	Spring.__index = Spring
	
	function Spring.new(targetValue, options)
		local self = setmetatable({
			_target = targetValue,
			_current = targetValue,
			_velocity = 0,
			_frequency = (options and options.frequency) or 4,
			_damping = (options and options.damping) or 1,
		}, Spring)
		return self
	end
	
	function Spring:step(dt)
		local target = self._target
		local current = self._current
		local velocity = self._velocity
		
		local offset = current - target
		local force = -self._frequency * self._frequency * offset
		local damping = -2 * self._damping * self._frequency * velocity
		
		velocity = velocity + (force + damping) * dt
		current = current + velocity * dt
		
		self._current = current
		self._velocity = velocity
		
		return current
	end
	
	local Instant = {}
	Instant.__index = Instant
	
	function Instant.new(targetValue)
		return setmetatable({
			_target = targetValue,
			_current = targetValue
		}, Instant)
	end
	
	function Instant:step(dt)
		self._current = self._target
		return self._current
	end
	
	local SingleMotor = {}
	SingleMotor.__index = SingleMotor
	
	function SingleMotor.new(initialValue)
		local self = setmetatable({
			_goal = Instant.new(initialValue),
			_value = initialValue,
			_onStep = nil
		}, SingleMotor)
		
		game:GetService("RunService").Heartbeat:Connect(function(dt)
			local newValue = self._goal:step(dt)
			if self._onStep and newValue ~= self._value then
				self._value = newValue
				self._onStep(newValue)
			end
		end)
		
		return self
	end
	
	function SingleMotor:setGoal(goal)
		self._goal = goal
	end
	
	function SingleMotor:onStep(callback)
		self._onStep = callback
	end
	
	function SingleMotor:getValue()
		return self._value
	end
	
	local GroupMotor = {}
	GroupMotor.__index = GroupMotor
	
	function GroupMotor.new(initialValues)
		local self = setmetatable({
			_motors = {},
			_onStep = nil
		}, GroupMotor)
		
		for key, value in pairs(initialValues) do
			self._motors[key] = SingleMotor.new(value)
		end
		
		game:GetService("RunService").Heartbeat:Connect(function(dt)
			local values = {}
			for key, motor in pairs(self._motors) do
				values[key] = motor:getValue()
			end
			if self._onStep then
				self._onStep(values)
			end
		end)
		
		return self
	end
	
	function GroupMotor:setGoal(goals)
		for key, goal in pairs(goals) do
			if self._motors[key] then
				self._motors[key]:setGoal(goal)
			end
		end
	end
	
	function GroupMotor:onStep(callback)
		self._onStep = callback
	end
	
	function GroupMotor:getValue()
		local values = {}
		for key, motor in pairs(self._motors) do
			values[key] = motor:getValue()
		end
		return values
	end
	
	Flipper.Spring = Spring
	Flipper.Instant = Instant
	Flipper.SingleMotor = SingleMotor
	Flipper.GroupMotor = GroupMotor
end

local Signal = {}
do
	Signal.__index = Signal
	
	function Signal.new()
		local self = setmetatable({
			_connections = {}
		}, Signal)
		return self
	end
	
	function Signal:Connect(callback)
		local connection = {
			callback = callback,
			connected = true
		}
		
		table.insert(self._connections, connection)
		
		return {
			Disconnect = function()
				connection.connected = false
				for i, conn in ipairs(self._connections) do
					if conn == connection then
						table.remove(self._connections, i)
						break
					end
				end
			end
		}
	end
	
	function Signal:Fire(...)
		for _, connection in ipairs(self._connections) do
			if connection.connected then
				coroutine.wrap(connection.callback)(...)
			end
		end
	end
	
	function Signal:Wait()
		local thread = coroutine.running()
		local connection
		connection = self:Connect(function(...)
			connection:Disconnect()
			coroutine.resume(thread, ...)
		end)
		return coroutine.yield()
	end
end

local Ripple = {}
-- Simplified Ripple - mostly placeholder since it's complex
Ripple.createSignal = Signal.new

-- Themes
local Themes = {
	Names = {
		"Vynixu",
		"Dark",
		"Darker",
		"Light",
		"Quiet Light",
		"Aqua",
		"Tomorrow Night Blue",
		"Abyss",
		"Amethyst",
		"Amethyst Dark",
		"Rose",
		"Yaru",
		"United Ubuntu",
		"Elementary",
		"Yaru Dark",
		"United GNOME",
		"Arc Dark",
		"Ambiance",
		"Adapta Nokto",
		"Monokai",
		"Monokai Classic",
		"Monokai Vibrant",
		"Monokai Dimmed",
		"Typewriter",
		"Dark Typewriter",
		"Kimbie Dark",
		"Solarized Dark",
		"Solarized Light",
		"DuoTone Dark Sea",
		"DuoTone Dark Sky",
		"DuoTone Dark Space",
		"DuoTone Dark Forest",
		"DuoTone Dark Earth",
		"VSC Dark+",
		"VSC Dark Modern",
		"VSC Dark High Contrast",
		"VSC Light+",
		"VSC Light Modern",
		"VSC Light High Contrast",
		"VSC Red",
		"VS Dark",
		"VS Light",
		"GitHub Dark",
		"GitHub Dark Dimmed",
		"GitHub Dark Default",
		"GitHub Dark High Contrast",
		"GitHub Dark Colorblind",
		"GitHub Light",
		"GitHub Light Default",
		"GitHub Light High Contrast",
		"GitHub Light Colorblind",
		"Viow Arabian",
		"Viow Arabian Mix",
		"Viow Darker",
		"Viow Flat",
		"Viow Light",
		"Viow Mars",
		"Viow Neon"
	}
}

-- Vynixu Theme
Themes["Vynixu"] = {
	Accent = Color3.fromRGB(90, 235, 45),
	AcrylicMain = Color3.fromRGB(30, 30, 30),
	AcrylicBorder = Color3.fromRGB(60, 60, 60),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(25, 25, 25), Color3.fromRGB(15, 15, 15)),
	AcrylicNoise = 0.94,
	TitleBarLine = Color3.fromRGB(65, 65, 65),
	Tab = Color3.fromRGB(100, 100, 100),
	Element = Color3.fromRGB(70, 70, 70),
	ElementBorder = Color3.fromRGB(25, 25, 25),
	InElementBorder = Color3.fromRGB(55, 55, 55),
	ElementTransparency = 0.82,
	ToggleSlider = Color3.fromRGB(70, 70, 70),
	ToggleToggled = Color3.fromRGB(0, 0, 0),
	SliderRail = Color3.fromRGB(70, 70, 70),
	DropdownFrame = Color3.fromRGB(120, 120, 120),
	DropdownHolder = Color3.fromRGB(35, 35, 35),
	DropdownBorder = Color3.fromRGB(25, 25, 25),
	DropdownOption = Color3.fromRGB(70, 70, 70),
	Keybind = Color3.fromRGB(70, 70, 70),
	Input = Color3.fromRGB(70, 70, 70),
	InputFocused = Color3.fromRGB(10, 10, 10),
	InputIndicator = Color3.fromRGB(150, 150, 150),
	Dialog = Color3.fromRGB(35, 35, 35),
	DialogHolder = Color3.fromRGB(25, 25, 25),
	DialogHolderLine = Color3.fromRGB(20, 20, 20),
	DialogButton = Color3.fromRGB(35, 35, 35),
	DialogButtonBorder = Color3.fromRGB(55, 55, 55),
	DialogBorder = Color3.fromRGB(50, 50, 50),
	DialogInput = Color3.fromRGB(45, 45, 45),
	DialogInputLine = Color3.fromRGB(120, 120, 120),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(70, 70, 70),
	HoverChange = 0.07
}

-- Dark Theme
Themes["Dark"] = {
	Accent = Color3.fromRGB(96, 205, 255),
	AcrylicMain = Color3.fromRGB(60, 60, 60),
	AcrylicBorder = Color3.fromRGB(90, 90, 90),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(40, 40, 40)),
	AcrylicNoise = 0.9,
	TitleBarLine = Color3.fromRGB(75, 75, 75),
	Tab = Color3.fromRGB(120, 120, 120),
	Element = Color3.fromRGB(120, 120, 120),
	ElementBorder = Color3.fromRGB(35, 35, 35),
	InElementBorder = Color3.fromRGB(90, 90, 90),
	ElementTransparency = 0.87,
	ToggleSlider = Color3.fromRGB(120, 120, 120),
	ToggleToggled = Color3.fromRGB(0, 0, 0),
	SliderRail = Color3.fromRGB(120, 120, 120),
	DropdownFrame = Color3.fromRGB(160, 160, 160),
	DropdownHolder = Color3.fromRGB(45, 45, 45),
	DropdownBorder = Color3.fromRGB(35, 35, 35),
	DropdownOption = Color3.fromRGB(120, 120, 120),
	Keybind = Color3.fromRGB(120, 120, 120),
	Input = Color3.fromRGB(160, 160, 160),
	InputFocused = Color3.fromRGB(10, 10, 10),
	InputIndicator = Color3.fromRGB(150, 150, 150),
	Dialog = Color3.fromRGB(45, 45, 45),
	DialogHolder = Color3.fromRGB(35, 35, 35),
	DialogHolderLine = Color3.fromRGB(30, 30, 30),
	DialogButton = Color3.fromRGB(45, 45, 45),
	DialogButtonBorder = Color3.fromRGB(80, 80, 80),
	DialogBorder = Color3.fromRGB(70, 70, 70),
	DialogInput = Color3.fromRGB(55, 55, 55),
	DialogInputLine = Color3.fromRGB(160, 160, 160),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(120, 120, 120),
	HoverChange = 0.07
}

-- Darker Theme
Themes["Darker"] = {
	Accent = Color3.fromRGB(72, 138, 182),
	AcrylicMain = Color3.fromRGB(30, 30, 30),
	AcrylicBorder = Color3.fromRGB(60, 60, 60),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(25, 25, 25), Color3.fromRGB(15, 15, 15)),
	AcrylicNoise = 0.94,
	TitleBarLine = Color3.fromRGB(65, 65, 65),
	Tab = Color3.fromRGB(100, 100, 100),
	Element = Color3.fromRGB(70, 70, 70),
	ElementBorder = Color3.fromRGB(25, 25, 25),
	InElementBorder = Color3.fromRGB(55, 55, 55),
	ElementTransparency = 0.82,
	ToggleSlider = Color3.fromRGB(70, 70, 70),
	ToggleToggled = Color3.fromRGB(0, 0, 0),
	SliderRail = Color3.fromRGB(70, 70, 70),
	DropdownFrame = Color3.fromRGB(120, 120, 120),
	DropdownHolder = Color3.fromRGB(35, 35, 35),
	DropdownBorder = Color3.fromRGB(25, 25, 25),
	DropdownOption = Color3.fromRGB(70, 70, 70),
	Keybind = Color3.fromRGB(70, 70, 70),
	Input = Color3.fromRGB(70, 70, 70),
	InputFocused = Color3.fromRGB(10, 10, 10),
	InputIndicator = Color3.fromRGB(150, 150, 150),
	Dialog = Color3.fromRGB(35, 35, 35),
	DialogHolder = Color3.fromRGB(25, 25, 25),
	DialogHolderLine = Color3.fromRGB(20, 20, 20),
	DialogButton = Color3.fromRGB(35, 35, 35),
	DialogButtonBorder = Color3.fromRGB(55, 55, 55),
	DialogBorder = Color3.fromRGB(50, 50, 50),
	DialogInput = Color3.fromRGB(45, 45, 45),
	DialogInputLine = Color3.fromRGB(120, 120, 120),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(70, 70, 70),
	HoverChange = 0.07
}

-- Light Theme
Themes["Light"] = {
	Accent = Color3.fromRGB(96, 205, 255),
	AcrylicMain = Color3.fromRGB(245, 245, 245),
	AcrylicBorder = Color3.fromRGB(220, 220, 220),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
	AcrylicNoise = 0.9,
	TitleBarLine = Color3.fromRGB(200, 200, 200),
	Tab = Color3.fromRGB(100, 100, 100),
	Element = Color3.fromRGB(100, 100, 100),
	ElementBorder = Color3.fromRGB(200, 200, 200),
	InElementBorder = Color3.fromRGB(150, 150, 150),
	ElementTransparency = 0.87,
	ToggleSlider = Color3.fromRGB(100, 100, 100),
	ToggleToggled = Color3.fromRGB(255, 255, 255),
	SliderRail = Color3.fromRGB(100, 100, 100),
	DropdownFrame = Color3.fromRGB(100, 100, 100),
	DropdownHolder = Color3.fromRGB(250, 250, 250),
	DropdownBorder = Color3.fromRGB(200, 200, 200),
	DropdownOption = Color3.fromRGB(100, 100, 100),
	Keybind = Color3.fromRGB(100, 100, 100),
	Input = Color3.fromRGB(100, 100, 100),
	InputFocused = Color3.fromRGB(245, 245, 245),
	InputIndicator = Color3.fromRGB(150, 150, 150),
	Dialog = Color3.fromRGB(250, 250, 250),
	DialogHolder = Color3.fromRGB(240, 240, 240),
	DialogHolderLine = Color3.fromRGB(220, 220, 220),
	DialogButton = Color3.fromRGB(250, 250, 250),
	DialogButtonBorder = Color3.fromRGB(180, 180, 180),
	DialogBorder = Color3.fromRGB(180, 180, 180),
	DialogInput = Color3.fromRGB(245, 245, 245),
	DialogInputLine = Color3.fromRGB(100, 100, 100),
	Text = Color3.fromRGB(50, 50, 50),
	SubText = Color3.fromRGB(100, 100, 100),
	Hover = Color3.fromRGB(100, 100, 100),
	HoverChange = 0.07
}

-- Quiet Light Theme
Themes["Quiet Light"] = {
	Accent = Color3.fromRGB(151, 105, 220),
	AcrylicMain = Color3.fromRGB(245, 245, 245),
	AcrylicBorder = Color3.fromRGB(196, 183, 215),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(245, 245, 245), Color3.fromRGB(245, 245, 245)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(196, 183, 215),
	Tab = Color3.fromRGB(112, 86, 151),
	Element = Color3.fromRGB(242, 242, 242),
	ElementBorder = Color3.fromRGB(173, 175, 183),
	InElementBorder = Color3.fromRGB(151, 105, 220),
	ElementTransparency = 0,
	ToggleSlider = Color3.fromRGB(112, 86, 151),
	ToggleToggled = Color3.fromRGB(245, 245, 245),
	SliderRail = Color3.fromRGB(112, 86, 151),
	DropdownFrame = Color3.fromRGB(245, 245, 245),
	DropdownHolder = Color3.fromRGB(245, 245, 245),
	DropdownBorder = Color3.fromRGB(173, 175, 183),
	DropdownOption = Color3.fromRGB(51, 51, 51),
	Keybind = Color3.fromRGB(245, 245, 245),
	Input = Color3.fromRGB(245, 245, 245),
	InputFocused = Color3.fromRGB(245, 245, 245),
	InputIndicator = Color3.fromRGB(170, 170, 170),
	Dialog = Color3.fromRGB(242, 248, 252),
	DialogHolder = Color3.fromRGB(242, 248, 252),
	DialogHolderLine = Color3.fromRGB(112, 86, 151),
	DialogButton = Color3.fromRGB(245, 245, 245),
	DialogButtonBorder = Color3.fromRGB(173, 175, 183),
	DialogBorder = Color3.fromRGB(112, 86, 151),
	DialogInput = Color3.fromRGB(245, 245, 245),
	DialogInputLine = Color3.fromRGB(151, 105, 220),
	Text = Color3.fromRGB(51, 51, 51),
	SubText = Color3.fromRGB(109, 112, 91),
	Hover = Color3.fromRGB(224, 224, 224),
	HoverChange = 0.1
}

-- Aqua Theme
Themes["Aqua"] = {
	Accent = Color3.fromRGB(60, 165, 165),
	AcrylicMain = Color3.fromRGB(20, 20, 20),
	AcrylicBorder = Color3.fromRGB(50, 100, 100),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(60, 140, 140), Color3.fromRGB(40, 80, 80)),
	AcrylicNoise = 0.92,
	TitleBarLine = Color3.fromRGB(60, 120, 120),
	Tab = Color3.fromRGB(140, 180, 180),
	Element = Color3.fromRGB(110, 160, 160),
	ElementBorder = Color3.fromRGB(40, 70, 70),
	InElementBorder = Color3.fromRGB(80, 110, 110),
	ElementTransparency = 0.84,
	ToggleSlider = Color3.fromRGB(110, 160, 160),
	ToggleToggled = Color3.fromRGB(0, 0, 0),
	SliderRail = Color3.fromRGB(110, 160, 160),
	DropdownFrame = Color3.fromRGB(160, 200, 200),
	DropdownHolder = Color3.fromRGB(40, 80, 80),
	DropdownBorder = Color3.fromRGB(40, 65, 65),
	DropdownOption = Color3.fromRGB(110, 160, 160),
	Keybind = Color3.fromRGB(110, 160, 160),
	Input = Color3.fromRGB(110, 160, 160),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(130, 170, 170),
	Dialog = Color3.fromRGB(40, 80, 80),
	DialogHolder = Color3.fromRGB(30, 60, 60),
	DialogHolderLine = Color3.fromRGB(25, 50, 50),
	DialogButton = Color3.fromRGB(40, 80, 80),
	DialogButtonBorder = Color3.fromRGB(80, 110, 110),
	DialogBorder = Color3.fromRGB(50, 100, 100),
	DialogInput = Color3.fromRGB(45, 90, 90),
	DialogInputLine = Color3.fromRGB(130, 170, 170),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(110, 160, 160),
	HoverChange = 0.04
}

-- Rose Theme
Themes["Rose"] = {
	Accent = Color3.fromRGB(180, 55, 90),
	AcrylicMain = Color3.fromRGB(40, 40, 40),
	AcrylicBorder = Color3.fromRGB(130, 90, 110),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(190, 60, 135), Color3.fromRGB(165, 50, 70)),
	AcrylicNoise = 0.92,
	TitleBarLine = Color3.fromRGB(140, 85, 105),
	Tab = Color3.fromRGB(180, 140, 160),
	Element = Color3.fromRGB(200, 120, 170),
	ElementBorder = Color3.fromRGB(110, 70, 85),
	InElementBorder = Color3.fromRGB(120, 90, 90),
	ElementTransparency = 0.86,
	ToggleSlider = Color3.fromRGB(200, 120, 170),
	ToggleToggled = Color3.fromRGB(0, 0, 0),
	SliderRail = Color3.fromRGB(200, 120, 170),
	DropdownFrame = Color3.fromRGB(200, 160, 180),
	DropdownHolder = Color3.fromRGB(120, 50, 75),
	DropdownBorder = Color3.fromRGB(90, 40, 55),
	DropdownOption = Color3.fromRGB(200, 120, 170),
	Keybind = Color3.fromRGB(200, 120, 170),
	Input = Color3.fromRGB(200, 120, 170),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(170, 150, 190),
	Dialog = Color3.fromRGB(120, 50, 75),
	DialogHolder = Color3.fromRGB(95, 40, 60),
	DialogHolderLine = Color3.fromRGB(90, 35, 55),
	DialogButton = Color3.fromRGB(120, 50, 75),
	DialogButtonBorder = Color3.fromRGB(155, 90, 115),
	DialogBorder = Color3.fromRGB(100, 70, 90),
	DialogInput = Color3.fromRGB(135, 55, 80),
	DialogInputLine = Color3.fromRGB(190, 160, 180),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(200, 120, 170),
	HoverChange = 0.04
}

-- Amethyst Theme
Themes["Amethyst"] = {
	Accent = Color3.fromRGB(97, 62, 167),
	AcrylicMain = Color3.fromRGB(20, 20, 20),
	AcrylicBorder = Color3.fromRGB(110, 90, 130),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(85, 57, 139), Color3.fromRGB(40, 25, 65)),
	AcrylicNoise = 0.92,
	TitleBarLine = Color3.fromRGB(95, 75, 110),
	Tab = Color3.fromRGB(160, 140, 180),
	Element = Color3.fromRGB(140, 120, 160),
	ElementBorder = Color3.fromRGB(60, 50, 70),
	InElementBorder = Color3.fromRGB(100, 90, 110),
	ElementTransparency = 0.87,
	ToggleSlider = Color3.fromRGB(140, 120, 160),
	ToggleToggled = Color3.fromRGB(0, 0, 0),
	SliderRail = Color3.fromRGB(140, 120, 160),
	DropdownFrame = Color3.fromRGB(170, 160, 200),
	DropdownHolder = Color3.fromRGB(60, 45, 80),
	DropdownBorder = Color3.fromRGB(50, 40, 65),
	DropdownOption = Color3.fromRGB(140, 120, 160),
	Keybind = Color3.fromRGB(140, 120, 160),
	Input = Color3.fromRGB(140, 120, 160),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(170, 150, 190),
	Dialog = Color3.fromRGB(60, 45, 80),
	DialogHolder = Color3.fromRGB(45, 30, 65),
	DialogHolderLine = Color3.fromRGB(40, 25, 60),
	DialogButton = Color3.fromRGB(60, 45, 80),
	DialogButtonBorder = Color3.fromRGB(95, 80, 110),
	DialogBorder = Color3.fromRGB(85, 70, 100),
	DialogInput = Color3.fromRGB(70, 55, 85),
	DialogInputLine = Color3.fromRGB(175, 160, 190),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(140, 120, 160),
	HoverChange = 0.04
}

-- Monokai Theme
Themes["Monokai"] = {
	Accent = Color3.fromRGB(249, 38, 114),
	AcrylicMain = Color3.fromRGB(39, 40, 34),
	AcrylicBorder = Color3.fromRGB(65, 67, 57),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(39, 40, 34), Color3.fromRGB(30, 31, 28)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(65, 67, 57),
	Tab = Color3.fromRGB(248, 248, 242),
	Element = Color3.fromRGB(65, 67, 57),
	ElementBorder = Color3.fromRGB(117, 113, 94),
	InElementBorder = Color3.fromRGB(249, 38, 114),
	ElementTransparency = 0,
	ToggleSlider = Color3.fromRGB(249, 38, 114),
	ToggleToggled = Color3.fromRGB(65, 67, 57),
	SliderRail = Color3.fromRGB(117, 113, 94),
	DropdownFrame = Color3.fromRGB(65, 67, 57),
	DropdownHolder = Color3.fromRGB(30, 31, 28),
	DropdownBorder = Color3.fromRGB(117, 113, 94),
	DropdownOption = Color3.fromRGB(248, 248, 242),
	Keybind = Color3.fromRGB(65, 67, 57),
	Input = Color3.fromRGB(65, 67, 57),
	InputFocused = Color3.fromRGB(65, 67, 57),
	InputIndicator = Color3.fromRGB(144, 144, 138),
	Dialog = Color3.fromRGB(30, 31, 28),
	DialogHolder = Color3.fromRGB(30, 31, 28),
	DialogHolderLine = Color3.fromRGB(65, 67, 57),
	DialogButton = Color3.fromRGB(65, 67, 57),
	DialogButtonBorder = Color3.fromRGB(117, 113, 94),
	DialogBorder = Color3.fromRGB(117, 113, 94),
	DialogInput = Color3.fromRGB(65, 67, 57),
	DialogInputLine = Color3.fromRGB(249, 38, 114),
	Text = Color3.fromRGB(248, 248, 242),
	SubText = Color3.fromRGB(136, 132, 111),
	Hover = Color3.fromRGB(62, 61, 50),
	HoverChange = 0.1
}

-- GitHub Dark Theme
Themes["GitHub Dark"] = {
	Accent = Color3.fromRGB(0, 92, 197),
	AcrylicMain = Color3.fromRGB(31, 36, 40),
	AcrylicBorder = Color3.fromRGB(27, 31, 35),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(31, 36, 40), Color3.fromRGB(31, 36, 40)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(27, 31, 35),
	Tab = Color3.fromRGB(225, 228, 232),
	Element = Color3.fromRGB(47, 54, 61),
	ElementBorder = Color3.fromRGB(27, 31, 35),
	InElementBorder = Color3.fromRGB(0, 92, 197),
	ElementTransparency = 0,
	ToggleSlider = Color3.fromRGB(0, 92, 197),
	ToggleToggled = Color3.fromRGB(47, 54, 61),
	SliderRail = Color3.fromRGB(0, 92, 197),
	DropdownFrame = Color3.fromRGB(47, 54, 61),
	DropdownHolder = Color3.fromRGB(47, 54, 61),
	DropdownBorder = Color3.fromRGB(27, 31, 35),
	DropdownOption = Color3.fromRGB(225, 228, 232),
	Keybind = Color3.fromRGB(47, 54, 61),
	Input = Color3.fromRGB(47, 54, 61),
	InputFocused = Color3.fromRGB(47, 54, 61),
	InputIndicator = Color3.fromRGB(149, 157, 165),
	Dialog = Color3.fromRGB(47, 54, 61),
	DialogHolder = Color3.fromRGB(47, 54, 61),
	DialogHolderLine = Color3.fromRGB(68, 77, 86),
	DialogButton = Color3.fromRGB(47, 54, 61),
	DialogButtonBorder = Color3.fromRGB(27, 31, 35),
	DialogBorder = Color3.fromRGB(27, 31, 35),
	DialogInput = Color3.fromRGB(47, 54, 61),
	DialogInputLine = Color3.fromRGB(0, 92, 197),
	Text = Color3.fromRGB(209, 213, 218),
	SubText = Color3.fromRGB(149, 157, 165),
	Hover = Color3.fromRGB(40, 46, 52),
	HoverChange = 0.1
}

-- Abyss Theme
Themes["Abyss"] = {
	Accent = Color3.fromRGB(102, 136, 204),
	AcrylicMain = Color3.fromRGB(0, 12, 24),
	AcrylicBorder = Color3.fromRGB(43, 43, 74),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(0, 12, 24), Color3.fromRGB(0, 12, 24)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(43, 43, 74),
	Tab = Color3.fromRGB(128, 162, 194),
	Element = Color3.fromRGB(24, 31, 47),
	ElementBorder = Color3.fromRGB(43, 43, 74),
	InElementBorder = Color3.fromRGB(0, 99, 165),
	ElementTransparency = 0,
	ToggleSlider = Color3.fromRGB(0, 99, 165),
	ToggleToggled = Color3.fromRGB(24, 31, 47),
	SliderRail = Color3.fromRGB(0, 99, 165),
	DropdownFrame = Color3.fromRGB(24, 31, 47),
	DropdownHolder = Color3.fromRGB(24, 31, 47),
	DropdownBorder = Color3.fromRGB(43, 43, 74),
	DropdownOption = Color3.fromRGB(102, 136, 204),
	Keybind = Color3.fromRGB(24, 31, 47),
	Input = Color3.fromRGB(24, 31, 47),
	InputFocused = Color3.fromRGB(24, 31, 47),
	InputIndicator = Color3.fromRGB(64, 99, 133),
	Dialog = Color3.fromRGB(38, 38, 65),
	DialogHolder = Color3.fromRGB(6, 6, 33),
	DialogHolderLine = Color3.fromRGB(43, 43, 74),
	DialogButton = Color3.fromRGB(24, 31, 47),
	DialogButtonBorder = Color3.fromRGB(43, 43, 74),
	DialogBorder = Color3.fromRGB(43, 43, 74),
	DialogInput = Color3.fromRGB(24, 31, 47),
	DialogInputLine = Color3.fromRGB(0, 99, 165),
	Text = Color3.fromRGB(102, 136, 204),
	SubText = Color3.fromRGB(64, 99, 133),
	Hover = Color3.fromRGB(8, 40, 107),
	HoverChange = 0.1
}

-- Tomorrow Night Blue Theme
Themes["Tomorrow Night Blue"] = {
	Accent = Color3.fromRGB(187, 218, 255),
	AcrylicMain = Color3.fromRGB(0, 36, 81),
	AcrylicBorder = Color3.fromRGB(64, 79, 125),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(0, 36, 81), Color3.fromRGB(0, 36, 81)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(64, 79, 125),
	Tab = Color3.fromRGB(255, 255, 255),
	Element = Color3.fromRGB(0, 23, 51),
	ElementBorder = Color3.fromRGB(64, 79, 125),
	InElementBorder = Color3.fromRGB(187, 218, 255),
	ElementTransparency = 0,
	ToggleSlider = Color3.fromRGB(187, 218, 255),
	ToggleToggled = Color3.fromRGB(0, 23, 51),
	SliderRail = Color3.fromRGB(187, 218, 255),
	DropdownFrame = Color3.fromRGB(0, 23, 51),
	DropdownHolder = Color3.fromRGB(0, 23, 51),
	DropdownBorder = Color3.fromRGB(64, 79, 125),
	DropdownOption = Color3.fromRGB(255, 255, 255),
	Keybind = Color3.fromRGB(0, 23, 51),
	Input = Color3.fromRGB(0, 23, 51),
	InputFocused = Color3.fromRGB(0, 23, 51),
	InputIndicator = Color3.fromRGB(64, 79, 125),
	Dialog = Color3.fromRGB(0, 28, 64),
	DialogHolder = Color3.fromRGB(0, 28, 64),
	DialogHolderLine = Color3.fromRGB(64, 79, 125),
	DialogButton = Color3.fromRGB(0, 23, 51),
	DialogButtonBorder = Color3.fromRGB(64, 79, 125),
	DialogBorder = Color3.fromRGB(255, 255, 255),
	DialogInput = Color3.fromRGB(0, 23, 51),
	DialogInputLine = Color3.fromRGB(187, 218, 255),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(114, 133, 183),
	Hover = Color3.fromRGB(255, 255, 255),
	HoverChange = 0.1
}

-- Yaru Theme
Themes["Yaru"] = {
	Accent = Color3.fromRGB(233, 84, 32),
	AcrylicMain = Color3.fromRGB(237, 238, 240),
	AcrylicBorder = Color3.fromRGB(212, 212, 212),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(237, 238, 240), Color3.fromRGB(237, 238, 240)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(212, 212, 212),
	Tab = Color3.fromRGB(17, 17, 17),
	Element = Color3.fromRGB(255, 255, 255),
	ElementBorder = Color3.fromRGB(206, 206, 206),
	InElementBorder = Color3.fromRGB(233, 84, 32),
	ElementTransparency = 0,
	ToggleSlider = Color3.fromRGB(233, 84, 32),
	ToggleToggled = Color3.fromRGB(255, 255, 255),
	SliderRail = Color3.fromRGB(233, 84, 32),
	DropdownFrame = Color3.fromRGB(255, 255, 255),
	DropdownHolder = Color3.fromRGB(255, 255, 255),
	DropdownBorder = Color3.fromRGB(206, 206, 206),
	DropdownOption = Color3.fromRGB(17, 17, 17),
	Keybind = Color3.fromRGB(255, 255, 255),
	Input = Color3.fromRGB(255, 255, 255),
	InputFocused = Color3.fromRGB(255, 255, 255),
	InputIndicator = Color3.fromRGB(118, 118, 118),
	Dialog = Color3.fromRGB(246, 246, 246),
	DialogHolder = Color3.fromRGB(255, 255, 255),
	DialogHolderLine = Color3.fromRGB(212, 212, 212),
	DialogButton = Color3.fromRGB(246, 246, 246),
	DialogButtonBorder = Color3.fromRGB(206, 206, 206),
	DialogBorder = Color3.fromRGB(212, 212, 212),
	DialogInput = Color3.fromRGB(255, 255, 255),
	DialogInputLine = Color3.fromRGB(233, 84, 32),
	Text = Color3.fromRGB(17, 17, 17),
	SubText = Color3.fromRGB(111, 111, 111),
	Hover = Color3.fromRGB(232, 232, 232),
	HoverChange = 0.1
}

-- Typewriter Theme
Themes["Typewriter"] = {
	Accent = Color3.fromRGB(97, 161, 107),
	AcrylicMain = Color3.fromRGB(252, 245, 228),
	AcrylicBorder = Color3.fromRGB(189, 189, 189),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(252, 245, 228), Color3.fromRGB(228, 220, 200)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(189, 189, 189),
	Tab = Color3.fromRGB(109, 180, 120),
	Element = Color3.fromRGB(255, 255, 255),
	ElementBorder = Color3.fromRGB(200, 200, 200),
	InElementBorder = Color3.fromRGB(191, 191, 193),
	ElementTransparency = 1,
	ToggleSlider = Color3.fromRGB(97, 161, 107),
	ToggleToggled = Color3.fromRGB(255, 255, 255),
	SliderRail = Color3.fromRGB(230, 230, 230),
	DropdownFrame = Color3.fromRGB(217, 218, 220),
	DropdownHolder = Color3.fromRGB(226, 220, 205),
	DropdownBorder = Color3.fromRGB(185, 182, 172),
	DropdownOption = Color3.fromRGB(27, 129, 229),
	Keybind = Color3.fromRGB(233, 227, 211),
	Input = Color3.fromRGB(255, 255, 255),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(170, 150, 190),
	Dialog = Color3.fromRGB(252, 245, 228),
	DialogHolder = Color3.fromRGB(228, 220, 200),
	DialogHolderLine = Color3.fromRGB(189, 189, 189),
	DialogButton = Color3.fromRGB(242, 243, 245),
	DialogButtonBorder = Color3.fromRGB(213, 213, 215),
	DialogBorder = Color3.fromRGB(189, 189, 189),
	DialogInput = Color3.fromRGB(252, 245, 228),
	DialogInputLine = Color3.fromRGB(190, 160, 180),
	Text = Color3.fromRGB(104, 104, 104),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(149, 149, 149),
	HoverChange = 0.04
}

-- Solarized Dark Theme
Themes["Solarized Dark"] = {
	Accent = Color3.fromRGB(42, 161, 152),
	AcrylicMain = Color3.fromRGB(0, 43, 54),
	AcrylicBorder = Color3.fromRGB(7, 54, 66),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(0, 43, 54), Color3.fromRGB(0, 43, 54)),
	AcrylicNoise = 1,
	TitleBarLine = Color3.fromRGB(42, 161, 152),
	Tab = Color3.fromRGB(131, 148, 150),
	Element = Color3.fromRGB(0, 56, 71),
	ElementBorder = Color3.fromRGB(42, 161, 152),
	InElementBorder = Color3.fromRGB(42, 161, 152),
	ElementTransparency = 0,
	ToggleSlider = Color3.fromRGB(42, 161, 152),
	ToggleToggled = Color3.fromRGB(0, 43, 54),
	SliderRail = Color3.fromRGB(42, 161, 152),
	DropdownFrame = Color3.fromRGB(0, 33, 43),
	DropdownHolder = Color3.fromRGB(0, 33, 43),
	DropdownBorder = Color3.fromRGB(42, 161, 152),
	DropdownOption = Color3.fromRGB(131, 148, 150),
	Keybind = Color3.fromRGB(0, 56, 71),
	Input = Color3.fromRGB(0, 56, 71),
	InputFocused = Color3.fromRGB(0, 56, 71),
	InputIndicator = Color3.fromRGB(147, 161, 161),
	Dialog = Color3.fromRGB(0, 33, 43),
	DialogHolder = Color3.fromRGB(0, 43, 54),
	DialogHolderLine = Color3.fromRGB(7, 54, 66),
	DialogButton = Color3.fromRGB(0, 56, 71),
	DialogButtonBorder = Color3.fromRGB(42, 161, 152),
	DialogBorder = Color3.fromRGB(42, 161, 152),
	DialogInput = Color3.fromRGB(0, 56, 71),
	DialogInputLine = Color3.fromRGB(42, 161, 152),
	Text = Color3.fromRGB(131, 148, 150),
	SubText = Color3.fromRGB(88, 110, 117),
	Hover = Color3.fromRGB(0, 68, 84),
	HoverChange = 0.1
}

-- VSC Dark+ Theme
Themes["VSC Dark+"] = {
	Accent = Color3.fromRGB(220, 220, 170),
	AcrylicMain = Color3.fromRGB(30, 30, 30),
	AcrylicBorder = Color3.fromRGB(68, 68, 68),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(30, 30, 30)),
	AcrylicNoise = 0.92,
	TitleBarLine = Color3.fromRGB(68, 68, 68),
	Tab = Color3.fromRGB(204, 204, 204),
	Element = Color3.fromRGB(45, 45, 45),
	ElementBorder = Color3.fromRGB(64, 64, 64),
	InElementBorder = Color3.fromRGB(220, 220, 170),
	ElementTransparency = 0.85,
	ToggleSlider = Color3.fromRGB(78, 201, 176),
	ToggleToggled = Color3.fromRGB(30, 30, 30),
	SliderRail = Color3.fromRGB(78, 201, 176),
	DropdownFrame = Color3.fromRGB(45, 45, 45),
	DropdownHolder = Color3.fromRGB(37, 37, 38),
	DropdownBorder = Color3.fromRGB(64, 64, 64),
	DropdownOption = Color3.fromRGB(156, 220, 254),
	Keybind = Color3.fromRGB(45, 45, 45),
	Input = Color3.fromRGB(60, 60, 60),
	InputFocused = Color3.fromRGB(60, 60, 60),
	InputIndicator = Color3.fromRGB(128, 128, 128),
	Dialog = Color3.fromRGB(37, 37, 38),
	DialogHolder = Color3.fromRGB(30, 30, 30),
	DialogHolderLine = Color3.fromRGB(64, 64, 64),
	DialogButton = Color3.fromRGB(45, 45, 45),
	DialogButtonBorder = Color3.fromRGB(64, 64, 64),
	DialogBorder = Color3.fromRGB(68, 68, 68),
	DialogInput = Color3.fromRGB(60, 60, 60),
	DialogInputLine = Color3.fromRGB(220, 220, 170),
	Text = Color3.fromRGB(212, 212, 212),
	SubText = Color3.fromRGB(128, 128, 128),
	Hover = Color3.fromRGB(42, 45, 46),
	HoverChange = 0.05
}

-- Helper function to clone tables
local function cloneTable(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = cloneTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

-- Copy some base themes for others
Themes["Amethyst Dark"] = cloneTable(Themes["Amethyst"])
Themes["Amethyst Dark"].Accent = Color3.fromRGB(147, 112, 219)

Themes["United Ubuntu"] = cloneTable(Themes["Yaru"])
Themes["Elementary"] = cloneTable(Themes["Light"])
Themes["Yaru Dark"] = cloneTable(Themes["Dark"])
Themes["United GNOME"] = cloneTable(Themes["Light"])
Themes["Arc Dark"] = cloneTable(Themes["Darker"])
Themes["Ambiance"] = cloneTable(Themes["Dark"])
Themes["Adapta Nokto"] = cloneTable(Themes["Darker"])

-- Monokai variants
Themes["Monokai Classic"] = cloneTable(Themes["Monokai"])
Themes["Monokai Vibrant"] = cloneTable(Themes["Monokai"])
Themes["Monokai Vibrant"].Accent = Color3.fromRGB(255, 216, 0)
Themes["Monokai Dimmed"] = cloneTable(Themes["Monokai"])
Themes["Monokai Dimmed"].AcrylicMain = Color3.fromRGB(25, 25, 20)

-- Typewriter variants
Themes["Dark Typewriter"] = cloneTable(Themes["Dark"])
Themes["Dark Typewriter"].Text = Color3.fromRGB(200, 200, 200)

-- Kimbie Dark
Themes["Kimbie Dark"] = cloneTable(Themes["Dark"])
Themes["Kimbie Dark"].Accent = Color3.fromRGB(216, 166, 87)

-- Solarized Light
Themes["Solarized Light"] = cloneTable(Themes["Light"])
Themes["Solarized Light"].Accent = Color3.fromRGB(42, 161, 152)

-- DuoTone variants
Themes["DuoTone Dark Sea"] = cloneTable(Themes["Aqua"])
Themes["DuoTone Dark Sky"] = cloneTable(Themes["Tomorrow Night Blue"])
Themes["DuoTone Dark Space"] = cloneTable(Themes["Abyss"])
Themes["DuoTone Dark Forest"] = cloneTable(Themes["Dark"])
Themes["DuoTone Dark Forest"].Accent = Color3.fromRGB(126, 186, 181)
Themes["DuoTone Dark Earth"] = cloneTable(Themes["Dark"])
Themes["DuoTone Dark Earth"].Accent = Color3.fromRGB(205, 168, 105)

-- VSC variants
Themes["VSC Dark Modern"] = cloneTable(Themes["VSC Dark+"])
Themes["VSC Dark High Contrast"] = cloneTable(Themes["VSC Dark+"])
Themes["VSC Dark High Contrast"].ElementBorder = Color3.fromRGB(255, 255, 255)

Themes["VSC Light+"] = cloneTable(Themes["Light"])
Themes["VSC Light Modern"] = cloneTable(Themes["Light"])
Themes["VSC Light High Contrast"] = cloneTable(Themes["Light"])
Themes["VSC Light High Contrast"].ElementBorder = Color3.fromRGB(0, 0, 0)

Themes["VSC Red"] = cloneTable(Themes["VSC Dark+"])
Themes["VSC Red"].Accent = Color3.fromRGB(220, 50, 50)

Themes["VS Dark"] = cloneTable(Themes["VSC Dark+"])
Themes["VS Light"] = cloneTable(Themes["VSC Light+"])

-- GitHub variants
Themes["GitHub Dark Dimmed"] = cloneTable(Themes["GitHub Dark"])
Themes["GitHub Dark Default"] = cloneTable(Themes["GitHub Dark"])
Themes["GitHub Dark High Contrast"] = cloneTable(Themes["GitHub Dark"])
Themes["GitHub Dark Colorblind"] = cloneTable(Themes["GitHub Dark"])

Themes["GitHub Light"] = cloneTable(Themes["Light"])
Themes["GitHub Light Default"] = cloneTable(Themes["Light"])
Themes["GitHub Light High Contrast"] = cloneTable(Themes["Light"])
Themes["GitHub Light Colorblind"] = cloneTable(Themes["Light"])

-- Viow variants
Themes["Viow Arabian"] = cloneTable(Themes["Rose"])
Themes["Viow Arabian"].Accent = Color3.fromRGB(255, 140, 0)

Themes["Viow Arabian Mix"] = cloneTable(Themes["Rose"])
Themes["Viow Arabian Mix"].Accent = Color3.fromRGB(255, 165, 0)

Themes["Viow Darker"] = cloneTable(Themes["Darker"])
Themes["Viow Flat"] = cloneTable(Themes["Light"])
Themes["Viow Light"] = cloneTable(Themes["Light"])
Themes["Viow Mars"] = cloneTable(Themes["Rose"])
Themes["Viow Mars"].Accent = Color3.fromRGB(255, 69, 0)

Themes["Viow Neon"] = cloneTable(Themes["Vynixu"])
Themes["Viow Neon"].Accent = Color3.fromRGB(0, 255, 127)

for _, Theme in next, Themes.Names do
	local ThemeData = Themes[Theme]
	if ThemeData then
		ThemeData.Name = Theme
		Themes[ThemeData.Name] = ThemeData
	end
end

-- Creator Module
local Creator = {
	Registry = {},
	Signals = {},
	TransparencyMotors = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 14,
			RichText = true,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			RichText = true,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			RichText = true,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		}
	},
	Theme = {
		Updating = false,
		Updated = Signal.new()
	}
}

function Creator.AddSignal(SignalConnection, Function)
	Creator.Signals[#Creator.Signals+1] = SignalConnection:Connect(Function)
end

function Creator.GetThemeProperty(Property)
	if Themes[FluentRenewed.Theme] and Themes[FluentRenewed.Theme][Property] then
		return Themes[FluentRenewed.Theme][Property]
	end
	return Themes["Dark"][Property]
end

function Creator.UpdateTheme(RegistryIndex)
	if Creator.Theme.Updating then
		Creator.Theme.Updated:Wait()
	end
	
	Creator.Theme.Updating = true
	
	if typeof(RegistryIndex) == "Instance" and Creator.Registry[RegistryIndex] then
		for Property, ColorIdx in next, Creator.Registry[RegistryIndex].Properties do
			RegistryIndex[Property] = Creator.GetThemeProperty(ColorIdx)
		end
	else
		for _, Object in next, Creator.Registry do
			for Property, ColorIdx in next, Object.Properties do
				Object.Object[Property] = Creator.GetThemeProperty(ColorIdx)
			end
		end
	end
	
	for _, Motor in next, Creator.TransparencyMotors do
		Motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
	end
	
	Creator.Theme.Updating = false
	Creator.Theme.Updated:Fire()
end

function Creator.AddThemeObject(Object, Properties)
	local Data = {
		Object = Object,
		Properties = Properties,
	}
	
	Creator.Registry[Object] = Data
	Creator.UpdateTheme(Object)
	
	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object].Properties = Properties
	Creator.UpdateTheme(Object)
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)
	
	-- Default properties
	for PropName, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[PropName] = Value
	end
	
	-- Custom properties
	for PropName, Value in next, Properties or {} do
		if PropName ~= "ThemeTag" then
			Object[PropName] = Value
		end
	end
	
	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end
	
	-- Theme handling
	if Properties and Properties.ThemeTag then
		Creator.AddThemeObject(Object, Properties.ThemeTag)
	end
	
	return Object
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		Instance[Prop] = value
	end)
	
	if ResetOnThemeChange then
		Creator.TransparencyMotors[#Creator.TransparencyMotors + 1] = Motor
	end
	
	local function SetValue(Value, Ignore)
		Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
	end
	
	return Motor, SetValue
end

-- Icons and Utilities
local Icons = {
	lucide = {
		["chevron-right"] = {
			Image = "rbxassetid://10709751939",
			ImageRectOffset = Vector2.new(4, 4),
			ImageRectSize = Vector2.new(16, 16)
		},
		["settings"] = {
			Image = "rbxassetid://10734883986",
			ImageRectOffset = Vector2.new(4, 4),
			ImageRectSize = Vector2.new(16, 16)
		},
		["search"] = {
			Image = "rbxassetid://10709761378",
			ImageRectOffset = Vector2.new(4, 4),
			ImageRectSize = Vector2.new(16, 16)
		}
	},
	phosphor = {
		["phosphor-users-bold"] = {
			Image = "rbxassetid://10709751939",
			ImageRectOffset = Vector2.new(4, 4),
			ImageRectSize = Vector2.new(16, 16)
		}
	}
}

local Utilities = {}

function Utilities:GetIcon(IconName)
	-- Check lucide icons first
	if Icons.lucide[IconName] then
		return Icons.lucide[IconName]
	end
	
	-- Check phosphor icons
	if Icons.phosphor[IconName] then
		return Icons.phosphor[IconName]
	end
	
	-- Return default icon
	return {
		Image = "rbxassetid://10709751939",
		ImageRectOffset = Vector2.new(4, 4),
		ImageRectSize = Vector2.new(16, 16)
	}
end

function Utilities:SetIcon(ImageLabel, IconName)
	local IconData = self:GetIcon(IconName)
	ImageLabel.Image = IconData.Image
	ImageLabel.ImageRectOffset = IconData.ImageRectOffset
	ImageLabel.ImageRectSize = IconData.ImageRectSize
end

function Utilities:Prettify(Text)
	if typeof(Text) == "EnumItem" then
		return string.gsub(tostring(Text), "Enum%.", "")
	elseif typeof(Text) == "string" then
		if Text == "LeftMousebutton" then
			return "LMB"
		elseif Text == "RightMousebutton" then
			return "RMB"
		else
			return Text
		end
	end
	return tostring(Text)
end

function Utilities:Round(Number, Factor)
	local Result = math.floor(Number/Factor + 0.5) * Factor
	return Factor == 1 and math.floor(Result) or Result
end

function Utilities:Clone(Object)
	return Object
end

function Utilities:GetOS()
	return game:GetService("UserInputService").TouchEnabled and "Mobile" or "Desktop"
end

-- Assets
local Assets = {
	Close = "rbxassetid://9886659671",
	Min = "rbxassetid://9886659276",
	Max = "rbxassetid://9886659406",
	Restore = "rbxassetid://9886659001",
}

-- Components
local Components = {}

-- Element Component
Components.Element = function(Title, Desc, Parent, Hover, Config)
	local Element = {
		CreatedAt = tick()
	}
	
	Config = typeof(Config) == "table" and Config or {}
	
	Element.TitleLabel = Creator.New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		Text = Title,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Config.TitleAlignment or Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})
	
	Element.DescLabel = Creator.New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Desc,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Config.DescriptionAlignment or Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})
	
	Element.LabelHolder = Creator.New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -28, 0, 0),
	}, {
		Creator.New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Creator.New("UIPadding", {
			PaddingBottom = UDim.new(0, 13),
			PaddingTop = UDim.new(0, 13),
		}),
		Element.TitleLabel,
		Element.DescLabel,
	})
	
	Element.Border = Creator.New("UIStroke", {
		Transparency = 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(0, 0, 0),
		ThemeTag = {
			Color = "ElementBorder",
		},
	})
	
	Element.Frame = Creator.New("TextButton", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 0.89,
		BackgroundColor3 = Color3.fromRGB(130, 130, 130),
		Parent = Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		LayoutOrder = 7,
		ThemeTag = {
			BackgroundColor3 = "Element",
			BackgroundTransparency = "ElementTransparency",
		},
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		Element.Border,
		Element.LabelHolder,
	})
	
	function Element:SetTitle(Set)
		Element.TitleLabel.Text = Set
	end
	
	function Element:SetDesc(Set)
		if Set == nil then
			Set = ""
		end
		if Set == "" then
			Element.DescLabel.Visible = false
		else
			Element.DescLabel.Visible = true
		end
		Element.DescLabel.Text = Set
	end
	
	function Element:Destroy()
		Element.Frame:Destroy()
	end
	
	Element:SetTitle(Title)
	Element:SetDesc(Desc)
	
	if Hover then
		local Motor, SetTransparency = Creator.SpringMotor(
			Creator.GetThemeProperty("ElementTransparency"),
			Element.Frame,
			"BackgroundTransparency",
			false,
			true
		)
		
		Creator.AddSignal(Element.Frame.MouseEnter, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
		end)
		Creator.AddSignal(Element.Frame.MouseLeave, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency"))
		end)
		Creator.AddSignal(Element.Frame.MouseButton1Down, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency") + Creator.GetThemeProperty("HoverChange"))
		end)
		Creator.AddSignal(Element.Frame.MouseButton1Up, function()
			SetTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
		end)
	end
	
	return setmetatable(Element, {
		__newindex = function(self, index, newvalue)
			if index == "Title" then
				Element:SetTitle(newvalue)
			elseif index == "Description" or index == "Desc" then
				Element:SetDesc(newvalue)
			end
			return rawset(self, index, newvalue)
		end
	})
end

-- Section Component
Components.Section = function(Title, Parent)
	local Section = {}
	
	Section.Layout = Creator.New("UIListLayout", {
		Padding = UDim.new(0, 5),
	})
	
	Section.Container = Creator.New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 24),
		BackgroundTransparency = 1,
	}, {
		Section.Layout,
	})
	
	Section.Root = Creator.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		Creator.New("TextLabel", {
			RichText = true,
			Text = Title,
			TextTransparency = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 18,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Size = UDim2.new(1, -16, 0, 18),
			Position = UDim2.fromOffset(0, 2),
			ThemeTag = {
				TextColor3 = "Text",
			},
		}),
		Section.Container,
	})
	
	Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Section.Container.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y)
		Section.Root.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y + 25)
	end)
	
	return Section
end

-- Textbox Component
Components.Textbox = function(Parent, Acrylic)
	local Textbox = {}
	
	Acrylic = Acrylic or false
	
	Textbox.Input = Creator.New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(10, 0),
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "SubText",
		},
	})
	
	Textbox.Container = Creator.New("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -12, 1, 0),
	}, {
		Textbox.Input,
	})
	
	Textbox.Indicator = Creator.New("Frame", {
		Size = UDim2.new(1, -4, 0, 1),
		Position = UDim2.new(0, 2, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = Acrylic and 0.5 or 0,
		ThemeTag = {
			BackgroundColor3 = Acrylic and "InputIndicator" or "DialogInputLine",
		},
	})
	
	Textbox.Frame = Creator.New("Frame", {
		Size = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = Acrylic and 0.9 or 0,
		Parent = Parent,
		ThemeTag = {
			BackgroundColor3 = Acrylic and "Input" or "DialogInput",
		},
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		Creator.New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = Acrylic and 0.5 or 0.65,
			ThemeTag = {
				Color = Acrylic and "InElementBorder" or "DialogButtonBorder",
			},
		}),
		Textbox.Indicator,
		Textbox.Container,
	})
	
	local function Update()
		local PADDING = 2
		local Reveal = Textbox.Container.AbsoluteSize.X
		
		if not Textbox.Input:IsFocused() or Textbox.Input.TextBounds.X <= Reveal - 2 * PADDING then
			Textbox.Input.Position = UDim2.new(0, PADDING, 0, 0)
		else
			local Cursor = Textbox.Input.CursorPosition
			if Cursor ~= -1 then
				local subtext = string.sub(Textbox.Input.Text, 1, Cursor - 1)
				local width = 0
				-- Simplified text measurement
				pcall(function()
					width = game:GetService("TextService"):GetTextSize(
						subtext,
						Textbox.Input.TextSize,
						Textbox.Input.FontFace.Family,
						Vector2.new(math.huge, math.huge)
					).X
				end)
				
				local CurrentCursorPos = Textbox.Input.Position.X.Offset + width
				if CurrentCursorPos < PADDING then
					Textbox.Input.Position = UDim2.fromOffset(PADDING - width, 0)
				elseif CurrentCursorPos > Reveal - PADDING - 1 then
					Textbox.Input.Position = UDim2.fromOffset(Reveal - width - PADDING - 1, 0)
				end
			end
		end
	end
	
	task.spawn(Update)
	
	Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("Text"), Update)
	Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("CursorPosition"), Update)
	
	Creator.AddSignal(Textbox.Input.Focused, function()
		Update()
		Textbox.Indicator.Size = UDim2.new(1, -2, 0, 2)
		Textbox.Indicator.Position = UDim2.new(0, 1, 1, 0)
		Textbox.Indicator.BackgroundTransparency = 0
		Creator.OverrideTag(Textbox.Frame, { BackgroundColor3 = Acrylic and "InputFocused" or "DialogHolder" })
		Creator.OverrideTag(Textbox.Indicator, { BackgroundColor3 = "Accent" })
	end)
	
	Creator.AddSignal(Textbox.Input.FocusLost, function()
		Update()
		Textbox.Indicator.Size = UDim2.new(1, -4, 0, 1)
		Textbox.Indicator.Position = UDim2.new(0, 2, 1, 0)
		Textbox.Indicator.BackgroundTransparency = 0.5
		Creator.OverrideTag(Textbox.Frame, { BackgroundColor3 = Acrylic and "Input" or "DialogInput" })
		Creator.OverrideTag(Textbox.Indicator, { BackgroundColor3 = Acrylic and "InputIndicator" or "DialogInputLine" })
	end)
	
	return Textbox
end

-- Button Component
Components.Button = function(Theme, Parent, DialogCheck)
	local Button = {}
	
	DialogCheck = DialogCheck or false
	
	Button.Title = Creator.New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ThemeTag = {
			TextColor3 = "Text",
		},
	})
	
	Button.HoverFrame = Creator.New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ThemeTag = {
			BackgroundColor3 = "Hover",
		},
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})
	
	Button.Frame = Creator.New("TextButton", {
		Size = UDim2.new(0, 0, 0, 32),
		Parent = Parent,
		Text = "",
		ThemeTag = {
			BackgroundColor3 = "DialogButton",
		},
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		Creator.New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = 0.65,
			ThemeTag = {
				Color = "DialogButtonBorder",
			},
		}),
		Button.HoverFrame,
		Button.Title,
	})
	
	local Motor, SetTransparency = Creator.SpringMotor(1, Button.HoverFrame, "BackgroundTransparency", DialogCheck)
	Creator.AddSignal(Button.Frame.MouseEnter, function()
		SetTransparency(0.97)
	end)
	Creator.AddSignal(Button.Frame.MouseLeave, function()
		SetTransparency(1)
	end)
	Creator.AddSignal(Button.Frame.MouseButton1Down, function()
		SetTransparency(1)
	end)
	Creator.AddSignal(Button.Frame.MouseButton1Up, function()
		SetTransparency(0.97)
	end)
	
	return Button
end

-- Notification Component
Components.Notification = {}

function Components.Notification:Init(GUI)
	Components.Notification.Holder = Creator.New("Frame", {
		Position = UDim2.new(1, -30, 1, -30),
		Size = UDim2.new(0, 310, 1, -30),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Parent = GUI,
	}, {
		Creator.New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 20),
		}),
	})
end

function Components.Notification:New(Config)
	local NewNotification = {
		Closed = false,
	}
	
	Config.Title = Config.Title or "Title"
	Config.Content = Config.Content or "Content"
	Config.SubContent = Config.SubContent or ""
	Config.Duration = Config.Duration or nil
	Config.Buttons = Config.Buttons or {}
	Config.Sound = Config.Sound or {}
	
	Config.Sound.Parent = game:GetService("SoundService")
	Config.Sound.PlayOnRemove = true
	
	NewNotification.AcrylicPaint = Acrylic.AcrylicBlur()
	
	NewNotification.Title = Creator.New("TextLabel", {
		Position = UDim2.new(0, 14, 0, 17),
		Text = Config.Title,
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextSize = 13,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, -12, 0, 12),
		TextWrapped = true,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})
	
	NewNotification.ContentLabel = Creator.New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Config.Content,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		TextWrapped = true,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})
	
	NewNotification.SubContentLabel = Creator.New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Config.SubContent,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextWrapped = true,
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})
	
	NewNotification.LabelHolder = Creator.New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 40),
		Size = UDim2.new(1, -28, 0, 0),
	}, {
		Creator.New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 3),
		}),
		NewNotification.ContentLabel,
		NewNotification.SubContentLabel,
	})
	
	NewNotification.CloseButton = Creator.New("TextButton", {
		Text = "✕",
		Position = UDim2.new(1, -14, 0, 13),
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		TextSize = 14,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})
	
	NewNotification.Root = Creator.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(1, 0),
	}, {
		NewNotification.AcrylicPaint.Frame,
		NewNotification.Title,
		NewNotification.CloseButton,
		NewNotification.LabelHolder,
	})
	
	if Config.Content == "" then
		NewNotification.ContentLabel.Visible = false
	end
	
	if Config.SubContent == "" then
		NewNotification.SubContentLabel.Visible = false
	end
	
	NewNotification.Holder = Creator.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 200),
		Parent = Components.Notification.Holder,
	}, {
		NewNotification.Root,
	})
	
	local RootMotor = Flipper.GroupMotor.new({
		Scale = 1,
		Offset = 60,
	})
	
	RootMotor:onStep(function(Values)
		NewNotification.Root.Position = UDim2.new(Values.Scale, Values.Offset, 0, 0)
	end)
	
	Creator.AddSignal(NewNotification.CloseButton.MouseButton1Click, function()
		NewNotification:Close()
	end)
	
	function NewNotification:Open()
		local ContentSize = NewNotification.LabelHolder.AbsoluteSize.Y
		NewNotification.Holder.Size = UDim2.new(1, 0, 0, 58 + ContentSize)
		
		if Config.Sound.SoundId then
			NewNotification.Sound = Creator.New("Sound", Config.Sound)
			
			if not NewNotification.Sound.IsLoaded then
				NewNotification.Sound.Loaded:Wait()
			end
			
			NewNotification.Sound:Destroy()
			NewNotification.Sound = nil
		end
		
		RootMotor:setGoal({
			Scale = Flipper.Spring.new(0, { frequency = 5 }),
			Offset = Flipper.Spring.new(0, { frequency = 5 }),
		})
	end
	
	function NewNotification:Close()
		if not NewNotification.Closed then
			NewNotification.Closed = true
			task.spawn(function()
				RootMotor:setGoal({
					Scale = Flipper.Spring.new(1, { frequency = 5 }),
					Offset = Flipper.Spring.new(60, { frequency = 5 }),
				})
				task.wait(0.4)
				if NewNotification.AcrylicPaint.Model and NewNotification.AcrylicPaint.Model.Destroy then
					NewNotification.AcrylicPaint.Model:Destroy()
				end
				NewNotification.Holder:Destroy()
			end)
		end
	end
	
	NewNotification:Open()
	if Config.Duration then
		task.delay(Config.Duration, function()
			NewNotification:Close()
		end)
	end
	return NewNotification
end

-- Initialize Acrylic (simplified)
local Acrylic = {
	AcrylicBlur = function() 
		return {
			Frame = Creator.New("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.15,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ThemeTag = {
					BackgroundColor3 = "AcrylicMain",
				},
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				Creator.New("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Transparency = 0.3,
					ThemeTag = {
						Color = "AcrylicBorder",
					},
				}),
			}), 
			Model = {}, 
			AddParent = function() end, 
			SetVisibility = function() end
		} 
	end,
	CreateAcrylic = function() return {} end,
	AcrylicPaint = function() 
		return {
			Frame = Creator.New("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.15,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ThemeTag = {
					BackgroundColor3 = "AcrylicMain",
				},
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				Creator.New("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Transparency = 0.3,
					ThemeTag = {
						Color = "AcrylicBorder",
					},
				}),
			}),
			Model = {},
			AddParent = function() end,
			SetVisibility = function() end
		}
	end,
}

function Acrylic.init()
	-- Simplified init
end

-- Main Library
FluentRenewed.Version = "1.0.5"
FluentRenewed.Theme = "Dark"
FluentRenewed.UseAcrylic = false
FluentRenewed.Acrylic = false
FluentRenewed.Transparency = true
FluentRenewed.OpenFrames = {}
FluentRenewed.Options = {}
FluentRenewed.DialogOpen = false
FluentRenewed.Unloaded = false
FluentRenewed.Loaded = true
FluentRenewed.CreatedWindow = nil
FluentRenewed.MinimizeKey = Enum.KeyCode.LeftControl
FluentRenewed.Connections = Creator.Signals

-- Utilities
FluentRenewed.Utilities = {
	Themes = Themes,
	Shared = SharedTable,
	Creator = Creator,
	Clone = Clone
}

function FluentRenewed.Utilities:Resize(X: number, Y: number): (number, number)
    local x, y, CurrentSize = X / 1920, Y / 1080, Camera.ViewportSize
    return CurrentSize.X * x, CurrentSize.Y * y
end

function FluentRenewed.Utilities:Truncate(number: number, decimals: number, round: boolean): number
	local shift = 10 ^ (typeof(decimals) == "number" and math.max(decimals, 0) or 0)

	if round then
		return math.round(number * shift) // 1 / shift
	else
		return number * shift // 1 / shift
	end
end

function FluentRenewed.Utilities:Round(Number: number, Factor: number): number
	return FluentRenewed.Utilities:Truncate(Number, Factor, true)
end

function FluentRenewed.Utilities:GetIcon(Name: string): { Image: string, ImageRectSize: Vector2, ImageRectOffset: Vector2 }
	return Name ~= "SetIcon" and Icons and Icons[Name] or nil
end

function FluentRenewed.Utilities:Prettify(ToPrettify: EnumItem & string & number): string | number
	if typeof(ToPrettify) == "EnumItem" then
		return ({ToPrettify.Name:gsub("(%l)(%u)", "%1 %2")})[1]
	elseif typeof(ToPrettify) == "string" then
		return ({ToPrettify:gsub("(%l)(%u)", "%1 %2")})[1]
	elseif typeof(ToPrettify) == "number" then
		return FluentRenewed.Utilities:Round(ToPrettify, 2)
	else
		return tostring(ToPrettify)
	end
end

function FluentRenewed.Utilities:GetOS()
	local OSName = "Unknown"
	
	if GuiService:IsTenFootInterface() then
		local L2Button_Name = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonL2)

		OSName = if L2Button_Name == "ButtonLT" then "Xbox" elseif L2Button_Name == "ButtonL2" then "PlayStation" else "Console"
	elseif GuiService.IsWindows then
		OSName = "Windows"
	elseif version():find("^0.") == 1 then
		OSName = "macOS"
	elseif version():find("^2.") == 1 then
		OSName = UserInputService.VREnabled and "MetaHorizon" or "Mobile"
	end

	return OSName
end

FluentRenewed.Themes = Themes.Names

-- GUI Setup with proper parent
FluentRenewed.GUI = Creator.New("ScreenGui", {
	Name = "FluentRenewed",
	Parent = GetProperParent(),
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

FluentRenewed.UIContainer = FluentRenewed.GUI.Parent

function FluentRenewed:SafeCallback(Function, ...)
	assert(typeof(Function) == "function", debug.traceback(`FluentRenewed:SafeCallback expects type 'function' at Argument #1, got '{typeof(Function)}'`, 2))

	task.spawn(function(...)
		local Success, Event = pcall(Function, ...)

		if not Success then
			local _, i = Event:find(":%d+: ")
	
			task.defer(error, debug.traceback(Event, 2))
	
			FluentRenewed:Notify({
				Title = "Interface",
				Content = "Callback error",
				SubContent = if typeof(i) == "number" then Event:sub(i + 1) else Event,
				Duration = 5,
			})
		end
	end, ...)
end

function FluentRenewed:ToggleAcrylic(Value: boolean)
	if FluentRenewed.CreatedWindow then
		if FluentRenewed.UseAcrylic then
			FluentRenewed.Acrylic = Value
			if FluentRenewed.CreatedWindow.AcrylicPaint and FluentRenewed.CreatedWindow.AcrylicPaint.Model then
				FluentRenewed.CreatedWindow.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
			end
			if Value then
				Acrylic.Enable()
			else
				Acrylic.Disable()
			end
		end
	end
end

function FluentRenewed:ToggleTransparency(Value: boolean)
	if FluentRenewed.CreatedWindow then
		FluentRenewed.Transparency = Value
		if FluentRenewed.CreatedWindow.AcrylicPaint and FluentRenewed.CreatedWindow.AcrylicPaint.Frame then
			FluentRenewed.CreatedWindow.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.35 or 0
		end
	end
end

function FluentRenewed:Destroy()
	if FluentRenewed.CreatedWindow then
		FluentRenewed.Unloaded = true
		FluentRenewed.Loaded = false

		if FluentRenewed.UseAcrylic and FluentRenewed.CreatedWindow.AcrylicPaint and FluentRenewed.CreatedWindow.AcrylicPaint.Model then
			FluentRenewed.CreatedWindow.AcrylicPaint.Model:Destroy()
		end

		Creator.Disconnect()

		for i,v in next, FluentRenewed.Connections do
			local type = typeof(v)

			if type == "RBXScriptConnection" and v.Connected then
				v:Disconnect()
			end
		end

		local info, tweenProps, doTween = TweenInfo.new(2 / 3, Enum.EasingStyle.Quint), {}, false

		local function IsA(obj: Instance, class: string)
			local isClass = obj:IsA(class)

			if isClass then
				doTween = true
			end

			return isClass
		end

		for i,v in next, FluentRenewed.GUI:GetDescendants() do
			table.clear(tweenProps)

			if IsA(v, "GuiObject") then
				tweenProps.BackgroundTransparency = 1
			end

			if IsA(v, "ScrollingFrame") then
				tweenProps.ScrollBarImageTransparency = 1		
			end

			if IsA(v, "TextLabel") or IsA(v, "TextBox") then
				tweenProps.TextStrokeTransparency = 1
				tweenProps.TextTransparency = 1
			end

			if IsA(v, "UIStroke") then
				tweenProps.Transparency = 1
			end

			if IsA(v, "ImageLabel") or IsA(v, "ImageButton") then
				tweenProps.ImageTransparency = 1
			end

			if doTween then
				doTween = false
				TweenService:Create(v, info, tweenProps):Play()
			end
		end

		task.delay(info.Time, function()
			FluentRenewed.GUI:Destroy()
		end)
	end
end

-- SaveManager for Config System
local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
	SaveManager.Options, SaveManager.Library = {}, {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value, Timestamp = os.time() } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = object.Value, Timestamp = os.time() }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi, Timestamp = os.time() }
			end,
			Load = function(idx, data)
				if data.value == nil then return end
				local DropdownElement = SaveManager.Options[idx]
				if DropdownElement then
					DropdownElement:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), Timestamp = os.time() }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value))
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value, Timestamp = os.time() }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value, Timestamp = os.time() }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			`{self.Folder}/settings`
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
		self.Options = library.Options
	end

	SaveManager:BuildFolderTree()
end

-- InterfaceManager for UI Settings  
local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentRenewedSettings"

    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = true,
        Transparency = true,
        MenuKeybind = Enum.KeyCode.RightControl
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library

		InterfaceManager.Settings = {
			Theme = self.Library.Theme or "Dark",
			Acrylic = self.Library.UseAcrylic or true,
			Transparency = self.Library.Transparency or true,
			MenuKeybind = self.Library.MinimizeKey or Enum.KeyCode.RightControl
		}
	end

    function InterfaceManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split("/")

		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end
		
		paths[#paths + 1] = self.Folder
		paths[#paths + 1] = `{self.Folder}/settings`

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function InterfaceManager:SaveSettings()
        writefile(`{self.Folder}/options.json`, HttpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = `{self.Folder}/options.json`

        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end
end

-- Expose Addons
FluentRenewed.SaveManager = SaveManager
FluentRenewed.InterfaceManager = InterfaceManager

function FluentRenewed:SetTheme(Theme)
	if table.find(Themes.Names, Theme) then
		FluentRenewed.Theme = Theme
		Creator.UpdateTheme()
	end
end

function FluentRenewed:ToggleAcrylic(Value)
	FluentRenewed.Acrylic = Value
	-- Acrylic toggle logic would go here
end

function FluentRenewed:ToggleTransparency(Value)
	FluentRenewed.Transparency = Value
	-- Transparency toggle logic would go here
end

function FluentRenewed:Notify(Config)
	-- Simple notification
	print("Notification:", Config.Title, "-", Config.Content)
end

function FluentRenewed:Destroy()
	FluentRenewed.Unloaded = true
	if FluentRenewed.GUI then
		FluentRenewed.GUI:Destroy()
	end
end

-- Window Creation
function FluentRenewed:CreateWindow(Config)
	Config = Config or {}
	Config.Title = Config.Title or "Fluent Renewed"
	Config.SubTitle = Config.SubTitle or ""
	Config.Size = Config.Size or UDim2.fromOffset(830, 525)
	Config.MinSize = Config.MinSize or Vector2.new(470, 380)
	Config.TabWidth = Config.TabWidth or 160
	Config.Resize = Config.Resize or true
	Config.Acrylic = Config.Acrylic or false
	Config.Theme = Config.Theme or "Dark"
	Config.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.RightControl
	Config.Parent = FluentRenewed.GUI
	
	FluentRenewed.Theme = Config.Theme
	FluentRenewed.UseAcrylic = Config.Acrylic
	FluentRenewed.MinimizeKey = Config.MinimizeKey
	
	-- Mobile Configuration
	Config.Mobile = Config.Mobile or {
		GetIcon = function(Minimized)
			return {
				Image = "rbxassetid://10709751939",
				ImageRectOffset = Vector2.new(4, 4),
				ImageRectSize = Vector2.new(16, 16)
			}
		end,
		Size = UDim2.fromOffset(50, 50)
	}
	
	local Window = {
		Minimized = false,
		OnMinimized = Signal.new(),
		PostMinimized = Signal.new(),
		Maximized = false,
		OnMaximized = Signal.new(),
		PostMaximized = Signal.new(),
		Size = Config.Size,
		MinSize = Config.MinSize,
		CurrentPos = 0,
		TabWidth = Config.TabWidth,
		Position = UDim2.fromOffset(
			game:GetService("Workspace").CurrentCamera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
			game:GetService("Workspace").CurrentCamera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
		),
		Tabs = {},
		TabCount = 0,
		SelectedTab = 0
	}
	
	Window.AcrylicPaint = Acrylic.AcrylicPaint()
	
	local Selector = Creator.New("Frame", {
		Size = UDim2.fromOffset(4, 0),
		BackgroundColor3 = Color3.fromRGB(76, 194, 255),
		Position = UDim2.fromOffset(0, 17),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
	})
	
	Window.TabHolder = Creator.New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		Creator.New("UIListLayout", {
			Padding = UDim.new(0, 4),
		}),
	})
	
	local TabFrame = Creator.New("Frame", {
		Size = UDim2.new(0, Window.TabWidth, 1, -66),
		Position = UDim2.new(0, 12, 0, 54),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		Window.TabHolder,
		Selector,
	})
	
	Window.TabDisplay = Creator.New("TextLabel", {
		RichText = true,
		Text = "Tab",
		TextTransparency = 0,
		FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		TextSize = 28,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 56),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})
	
	Window.ContainerHolder = Creator.New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})
	
	Window.ContainerAnim = Creator.New("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})
	
	Window.ContainerCanvas = Creator.New("Frame", {
		Size = UDim2.new(1, -Window.TabWidth - 32, 1, -102),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 90),
		BackgroundTransparency = 1,
	}, {
		Window.ContainerAnim,
		Window.ContainerHolder
	})
	
	Window.Root = Creator.New("Frame", {
		BackgroundTransparency = 1,
		Size = Window.Size,
		Position = Window.Position,
		Parent = Config.Parent,
	}, {
		Window.AcrylicPaint.Frame,
		Window.TabDisplay,
		Window.ContainerCanvas,
		TabFrame,
	})
	
	-- Title Bar
	local TitleBarFrame = Creator.New("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		Parent = Window.Root
	}, {
		Creator.New("Frame", {
			BackgroundTransparency = 0.5,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			ThemeTag = {
				BackgroundColor3 = "TitleBarLine",
			}
		})
	})
	
	-- Window Dragging Functionality
	local UserInputService = game:GetService("UserInputService")
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	local function UpdateInput(input)
		local delta = input.Position - dragStart
		Window.Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	
	Creator.AddSignal(TitleBarFrame.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Window.Root.Position
			
			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					connection:Disconnect()
				end
			end)
		end
	end)
	
	Creator.AddSignal(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateInput(input)
		end
	end)
	
	local TitleHolder = Creator.New("Frame", {
		Size = UDim2.new(1, -16, 1, 0),
		Parent = TitleBarFrame,
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
	}, {
		Creator.New("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	})
	
	local Title = Creator.New("TextLabel", {
		RichText = true,
		Text = Config.Title,
		Parent = TitleHolder,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextSize = 12,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		}
	})
	
	local SubTitle = Creator.New("TextLabel", {
		RichText = true,
		Text = Config.SubTitle,
		Parent = TitleHolder,
		TextTransparency = 0.4,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextSize = 12,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		}
	})
	
	-- Motors
	local SizeMotor = Flipper.GroupMotor.new({
		X = Window.Size.X.Offset,
		Y = Window.Size.Y.Offset,
	})
	
	local PosMotor = Flipper.GroupMotor.new({
		X = Window.Position.X.Offset,
		Y = Window.Position.Y.Offset,
	})
	
	Window.SelectorPosMotor = Flipper.SingleMotor.new(17)
	Window.SelectorSizeMotor = Flipper.SingleMotor.new(0)
	Window.ContainerBackMotor = Flipper.SingleMotor.new(0)
	Window.ContainerPosMotor = Flipper.SingleMotor.new(94)
	
	SizeMotor:onStep(function(values)
		Window.Root.Size = UDim2.new(0, values.X, 0, values.Y)
	end)
	
	PosMotor:onStep(function(values)
		Window.Root.Position = UDim2.new(0, values.X, 0, values.Y)
	end)
	
	Window.SelectorPosMotor:onStep(function(Value)
		Selector.Position = UDim2.new(0, 0, 0, Value + 17)
		Window.SelectorSizeMotor:setGoal(Flipper.Spring.new(16, { frequency = 6 }))
	end)
	
	Window.SelectorSizeMotor:onStep(function(Value)
		Selector.Size = UDim2.new(0, 4, 0, Value)
	end)
	
	Window.ContainerBackMotor:onStep(function(Value)
		Window.ContainerAnim.GroupTransparency = Value
	end)
	
	Window.ContainerPosMotor:onStep(function(Value)
		Window.ContainerAnim.Position = UDim2.fromOffset(0, Value)
	end)
	
	-- Tab Creation
	function Window:CreateTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Title = TabConfig.Title or "Tab"
		TabConfig.Icon = TabConfig.Icon or nil
		
		local Tab = {
			Selected = false,
			Name = TabConfig.Title,
			Type = "Tab",
			Container = nil,
		}
		
		Window.TabCount = Window.TabCount + 1
		local TabIndex = Window.TabCount
		
		local Icon = TabConfig.Icon and Utilities:GetIcon(TabConfig.Icon) or nil
		
		Tab.Frame = Creator.New("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundTransparency = 1,
			Parent = Window.TabHolder,
			ThemeTag = {
				BackgroundColor3 = "Tab",
			},
		}, {
			Creator.New("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			Creator.New("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = Icon and UDim2.new(0, 30, 0.5, 0) or UDim2.new(0, 12, 0.5, 0),
				Text = TabConfig.Title,
				RichText = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextTransparency = 0,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextSize = 12,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				Size = UDim2.new(1, -12, 1, 0),
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
			Icon and Creator.New("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(0, 8, 0.5, 0),
				BackgroundTransparency = 1,
				ImageRectOffset = Icon.ImageRectOffset,
				ImageRectSize = Icon.ImageRectSize,
				Image = Icon.Image,
				ThemeTag = {
					ImageColor3 = "Text",
				},
			}) or nil,
		})
		
		local ContainerLayout = Creator.New("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		
		Tab.Container = Creator.New("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = Window.ContainerHolder,
			Visible = false,
			BottomImage = "rbxassetid://6889812791",
			MidImage = "rbxassetid://6889812721",
			TopImage = "rbxassetid://6276641225",
			ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
			ScrollBarImageTransparency = 0.95,
			ScrollBarThickness = 3,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromScale(0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, {
			ContainerLayout,
			Creator.New("UIPadding", {
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 1),
				PaddingTop = UDim.new(0, 1),
				PaddingBottom = UDim.new(0, 1),
			}),
		})
		
		Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Tab.Container.CanvasSize = UDim2.fromOffset(0, ContainerLayout.AbsoluteContentSize.Y + 2)
		end)
		
		Tab.Motor, Tab.SetTransparency = Creator.SpringMotor(1, Tab.Frame, "BackgroundTransparency")
		
		Creator.AddSignal(Tab.Frame.MouseEnter, function()
			Tab.SetTransparency(Tab.Selected and 0.85 or 0.89)
		end)
		Creator.AddSignal(Tab.Frame.MouseLeave, function()
			Tab.SetTransparency(Tab.Selected and 0.89 or 1)
		end)
		Creator.AddSignal(Tab.Frame.MouseButton1Click, function()
			Window:SelectTab(TabIndex)
		end)
		
		Window.Tabs[TabIndex] = Tab
		
		-- Elements creation methods
		Tab.Elements = {}
		Tab.Library = FluentRenewed
		Tab.ScrollFrame = Tab.Container
		
		function Tab:CreateSection(SectionTitle)
			local Section = {
				Type = "Section",
				Container = nil,
				ScrollFrame = Tab.Container,
				Library = FluentRenewed
			}
			
			local SectionFrame = Components.Section(SectionTitle, Tab.Container)
			Section.Container = SectionFrame.Container
			
			-- Add element creation methods to section
			Section.CreateButton = function(self, Config)
				return Tab:CreateButton(Config, Section.Container)
			end
			
			Section.CreateToggle = function(self, Idx, Config)
				return Tab:CreateToggle(Idx, Config, Section.Container)
			end
			
			Section.CreateSlider = function(self, Idx, Config)
				return Tab:CreateSlider(Idx, Config, Section.Container)
			end
			
			Section.CreateDropdown = function(self, Idx, Config)
				return Tab:CreateDropdown(Idx, Config, Section.Container)
			end
			
			Section.CreateInput = function(self, Idx, Config)
				return Tab:CreateInput(Idx, Config, Section.Container)
			end
			
			Section.CreateParagraph = function(self, Idx, Config)
				return Tab:CreateParagraph(Idx, Config, Section.Container)
			end
			
			Section.CreateColorpicker = function(self, Idx, Config)
				return Tab:CreateColorpicker(Idx, Config, Section.Container)
			end
			
			Section.CreateKeybind = function(self, Idx, Config)
				return Tab:CreateKeybind(Idx, Config, Section.Container)
			end
			
			return Section
		end
		
		Tab.CreateSection = Tab.CreateSection
		Tab.AddSection = Tab.CreateSection
		Tab.Section = Tab.CreateSection
		
		-- Element creation methods
		function Tab:CreateButton(Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			
			local Button = {
				Title = Config.Title or "Button",
				Description = Config.Description,
				Callback = Config.Callback or function() end,
				Type = "Button"
			}
			
			local ButtonFrame = Components.Element(Button.Title, Button.Description, Parent, true)
			
			local ButtonIco = Creator.New("ImageLabel", {
				Size = UDim2.fromOffset(16, 16),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				BackgroundTransparency = 1,
				Parent = ButtonFrame.Frame,
				ThemeTag = {
					ImageColor3 = "Text",
				}
			})
			
			Utilities:SetIcon(ButtonIco, "chevron-right")
			
			Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
				FluentRenewed:SafeCallback(Button.Callback)
			end)
			
			return Button
		end
		
		function Tab:CreateToggle(Idx, Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			Idx = Idx or tostring(math.random(1000000, 9999999))
			
			local Toggle = {
				Value = Config.Default or false,
				Callback = Config.Callback or function() end,
				Type = "Toggle",
			}
			
			local ToggleFrame = Components.Element(Config.Title, Config.Description, Parent, true)
			
			local ToggleCircle = Creator.New("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.new(0, 2, 0.5, 0),
				Image = "http://www.roblox.com/asset/?id=12266946128",
				ImageTransparency = 0.5,
				ThemeTag = {
					ImageColor3 = "ToggleSlider",
				},
			})
			
			local ToggleSlider = Creator.New("Frame", {
				Size = UDim2.fromOffset(36, 18),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Parent = ToggleFrame.Frame,
				BackgroundTransparency = 1,
				ThemeTag = {
					BackgroundColor3 = "Accent",
				},
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 9),
				}),
				Creator.New("UIStroke", {
					Transparency = 0.5,
					ThemeTag = {
						Color = "ToggleSlider",
					},
				}),
				ToggleCircle,
			})
			
			function Toggle:SetValue(Value)
				Toggle.Value = not not Value
				
				game:GetService("TweenService"):Create(
					ToggleCircle,
					TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0, Toggle.Value and 19 or 2, 0.5, 0) }
				):Play()
				
				game:GetService("TweenService"):Create(
					ToggleSlider,
					TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ BackgroundTransparency = Toggle.Value and 0 or 1 }
				):Play()
				
				ToggleCircle.ImageTransparency = Toggle.Value and 0 or 0.5
				
				FluentRenewed:SafeCallback(Toggle.Callback, Toggle.Value)
			end
			
			function Toggle:OnChanged(Func)
				Toggle.Changed = Func
				FluentRenewed:SafeCallback(Func, Toggle.Value)
			end
			
			Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
				Toggle:SetValue(not Toggle.Value)
			end)
			
			Toggle:SetValue(Toggle.Value)
			
			FluentRenewed.Options[Idx] = Toggle
			
			return Toggle
		end
		
		function Tab:CreateSlider(Idx, Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			Idx = Idx or tostring(math.random(1000000, 9999999))
			
			local Slider = {
				Value = Config.Default or Config.Min or 0,
				Min = Config.Min or 0,
				Max = Config.Max or 100,
				Rounding = Config.Rounding or 0,
				Callback = Config.Callback or function() end,
				Type = "Slider"
			}
			
			local SliderFrame = Components.Element(Config.Title or "Slider", Config.Description, Parent, false)
			
			local SliderDisplay = Creator.New("TextBox", {
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				Text = tostring(Slider.Value),
				ClearTextOnFocus = true,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 100, 0, 14),
				Position = UDim2.new(1, -10, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Parent = SliderFrame.Frame,
				ThemeTag = {
					TextColor3 = "SubText",
				}
			})
			
			function Slider:SetValue(Value)
				local OldValue = Slider.Value
				Slider.Value = Utilities:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
				SliderDisplay.Text = tostring(Slider.Value)
				FluentRenewed:SafeCallback(Slider.Callback, Slider.Value, OldValue)
			end
			
			function Slider:OnChanged(Func)
				Slider.Changed = Func
				FluentRenewed:SafeCallback(Func, Slider.Value)
			end
			
			Creator.AddSignal(SliderDisplay.FocusLost, function()
				Slider:SetValue(tonumber(SliderDisplay.Text) or Slider.Value)
			end)
			
			Slider:SetValue(Slider.Value)
			
			FluentRenewed.Options[Idx] = Slider
			
			return Slider
		end
		
		function Tab:CreateDropdown(Idx, Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			Idx = Idx or tostring(math.random(1000000, 9999999))
			
			local Dropdown = {
				Values = Config.Values or {},
				Value = Config.Default,
				Multi = Config.Multi or false,
				Callback = Config.Callback or function() end,
				Type = "Dropdown"
			}
			
			local DropdownFrame = Components.Element(Config.Title or "Dropdown", Config.Description, Parent, false)
			
			local DropdownDisplay = Creator.New("TextLabel", {
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				Text = "--",
				TextColor3 = Color3.fromRGB(240, 240, 240),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -30, 0, 14),
				Position = UDim2.new(0, 8, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ThemeTag = {
					TextColor3 = "Text",
				},
			})
			
			local DropdownInner = Creator.New("TextButton", {
				Size = UDim2.fromOffset(160, 30),
				Position = UDim2.new(1, -10, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 0.1,
				Parent = DropdownFrame.Frame,
				Text = "",
				ThemeTag = {
					BackgroundColor3 = "DropdownFrame"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				DropdownDisplay,
			})
			
			-- Dropdown List
			local DropdownList = Creator.New("Frame", {
				Size = UDim2.new(0, 160, 0, 0),
				Position = UDim2.new(1, -10, 1, 5),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 0.1,
				Parent = DropdownFrame.Frame,
				Visible = false,
				ZIndex = 1000,
				ThemeTag = {
					BackgroundColor3 = "DropdownHolder"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				Creator.New("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Transparency = 0.5,
					ThemeTag = {
						Color = "DropdownBorder",
					},
				}),
				Creator.New("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Creator.New("UIPadding", {
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
				}),
			})
			
			local function UpdateDropdownList()
				-- Clear existing options
				for _, child in ipairs(DropdownList:GetChildren()) do
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end
				
				-- Create new options
				for i, value in ipairs(Dropdown.Values) do
					local OptionButton = Creator.New("TextButton", {
						Size = UDim2.new(1, -10, 0, 25),
						Position = UDim2.new(0, 5, 0, 0),
						BackgroundTransparency = 1,
						Text = tostring(value),
						FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = DropdownList,
						ThemeTag = {
							TextColor3 = "DropdownOption"
						}
					})
					
					Creator.AddSignal(OptionButton.MouseButton1Click, function()
						if Dropdown.Multi then
							local CurrentValues = Dropdown.Value or {}
							local Found = false
							for j, v in ipairs(CurrentValues) do
								if v == value then
									table.remove(CurrentValues, j)
									Found = true
									break
								end
							end
							if not Found then
								table.insert(CurrentValues, value)
							end
							Dropdown:SetValue(CurrentValues)
						else
							Dropdown:SetValue(value)
							DropdownList.Visible = false
						end
					end)
					
					Creator.AddSignal(OptionButton.MouseEnter, function()
						OptionButton.BackgroundTransparency = 0.9
					end)
					
					Creator.AddSignal(OptionButton.MouseLeave, function()
						OptionButton.BackgroundTransparency = 1
					end)
				end
				
				-- Update size
				DropdownList.Size = UDim2.new(0, 160, 0, math.min(#Dropdown.Values * 25 + 10, 200))
			end
			
			-- Click handler to toggle dropdown
			Creator.AddSignal(DropdownInner.MouseButton1Click, function()
				DropdownList.Visible = not DropdownList.Visible
				if DropdownList.Visible then
					UpdateDropdownList()
				end
			end)
			
			-- Close dropdown when clicking outside
			Creator.AddSignal(game:GetService("UserInputService").InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if DropdownList.Visible then
						local mouse = game:GetService("Players").LocalPlayer:GetMouse()
						local dropdownPos = DropdownList.AbsolutePosition
						local dropdownSize = DropdownList.AbsoluteSize
						
						if mouse.X < dropdownPos.X or mouse.X > dropdownPos.X + dropdownSize.X or
						   mouse.Y < dropdownPos.Y or mouse.Y > dropdownPos.Y + dropdownSize.Y then
							DropdownList.Visible = false
						end
					end
				end
			end)
			
			function Dropdown:SetValue(Value)
				if Dropdown.Multi then
					Dropdown.Value = Value or {}
				else
					Dropdown.Value = Value
				end
				
				local Str = ""
				if Dropdown.Multi then
					for _, v in pairs(Dropdown.Value) do
						Str = Str .. tostring(v) .. ", "
					end
					Str = Str:sub(1, #Str - 2)
				else
					Str = tostring(Dropdown.Value or "")
				end
				
				DropdownDisplay.Text = Str == "" and "--" or Str
				FluentRenewed:SafeCallback(Dropdown.Callback, Dropdown.Value)
			end
			
			function Dropdown:OnChanged(Func)
				Dropdown.Changed = Func
				FluentRenewed:SafeCallback(Func, Dropdown.Value)
			end
			
			Dropdown:SetValue(Dropdown.Value)
			
			FluentRenewed.Options[Idx] = Dropdown
			
			return Dropdown
		end
		
		function Tab:CreateInput(Idx, Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			Idx = Idx or tostring(math.random(1000000, 9999999))
			
			local Input = {
				Value = Config.Default or "",
				Numeric = Config.Numeric or false,
				Finished = Config.Finished or false,
				Callback = Config.Callback or function() end,
				Type = "Input"
			}
			
			local InputFrame = Components.Element(Config.Title or "Input", Config.Description, Parent, false)
			
			local InputBox = Creator.New("TextBox", {
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				Text = Input.Value,
				PlaceholderText = Config.Placeholder or "",
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 0.1,
				Size = UDim2.fromOffset(160, 30),
				Position = UDim2.new(1, -10, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Parent = InputFrame.Frame,
				ThemeTag = {
					TextColor3 = "Text",
					BackgroundColor3 = "Input",
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				Creator.New("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
			})
			
			function Input:SetValue(Value)
				if Input.Numeric then
					Value = tonumber(Value) or 0
				end
				Input.Value = Input.Numeric and Value or tostring(Value)
				InputBox.Text = tostring(Input.Value)
				
				if not Input.Finished then
					FluentRenewed:SafeCallback(Input.Callback, Input.Value)
				end
			end
			
			function Input:OnChanged(Func)
				Input.Changed = Func
				FluentRenewed:SafeCallback(Func, Input.Value)
			end
			
			if Input.Finished then
				Creator.AddSignal(InputBox.FocusLost, function(enter)
					if enter then
						local newText = InputBox.Text
						if Input.Numeric then
							newText = newText:gsub("[^%d%.%-]", "")
							InputBox.Text = newText
						end
						Input:SetValue(newText)
						FluentRenewed:SafeCallback(Input.Callback, Input.Value)
					end
				end)
			else
				Creator.AddSignal(InputBox:GetPropertyChangedSignal("Text"), function()
					local newText = InputBox.Text
					if Input.Numeric then
						newText = newText:gsub("[^%d%.%-]", "")
						InputBox.Text = newText
					end
					Input:SetValue(newText)
				end)
			end
			
			FluentRenewed.Options[Idx] = Input
			
			return Input
		end
		
		function Tab:CreateParagraph(Idx, Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			Idx = Idx or tostring(math.random(1000000, 9999999))
			
			local Paragraph = {
				Value = Config.Content or "",
				Type = "Paragraph"
			}
			
			local ParagraphFrame = Components.Element(Config.Title or "Paragraph", Paragraph.Value, Parent, false, {
				TitleAlignment = Config.TitleAlignment,
				DescriptionAlignment = Config.ContentAlignment
			})
			
			ParagraphFrame.Frame.BackgroundTransparency = 0.15
			ParagraphFrame.Border.Transparency = 0.3
			
			function Paragraph:SetValue(Value)
				Paragraph.Value = tostring(Value or "")
				ParagraphFrame:SetDesc(Paragraph.Value)
			end
			
			FluentRenewed.Options[Idx] = Paragraph
			
			return Paragraph
		end
		
		function Tab:CreateColorpicker(Idx, Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			Idx = Idx or tostring(math.random(1000000, 9999999))
			
			assert(Config.Title, "Colorpicker - Missing Title")
			assert(Config.Default, "Colorpicker - Missing default value")
			
			local Colorpicker = {
				Value = Config.Default or Config.Value or Color3.fromRGB(255, 255, 255),
				Transparency = Config.Transparency or 0,
				UpdateOnChange = Config.UpdateOnChange or Config.UpdateWhileSliding or false,
				Type = "Colorpicker",
				Title = type(Config.Title) == "string" and Config.Title or "Colorpicker",
				Callback = Config.Callback or function(Color) end,
			}
			
			function Colorpicker:SetHSVFromRGB(Color)
				local H, S, V = Color3.toHSV(Color)
				Colorpicker.Hue = H
				Colorpicker.Sat = S
				Colorpicker.Vib = V
			end
			
			Colorpicker:SetHSVFromRGB(Colorpicker.Value)
			
			local ColorpickerFrame = Components.Element(Config.Title, Config.Description, Parent, true)
			
			Colorpicker.SetTitle = ColorpickerFrame.SetTitle
			Colorpicker.SetDesc = ColorpickerFrame.SetDesc
			
			local DisplayFrameColor = Creator.New("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Colorpicker.Value,
				Parent = ColorpickerFrame.Frame,
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),
			})
			
			local DisplayFrame = Creator.New("ImageLabel", {
				Size = UDim2.fromOffset(26, 26),
				Position = UDim2.new(1, -10, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Parent = ColorpickerFrame.Frame,
				Image = "http://www.roblox.com/asset/?id=14204231522",
				ImageTransparency = 0.45,
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.fromOffset(40, 40),
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),
				DisplayFrameColor,
			})
			
			function Colorpicker:Display()
				rawset(Colorpicker, "Value", Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib))
				
				DisplayFrameColor.BackgroundColor3 = Colorpicker.Value
				DisplayFrameColor.BackgroundTransparency = Colorpicker.Transparency
				
				if typeof(Colorpicker.Callback) == "function" then
					FluentRenewed:SafeCallback(Colorpicker.Callback, Colorpicker.Value)
				end
				if typeof(Colorpicker.Changed) == "function" then
					FluentRenewed:SafeCallback(Colorpicker.Changed, Colorpicker.Value)
				end
			end
			
			function Colorpicker:SetValue(HSV, Transparency)
				if type(HSV) == "table" then
					local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
					rawset(Colorpicker, "Transparency", Transparency or 0)
					Colorpicker:SetHSVFromRGB(Color)
				else
					-- Direct Color3 value
					rawset(Colorpicker, "Transparency", Transparency or 0)
					Colorpicker:SetHSVFromRGB(HSV)
				end
				Colorpicker:Display()
			end
			
			function Colorpicker:SetValueRGB(Color, Transparency)
				rawset(Colorpicker, "Transparency", Transparency or 0)
				Colorpicker:SetHSVFromRGB(Color)
				Colorpicker:Display()
			end
			
			function Colorpicker:OnChanged(Func)
				Colorpicker.Changed = Func
				FluentRenewed:SafeCallback(Func, Colorpicker.Value, Colorpicker.Value)
			end
			
			function Colorpicker:Destroy()
				ColorpickerFrame:Destroy()
				FluentRenewed.Options[Idx] = nil
			end
			
			Creator.AddSignal(ColorpickerFrame.Frame.MouseButton1Click, function()
				FluentRenewed:Notify({
					Title = "Colorpicker",
					Content = "Color picker dialog not implemented in simplified version",
					Duration = 2
				})
			end)
			
			Colorpicker:Display()
			
			FluentRenewed.Options[Idx] = Colorpicker
			
			Colorpicker.Instance = ColorpickerFrame
			
			return setmetatable(Colorpicker, {
				__newindex = function(self, index, newvalue)
					local NewValue_Type = typeof(newvalue)
					if index == "Value" then
						if NewValue_Type == "table" then
							task.spawn(Colorpicker.SetValue, Colorpicker, newvalue, Colorpicker.Transparency)
						else
							task.spawn(Colorpicker.SetValueRGB, Colorpicker, newvalue, Colorpicker.Transparency)
						end
					elseif index == "Transparency" and NewValue_Type == "number" then
						task.spawn(Colorpicker.SetValueRGB, Colorpicker, Colorpicker.Value, newvalue)
					else
						rawset(self, index, newvalue)
					end
				end
			})
		end
		
		function Tab:CreateKeybind(Idx, Config, Parent)
			Config = Config or {}
			Parent = Parent or Tab.Container
			Idx = Idx or tostring(math.random(1000000, 9999999))
			
			local Keybind = {
				Value = Config.Default or Config.Value or Enum.KeyCode.Unknown,
				Toggled = false,
				Mode = Config.Mode or "Toggle",
				Type = "Keybind",
				Callback = Config.Callback or function(Value) end,
				ChangedCallback = Config.ChangedCallback or function(New) end,
			}
			
			local Picking = false
			
			local KeybindFrame = Components.Element(Config.Title or "Keybind", Config.Description, Parent, true)
			
			Keybind.SetTitle = KeybindFrame.SetTitle
			Keybind.SetDesc = KeybindFrame.SetDesc
			
			local KeybindDisplayLabel = Creator.New("TextLabel", {
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				Text = FluentRenewed.Utilities:Prettify(Keybind.Value),
				TextColor3 = Color3.fromRGB(240, 240, 240),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(0, 0, 0, 14),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			})
			
			local KeybindDisplayFrame = Creator.New("TextButton", {
				Size = UDim2.fromOffset(0, 30),
				Position = UDim2.new(1, -10, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 0.1,
				Parent = KeybindFrame.Frame,
				AutomaticSize = Enum.AutomaticSize.X,
				Text = "",
				ThemeTag = {
					BackgroundColor3 = "Keybind",
				},
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				Creator.New("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
				Creator.New("UIStroke", {
					Transparency = 0.5,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					ThemeTag = {
						Color = "InElementBorder",
					},
				}),
				KeybindDisplayLabel,
			})
			
			function Keybind:GetState()
				local UserInputService = game:GetService("UserInputService")
				if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= "Always" then
					return false
				end
				
				if Keybind.Mode == "Always" then
					return true
				elseif Keybind.Mode == "Hold" then
					if Keybind.Value == "None" then
						return false
					end
					
					local Key = Keybind.Value
					
					if Key == "LeftMousebutton" or Key == "RightMousebutton" then
						return Key == "LeftMousebutton" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
							or Key == "RightMousebutton"
								and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
					else
						return UserInputService:IsKeyDown(Enum.KeyCode[Keybind.Value])
					end
				else
					return Keybind.Toggled
				end
			end
			
			function Keybind:SetValue(Key, Mode)
				Key = Key or Keybind.Value
				Mode = Mode or Keybind.Mode
				
				rawset(Keybind, "Value", Key)
				Keybind.Mode = Mode
				
				KeybindDisplayLabel.Text = FluentRenewed.Utilities:Prettify(Keybind.Value)
				
				if typeof(Keybind.ChangedCallback) == "function" then
					FluentRenewed:SafeCallback(Keybind.ChangedCallback, Key)
				end
				if typeof(Keybind.Changed) == "function" then
					FluentRenewed:SafeCallback(Keybind.Changed, Key)
				end
			end
			
			function Keybind:OnClick(Callback)
				Keybind.Clicked = Callback
			end
			
			function Keybind:OnChanged(Callback)
				Keybind.Changed = Callback
				FluentRenewed:SafeCallback(Callback, Keybind.Value, Keybind.Value)
			end
			
			function Keybind:DoClick()
				if typeof(Keybind.Callback) == "function" then
					FluentRenewed:SafeCallback(Keybind.Callback, Keybind.Toggled)
				end
				if typeof(Keybind.Clicked) == "function" then
					FluentRenewed:SafeCallback(Keybind.Clicked, Keybind.Toggled)
				end
			end
			
			function Keybind:Destroy()
				KeybindFrame:Destroy()
				FluentRenewed.Options[Idx] = nil
			end
			
			Creator.AddSignal(KeybindDisplayFrame.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch then
					Picking = true
					KeybindDisplayLabel.Text = "..."
					
					wait(0.2)
					
					game:GetService("UserInputService").InputBegan:Once(function(Input)
						local Key
						
						if Input.UserInputType == Enum.UserInputType.Keyboard then
							Key = Input.KeyCode.Name
						elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
							Key = "LeftMousebutton"
						elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
							Key = "RightMousebutton"
						end
						
						game:GetService("UserInputService").InputEnded:Once(function(Input)
							if (Input.KeyCode.Name == Key
								or Key == "LeftMousebutton" and Input.UserInputType == Enum.UserInputType.MouseButton1
								or Key == "RightMousebutton" and Input.UserInputType == Enum.UserInputType.MouseButton2)
								and not FluentRenewed.Unloaded then
								Picking = false
								
								Keybind.Value = Key
								
								KeybindDisplayLabel.Text = FluentRenewed.Utilities:Prettify(Keybind.Value)
								
								FluentRenewed:SafeCallback(Keybind.ChangedCallback, Input.KeyCode or Input.UserInputType)
								FluentRenewed:SafeCallback(Keybind.Changed, Input.KeyCode or Input.UserInputType)
							end
						end)
					end)
				end
			end)
			
			Creator.AddSignal(game:GetService("UserInputService").InputBegan, function(Input)
				if not Picking and not game:GetService("UserInputService"):GetFocusedTextBox() then
					if Keybind.Mode == "Toggle" then
						local Key = Keybind.Value
						
						if Key == "LeftMousebutton" or Key == "RightMousebutton" then
							if Key == "LeftMousebutton" and Input.UserInputType == Enum.UserInputType.MouseButton1
								or Key == "RightMousebutton" and Input.UserInputType == Enum.UserInputType.MouseButton2 then
								Keybind.Toggled = not Keybind.Toggled
								Keybind:DoClick()
							end
						elseif Input.UserInputType == Enum.UserInputType.Keyboard then
							if Input.KeyCode.Name == Key or Input.KeyCode == Key then
								Keybind.Toggled = not Keybind.Toggled
								Keybind:DoClick()
							end
						end
					end
				end
			end)
			
			Keybind:SetValue(Keybind.Value)
			
			FluentRenewed.Options[Idx] = Keybind
			
			Keybind.Instance = KeybindFrame
			
			return setmetatable(Keybind, {
				__newindex = function(self, index, newvalue)
					if index == "Value" then
						task.spawn(Keybind.SetValue, Keybind, newvalue)
					end
					rawset(self, index, newvalue)
				end
			})
		end
		
		Tab.CreateButton = Tab.CreateButton
		Tab.CreateToggle = Tab.CreateToggle
		Tab.CreateSlider = Tab.CreateSlider
		Tab.CreateDropdown = Tab.CreateDropdown
		Tab.CreateInput = Tab.CreateInput
		Tab.CreateParagraph = Tab.CreateParagraph
		Tab.CreateColorpicker = Tab.CreateColorpicker
		Tab.CreateKeybind = Tab.CreateKeybind
		
		-- Aliases
		Tab.Button = Tab.CreateButton
		Tab.Toggle = Tab.CreateToggle
		Tab.Slider = Tab.CreateSlider
		Tab.Dropdown = Tab.CreateDropdown
		Tab.Input = Tab.CreateInput
		Tab.Paragraph = Tab.CreateParagraph
		Tab.Colorpicker = Tab.CreateColorpicker
		Tab.Keybind = Tab.CreateKeybind
		
		return Tab
	end
	
	function Window:SelectTab(TabIndex)
		Window.SelectedTab = TabIndex
		
		for i, TabObject in pairs(Window.Tabs) do
			TabObject.SetTransparency(1)
			TabObject.Selected = false
			TabObject.Container.Visible = false
		end
		
		if Window.Tabs[TabIndex] then
			Window.Tabs[TabIndex].SetTransparency(0.89)
			Window.Tabs[TabIndex].Selected = true
			Window.Tabs[TabIndex].Container.Visible = true
			Window.TabDisplay.Text = Window.Tabs[TabIndex].Name
		end
	end
	
	function Window:Dialog(Config)
		local Dialog = {
			Title = Config.Title or "Dialog",
			Content = Config.Content or "",
			Buttons = Config.Buttons or {},
			Closed = Signal.new()
		}
		
		local DialogFrame = Creator.New("Frame", {
			Size = UDim2.fromOffset(400, 200),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Parent = FluentRenewed.GUI,
			ThemeTag = {
				BackgroundColor3 = "Dialog"
			}
		}, {
			Creator.New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			Creator.New("TextLabel", {
				Text = Dialog.Title,
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.fromOffset(0, 10),
				TextSize = 18,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text"
				}
			}),
			Creator.New("TextLabel", {
				Text = Dialog.Content,
				Size = UDim2.new(1, -20, 1, -80),
				Position = UDim2.fromOffset(10, 50),
				TextSize = 14,
				TextWrapped = true,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text"
				}
			})
		})
		
		local ButtonHolder = Creator.New("Frame", {
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0, 10, 1, -40),
			BackgroundTransparency = 1,
			Parent = DialogFrame
		}, {
			Creator.New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 10)
			})
		})
		
		for _, ButtonConfig in ipairs(Dialog.Buttons) do
			local Button = Creator.New("TextButton", {
				Size = UDim2.fromOffset(80, 30),
				Text = ButtonConfig.Title or "Button",
				Parent = ButtonHolder,
				ThemeTag = {
					BackgroundColor3 = "DialogButton",
					TextColor3 = "Text"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 5),
				})
			})
			
			Creator.AddSignal(Button.MouseButton1Click, function()
				FluentRenewed:SafeCallback(ButtonConfig.Callback or function() end)
				DialogFrame:Destroy()
				Dialog.Closed:Fire()
			end)
		end
		
		task.wait(0.1)
		
		return Dialog
	end
	
	Creator.AddSignal(Window.TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Window.TabHolder.CanvasSize = UDim2.fromOffset(0, Window.TabHolder.UIListLayout.AbsoluteContentSize.Y)
	end)
	
	FluentRenewed.CreatedWindow = Window
	
	-- Aliases
	Window.Tab = Window.CreateTab
	Window.AddTab = Window.CreateTab
	
	return Window
end

-- Aliases for main library
FluentRenewed.Window = FluentRenewed.CreateWindow

return FluentRenewed
