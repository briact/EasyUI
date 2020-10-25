-- Imports
local RepSource = game:GetService("ReplicatedStorage"):WaitForChild("src")
local Class = require(RepSource:WaitForChild("Class"))
local TweenService = game:GetService("TweenService")


-- ObjectComponent Class
local TestComponent = Class.new("TestComponent", "ObjectComponent")


-- constructor
function TestComponent.new(self, guiObject)
	-- setup variables
	self.super(guiObject)

	local outline = guiObject:WaitForChild("Outline")
	local content = guiObject:WaitForChild("Content")
	
	self.outline = outline
	self.content = content
	self.originalPosition = guiObject.Position
	self.outlineSize = outline.Size
	self.contentTransparency = content.BackgroundTransparency
end


-- abstract methods
function TestComponent:setVisibility(visible) -- abstract
	if visible then
		self.object.Visible = true
		
		TweenService:Create(self.outline, TweenInfo.new(0.45), {Size = self.outlineSize}):Play()
		TweenService:Create(self.object, TweenInfo.new(0.45), {Position = self.originalPosition}):Play()
		local contentTween = TweenService:Create(self.content, TweenInfo.new(0.45), {BackgroundTransparency = self.contentTransparency})
		contentTween:Play()

		local finishedEvent
		finishedEvent = contentTween.Completed:Connect(function()
			finishedEvent:Disconnect()

			for _, object in ipairs(self.content:GetChildren()) do
				if object:IsA("GuiObject") then
					object.Visible = true
				end
			end
		end)
		
	else

		TweenService:Create(self.outline, TweenInfo.new(0.45), {Size = self.outline.Size - UDim2.new(0, 0, self.outline.Size.Y.Scale, self.outline.Size.Y.Offset)}):Play()
		TweenService:Create(self.object, TweenInfo.new(0.45), {Position = self.object.Position + UDim2.new(0, 0, 0, 75)}):Play()
		local contentTween = TweenService:Create(self.content, TweenInfo.new(0.45), {BackgroundTransparency = 1})
		contentTween:Play()

		local finishedEvent
		finishedEvent = contentTween.Completed:Connect(function()
			finishedEvent:Disconnect()

			for _, object in ipairs(self.content:GetChildren()) do
				if object:IsA("GuiObject") then
					object.Visible = false
				end
			end
		end)
	end
end


-- return class
return TestComponent