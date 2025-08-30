-- Fluent Renewed UI Library - Combined Single File
-- Original by ActualMasterOogway
-- Combined by AI Assistant for loadstring usage

local FluentRenewed = {}

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
		"Dark", "Light", "Vynixu"
	}
}

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

Themes["Vynixu"] = Themes["Dark"] -- Copy of Dark theme for simplicity

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

-- Initialize Acrylic (simplified)
local Acrylic = {
	AcrylicBlur = function() return {Frame = Creator.New("Frame", {BackgroundTransparency = 1}), Model = {}, AddParent = function() end, SetVisibility = function() end} end,
	CreateAcrylic = function() return {} end,
	AcrylicPaint = function() 
		return {
			Frame = Creator.New("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.9,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 8),
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
FluentRenewed.Transparency = false
FluentRenewed.OpenFrames = {}
FluentRenewed.Options = {}
FluentRenewed.DialogOpen = false
FluentRenewed.Unloaded = false
FluentRenewed.CreatedWindow = nil
FluentRenewed.Utilities = Utilities
FluentRenewed.Themes = Themes.Names

-- GUI Setup
FluentRenewed.GUI = Creator.New("ScreenGui", {
	Name = "FluentRenewed",
	Parent = game:GetService("CoreGui"),
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

function FluentRenewed:SafeCallback(Callback, ...)
	local Success, Error = pcall(Callback, ...)
	if not Success then
		warn("Fluent Renewed Callback Error:", Error)
	end
end

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
				BackgroundTransparency = 0.9,
				Parent = DropdownFrame.Frame,
				ThemeTag = {
					BackgroundColor3 = "DropdownFrame"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				DropdownDisplay,
			})
			
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
				BackgroundTransparency = 0.9,
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
				Input.Value = tostring(Value)
				InputBox.Text = Input.Value
				FluentRenewed:SafeCallback(Input.Callback, Input.Value)
			end
			
			function Input:OnChanged(Func)
				Input.Changed = Func
				FluentRenewed:SafeCallback(Func, Input.Value)
			end
			
			if Config.Finished then
				Creator.AddSignal(InputBox.FocusLost, function(enter)
					if enter then
						Input:SetValue(InputBox.Text)
					end
				end)
			else
				Creator.AddSignal(InputBox:GetPropertyChangedSignal("Text"), function()
					Input:SetValue(InputBox.Text)
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
			
			ParagraphFrame.Frame.BackgroundTransparency = 0.92
			ParagraphFrame.Border.Transparency = 0.6
			
			function Paragraph:SetValue(Value)
				Paragraph.Value = tostring(Value or "")
				ParagraphFrame:SetDesc(Paragraph.Value)
			end
			
			FluentRenewed.Options[Idx] = Paragraph
			
			return Paragraph
		end
		
		Tab.CreateButton = Tab.CreateButton
		Tab.CreateToggle = Tab.CreateToggle
		Tab.CreateSlider = Tab.CreateSlider
		Tab.CreateDropdown = Tab.CreateDropdown
		Tab.CreateInput = Tab.CreateInput
		Tab.CreateParagraph = Tab.CreateParagraph
		
		-- Aliases
		Tab.Button = Tab.CreateButton
		Tab.Toggle = Tab.CreateToggle
		Tab.Slider = Tab.CreateSlider
		Tab.Dropdown = Tab.CreateDropdown
		Tab.Input = Tab.CreateInput
		Tab.Paragraph = Tab.CreateParagraph
		
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
