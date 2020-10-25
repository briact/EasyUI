-- Imports
local RepSource = game:GetService("ReplicatedStorage"):WaitForChild("src")
local Rodux = require(RepSource:WaitForChild("Rodux")) -- Note: this is a FORKED version of Rodux, regular Rodux will NOT work properly


-- Class: Visibility (handler)
local Visibility = {}


-- Private variables
local visibilityStates = {}


--[[
	Method: setupVisibilityState
	
	Description: Sets up the visibility state of a guiObject (basically wraps .Visible property of GuiObject to allow for
				more customization
				
	Input:
		- GuiObject: guiObject = GuiObject to setup a visibility state for
		
	Output:
		- Store: visibilityStore = Created or existing visibility store for GuiObject
]]

function Visibility.setupVisibilityState(guiObject)
	-- check for existing state
	local existingState = visibilityStates[guiObject]
	
	-- return if there is already an existing state
	if existingState then
		return existingState
	end
	
	-- init store
	local visibilityStore
	
	-- create a new reducer for visibilty state
	local visibilityReducer = function(state, action)
		-- create initial state if it does not exist
		state = state or {
			visible = guiObject.Visible;
			callbacks = {};
		}
		
		-- method to add a new callback (init a new component callback) to state
		if action.type == "addCallback" then
			local callback = action.payload
			
			-- verify callback
			if callback and type(callback) == "function" then
				print("add callback...")
				
				-- get current callbacks from the state
				local callbacks = state.callbacks
				
				-- add the callback to the callbacks array
				callbacks[#callbacks+1] = callback
				
				-- call the callback with the current visibility of the guiObject
				callback(state.visible)
				
				-- return the edited callbacks array without visibilty in a new dictionary
				-- because Rodux [edited] adds Store.mergeStates, this will shallow copy the current state and set callbacks = to this, which forces
				-- an update of the state, differing state and lastState with the same reference points for the callbacks array
				return {
					callbacks = callbacks;
				}
				
			-- show a warning if the callback fails to be added (only because type of callback ~= "function", or callback == nil
			else
				warn("Attempted to add callback to visibility reducer for guiObject [" .. guiObject.Name .. "], but no callback was provided. Object path: game." .. guiObject:GetFullName())
			end
			
		elseif action.type == "updateVisibility" then
			-- get new / current visibility of guiObject
			local newVisibility = action.payload
			local currentVisibility = state.visible
			
			-- check if the new visibility does not match the current visibility -> if they do not, update the visibility and call callbacks
			if newVisibility ~= currentVisibility then
				-- get current callbacks from the state
				local callbacks = state.callbacks
				
				-- check the count of the callbacks -> if > 0, call callbacks... else set .Visible property of guiObject
				if #callbacks > 0 then
					-- call all callbacks with updated visibility
					for _, callback in ipairs(callbacks) do
						xpcall(function()
							callback(newVisibility)
						end, function(err)
							warn("Error [handled] occured while trying to call a callback connected to " .. guiObject.Name .. ". Object path: " .. guiObject:GetFullName() .. "\nError:", err)
						end)
					end
					
				else
					-- set visibility of guiObject using .Visible GuiObject property
					guiObject.Visible = newVisibility
				end
				
				-- return updated state
				return {
					visible = newVisibility
				}
			end
		end
		
		-- no updates, or init, or action.type does not exist
		return state
	end
	
	-- create a store from the visibilityReducer
	visibilityStore = Rodux.Store.new(visibilityReducer)
	
	-- cache store
	visibilityStates[guiObject] = visibilityStore
	
	-- return store
	return visibilityStore
end

--[[
	Method: setObjectVisibility
	
	Description: Dispatches visibility updates to a guiObject's visibility store
	
	Input:
		- GuiObject: guiObject = Object to update the visibility of
		- boolean: newVisiblity = Whether or not the object should be visible
		
	Output:
		- boolean: success = Whether or not the input was valid, and the action was successfully dispatched
]]

function Visibility.setObjectVisibility(guiObject, newVisibility)
	-- get object visibility state
	local objectVisibilityStore = visibilityStates[guiObject]
	
	-- if visibility store does not exist: create it
	if not objectVisibilityStore then
		-- set objectVisibilityStore = created visibility state
		objectVisibilityStore = Visibility.setupVisibilityState(guiObject)
	end
	
	-- check if the object visibility state exists, and that the type of newVisibility is a boolean
	if objectVisibilityStore and type(newVisibility) == "boolean" then
		-- dispatch update to store
		objectVisibilityStore:dispatch{
			type = "updateVisibility";
			payload = newVisibility;
		}
		
		-- return success
		return true
	end
	
	-- return failure
	return false
end

--[[
	Method: getObjectVisibility
	
	Description: Gets .visible state from guiObject's visibility store
	
	Input:
		- GuiObject: guiObject = Object to get the visibility of
		
	Output:
		- boolean: visible = Whether or not the object is visible
]]

function Visibility.getObjectVisibility(guiObject)
	-- get object visibility state
	local objectVisibilityStore = visibilityStates[guiObject]

	-- if visibility store does not exist: create it
	if not objectVisibilityStore then
		-- set objectVisibilityStore = created visibility state
		objectVisibilityStore = Visibility.setupVisibilityState(guiObject)
	end
	
	-- get object visibility
	local objectVisibilityState = objectVisibilityStore:getState()
	local visible = objectVisibilityState and objectVisibilityState.visible or false
	
	-- return visibility
	return visible
end


-- Return Visibility (handler)
return Visibility