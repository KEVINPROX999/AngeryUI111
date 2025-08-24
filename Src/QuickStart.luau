--[[
	Angeryy05 UI Library - Quick Start Script
	Copy và paste script này vào Roblox để test nhanh UI Library!
	
	GitHub: https://github.com/KEVINPROX999/AngeryUI111
]]

-- Load Angeryy05 UI Library
print("🔄 Loading Angeryy05 UI Library...")
local Angeryy05 = loadstring(game:HttpGet("https://raw.githubusercontent.com/KEVINPROX999/AngeryUI111/main/Src/init.luau"))()
print("✅ Angeryy05 UI Library loaded successfully!")

-- Create window
local Window = Angeryy05:CreateWindow({
	Title = "Angeryy05 Quick Start",
	SubTitle = "Test the UI Library!",
	Size = UDim2.fromOffset(500, 350),
	Theme = "Angeryy05Dark"
})

-- Create main tab
local MainTab = Window:CreateTab({
	Title = "Quick Test",
	Icon = "home"
})

-- Welcome message
Angeryy05:Notify({
	Title = "🎉 Welcome!",
	Content = "Angeryy05 UI Library loaded successfully!",
	Type = "success",
	Duration = 4
})

-- Add some test elements
MainTab:CreateParagraph({
	Title = "Quick Start Guide",
	Content = "This is a quick test of the Angeryy05 UI Library. Try the elements below!"
})

MainTab:CreateButton({
	Title = "Test Button",
	Description = "Click me to test notifications",
	Icon = "star",
	Callback = function()
		Angeryy05:Notify({
			Title = "Button Clicked!",
			Content = "The button is working perfectly! ✨",
			Type = "success",
			Duration = 3
		})
	end
})

local testToggle = MainTab:CreateToggle({
	Title = "Test Toggle",
	Description = "Toggle this switch on/off",
	Default = false,
	Callback = function(value)
		local status = value and "ON" or "OFF"
		Angeryy05:Notify({
			Title = "Toggle Changed",
			Content = "Toggle is now " .. status .. "! 🔄",
			Type = "info",
			Duration = 2
		})
	end
})

MainTab:CreateButton({
	Title = "Toggle the Toggle",
	Description = "Programmatically control the toggle above",
	Icon = "refresh",
	Callback = function()
		testToggle:SetValue(not testToggle:GetValue())
	end
})

-- Theme switcher
MainTab:CreateButton({
	Title = "Switch to Light Theme",
	Description = "Try the light theme",
	Icon = "sun",
	Callback = function()
		Angeryy05:SetTheme("Angeryy05Light")
		Angeryy05:Notify({
			Title = "Theme Changed",
			Content = "Switched to Light theme! ☀️",
			Type = "info",
			Duration = 3
		})
	end
})

MainTab:CreateButton({
	Title = "Switch to CyberPunk Theme",
	Description = "Try the cyberpunk theme",
	Icon = "zap",
	Callback = function()
		Angeryy05:SetTheme("CyberPunk")
		Angeryy05:Notify({
			Title = "Theme Changed",
			Content = "Welcome to the future! 🚀",
			Type = "info",
			Duration = 3
		})
	end
})

MainTab:CreateButton({
	Title = "Back to Dark Theme",
	Description = "Return to the default dark theme",
	Icon = "moon",
	Callback = function()
		Angeryy05:SetTheme("Angeryy05Dark")
		Angeryy05:Notify({
			Title = "Theme Changed",
			Content = "Back to the classic dark theme! 🌙",
			Type = "info",
			Duration = 3
		})
	end
})

-- Destroy button
MainTab:CreateButton({
	Title = "Close UI",
	Description = "Close the UI Library",
	Icon = "x",
	Callback = function()
		Angeryy05:Notify({
			Title = "Goodbye!",
			Content = "Thanks for testing Angeryy05 UI Library! 👋",
			Type = "info",
			Duration = 2
		})
		
		task.wait(2.5)
		Angeryy05:Destroy()
	end
})

print("🎉 Angeryy05 UI Library Quick Start loaded!")
print("📝 GitHub: https://github.com/KEVINPROX999/AngeryUI111")
print("✨ Version:", Angeryy05.Version)
