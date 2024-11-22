-- this script MUST have the same working direactory and location folder to work correctly! : /*your dir*/*proj dir*/tests

-- requirements
-- lua5.1 - VM
-- libcompat51 (lzss test only)
-- bitop-lua51 or bit32-lua51
-- compilled lua-mc.lua51.original.lua

--source file of lzss program to test (imposible to launch in lua by default)
--#region test_sources
lzss_src = [===[
--[[----------------------------------------------------------------------------

	LZSS - encoder / decoder

	This is free and unencumbered software released into the public domain.

	Anyone is free to copy, modify, publish, use, compile, sell, or
	distribute this software, either in source code form or as a compiled
	binary, for any purpose, commercial or non-commercial, and by any
	means.

	In jurisdictions that recognize copyright laws, the author or authors
	of this software dedicate any and all copyright interest in the
	software to the public domain. We make this dedication for the benefit
	of the public at large and to the detriment of our heirs and
	successors. We intend this dedication to be an overt act of
	relinquishment in perpetuity of all present and future rights to this
	software under copyright law.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.

	For more information, please refer to <http://unlicense.org/>

--]]----------------------------------------------------------------------------
--------------------------------------------------------------------------------
local M = {}
local string, table = string, table

--------------------------------------------------------------------------------
local POS_BITS = 12
local LEN_BITS = 16 - POS_BITS
local POS_SIZE = 1 << POS_BITS
local LEN_SIZE = 1 << LEN_BITS
local LEN_MIN = 3

--------------------------------------------------------------------------------
function M.compress(input)
	local offset, output = 1, {}
	local window = ''

	local function search()
		for i = LEN_SIZE + LEN_MIN - 1, LEN_MIN, -1 do
			local str = string.sub(input, offset, offset + i - 1)
			local pos = string.find(window, str, 1, true)
			if pos then
				return pos, str
			end
		end
	end

	while offset <= #input do
		local flags, buffer = 0, {}

		for i = 0, 7 do
			if offset <= #input then
				local pos, str = search()
				if pos and #str >= LEN_MIN then
					local tmp = ((pos - 1) << LEN_BITS) | (#str - LEN_MIN)
					buffer[#buffer + 1] = string.pack('>I2', tmp)
				else
					flags = flags | (1 << i)
					str = string.sub(input, offset, offset)
					buffer[#buffer + 1] = str
				end
				window = string.sub(window .. str, -POS_SIZE)
				offset = offset + #str
			else
				break
			end
		end

		if #buffer > 0 then
			output[#output + 1] = string.char(flags)
			output[#output + 1] = table.concat(buffer)
		end
	end

	return table.concat(output)
end

--------------------------------------------------------------------------------
function M.decompress(input)
	local offset, output = 1, {}
	local window = ''

	while offset <= #input do
		local flags = string.byte(input, offset)
		offset = offset + 1

		for i = 1, 8 do
			local str = nil
			if (flags & 1) ~= 0 then
				if offset <= #input then
					str = string.sub(input, offset, offset)
					offset = offset + 1
				end
			else
				if offset + 1 <= #input then
					local tmp = string.unpack('>I2', input, offset)
					offset = offset + 2
					local pos = (tmp >> LEN_BITS) + 1
					local len = (tmp & (LEN_SIZE - 1)) + LEN_MIN
					str = string.sub(window, pos, pos + len - 1)
				end
			end
			flags = flags >> 1
			if str then
				output[#output + 1] = str
				window = string.sub(window .. str, -POS_SIZE)
			end
		end
	end

	return table.concat(output)
end

return M
]===]





--------------------------------------------------------------------------------
--lzss algoritm optimized with cssc extemsion module operators
lzss_src_oprimised=[===[
@M = {}
@string, table = string, table

--------------------------------------------------------------------------------
@POS_BITS = 12
@LEN_BITS = 16 - POS_BITS
@POS_SIZE = 1 << POS_BITS
@LEN_SIZE = 1 << LEN_BITS
@LEN_MIN = 3
--------------------------------------------------------------------------------
function M.compress(input)
	@offset, output = 1, {}
	@window = ''

	@search= ()=> --lambda func
		for i = LEN_SIZE + LEN_MIN - 1, LEN_MIN, -1 do 
			@str = string.sub(input, offset, offset + i - 1)
			@pos = string.find(window, str, 1, true)
			if pos then
				return pos, str
			end
		end
	end

	while offset <= #input do
		@flags, buffer = 0, {}

		for i = 0, 7 do
			if offset <= #input then
				@pos, str = search()
				if pos && #str >= LEN_MIN then
					@tmp = ((pos - 1) << LEN_BITS) | (#str - LEN_MIN)
					buffer[#buffer + 1] = string.pack('>I2', tmp)
				else
					flags |= (1 << i) -- C addidional asignment
					str = string.sub(input, offset, offset)
					buffer[#buffer + 1] = str
				end
				window = string.sub(window .. str, -POS_SIZE)
				offset += #str -- C addidional asignment
			else
				break
			end
		end

		if #buffer > 0 then
			output[#output + 1] = string.char(flags)
			output[#output + 1] = table.concat(buffer)
		end
	end

	return table.concat(output)
end
--------------------------------------------------------------------------------
M.decompress = input =>
	@offset, output = 1, {}
	@window = ''

	while offset <= #input do
		@flags = string.byte(input, offset)
		offset += 1

		for i = 1, 8 do
			@str = nil
			if (flags & 1) ~= 0 then
				if offset <= #input then
					str = string.sub(input, offset, offset)
					offset += 1
				end
			else
				if offset + 1 <= #input then
					@tmp = string.unpack('>I2', input, offset)
					offset += 2
					@pos = (tmp >> LEN_BITS) + 1
					@len = (tmp & (LEN_SIZE - 1)) + LEN_MIN
					str = string.sub(window, pos, pos + len - 1)
				end
			end
			flags >>= 1
			if str then
				output[#output + 1] = str
				window = string.sub(window .. str, -POS_SIZE)
			end
		end
	end

	return table.concat(output)
end

return M
]===]



--------------------------------------------------------------------------------
--lzss 
lzss_src_final=[===[
    @M = {}
    @string, table = string, table
    
    --------------------------------------------------------------------------------
    @POS_BITS = 0b1100 --number format (binary/ octal)
    @LEN_BITS = 0o20 - POS_BITS
    @POS_SIZE = 1 << POS_BITS
    @LEN_SIZE = 1 << LEN_BITS
    @LEN_MIN = 3
    --------------------------------------------------------------------------------
    M.compress = function(input : string = string.rep("basic string to compress\n",100))--default args
        @offset, output = 1, {}
        @window = ''
    
        @search= ()=> --lambda func
            for i = LEN_SIZE + LEN_MIN - 1, LEN_MIN, -1 do 
                @str = string.sub(input, offset, offset + i - 1)
                @pos = string.find(window, str, 1, true)
                /| pos ? return pos, str;
            end;
    
        while offset <= #input do
            @flags, buffer = 0, {}
    
            for i = 0, 7 do
                /| offset <= #input ?
                    @pos, str = search()
                    /|pos && #str >= LEN_MIN ?
                        @tmp = ((pos - 1) << LEN_BITS) | (#str - LEN_MIN)
                        buffer[#buffer + 1] = string.pack('>I2', tmp)

                    \|  flags |= (1 << i) -- C addidional asignment
                        str = string.sub(input, offset, offset)
                        buffer[#buffer + 1] = str;
                    window = string.sub(window .. str, -POS_SIZE)
                    offset += #str -- C addidional asignment
                \|break;
            end
    
            /|#buffer>0?
                output[#output + 1] = string.char(flags)
                output[#output + 1] = table.concat(buffer);
        end
    
        return table.concat(output)
    end
    --------------------------------------------------------------------------------
    function  M.decompress(input : string)
        @offset, output = 1, {}
        @window = ''
    
        while offset <= #input do
            @flags = string.byte(input, offset)
            offset += 1
    
            for i = 1, 8 do
                @str = nil
                if (flags & 1) ~= 0 then
                    /|offset <= #input?
                        str = string.sub(input, offset, offset)
                        offset += 1;
                else
                    /|offset + 1 <= #input?
                        @tmp = string.unpack('>I2', input, offset)
                        offset += 2
                        @pos = (tmp >> LEN_BITS) + 1
                        @len = (tmp & (LEN_SIZE - 1)) + LEN_MIN
                        str = string.sub(window, pos, pos + len - 1);
                end
                flags >>= 1
                /|str? output[#output + 1] = str
                       window = string.sub(window .. str, -POS_SIZE);
            end
        end
    
        return table.concat(output)
    end
    
    return M
    ]===]

--#endregion

--prepare:
package.path=package.path..";../?.lua"--add previous directory to require check
local lua_mc=require("out/lua_mc__lua51__original")--load system

local comp1 = lua_mc.make("sys.err,cssc={BO}")--basic compiller
local compilled=comp1:run(lzss_src)--compile basic lzss
print(compilled)

require("compat53")--for lzss load string.pack/unpack methods (lua-mc not uses them)
local lzss_basic = comp1:cssc_load("basic_lzss",nil,setmetatable({},{__index=_G}))()--specific _ENV with _G protected

assert(lzss_basic,"Unable to compile lzss src")

local compressed_lzss_src=lzss_basic.compress(lzss_src)
local decompressed_lzss_src=lzss_basic.decompress(compressed_lzss_src)
assert(decompressed_lzss_src == lzss_src,"Error lzss compress/decompress output not equal to input!")
print("Basic lzss test complete.")

local comp2 = lua_mc.make("sys.err,cssc={KS,LF,BO,CA}")
compilled=comp2:run(lzss_src_oprimised)--compile advanced lzss
print(compilled)

local lzss_advanced = comp2:cssc_load("advanced_lzss",nil,setmetatable({},{__index=_G}))()--specific _ENV with _G protected

assert(lzss_advanced,"Unable to compile advanced lzss src")

local compressed_lzss_src=lzss_advanced.compress(lzss_src_oprimised)
local decompressed_lzss_src=lzss_advanced.decompress(compressed_lzss_src)
assert(decompressed_lzss_src == lzss_src_oprimised,"Error lzss compress/decompress output not equal to input!")
print("Advanced lzss test complete.")


local comp3 = lua_mc.make("sys.err,cssc={KS(sc_end,pl_cond),LF,DA,BO,CA,NF}")
compilled=comp3:run(lzss_src_final)--compile advanced lzss
print(compilled)

local lzss_final = comp3:cssc_load("final_lzss",nil,setmetatable({},{__index=_G}))()--specific _ENV with _G protected
--[[
if e then print(e)end
print("lc")
for k,v in pairs(comp3.Event.main.lvl_close) do print(k,v) end
print("lo")
for k,v in pairs(comp3.Event.main.lvl_open) do print(k,v) end
print("op")
for k,v in pairs(comp3.Event.main[2]) do print(k,v) end
assert(lzss_final,"Unable to compile final lzss src")]]

local compressed_lzss_src=lzss_final.compress(lzss_src_final)
local decompressed_lzss_src=lzss_final.decompress(compressed_lzss_src)
assert(decompressed_lzss_src == lzss_src_final,"Error lzss compress/decompress output not equal to input!")
print("Final lzss test complete.")
print("Def arg decompressed output:")
print(lzss_final.decompress(lzss_final.compress()))