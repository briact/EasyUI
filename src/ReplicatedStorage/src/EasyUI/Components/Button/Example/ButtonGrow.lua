-- Imports
local RepSource = game:GetService("ReplicatedStorage"):WaitForChild("src")
local Class = require(RepSource:WaitForChild("Class"))
local TweenService = game:GetService("TweenService")


-- ObjectComponent Class
local ButtonGrow = Class.new("ButtonGrow", "ButtonComponent")


-- constructor
function ButtonGrow.new(self, button)
	-- setup variables
	self.super(button)
	self.outline = button:WaitForChild("GrowableOutline")
	
	local content = button:FindFirstChild("Content")
	local contentOutline = button:FindFirstChild("Outline")
	self.defaultSize = contentOutline and contentOutline.Size or content.Size
end


-- abstract methods
function ButtonGrow:activated() -- abstract
	local growTween = TweenService:Create(self.outline, TweenInfo.new(0.2), {Size = self.defaultSize + UDim2.new(0,6,0,6)})
	local shrinkTween = TweenService:Create(self.outline, TweenInfo.new(0.2), {Size = self.defaultSize})
	local completionTask

	completionTask = growTween.Completed:Connect(function()
		if completionTask then
			completionTask:Disconnect()
			completionTask = nil
			shrinkTween:Play()
		end
	end)

	growTween:Play()
end


-- return class
return ButtonGrow