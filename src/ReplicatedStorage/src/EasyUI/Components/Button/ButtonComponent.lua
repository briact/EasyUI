-- Imports
local RepSource = game:GetService("ReplicatedStorage"):WaitForChild("src")
local Class = require(RepSource:WaitForChild("Class"))


-- ObjectComponent Class
local ButtonComponent = Class.new("ButtonComponent")


-- constructor
function ButtonComponent.new(self, button)
	-- setup variables
	self.button = button
end


-- abstract methods
function ButtonComponent:activated() -- abstract
	
end

function ButtonComponent:hovered(isHovering) -- abstract
	
end

function ButtonComponent:targetVisibilityUpdated(target, isVisible) -- abstract
	
end


-- return class
return ButtonComponent