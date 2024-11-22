-- PROTECTION LAYER
-- This local var layer was created to prevent unpredicted behaviour of preprocessor if one of the functions in _G table was changed.
local A,E=assert,"__PROJECT_NAME__ load failed because of missing libruary method!"

-- string.lib
local gmatch = A(string.gmatch,E)
local match  = A(string.match,E)
local format = A(string.format,E)
local find   = A(string.find,E)
local gsub   = A(string.gsub,E)
local sub    = A(string.sub,E)

-- table.lib
local insert = A(table.insert,E)
local concat = A(table.concat,E)
local remove = A(table.remove,E)
local unpack = A(__UNPACK_MACRO__,E)

-- math.lib
local floor = A(math.floor,E)

-- generic.lib
local assert       = A
local type         = A(type,E)
local pairs        = A(pairs,E)
local error        = A(error,E)
local tostring     = A(tostring,E)
local getmetatable = A(getmetatable,E)
local setmetatable = A(setmetatable,E)
local pcall        = A(pcall,E)
local _ --WASTE (dev null)
__BIT32_LIBRUARY_VERSION_MACRO__

__NATIVE_LOAD_VERSION_MACRO__

A,E=nil
local __PROJECT_NAME__ = {}
local placeholder_func = function()end

-- BASE VARIABLES LAYER END
