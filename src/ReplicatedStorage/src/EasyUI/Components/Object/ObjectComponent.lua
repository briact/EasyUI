-- Imports
local RepSource = game:GetService("ReplicatedStorage"):WaitForChild("src")
local Class = require(RepSource:WaitForChild("Class"))
local VisibilityState = require(RepSource:WaitForChild("UserInterface"):WaitForChild("VisibilityState"))


-- ObjectComponent Class
local ObjectComponent = Class.new("ObjectComponent")


-- constructor
function ObjectComponent.new(self, guiObject)
	-- setup variables
	self.object = guiObject
	self.visible = guiObject.Visible
	self.visibilityState = VisibilityState.setupVisibilityState(guiObject)
	
	-- bind visible to VisibilityState changes
	self.visibilityState.changed:connect(function(state, lastState)
		self.visible = state.visible
	end)
end


-- abstract methods
function ObjectComponent:setVisibility(visible) -- abstract
	
end


-- return class
return ObjectComponent