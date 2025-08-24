--[[
	Angeryy05 Creator Module
	Modern UI element creation system
]]

local Root = script.Parent.Parent
local Themes = require(Root.Themes)
local Tween = require(Root.Packages.Tween)
local Signal = require(Root.Packages.Signal)

local Creator = {
	Registry = {},
	Connections = {},
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
			ScrollBarThickness = 0,
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.GothamMedium,
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
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			RichText = true,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			RichText = true,
		},
		ImageLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		UICorner = {
			CornerRadius = UDim.new(0, 8),
		},
		UIStroke = {
			Thickness = 1,
			Color = Color3.new(0, 0, 0),
		}
	}
}

function Creator.New(className, properties)
	local instance = Instance.new(className)
	
	-- Apply default properties
	if Creator.DefaultProperties[className] then
		for property, value in pairs(Creator.DefaultProperties[className]) do
			instance[property] = value
		end
	end
	
	-- Apply custom properties
	if properties then
		for property, value in pairs(properties) do
			if property == "Parent" then
				-- Set parent last to avoid errors
				continue
			elseif property:sub(1, 2) == "On" then
				-- Handle events
				local event = instance[property:sub(3)]
				if event and typeof(event.Connect) == "function" then
					local connection = event:Connect(value)
					table.insert(Creator.Connections, connection)
				end
			else
				instance[property] = value
			end
		end
		
		-- Set parent last
		if properties.Parent then
			instance.Parent = properties.Parent
		end
	end
	
	-- Add to registry for theme updates
	table.insert(Creator.Registry, {
		Instance = instance,
		ClassName = className,
		Properties = properties or {}
	})
	
	return instance
end

function Creator.UpdateTheme()
	local theme = Themes.GetTheme()
	
	for _, registryItem in ipairs(Creator.Registry) do
		local instance = registryItem.Instance
		local className = registryItem.ClassName
		local properties = registryItem.Properties
		
		if instance and instance.Parent then
			-- Update theme-related properties
			if properties.ThemeTag then
				local themeColor = theme[properties.ThemeTag]
				if themeColor and typeof(themeColor) == "Color3" then
					if className == "Frame" or className == "TextLabel" or className == "TextButton" then
						instance.BackgroundColor3 = themeColor
					elseif className == "UIStroke" then
						instance.Color = themeColor
					end
				end
			end
		end
	end
end

function Creator.Disconnect()
	for _, connection in ipairs(Creator.Connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(Creator.Connections)
	table.clear(Creator.Registry)
end

-- Modern UI creation helpers
function Creator.CreateModernFrame(properties)
	local frame = Creator.New("Frame", properties)
	local corner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, properties.CornerRadius or 12),
		Parent = frame
	})
	return frame
end

function Creator.CreateGlassFrame(properties)
	local frame = Creator.CreateModernFrame(properties)
	frame.BackgroundTransparency = 0.1
	
	local stroke = Creator.New("UIStroke", {
		Thickness = 1,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.8,
		Parent = frame
	})
	
	return frame
end

function Creator.CreateButton(properties)
	local button = Creator.New("TextButton", properties)
	local corner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, properties.CornerRadius or 8),
		Parent = button
	})
	
	-- Add hover effects
	local isHovering = false
	
	button.MouseEnter:Connect(function()
		isHovering = true
		Tween:Smooth(button, 0.2, {
			BackgroundColor3 = button.BackgroundColor3:lerp(Color3.fromRGB(255, 255, 255), 0.1)
		})
	end)
	
	button.MouseLeave:Connect(function()
		isHovering = false
		Tween:Smooth(button, 0.2, {
			BackgroundColor3 = properties.BackgroundColor3 or Creator.DefaultProperties.TextButton.BackgroundColor3
		})
	end)
	
	return button
end

return Creator
