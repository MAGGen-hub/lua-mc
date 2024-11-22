-- CSSC_LUA-MC_COMPILLER1.1 (L-make)
-- Required System Parameters:
--
-- LinuxOS 
-- IntelCoreI3
-- RAM 4Gb
-- -- or other with same or gather computing power
-- 
-- Required Libs (depends on version)
-- lua-Jit
-- lua5.1
-- lua5.2
-- lua5.3
-- lua5.4
-- craftos-pc
-- craftos-pc-data
-- bit32-lua51
-- bitop-lua51
-- libcompat51 --for tests
-- libcompat52
-- os.execute-plugin --for craft os related tests
--
-- Required compilling/testing ENV/IDE: CraftOS-pc - latest


--PROJECT DATA
local project_name = "lua_mc"
local version	  = "4.5-beta"
local version_num  = 4.5

--COMPILE DATA
local work_dir	 = "/cssc_final"
local src_dir	  = fs.combine(work_dir,"src")
local out_dir	  = fs.combine(work_dir,"out")
local protect_src  = fs.combine(src_dir ,"protection_and_variable_layer.lua")
local base_src	 = fs.combine(src_dir ,"new_base.lua")
local features_src = fs.combine(src_dir ,"features")
local modules_src  = fs.combine(src_dir ,"modules")
local macro_src	= fs.combine(src_dir ,"common_macro.csv")
local test_src	 = "tests/tests.lua"
local lzss_src	 = "lzss_lib/lzss.lua"
local lzss_sep_src = "lzss_lib/sep_make.lua"
local macro={
	--Bit32/bit
	"__BIT32_LIBRUARY_VERSION_MACRO__",
	"__BIT32_LIBRUARY_VERSION_MACRO_MINIFIED_LOAD_PART__",
	"__BIT32_LIBRUARY_VERSION_MACRO_MINIFIED_VARIABLE_NAME__",
	"__BIT32_LIBRUARY_VERSION_MACRO_MINIFIED_VARIABLE_VALUE__",
	--Native Load
	"__NATIVE_LOAD_VERSION_MACRO__",
	"__NATIVE_LOAD_VERSION_MACRO_MINIFIED__",
	--Unpack Method
	"__UNPACK_MACRO__",
	"__UNPACK_MACRO_MINIFIED__",
}


--COMPILE CONFIG
local config ={

--minification function to decrase code size
  minify={--WARNING!: temporaly unavaliable. 
	del_spaces	= false, --removes all posible tabs and spaces to make code smaller
	default_words = false, --turn default variable names (such as operator,word,index) into o,w,i
	del_comments  = false, -- delete all comments from code
	control_table = false, --turn control-table into unreadable, but ultra fast mess
	other		 = false}, --minify other stuff

  debug=true --if true then @@DEBUG macro will be compilled and inserted in code (required some times)
}

--compilation function
local compile = {
	craft_os = true,  --default C SuS SuS for CraftOS
	lua51   = true, --optimised for specific Lua version use
	lua52   = true, 
	lua53   = false,
	lua54   = false,
	Lua_Jit  = false} --Lua-Jit


--lzss archiver function to decrase code size
local compile_lzss = {--WARNING!: temporaly unavaliable. 
	pre_compress = false, -- Replace common stuff with bytes before compressing
	default	  = false, -- Default LZSS version
	SEP		  = false} -- Self extracting program

--testing function
local run_tests = {--WARNING!: temporaly unavaliable. (other test system setup)
	craft_os = true,
	lua51   = false,
	lua52   = false,
	lua53   = false,
	lua54   = false,
	Lua_Jit  = false}

--OUTPUT_FILE_NAME_DEFINE:  <__PROJECT_NAME__>_api<version_number>.<minification_type>.<compile_type>.<extension>

--COMPILATOR FUNCS
local function get_src(src)
	local file = fs.open(src,"r")
	local str = file.readAll()
	file.close()
	return str
end
local function set_out(out,data)
	local file,err = fs.open(out,"w")
	print(out)
	file.write(data)
	file.close()
end

string.gifsub = function(text,condition,pattern,replacement)
	return condition and text:gsub(pattern,replacement) or text
end

local compile_dir
compile_dir = function(src,path,subdir,md)
	path=path.."={"
	for k,v in pairs(fs.list(src))do
		k=fs.combine(src,v)
		if fs.isDir(k)then
			--print(v,md)
			path=compile_dir(k,path..(md and v=="modules"and"[_modules]"or v),1,md).."},--Close "..v.."\n"
		else--file
			k=get_src(k)
			v=v:sub(1,-5)
			path=path..(md and v=="init"and"[_init]"or v).."="..(#k>0 and k or"function()end")..",\n"
			--path=v=="doend"and k..path or path..k
		end
	end
	return path..(subdir and""or"}")
end

--COMPILE:
for code_name,enabled in pairs(compile) do
	if enabled then
		--GET CODE
		local code = table.concat{get_src(protect_src),get_src(base_src)}--,get_src(cores_src),get_src(modules_src)}
		--MAKE_FEATURES
		code=code:gsub("__FEATURES__",function()return compile_dir(features_src,"\nFeatures").."--END OF FEATURES\n"end)
		--MAKE MODULES
		code=code:gsub("__MODULES__",function()return compile_dir(modules_src ,"\nModules",nil,1).."--END OF MODULES\n"end)
		--COMPILE MACROS
		for k,v in pairs(macro)do
			code=code:gsub(v,get_src(fs.combine(src_dir,code_name,v..".lua")))
			get_src(macro_src):sub(16):gsub("\n+(.-),(.-),.-",function(name,value)code=code:gsub(name,value)end)
		end 
		--SET PROJECT NAME
		code=code:gsub("__PROJECT_NAME__",project_name)
		--code = code
		--REMOVE DEBUG
		if config.debug then
			code=code:gsub("@@DEBUG_START",""):gsub("@@DEBUG_END",""):gsub("@@DEBUG","")
		else
			code=code:gsub("@@DEBUG_START.-@@DEBUG_END",""):gsub("@@DEBUG.-\n","")
		end
		--SET OUT
		set_out(fs.combine(out_dir,table.concat({project_name,code_name,"original"},"__")..".lua"),code)
	end
end

--CLEAR STRING METATABLE
string.gifsub = nil
--WARNING: debug feature! disable if unwanted
shell.run("/cssc_final/out/lua_mc__craft_os__original.lua")
