--[[
	Angeryy05 Toggle Element
	Modern toggle switch with smooth animations
]]

return function(config, parent, tab, library)
	local Creator = library.Utilities.Creator
	local Tween = library.Utilities.Tween
	local Icons = library.Utilities.Icons
	local Themes = library.Utilities.Themes
	local Signal = library.Utilities.Signal
	
	-- Toggle configuration
	config = config or {}
	local toggleConfig = {
		Title = config.Title or "Toggle",
		Description = config.Description,
		Default = config.Default or false,
		Callback = config.Callback,
		Size = config.Size or UDim2.new(1, -20, 0, config.Description and 60 or 45)
	}
	
	-- Get theme
	local theme = Themes.GetTheme(library.CurrentTheme)
	
	-- Create toggle container
	local ToggleContainer = Creator.New("Frame", {
		Name = "ToggleContainer",
		Size = toggleConfig.Size,
		BackgroundColor3 = theme.Element,
		BorderSizePixel = 0,
		Parent = parent
	})
	
	local ToggleCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = ToggleContainer
	})
	
	local ToggleBorder = Creator.New("UIStroke", {
		Color = theme.ElementBorder,
		Thickness = 1,
		Transparency = 0.7,
		Parent = ToggleContainer
	})
	
	-- Toggle title
	local ToggleTitle = Creator.New("TextLabel", {
		Name = "ToggleTitle",
		Size = UDim2.new(1, -70, toggleConfig.Description and 0 or 1, toggleConfig.Description and 18 or 0),
		Position = UDim2.fromOffset(15, toggleConfig.Description and 10 or 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = toggleConfig.Title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = ToggleContainer
	})
	
	-- Toggle description
	local ToggleDescription = nil
	if toggleConfig.Description then
		ToggleDescription = Creator.New("TextLabel", {
			Name = "ToggleDescription",
			Size = UDim2.new(1, -70, 0, 16),
			Position = UDim2.fromOffset(15, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = toggleConfig.Description,
			TextColor3 = theme.TextSecondary,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = ToggleContainer
		})
	end
	
	-- Toggle switch
	local ToggleSwitch = Creator.New("Frame", {
		Name = "ToggleSwitch",
		Size = UDim2.fromOffset(50, 25),
		Position = UDim2.new(1, -65, 0.5, -12.5),
		BackgroundColor3 = theme.Toggle,
		BorderSizePixel = 0,
		Parent = ToggleContainer
	})
	
	local ToggleSwitchCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = ToggleSwitch
	})
	
	-- Toggle slider
	local ToggleSlider = Creator.New("Frame", {
		Name = "ToggleSlider",
		Size = UDim2.fromOffset(21, 21),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = theme.ToggleSlider,
		BorderSizePixel = 0,
		Parent = ToggleSwitch
	})
	
	local ToggleSliderCorner = Creator.New("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = ToggleSlider
	})
	
	-- Toggle object
	local Toggle = {
		Title = toggleConfig.Title,
		Description = toggleConfig.Description,
		Value = toggleConfig.Default,
		Callback = toggleConfig.Callback,
		
		-- Events
		OnChanged = Signal.new(),
		
		-- Internal
		Frame = ToggleContainer,
		Switch = ToggleSwitch,
		Slider = ToggleSlider,
		Enabled = true
	}
	
	-- Set initial state
	if Toggle.Value then
		ToggleSwitch.BackgroundColor3 = theme.ToggleActive
		ToggleSlider.Position = UDim2.fromOffset(27, 2)
	end
	
	-- Functions
	function Toggle:SetValue(value)
		Toggle.Value = value
		
		if value then
			-- Turn on
			Tween:Smooth(ToggleSwitch, 0.2, {
				BackgroundColor3 = theme.ToggleActive
			})
			Tween:Smooth(ToggleSlider, 0.2, {
				Position = UDim2.fromOffset(27, 2)
			})
		else
			-- Turn off
			Tween:Smooth(ToggleSwitch, 0.2, {
				BackgroundColor3 = theme.Toggle
			})
			Tween:Smooth(ToggleSlider, 0.2, {
				Position = UDim2.fromOffset(2, 2)
			})
		end
		
		Toggle.OnChanged:Fire(value)
		if Toggle.Callback then
			library:SafeCallback(Toggle.Callback, value)
		end
	end
	
	function Toggle:GetValue()
		return Toggle.Value
	end
	
	function Toggle:SetTitle(title)
		Toggle.Title = title
		ToggleTitle.Text = title
	end
	
	function Toggle:SetDescription(description)
		Toggle.Description = description
		if ToggleDescription then
			ToggleDescription.Text = description
		end
	end
	
	function Toggle:SetEnabled(enabled)
		Toggle.Enabled = enabled
		
		if enabled then
			Tween:Smooth(ToggleContainer, 0.2, {
				BackgroundTransparency = 0
			})
			Tween:Smooth(ToggleTitle, 0.2, {
				TextTransparency = 0
			})
			if ToggleDescription then
				Tween:Smooth(ToggleDescription, 0.2, {
					TextTransparency = 0
				})
			end
		else
			Tween:Smooth(ToggleContainer, 0.2, {
				BackgroundTransparency = 0.5
			})
			Tween:Smooth(ToggleTitle, 0.2, {
				TextTransparency = 0.5
			})
			if ToggleDescription then
				Tween:Smooth(ToggleDescription, 0.2, {
					TextTransparency = 0.5
				})
			end
		end
	end
	
	-- Click handlers
	local function toggleValue()
		if Toggle.Enabled then
			Toggle:SetValue(not Toggle.Value)
		end
	end
	
	ToggleContainer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggleValue()
		end
	end)
	
	ToggleSwitch.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggleValue()
		end
	end)
	
	-- Hover effects
	ToggleContainer.MouseEnter:Connect(function()
		if Toggle.Enabled then
			Tween:Smooth(ToggleContainer, 0.15, {
				BackgroundColor3 = theme.ElementHover
			})
			Tween:Smooth(ToggleBorder, 0.15, {
				Transparency = 0.4
			})
		end
	end)
	
	ToggleContainer.MouseLeave:Connect(function()
		if Toggle.Enabled then
			Tween:Smooth(ToggleContainer, 0.15, {
				BackgroundColor3 = theme.Element
			})
			Tween:Smooth(ToggleBorder, 0.15, {
				Transparency = 0.7
			})
		end
	end)
	
	return Toggle
end
