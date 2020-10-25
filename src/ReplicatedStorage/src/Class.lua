-- Class: Class
local Class = {}

-- Public static class constants
Class.__type = "Class"
Class.Enum = {
	Operations = {
		Addition = "+";
		Subtraction = "-";
		Multiplication = "*";
		Division = "/";
		Modulus = "%";
		Exponent = "^";
	};

	Comparisons = {
		LessThan = "<";
		LessThanOrEqualTo = "<=";
		EqualTo = "==";
	};


}

-- Private static class variables
local cachedClasses = {}
local cachedClassBases = {}
local cachedClassObjectCalls = {}

-- Private methods

--[[
	Method: createAbstractMethods
	
	Description: Creates abstract methods for a new class, specifically methods for creating/modifying/handling objects and their properties
	
	Input:
		- table: customObjectCalls = dictionary containing object calls created after class init
		
	Output: None
]]

local function createAbstractMethods(customObjectCalls)
	function customObjectCalls.new(self) -- constructor

	end

	function customObjectCalls.handleGet(object, index) -- __index

	end

	function customObjectCalls.handleSet(object, index, value) -- __newindex

	end

	function customObjectCalls.handleCall(object, ...) -- __call

	end

	function customObjectCalls.handleConcat(object, value) -- __concat

	end

	function customObjectCalls.handleUnaryMinus(object) -- __unm

	end

	function customObjectCalls.handleArithmetic(object, value, operation) -- __add __sub __mul __div __mod __pow
		-- operations:
		-- "+"
		-- "-"
		-- "*"
		-- "/"
		-- "%"
		-- "^"
	end

	function customObjectCalls.toString(object) -- __tostring
		return object.__type .. "[ToString]";
	end

	function customObjectCalls.handleComparison(object, value, comparison) -- __eq __lt __le
		-- comparisons:
		-- "=="
		-- "<"
		-- "<="
	end

	function customObjectCalls.handleLength(object) -- __len

	end

	-- note: __mode, __metatable must be called when calling Class.new(a, b?, {__mode = "kv", __metatable = ?)
end


--[[
	Method: createRouting
	
	Description: sets up the routing from __[name] to custom methods
	
	Input:
		- CustomClass: customClass = Custom class object created when creating a new class
		- table: customObjectCalls = dictionary containing object calls created after class init
		- table: additionalArgs = dictionary containing __mode and/or __metatable used in class construction
		
	Output: None
]]

local function createRouting(customClass, customObjectCalls, additionalArgs)
	-- Routing enabling/disabling
	local routesEnabled = {
		["handleGet"] = true;
		["handleSet"] = true;
		["handleCall"] = false;
		["handleConcat"] = false;
		["handleUnaryMinus"] = false;
		["handleArithmetic"] = false;
		["handleComparison"] = false;
		["handleLength"] = false;
		["toString"] = false;
	}

	local function checkForDisabled(route)
		if not routesEnabled[route] then
			error("Attempted to call route ["..route.."] of Class ["..customClass.__type.."], but it has not been enabled. Enable it by calling [Class]:enableRoute("..route..")")
		end
	end

	function customClass:disableRoute(route)
		routesEnabled[route] = false
	end

	function customClass:enableRoute(route)
		routesEnabled[route] = true
	end

	-- Set metatable properties
	customClass.__index = function(object, index) -- handles object indexing
		if customObjectCalls[index] ~= nil then
			return customObjectCalls[index]
			
		elseif Class[index] ~= nil then
			return Class[index]
			
		else
			local canGet = routesEnabled["handleGet"]

			if canGet then
				local possibleReturn = object:handleGet(object, index)
				if possibleReturn ~= nil then
					return possibleReturn
				end
			end
			
			local superObject = object.super
			
			if superObject ~= nil and type(superObject) ~= "function" then
				local superIndexed = superObject[index]
				if superIndexed ~= nil then
					return superIndexed
				end
			end
		end
	end

	customClass.__newindex = function(object, index, value)
		checkForDisabled("handleSet")
		object:handleSet(object, index, value)
	end

	customClass.__call = function(object, ...)
		checkForDisabled("handleCall")
		return object:handleCall(...)
	end

	customClass.__concat = function(object, value)
		checkForDisabled("handleConcat")
		return object:handleConcat(value)
	end

	customClass.__unm = function(object)
		checkForDisabled("handleUnaryMinus")
		return object:handleUnaryMinus()
	end

	customClass.__add = function(object, value)
		checkForDisabled("handleArithmetic")
		return object:handleArithmetic(object, value, Class.Enum.Operations.Addition)
	end

	customClass.__sub = function(object, value)
		checkForDisabled("handleArithmetic")
		return object:handleArithmetic(object, value, Class.Enum.Operations.Subtraction)
	end

	customClass.__mul = function(object, value)
		checkForDisabled("handleArithmetic")
		return object:handleArithmetic(object, value, Class.Enum.Operations.Multiplication)
	end

	customClass.__div = function(object, value)
		checkForDisabled("handleArithmetic")
		return object:handleArithmetic(object, value, Class.Enum.Operations.Division)
	end

	customClass.__mod = function(object, value)
		checkForDisabled("handleArithmetic")
		return object:handleArithmetic(object, value, Class.Enum.Operations.Modulus)
	end

	customClass.__pow = function(object, value)
		checkForDisabled("handleArithmetic")
		return object:handleArithmetic(object, value, Class.Enum.Operations.Exponent)
	end

	customClass.__tostring = function(object)
		checkForDisabled("toString")
		return object:toString()
	end

	customClass.__eq = function(object, value)
		checkForDisabled("handleComparison")
		return object:handleComparison(object, value, Class.Enum.Comparisons.EqualTo)
	end

	customClass.__lt = function(object, value)
		checkForDisabled("handleComparison")
		return object:handleComparison(object, value, Class.Enum.Comparisons.LessThan)
	end

	customClass.__le = function(object, value)
		checkForDisabled("handleComparison")
		return object:handleComparison(object, value, Class.Enum.Comparisons.LessThanOrEqualTo)
	end

	customClass.__len = function(object)
		checkForDisabled("handleLength")
		return object:handleLength()
	end

	-- set additional arguments (__mode and __metatable specifically, but anything can be edited here including __index technically)
	if additionalArgs then
		for index, value in next, additionalArgs do
			customClass["__"..index] = value
		end
	end
end


-- Public Methods

--[[
	Method: Class.new()
	
	Description: Creates a new class with a supplied name, optional class to extend, and optional additionalArgs.
	
	@overload : 1
		Input:
			- String: className = Name of the class to create
			- table?: additionalArgs = Class info, specifically __mode and __metatable
			
		Output:
			- Class: customClass = New class created with supplied name
	
	@overload : 2
		Input:
			- String: className = Name of the class to create
			- String: classNameToExtend = Name of the class to extend
			- table?: additionalArgs = Class info, specifically __mode and __metatable
			
		Output:
			- Class: customClass = New class created with supplied name extending the class with the another supplied name
]]

function Class.new(name, nameToExtend, additionalArgs) -- > throws if the class to extend does not exist
	-- Get cached class if it exists
	local cachedClass = cachedClasses[name]

	if cachedClass then -- Return cached class
		return cachedClass

	else -- Create new class
		if nameToExtend then -- Check if the second property exists
			if type(nameToExtend) == "table" and not nameToExtend.__type then -- If it is not a string, then it is additional args // vice-versa
				additionalArgs = nameToExtend
				nameToExtend = nil
			end
		end

		if nameToExtend then -- Check if we are extending a class
			-- Extend class with name nameToExtend
			-- Get extended class information
			local classToExtend = cachedClasses[nameToExtend]
			local classBaseToExtend = cachedClassBases[nameToExtend]
			local cachedObjectCallsToExtend = cachedClassObjectCalls[nameToExtend]

			-- Verify class we're extending exists
			if classToExtend and classBaseToExtend and cachedObjectCallsToExtend then
				-- Create a new customClass
				local customClass = {}
				local customObjectCalls = {}

				customClass.__type = "Class_"..name

				-- Constructor

				function customClass.__new(...)
					local self = {}
					local selfmetatable

					self.super = function(...)
						local superObject = classToExtend.new(...)

						self.super = setmetatable({}, {
							__index = function(object, index)
								if cachedObjectCallsToExtend[index] ~= nil then
									return cachedObjectCallsToExtend[index]

								else
									local superProperty = superObject[index]

									if superProperty ~= nil then
										return superProperty
									end
								end
							end;
							__newindex = function(object, index, value)
								self[index] = value
							end
						})
					end

					customObjectCalls.new(self, ...)

					selfmetatable = setmetatable(self, customClass)
					return selfmetatable
				end

				-- Define abstract methods

				createAbstractMethods(customObjectCalls)

				-- Create routing to abstract methods

				createRouting(customClass, customObjectCalls, additionalArgs)

				-- Cache and return class data

				local classMetatable = setmetatable(customClass, Class)

				cachedClasses[name] = classMetatable
				cachedClassBases[name] = customClass
				cachedClassObjectCalls[name] = customObjectCalls
				cachedClassObjectCalls[customClass.__type] = customObjectCalls

				return classMetatable
			else
				error("Tried to create class ["..name.."] which extends class ["..nameToExtend.."], but class ["..nameToExtend.."] does not exist. Ensure you create the class you want to extend before trying to extend said class.")
			end

		else -- Don't extend any classes
			-- Create a new customClass
			local customClass = {}
			local customObjectCalls = {}

			customClass.__type = "Class_"..name

			-- Constructor

			function customClass.__new(...)
				local self = {}

				customObjectCalls.new(self, ...)

				return setmetatable(self, customClass)
			end

			-- Define abstract methods

			createAbstractMethods(customObjectCalls)

			-- Create routing to abstract methods

			createRouting(customClass, customObjectCalls)

			customClass.__index = function(object, index)
				if customObjectCalls[index] ~= nil then
					return customObjectCalls[index]
				elseif Class[index] ~= nil then
					return Class[index]
				else
					return object:handleGet(object, index)
				end
			end

			-- Cache and return class data

			local classMetatable = setmetatable(customClass, Class)

			cachedClasses[name] = classMetatable
			cachedClassBases[name] = customClass
			cachedClassObjectCalls[name] = customObjectCalls
			cachedClassObjectCalls[customClass.__type] = customObjectCalls

			return classMetatable
		end
	end
end

-- Handle class indexing, specifically for creating an object or getting created methods
function Class.__index(object, index)
	if index == "new" then -- Route to constructor
		return object.__new
	end

	local cachedObjectCalls = object.__type and cachedClassObjectCalls[object.__type] or nil

	if cachedObjectCalls and cachedObjectCalls[index] then
		return cachedObjectCalls[index]
	elseif Class[index] then
		return Class[index]
	end
end

-- Handle class newindexing, specifically for overriding abstract methods or creating new class methods
function Class.__newindex(object, index, value)
	local cachedObjectCalls = object.__type and cachedClassObjectCalls[object.__type] or nil

	if cachedObjectCalls then
		cachedObjectCalls[index] = value
	end
end

return Class