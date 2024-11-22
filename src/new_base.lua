--ARG CHECK FUNC
local arg_check,t_copy,t_swap,Modules,Features=function(Control)if(getmetatable(Control)or{}).__type~="cssc_unit"then error(format("Bad argument #1 (expected cssc_unit, got %s)",type(Control)),3)end end,function(s,o,f) for k,v in pairs(s)do o[k]=f and o[k]or v end end,function(t,o)o=o or {}for k,v in pairs(t)do o[v]=k end return o end
--LOCALS
local Configs,_init,_modules,_arg,load_lib,continue,clear,make,run,read_control_string,load_control_string={__PROJECT_NAME___basic="sys.err,cssc={NF,KS,LF,BO,CA}",__PROJECT_NAME___user="sys.err,cssc={NF,KS(sc_end),LF,DA,BO,CA,NC,IS}",__PROJECT_NAME___full="sys.err,cssc={NF,KS(sc_end,pl_cond),LF,DA,BO,CA,NC,IS}"},setmetatable({},{__tostring=native_load"return'init'"}),setmetatable({},{__tostring=native_load"return'modules'"}),{'arg'},
function(Control,path,...)arg_check(Control)--load_lib
	local ld,arg,tp=Control.Loaded[">"..path],{}
	if false~=ld then
		Control.log("Load %s",">"..path)
		if ld and ld~=__RECALLABLE__ then return unpack(ld)end--return previous result (__RESULTABLE__ mode)
		arg={native_load("return "..path.."(...)","Feature Loader",nil,Features)(Control,...)}
		tp=remove(arg,1)or false --if no return -> default mode (only one launch allowed)
		Control.Loaded[">"..path]=__RESULTABLE__==tp and arg or tp--setup reaction to future call(deny_lib_load/recal/return_old_rez)
	end
	return unpack(arg)
end,
function(Control,x,...)arg_check(Control)--continue
	Control.src=x
	Control.args={...}
	--PRE RUN
	Control:tab_run"PreRun"
	--COMPILE
	while not Control.Iterator(__MAIN_CYCLE__)do
		Control:tab_run("Struct",1)
		--for k,v in pairs(Control.Struct)do --custom structure system
		--	if v(Control)then break end
		--end
	end
	--POST RUN
	Control:tab_run"PostRun"
	--FINISH COMPILE and return result
	local e=type(Control.Return)
	if"function"==e then
		return Control.Return()
	elseif"table"==e then
		return unpack(Control.Return)
	else
		return Control.Return
	end
end,
function(Control)arg_check(Control)Control:tab_run"Clear"end--clear
run=function(Control,x,...)Control:clear()return Control:continue(x,...)end

make=function(ctrl_str)
	--ARG CHECK
	if"string"~=type(ctrl_str)then error(format("Bad argument #2 (expected string, got %s)",type(ctrl_str)))end
	--INITIALISE PREPROCESSOR OBJECT
	local m,i,Control,r={__type="cssc_unit",__name="cssc_unit"},1
	r={__call=function(S,s,...)if#S>999 then remove(S,1)end insert(S,format("%-16s : "..s,format("[%0.3d] [%s]",i,S._),...)) i=i+1 end}
	Control=setmetatable({
		--MAIN FUNCTIONS
		ctrl=ctrl_str,run=run,clear=clear,continue=continue,load_lib=load_lib,
		tab_run=function(Control,tab,br)for k,v in pairs(Control[tab])do if v(Control)and br then break end end end,
		--MAIN OBJECTS TO WORK WITH
		PostLoad={},PreRun={},PostRun={},Struct={},Loaded={},Clear={},Result={},
		--SYSTEM PLACEHOLDERS
		error=setmetatable({_=" Error "},r),--send error msg
		log=setmetatable({_="  Log  "},r),  --send log msg
		warn=setmetatable({_="Warning"},r), --send warning msg
		Core=placeholedr_func,
		Iterator=native_load"return 1",
		--META
		meta=m},m)
	--Control.push_error=function(str,...)insert(Control.Errors,{format(str,...),...})end--default error inserter
	--CONTROL STRING LOAD
	load_control_string(Control,read_control_string(ctrl_str))
	--POST LOAD
	Control:tab_run"PostLoad"
	return Control
end
read_control_string=function(s)--RECURSIVE FUNC: turn control string into table and load configs
	local c,t,l,e,m={"config",[_arg]={}}--config and arg marks!
	m={__index=function(s,i)s=s==c and setmetatable({c[1],[_arg]={}},m)or s s[#s+1]=i return s end,__call=function(s,...)
			local l={...}
			for i=1,#l do l[i]="table"==type(l[i])and l[i][_arg]and concat(l[i],".")or l[i] end
			s[_arg][s[#s]]=#l==1 and"table"==type(l[1])and l[1]or l
			return s end}
	l,e=native_load(gsub(format("return{%s}",s),"([{,])([^,]-)=","%1[%2]="),"ctrl_str",t,setmetatable({},{__index=function(s,i)return setmetatable(i==c[1]and c or{[_arg]={},i},m) end}))
	l=e and error(format("Invalid control string: <%s> -> %s",s,e))or l()
	s,l[c]=l[c]
	t,e=pcall(concat,s)
	e=Configs[t and e or s]
	t=1
	for k,v in pairs(e and read_control_string(e)or{})do
		-- l["number"==type(k)and#l+1 or k]=v
		if"number"==type(k)then insert(l,t,v) t=t+1 else l[k]=v end
	end
	return l,a
end
load_control_string=function(Control,main,sub,nxt,path)--RECURSIVE FUNC: load readed control string and fill Control table with contents of loaded modules
	local prt,mod,e
	if nxt then--LOAD MODULE
		prt=remove(main,1)
		mod=nxt[prt]or{}
		path=path..prt
		Control.Loaded[path],e=pcall(function()
			if Control.Loaded[path]then return end --prevent double load
			Control.log("Load %s",path)
			--prt=mod[_modules]and{}or#main>0 and main or sub or{}
			--for k,v in pairs(prt)do if"table"==type(v)then prt={}break end end
			--   print(path,mod[_init])
			;(mod[_init]or placeholder_func)(Control,mod,main[_arg][prt])
			--write(path)write"Args: "p(prt)
		end)
		mod=e and error(format('Error loading module "%s": %s',path,e),4)or mod[_modules]
	else
		mod=Modules--INIT LOADER
		sub=main
	end
	--mod={}--DEBUG! Show all modules without any rules
	if mod then  --load sub_modules if exist
		path=path and path.."."or"@"
		if nxt and#main>0 then load_control_string(Control,main,sub,mod,path)
		else for k,v in pairs(sub or{})do
			e=e or"string"==type(v)--set correct mode
			v=e and{v}or v
			v="number"==type(k)and{v}or{k,v}
			load_control_string(Control,v[1],v[2],mod,path)
		end end
	end
end
--TODO: giper native load with auto _ENV set
do
--__PREPARE_FEATURES__
__FEATURES__
end
do
--__PREPARE_MODULES__
__MODULES__
end

__PROJECT_NAME__={make=make,run=run,clear=clear,Features=Features,Modules=Modules,Configs=Configs,dev={init=_init,modules=_modules}}
@@DEBUG __PROJECT_NAME__.continue=continue --curently in testing 
@@DEBUG _G.__PROJECT_NAME__=__PROJECT_NAME__
--@@DEBUG _G.__PROJECT_NAME__.test=read_control_string
return __PROJECT_NAME__

