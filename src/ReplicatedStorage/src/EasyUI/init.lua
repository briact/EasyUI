-- imports
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local componentCreators = script:WaitForChild("ComponentCreators")
local Button = require(componentCreators:WaitForChild("Button"))
local Object = require(componentCreators:WaitForChild("Object"))


-- wait for game/ui to load
repeat
	RunService.RenderStepped:wait()
until game:IsLoaded()

RunService.RenderStepped:wait()


-- Class: UserInterface
local UserInterface = {}


-- private variables/constants
local MAX_COMPONENT_TRIES = 30
local FORCE_COMPONENT_SUCCESS = false -- forces components to be required successfully before the 
local DEBUG = true


-- initialize component classes
do
	-- initialize variables
	local components = script:WaitForChild("Components")
	local componentObjects = {}
	local componentObjectsThatThrew = {"init"}
	local errors = {}
	local tries = 0
	local success = false
	
	-- get component objects
	for _, object in ipairs(components:GetDescendants()) do
		if object:IsA("ModuleScript") then
			componentObjects[#componentObjects+1] = object
		end
	end
	
	-- require components until nothing throws, with a try count of MAX_COMPONENT_TRIES
	repeat
		-- reset componentObjectsThatThrew
		componentObjectsThatThrew = {}
		errors = {}
		
		-- require components
		for _, object in ipairs(componentObjects) do
			xpcall(function()
				require(object)
			end, function(err)
				componentObjectsThatThrew[#componentObjectsThatThrew] = object
				errors[object] = err
			end)
		end
		
		-- update variables
		componentObjects = componentObjectsThatThrew
		tries += 1
	until tries == MAX_COMPONENT_TRIES or #componentObjectsThatThrew == 0
	
	-- display warning if component tries exceeds MAX_COMPONENT_TRIES
	if #componentObjectsThatThrew ~= 0 then
		warn("Max component tries [" .. MAX_COMPONENT_TRIES .. "] exceeded. Please see error dump for more information, and consider increasing the MAX_COMPONENT_TRIES of UserInterface module.")
		print("\n\nError dump:")
		
		for object, err in next, errors do
			print("\n\nError occured in component [" .. object.Name .. "] with path = game." .. object:GetFullName() .. "\nERROR:\n", err)
		end
		
		if FORCE_COMPONENT_SUCCESS then
			error("UserInterface process finished with exit code 1: Cannot proceed until all errors are fixed in component classes")
		end
	end
	
	-- display try count if debug is enabled
	if DEBUG then
		print("Component require tries: " .. tries .. "/" .. MAX_COMPONENT_TRIES)
	end
end


-- run component creators
do
	-- create object components
	local function setupObject(guiObject)
		if guiObject then
			if guiObject:IsA("GuiButton") then
				Button.new(guiObject)
			elseif guiObject:IsA("GuiObject") then
				Object.new(guiObject)
			end
		end
	end
	
	local duringInit = {}
	local initEvent = PlayerGui.DescendantAdded:Connect(function(descendant)
		duringInit[#duringInit+1] = descendant
	end)
	
	-- store buttons to be implemented after objects
	local buttons = {}
	
	-- implement objects and store buttons
	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object then
			if object:IsA("GuiButton") then
				buttons[#buttons+1] = object
			elseif object:IsA("GuiObject") then
				Object.new(object)
			end
		end
	end
	
	-- implement buttons
	for _, button in ipairs(buttons) do
		Button.new(button)
	end
	
	-- setup objects added after init
	PlayerGui.DescendantAdded:Connect(function(descendant)
		setupObject(descendant)
	end)
	
	initEvent:Disconnect()
	
	for _, initObject in ipairs(duringInit) do
		setupObject(initObject)
	end
end


-- return UserInterface
return UserInterface