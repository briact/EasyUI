-- Imports
local RepSource = game:GetService("ReplicatedStorage"):WaitForChild("src")
local Class = require(RepSource:WaitForChild("Class"))
local TweenService = game:GetService("TweenService")


-- ObjectComponent Class
local ButtonDim = Class.new("ButtonDim", "ButtonComponent")


-- constructor
function ButtonDim.new(self, button)
	-- setup variables
	self.super(button)
	self.content = button:FindFirstChild("Content")
	self.defaultBackgroundColor = self.content.BackgroundColor3
end


-- abstract methods
function ButtonDim:hovered(isHovering)
	if isHovering then
		local c0 = self.defaultBackgroundColor
		local c1 = Color3.new(c0.R*.8, c0.G*.8, c0.B*.8)

		TweenService:Create(self.content, TweenInfo.new(0.225), {BackgroundColor3 = c1}):Play()
		
	else
		TweenService:Create(self.content, TweenInfo.new(0.225), {BackgroundColor3 = self.defaultBackgroundColor}):Play()
	end
end


-- return class
return ButtonDim