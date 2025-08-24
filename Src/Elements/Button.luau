--[[
	Angeryy05 Button Element
	Modern button with hover effects and ripple animation
]]

return function(config, parent, tab, library)
	local Creator = library.Utilities.Creator
	local Tween = library.Utilities.Tween
	local Icons = library.Utilities.Icons
	local Themes = library.Utilities.Themes
	local Signal = library.Utilities.Signal
	
	-- Button configuration
	config = config or {}
	local buttonConfig = {
		Title = config.Title or "Button",
		Description = config.Description,
		Icon = config.Icon,
		Callback = config.Callback,
		Size = config.Size or UDim2.new(1, -20, 0, 50)
	}
	
	-- Get theme
	local theme = Themes.GetTheme(library.CurrentTheme)
	
	-- Create button container
	local ButtonContainer = Creator.New("Frame", {
		Name = "ButtonContainer",
		Size = buttonConfig.Size,
		BackgroundTransparency = 1,
		Parent = parent
	})
	
	-- Create button frame
	local ButtonFrame = Creator.CreateButton({
		Name = "ButtonFrame",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = theme.Button,
		Text = "",
		CornerRadius = 10,
		Parent = ButtonContainer
	})
	
	local ButtonBorder = Creator.New("UIStroke", {
		Color = theme.ButtonBorder,
		Thickness = 1,
		Transparency = 0.5,
		Parent = ButtonFrame
	})
	
	-- Button icon
	local ButtonIcon = nil
	if buttonConfig.Icon then
		ButtonIcon = Creator.New("ImageLabel", {
			Name = "ButtonIcon",
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.fromOffset(15, 15),
			BackgroundTransparency = 1,
			Image = Icons.Get(buttonConfig.Icon),
			ImageColor3 = theme.Text,
			Parent = ButtonFrame
		})
	end
	
	-- Button title
	local ButtonTitle = Creator.New("TextLabel", {
		Name = "ButtonTitle",
		Size = UDim2.new(1, buttonConfig.Icon and -50 or -30, buttonConfig.Description and 0 or 1, buttonConfig.Description and 18 or 0),
		Position = UDim2.fromOffset(buttonConfig.Icon and 45 or 15, buttonConfig.Description and 8 or 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = buttonConfig.Title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = buttonConfig.Description and Enum.TextYAlignment.Center or Enum.TextYAlignment.Center,
		Parent = ButtonFrame
	})
	
	-- Button description
	local ButtonDescription = nil
	if buttonConfig.Description then
		ButtonDescription = Creator.New("TextLabel", {
			Name = "ButtonDescription",
			Size = UDim2.new(1, buttonConfig.Icon and -50 or -30, 0, 16),
			Position = UDim2.fromOffset(buttonConfig.Icon and 45 or 15, 26),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = buttonConfig.Description,
			TextColor3 = theme.TextSecondary,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = ButtonFrame
		})
	end
	
	-- Button object
	local Button = {
		Title = buttonConfig.Title,
		Description = buttonConfig.Description,
		Callback = buttonConfig.Callback,
		
		-- Events
		OnClick = Signal.new(),
		
		-- Internal
		Frame = ButtonContainer,
		Button = ButtonFrame,
		Enabled = true
	}
	
	-- Add ripple effect
	library.Utilities:CreateRipple(ButtonFrame, theme.Accent)
	
	-- Hover effects
	ButtonFrame.MouseEnter:Connect(function()
		if Button.Enabled then
			Tween:Smooth(ButtonFrame, 0.2, {
				BackgroundColor3 = theme.ButtonHover
			})
			
			Tween:Smooth(ButtonBorder, 0.2, {
				Transparency = 0.2
			})
		end
	end)
	
	ButtonFrame.MouseLeave:Connect(function()
		if Button.Enabled then
			Tween:Smooth(ButtonFrame, 0.2, {
				BackgroundColor3 = theme.Button
			})
			
			Tween:Smooth(ButtonBorder, 0.2, {
				Transparency = 0.5
			})
		end
	end)
	
	-- Click handler
	ButtonFrame.MouseButton1Click:Connect(function()
		if Button.Enabled then
			Button.OnClick:Fire()
			if Button.Callback then
				library:SafeCallback(Button.Callback)
			end
		end
	end)
	
	-- Functions
	function Button:SetTitle(title)
		Button.Title = title
		ButtonTitle.Text = title
	end
	
	function Button:SetDescription(description)
		Button.Description = description
		if ButtonDescription then
			ButtonDescription.Text = description
		end
	end
	
	function Button:SetEnabled(enabled)
		Button.Enabled = enabled
		
		if enabled then
			Tween:Smooth(ButtonFrame, 0.2, {
				BackgroundTransparency = 0
			})
			Tween:Smooth(ButtonTitle, 0.2, {
				TextTransparency = 0
			})
			if ButtonDescription then
				Tween:Smooth(ButtonDescription, 0.2, {
					TextTransparency = 0
				})
			end
			if ButtonIcon then
				Tween:Smooth(ButtonIcon, 0.2, {
					ImageTransparency = 0
				})
			end
		else
			Tween:Smooth(ButtonFrame, 0.2, {
				BackgroundTransparency = 0.5
			})
			Tween:Smooth(ButtonTitle, 0.2, {
				TextTransparency = 0.5
			})
			if ButtonDescription then
				Tween:Smooth(ButtonDescription, 0.2, {
					TextTransparency = 0.5
				})
			end
			if ButtonIcon then
				Tween:Smooth(ButtonIcon, 0.2, {
					ImageTransparency = 0.5
				})
			end
		end
	end
	
	function Button:Click()
		if Button.Enabled then
			Button.OnClick:Fire()
			if Button.Callback then
				library:SafeCallback(Button.Callback)
			end
		end
	end
	
	return Button
end
