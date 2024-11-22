
--LUA-MC tests

--TEST LIB
local test_matrix = { 
    {   test_name = "single_lambda_test", --1 test
        short_ctrl = "sys.err,cssc.LF",
        --full_ctrl = "<lambda_functions>",
        test_function = [===[
    
            local dbg_str = "debug string"
    
            -- default lua5.1 function
            local func = function (a,b) return a+b end
    
            -- lambda with return included
            local func1 = a,b -> a + b end
    
            -- lambda with no return
            local func2 = a,b => return a+b end
    
            --argument-less lambda
            local func3 = ()=> return dbg_str end
    
    
            local test_print = function (f)
                local result = f(3,4)
                print(result)
                return result
            end
            --assert results
            assert(test_print(func ) == 7)
            assert(test_print(func1) == 7)
            assert(test_print(func2) == 7)
            assert(test_print(func3) == dbg_str)
        ]===] },
    {   test_name = "single_default_args_test",--2 test
        short_ctrl = "sys.err,cssc.DA",
        --full_ctrl = "<default_arguments>" ,
        test_function = [===[
             
             --single arg
             local func = function (a := 1) return a end
             
             --second arg with formula
             local func1= function (a, b := 1+1*1) return b end
             
             --ULTRA args
             local func2= function (a := function() end, b := 2^4) return a,b end
             
             
             local test_print = function (f)
                 local result = f()
                 print(result)
                 return result
             end
             
             --assert results
             assert(test_print(func))
             assert(test_print(func1))
             assert(test_print(func2))
             
             
         ]===] },
     {   test_name = "single_number_format_test",--3 test
         short_ctrl = "sys.err,cssc.NF",
         --full_ctrl = "<number_formats>",
         test_function = [===[
             
             --binary test
             print(assert(0b10001 == 17)) --default
             print(assert(0b0.1 == 0.5))  --floating point
             print(assert(0b0.01 == 0.25))
             --print(assert(0b111E+1 == 7E+1)) --decimal exponenta
             print(assert(0b111P+1 ,14))
             
             --octal test
             print(assert(0o10 == 8)) --default
             print(assert(0o4501 == 2369)) --hard
             print(assert(0o0.1 == 0.125)) --floating point
             print(assert(0o10.201 == 8.251953125))
             --print(assert(0o11.2E-1 == 9.25E-1)) --exponenta
             print(assert(0o12.1P+2,40.5))
             
         ]===] },
     {   test_name = "single_C_assignment_addition",--4 test
         short_ctrl = "sys.err,cssc.CA",
         --full_ctrl = "<C_assignment_addition>",
         test_function = [===[
             local a = 1
             
             a+=1
             assert(a==2)
             
             a*=8
             assert(a==16)
             
             a/=2
             assert(a==8)
             
             a-=3
             assert(a==5)
             
         ]===] },
     {   test_name = "single_nil_forgiving_test",--5 test
         short_ctrl = "sys.err,cssc.NC",
         --full_ctrl = "<nil_forgiving>",
         test_function = [===[
         
             local nil_call = function (obj) return obj?() end
             local nil_call_str = function (obj) return obj?"str" end
             local nil_table_ind = function (obj) return obj?.index end
             local test_obj = { index = 1 }
             local test_obj_nil = {}
             local test_func = function(arg) if arg=="str" then return "str" else return "default" end end
             
             --nil functions 
             assert(nil_call(test_func)=="default")
             assert(nil_call_str(test_func)=="str")
             assert(nil_call()==nil)
             assert(nil_call_str()==nil)
             
             --table nil indexing
             assert(nil_table_ind(test_obj)==1)
             assert(nil_table_ind(test_obj_nil)==nil)
             assert(nil_table_ind()==nil)
             
         ]===] },
     {   test_name = "single_lua5.3_opts_test_(bitwizes)",--6 test
         short_ctrl = "sys.err,cssc.BO",
         --long_ctrl = "<lua5.3>",
         test_function = [===[
             
             --single operator test
             assert(2>>1==1)
             assert(2<<1==4)
             assert(2|4==6)
             assert(4|2==6)
             assert(2&4==0)
             assert(4&2==0)
             assert(2==2&3)
             assert(4==6&5)
             assert(0==4~4)
             
             --complex
             assert(2<<4|1+17&~18==32)
             assert(7*3>>1|1+12==15)
             assert(19==800>>4&10<<1|3&3)
             
             --idiv
             assert(8//3==2)
             
             --metatable
             local metadata = {
                 __shl = function(a,b) return "shift left" end,
                 __shr = function(a,b) return "shift right"end,
                 __bnot= function(a)   return "binary not" end,
                 __bor = function(a,b) return "binary or"  end,
                 __band= function(a,b) return "binary and" end,
                 __bxor= function(a,b) return "binary xor" end,
                 __idiv= function(a,b) return "int divide" end
             }
             local obj = setmetatable({},metadata)
             
             assert(obj<<1 =="shift left")
             assert(obj>>1 =="shift right")
             assert(~obj   =="binary not")
             assert(1|obj  =="binary or" )
             assert(1&obj  =="binary and")
             assert(obj~obj=="binary xor")
             assert(obj//1 =="int divide")
             
         ]===]
     },
     --[[{   test_name = "single_complex_test", --DEPRECATED!
         short_ctrl = "<A>",--config
         long_ctrl = "<All>",
         test_function = [===[
             
             --keyword shortcuts,lambda and bitwize
             @func = a,b -> a | b;
             
             assert(func(27,23)==31)
             
             func=nil
             
             --quick nil forgiving
             assert(func?(27,23)==nil)
             
             @a = 1
             
             --additional assignment opts with logical (?=, ||=. &&=, ...) and bitwize injection (>>, <<, |, &) exept xor (~= reserved for "not equal" opt)
             a += 1<<1
             
             a <<= 1
             
             assert(a == (1 + (1<<1)) << 1)
             
             a &= 1
             assert(a) -- a will be equal to "true"
             
             @str_var = "basic string"
             
             --IS keyword
             assert(str_var is "string")
             assert(12 is {"number","string"}) --string or table
             assert({} is "table")
             
             
             
         ]===] },]]
         
         
}

package.path=package.path..";../?.lua"--add previous directory to require check
local bitop = require("lib/bitop")

local bitop_force_load=true
if bitop_force_load then
    local req = require 
    require = function(s,...)if s=="bit" or s=="bit32"then return nil end return req(s,...)end
end

package.preload["bitop"]=function() print("\nWARNIGN!\nBitop.lua loaded. Bitwize operators performance might be low.\n\n") return bitop end--for situations where bit/bit32 dlls not exist
local lua_mc=require("out/lua_mc__lua51__original")--load system

test = test_matrix[tonumber(arg[1])]
print("Selected test: ",arg[1],"- ",test.test_name)
print("SOURCE CODE  : \n", test.test_function)
print("PREPROCESSED : ")
comp1 = lua_mc.make(test.short_ctrl)
local prep = comp1:run(test.test_function)
print(prep)
local l, err = comp1:cssc_load(nil,nil,setmetatable({},{__index=_G}))
print("Call output  : ",pcall(l))
print("Error        : ", err)

package.path=package.path..";../lib/?.lua" --load cc.pretty extracted from CraftOS for better output with -i atrubute
P=require("lib/cc.pretty")


