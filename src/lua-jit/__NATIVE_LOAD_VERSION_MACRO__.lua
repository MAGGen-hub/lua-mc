-- Lua5.2 load mimicry
local native_load
do
local loadstring,load,setfenv=A(loadstring,E),A(load,E),A(setfenv,E)
    native_load = function(x,name,mode,env)
        local r,e=(type(x)=="string"and loadstring or load)(x,name)
        if env and r then setfenv(r,env)end
        return r,e
    end
end