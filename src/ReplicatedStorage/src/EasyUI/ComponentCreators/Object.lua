-- imports
local InterfaceUtil = require(script.Parent.Parent:WaitForChild("InterfaceUtil"))
local VisibilityState = require(script.Parent.Parent:WaitForChild("VisibilityState"))


-- Class: Object
local Object = {}


-- private variables
local createdObjects = {}


-- constructor
function Object.new(guiObject)
	-- check for existing Object object
	local existingObject = createdObjects[guiObject]

	-- if there is an existing Button object for this button, return that object
	if existingObject then
		return existingObject
	end
	
	-- otherwise: create a new Object object
	local self = {}
	local components = {}
	local visibilityCallbacks = {}

	self.object = guiObject
	
	-- setup visibility state
	local visibilityStore = VisibilityState.setupVisibilityState(guiObject)

	-- get components and setup visibility callback
	local classes = InterfaceUtil.parseClasses(guiObject)

	for _, class in ipairs(classes) do
		-- create component
		local component = class.new(guiObject)
		
		-- setup visibility callback

		visibilityStore:dispatch{
			type = "addCallback";
			payload = function(visible)
				component:setVisibility(visible)
			end
		}
		
		-- cache component
		components[#components+1] = component
	end
	
	-- final init
	self.components = components
	
	-- cache and return Object object
	local object = setmetatable(self, Object)

	createdObjects[guiObject] = object

	return object
end


-- return Object class
return Object