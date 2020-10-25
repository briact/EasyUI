-- Interface Utility
local InterfaceUtil = {}


-- private variables
local BUTTON_CLASSES = script.Parent:WaitForChild("Components"):WaitForChild("Button")
local OBJECT_CLASSES = script.Parent:WaitForChild("Components"):WaitForChild("Object")
local ARRAY_EMPTY = {}


-- class parsing
function InterfaceUtil.parseClasses(object, dontRequireModules)
	-- get information about this object
	local classValue = object:FindFirstChild("Class")
	local classesToSearch = object:IsA("GuiButton") and BUTTON_CLASSES or OBJECT_CLASSES
	
	-- verify information about this object and its classes
	if classValue and classValue:IsA("StringValue") and classValue.Value ~= "" then
		-- get all classes and setup info about classes
		local classStringList = classValue.Value:split(" ")
		local classModuleList = {}
		
		-- iterate through classes and require their respective modules
		for _, className in ipairs(classStringList) do
			if classValue ~= "" then
				local classModule = classesToSearch:FindFirstChild(className)
			
				if not classModule then
					-- module was not found as a direct child: get descendants
					local descendants = classesToSearch:GetDescendants()
					
					for _, descendant in ipairs(descendants) do
						if descendant.Name == className then
							classModule = descendant
							break
						end
					end
				end
				
				-- verify classModule exists
				if classModule then
					-- insert the module into the classModuleList
					local requiredModule = dontRequireModules and classModule or require(classModule)
					table.insert(classModuleList, #classModuleList+1, requiredModule)

				else
					-- warn the user that the requested class does not exist
					warn("Attempted to find " .. (object:IsA("GuiButton") and "Button" or "Component") .. "Class [" .. className .. "] for object [" .. object.Name .."], but that class does not exist. Path = game." .. object:GetFullName())
				end
			end
		end
		
		-- return found modules list
		return classModuleList
	end
	
	-- return an empty array
	return ARRAY_EMPTY
end


-- return interface utility
return InterfaceUtil