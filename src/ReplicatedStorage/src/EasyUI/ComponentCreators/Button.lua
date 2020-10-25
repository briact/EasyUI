-- imports
local InterfaceUtil = require(script.Parent.Parent:WaitForChild("InterfaceUtil"))
local VisibilityState = require(script.Parent.Parent:WaitForChild("VisibilityState"))


-- Class: Button
local Button = {}


-- private variables
local createdButtons = {}


-- constructor
function Button.new(button)
	-- check for existing Button object
	local existingButtonObject = createdButtons[button]
	
	-- if there is an existing Button object for this button, return that object
	if existingButtonObject then
		return existingButtonObject
	end
	
	-- otherwise: create a new Button object
	local self = {}
	local components = {}
	local updators = {
		globalClosers = {};
		switches = {};
		openers = {};
		closers = {};
	}
	
	local visibilityCallbacks = {}

	self.button = button
	
	-- get components
	local classes = InterfaceUtil.parseClasses(button)
	
	for _, class in ipairs(classes) do
		components[#components+1] = class.new(button)
	end
	
	-- get updators
	for _, object in ipairs(button:GetChildren()) do
		if object:IsA("ObjectValue") then
			local value = object.Value

			if value then
				-- store updator
				if object.Name == "GlobalCloser" then
					updators.globalCloser[#updators.globalCloser + 1] = value

				elseif object.Name == "Switch" then
					updators.switches[#updators.switches + 1] = value

				elseif object.Name == "Open" then
					updators.openers[#updators.openers + 1] = value

				elseif object.Name == "Close" then
					updators.closers[#updators.closers + 1] = value
				end
				
				-- create visibility callback
				local updatorVisibilityStore = VisibilityState.setupVisibilityState(value)
				
				updatorVisibilityStore:dispatch{
					type = "newCallback";
					payload = function(visible)
						for _, component in ipairs(components) do
							component:targetVisibilityUpdated(value, visible)
						end
					end
				}
			else
				warn("An ObjectValue is set as a child of a button, but has no value. ObjectValue path: " .. object:GetFullName())
			end
		end
	end
	
	-- handle updators on action
	button.Activated:Connect(function()
		-- handle button component updates
		for _, component in ipairs(components) do
			component:activated()
		end
		
		-- handle visibility updators
		for _, globalCloser in ipairs(updators.globalClosers) do -- globalClosers
			-- get information about this globalCloser
			local tab = globalCloser.Parent
			
			-- update other objects visibility
			for _, object in ipairs(tab:GetChildren()) do
				if object:IsA("GuiObject") and object ~= globalCloser then
					VisibilityState.setObjectVisibility(object, false)
				end
			end
		end
		
		for _, switch in ipairs(updators.switches) do -- switches
			-- get information about this switch
			local visible = VisibilityState.getObjectVisibility(switch)

			-- set switch visibility
			VisibilityState.setObjectVisibility(switch, not visible)
		end
		
		for _, opener in ipairs(updators.openers) do -- openers
			-- set opener visibility
			VisibilityState.setObjectVisibility(opener, true)
		end
		
		for _, closer in ipairs(updators.closers) do -- closers
			-- set closer visibility
			VisibilityState.setObjectVisibility(closer, false)
		end
	end)
	
	local function hovered()
		-- update components
		for _, component in ipairs(components) do
			component:hovered(true)
		end
	end
	
	local function unhovered()
		-- update components
		for _, component in ipairs(components) do
			component:hovered(false)
		end
	end
	
	button.MouseEnter:Connect(hovered)
	button.SelectionGained:Connect(hovered)
	button.MouseLeave:Connect(unhovered)
	button.SelectionLost:Connect(unhovered)
	
	-- final init
	unhovered()
	self.updators = updators
	
	-- cache and return Button object
	local buttonObject = setmetatable(self, Button)
	
	createdButtons[button] = buttonObject
	
	return buttonObject
end


-- return Button Class
return Button
