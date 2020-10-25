-- Imports
local RepSource = game:GetService("ReplicatedStorage"):WaitForChild("src")
local Class = require(RepSource:WaitForChild("Class"))
local TweenService = game:GetService("TweenService")


-- ObjectComponent Class
local ButtonOutline = Class.new("ButtonOutline", "ButtonComponent")


-- constructor
function ButtonOutline.new(self, button)
	-- setup variables
	self.super(button)
	self.content = button:FindFirstChild("Content")
	self.outline = button:FindFirstChild("Outline")
	self.textLabel = self.content and self.content:FindFirstChild("Text")
	self.defaultBackgroundColor = self.content and self.content.BackgroundColor3
	self.defaultTextColor = self.textLabel and self.textLabel.TextColor3
end


-- abstract methods
function ButtonOutline:hovered(isHovering)
	if isHovering then
		-- change colors
		TweenService:Create(self.content, TweenInfo.new(0.225), {BackgroundColor3 = self.outline.BackgroundColor3}):Play()

		if self.textLabel then
			TweenService:Create(self.textLabel, TweenInfo.new(0.225), {TextColor3 = self.defaultBackgroundColor}):Play()
		end
		
	else
		-- change colors
		TweenService:Create(self.content, TweenInfo.new(0.225), {BackgroundColor3 = self.defaultBackgroundColor}):Play()

		if self.textLabel and self.defaultTextColor then
			TweenService:Create(self.textLabel, TweenInfo.new(0.225), {TextColor3 = self.defaultTextColor}):Play()
		end
	end
end


-- return class
return ButtonOutline