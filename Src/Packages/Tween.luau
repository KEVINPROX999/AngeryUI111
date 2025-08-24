--[[
	Angeryy05 Tween Library
	Modern tweening system for smooth animations
]]

local TweenService = game:GetService("TweenService")

local Tween = {}

-- Modern easing styles
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

-- Quick tween function
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

-- Smooth tween with callback
function Tween:Smooth(instance, duration, properties, callback)
	local tween = self:Create(instance, duration, properties, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	return tween
end

-- Spring animation
function Tween:Spring(instance, duration, properties, callback)
	local tween = self:Create(instance, duration, properties, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	return tween
end

-- Bounce animation
function Tween:Bounce(instance, duration, properties, callback)
	local tween = self:Create(instance, duration, properties, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	
	if callback then
		tween.Completed:Connect(callback)
	end
	
	return tween
end

return Tween
