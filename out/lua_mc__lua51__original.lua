-- PROTECTION LAYER
-- This local var layer was created to prevent unpredicted behaviour of preprocessor if one of the functions in _G table was changed.
local A,E=assert,"lua_mc load failed because of missing libruary method!"

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
local unpack = A(unpack,E)

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
--Bit32 libruary prepare section
local bit32 = pcall(require,"bit")and require"bit" --attempt to get bitop.dll (bit64)
or pcall(require,"bit32")and require"bit32" --attempt to get bit32.dll as replacement
or pcall(require,"bitop")and (require"bitop".bit or require"bitop".bit32) --emergency solution: bitop.lua
or print and print"Warning! Bit32/bitop libruary not found! Bitwize operators module disabled!"and nil --loading alarm
if bit32 then
    local b = {}
    for k,v in pairs(bit32)do b[k]=v end
    b.shl=b.lshift
    b.shr=b.rshift
    b.lshift,b.rshift=nil --optimisation
    bit32=b
end

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

A,E=nil
local lua_mc = {}
local placeholder_func = function()end

-- BASE VARIABLES LAYER END
--ARG CHECK FUNC
local arg_check,t_copy,t_swap,Modules,Features=function(Control)if(getmetatable(Control)or{}).__type~="cssc_unit"then error(format("Bad argument #1 (expected cssc_unit, got %s)",type(Control)),3)end end,function(s,o,f) for k,v in pairs(s)do o[k]=f and o[k]or v end end,function(t,o)o=o or {}for k,v in pairs(t)do o[v]=k end return o end
--LOCALS
local Configs,_init,_modules,_arg,load_lib,continue,clear,make,run,read_control_string,load_control_string={lua_mc_basic="sys.err,cssc={NF,KS,LF,BO,CA}",lua_mc_user="sys.err,cssc={NF,KS(sc_end),LF,DA,BO,CA,NC,IS}",lua_mc_full="sys.err,cssc={NF,KS(sc_end,pl_cond),LF,DA,BO,CA,NC,IS}"},setmetatable({},{__tostring=native_load"return'init'"}),setmetatable({},{__tostring=native_load"return'modules'"}),{'arg'},
function(Control,path,...)arg_check(Control)--load_lib
	local ld,arg,tp=Control.Loaded[">"..path],{}
	if false~=ld then
		Control.log("Load %s",">"..path)
		if ld and ld~=1 then return unpack(ld)end--return previous result (2 mode)
		arg={native_load("return "..path.."(...)","Feature Loader",nil,Features)(Control,...)}
		tp=remove(arg,1)or false --if no return -> default mode (only one launch allowed)
		Control.Loaded[">"..path]=2==tp and arg or tp--setup reaction to future call(deny_lib_load/recal/return_old_rez)
	end
	return unpack(arg)
end,
function(Control,x,...)arg_check(Control)--continue
	Control.src=x
	Control.args={...}
	--PRE RUN
	Control:tab_run"PreRun"
	--COMPILE
	while not Control.Iterator(0)do
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

Features={code={cdata=function(Control,opts_hash,level_hash)--API to save code data to specific table
    local check,c,clr=t_swap{2,4,9}
    clr=function()
        for i=1,#c do c[i]=nil end c[1]={2,0}
        --c={opts=c.opts,lvl=c.lvl,run=c.run,reg=c.reg,del=c.del,tb_until=c.tb_until,tb_while=c.tb_while, {11}}
        --Control.Cdata=c
    end
    c={opts=opts_hash,lvl=level_hash,
    run=function(obj,tp)--to call from core
        local lh,rez=c.lvl[obj]
        --if obj=="(" then print(lh,rez) end
        if lh and lh[2] then --object with lvl props
            rez=Control.Level[#Control.Level] --TODO: temporal solution! REWORK!!!
            rez ={tp,rez.ends[obj] and rez.index}
        elseif tp==2 then
            local pd,lt,un = c.opts[obj],c[#c][1]--priority_data,last_type,is_unary
            un = pd[2] and (not pd[1] or not check[lt])--unary or binary
            rez={tp,not un and pd[1],un and pd[2]}--insert operator data handle
        else
            rez={tp}
        end
        c[#c+1]=rez
    end,
    reg=function(tp,id,...)--reg custom value in specific field
        local rez = {tp,...}--args and {tp,...} or {tp}
        insert(c,id or #c+1,rez)
    end,
    del=function(id)--del specific value from index
        return remove(c,id or #c+1)
    end,
    tb_until=function(type_tab,i)--thaceback_until:
        i=i or#c+1
        repeat i=i-1 until i<1 or type_tab[c[i][1]]
        return i,c[i]
    end,
    tb_while=function(type_tab,i)--thaceback_while:
        i=i or#c
        while i>0 and type_tab[c[i][1]]do i=i-1 end
        return i,c[i]
    end, {2,0}
    }
    Control.Cdata=c
    insert(Control.Clear,clr)
end,
cssc={op_stack=function(Control) --cssc feature to process and stack unfinished operators (turned into function calls) in current level data field. (op_st - field name) 
    --Control.OStack
    --OP_stack feature: {OP_index,OP_priority,OP_start,OP_breaket}
    local L,CD,pht = Control.Level,Control.Cdata,{}

    --fin all unfinished operators
    Control.Event.reg("lvl_close",function(lvl)
        --print("OP lc")
        if lvl.OP_st then
            local i = #CD
            for k=#lvl.OP_st,1,-1 do
                Control.inject(i,")",10,lvl.OP_st[k][4])--fin all unfinished
            end
        end
    end,"OP_st_f",1)

    --priority check
    Control.Event.reg(2,function(obj,tp)
        --print("OP op")
        local lvl,cdt,st,cst = L[#L],CD[#CD]
        st=lvl.OP_st
        if st and cdt[2] then --level has OP_stack and current op is binary (unary opts has no affection on opts before them)
            --TODO: add for cycle for all that lower!!!!
            while #st>0 and cdt[2] <= st[#st][2] do--priority of CSSC operator is highter or equal -> inject closing breaket
                --print(obj,cdt[2],st[#st][2])
                cst=remove(st)--del last
                Control.inject(#CD,")",10,cst[4])--insert breaket before current operator
            end
        end
    end,"OP_st_d",1)

    Control.inject_operator = function(pre_tab,priority, is_unary,skip_fb,now_end,id)--function to inject common operators fast
        --init locals
        local lvl,i,cdt,b,st,sp,last =L[#L],id or #CD --level; index; breaket; curent_cdata,stack_tab,start_pos
        cdt,st,pre_tab=CD[i],lvl.OP_st or{},pre_tab or{}
        sp=#st>0 and st[#st][4] or lvl.index --find start_position for while cycle
        --print(sp==lvl.index,lvl.OP_st)
        --trace back cycle
        if not is_unary then
			--print(i,sp,cdt,cdt[1],cdt[2])
            while i>sp and not(cdt[1]==2 and (cdt[2]or cdt[3])<priority)do
                i=(L.data[match(Control.Result[i],"%S+")]or pht)[2] and cdt[2] or i-1
                --if cdt[1]==2 and cdt[2]==0 then end --TODO: EMIT ERROR!!! statement_end detected!!!!
                cdt=CD[i]
            end --after that cycle i will contain index where we need to place the start of our operator
            --print("cdt:",cdt)
            last=cdt
        else
            _,last=Control.Cdata.tb_while({[11]=1},i-1)
        end
        if i<sp then Control.error("OP_STACK Unexpected error!")end
        i=i+1 --increment i (index correction)
        --iject data before
        if not skip_fb then
            Control.inject(i,"(",9)--insert open breaket
            if #pre_tab>0 then
                Control.inject(i,"" -- .."--[[cl mrk]]"
		        ,2,Control.Cdata.opts[":"][1])--call mark
            end
            for k=#pre_tab,1,-1 do --insert caller function/construct if exist
                Control.inject(i,unpack(pre_tab[k]))
            end
        end
        if now_end then--inject fin breaket imidiatly
            Control.inject(nil,")",10)
            return i-1,last
        end
        insert(st,{#CD,priority,i,i+#pre_tab})--new element in stack to finalize
        lvl.OP_st=st--save table (if unsaved)
        return i-1,last
    end
end,
pdata=function(Control,path,dt)--api to inject locals form Control table right into code
    local p,clr
    p={path=path or "__lua_mc__runtime", locals={}, modules={}, 
        data=dt or setmetatable({},{__call=function(self,...)
            local t={}
            for _,v in pairs{...}do
                insert(t,self[v] or error(format("Unable to load '%s' run-time module!",v)))
            end
            return unpack(t)
        end}),
        reg = function(l_name,m_name) --local name/module name
            insert(p.locals,l_name)
            insert(p.modules,"'"..m_name.."'")
        end,
        build=function(m_name,func)--TODO: REWORK!
            if (not p.data[m_name] or Control.error("Attempt to rewrite runtime module '%s'! Choose other name or delete module first!",m_name)) then p.data[m_name]=func end
        end,
        is_done=false,
        mk_env=function(tb)
            tb=tb or {}
            if #p.locals>0 then
                if tb[p.path] then Control.warn(" CSSC environment var '%s' already exist in '%s'. Override performed.",p.path,tb)end
                tb[p.path]=p.data 
            end
            return tb
        end
    }
    insert(Control.PostRun,function()
        if not p.is_done and #p.locals>0 then
            insert(Control.Result,1,"local "..concat(p.locals,",").."="..p.path.."("..concat(p.modules,",")..");")
        end
        p.is_done=true
    end)
    clr = function()
        p.locals={}
        p.modules={}
        p.is_done=false
    end
    Control.Runtime=p
    insert(Control.Clear,clr)
end,
typeof=function(Control)--typeof function used for "DA" and "IS" modules
    local ltp,lmt,pht=type,getmetatable,{}
    Control.typeof=function(obj)
        return (lmt(obj)or pht).__type or ltp(obj)
    end
end,
},--Close cssc
lua={base=function(Control,O,W)-- O - Control.Operators or other table; W - Control.Words or other table (depends on current text parceing system)
--BASE LUA SYNTAX STRING (keywords/operators/breakets/values)
local make_react,lvl,kw,kwrd,opt,t,p,lua51=Control:load_lib"text.dual_queue.make_react",{},{},{},{},{},1,
[[K
end
else 1
elseif
then 1 2 3
do 1
in 5
until
if 4
function 1
for 5 6
while 5
repeat 7
elseif 4
local
return
break
B
{ }
[ ]
( )
V
...
nil
true
false
O
;
=
,
or
and
< > <= >= ~= ==




..
+ -
* / %
not # -
^
. :
]]-- [ ( { "
--INSERT VERSION DIFF
Control:load_lib"text.dual_queue.base"
Control:load_lib"code.syntax_loader"(lua51,{
     K=function(k,...)--keyword parce
        kw[#kw+1]=k
        t=lvl[k]or{}
        for k,v in pairs{...}do
            v=tonumber(v)--or error("Expected number got: "..v)
            t[1]=t[1]or{}--open lvl
            t[1][kw[v]]=1--expected end
            lvl[kw[v]][2]=1--closing lvl
        end
        kwrd[k]=1
        lvl[k]=t
        W[k]=make_react(k,4)
    end,
    B=function(o,c)--breaket parce
        lvl[o]={{[c]=1}}--open with exepected end == c
        lvl[c]={nil,1}--closing
        O[o]=make_react(o,9)
        O[c]=make_react(c,10)
    end,
    V=function(v)--value parce
        (match(v,"%w")and W or O)[v]=make_react(v,8)
    end,
    O=function(...)--opt parce
        for k,v in pairs{...}do if""~=v then
            opt[v]=opt[v]and{opt[v][1],p}or{p}
            if match(v,"%w")then W[v]=W[v] or make_react(v,2)
            else O[v]=O[v] or v end
        end end
        p=p+1--increade priority
    end
})
lvl["do"][3]=1 --do can be standalone level and init block on it's own
opt["not"]={nil,opt["not"][1]}--unary opts fix
opt["#"]={nil,opt["#"][1]}
--TODO: inject cdata api -> stat_ends/calls
return 1,lvl,opt,kwrd--(leveling_hash,operator_hash<with_priority>,keywrod_hash)
end,
meta_opt=function(Control,place_mark) 
    -- call marker:    local a = print *call_mark* ("Hello World")
    local call_prew = t_swap{7,10,3}
    local call_nxt = t_swap{7,9}

    -- calculation statement marker: function() *stat_end* local *stat_end* a = v + a.b:c("s") + function()end+1 *stat_end* return *stat_end* a *stat_end* end
    local stat_end_prew=t_swap{3,10,7,8,6}
    local stat_end_nxt=t_swap{3,4,8,6}

    --function to detect statements separation and function calls
    return 2,function(prew,nxt,spifc)--cpf -> call_prew_is_function_kwrd spf -> stat_prew_is_function_construction
        if call_prew[prew] and call_nxt[nxt] then --CALL DETECTED (or function constructor start)
            place_mark(1)
        elseif stat_end_prew[prew] and stat_end_nxt[nxt] or prew==4 and not spifc then --STAT END DETECTED
            --:local a = b + function()end + 1 --valid statment!!!
            place_mark(-1)
        end
    end
end,
struct=function(Control)--comment/string/number detector
	local get_number_part=function(nd,f) --function that collect number parts into num_data. 
		local ex                            --Returns 1 if end of number found or nil if floating point posible
		nd[#nd+1],ex,Control.word=match(Control.word,format("^(%s*([%s]?%%d*))(.*)",unpack(f)))--get number part
		--print(format("^(%s*([%s]?%%d*))(.*)",unpack(f)))
		--print(nd[#nd],ex)
		Control.operator="" -- dot-able number protection (reset operator)
		if#Control.word>0 or#ex>1 then return 1 end--finished number or finished exponenta
		if#ex>0 then--unfinished exponenta #ex==1
			Control.Iterator()-- update op_word_seq
			ex=match(Control.operator or"","^[+-]$")
			if ex then
				nd[#nd+1]=ex
				nd[#nd+1],Control.word=match(Control.word,"^(%d*)(.*)")
				Control.operator=""
			end --TODO: else push_error() end -> incorrect exponenta prohibited by lua
			return 1
		end --unfinished exponenta #ex==1
	end
	local get_number,split_seq=function()--get_number:function to locate numbers with floating point;
		local c,d=match(Control.word,"^0([Xx])")d=Control.operator=="."and not c--dot-able number detection (t-> dot located | c->hex located)
		if not match(Control.word,"^%d")or not d and#Control.operator>0 then return end --number not located... return
		local num_data,f=d and{"."}or{},c and{"0"..c.."%x","Pp"}or{"%d","Ee"}
		if get_number_part(num_data,f)or"."==num_data[1]then return num_data end--fin of number or dot-able floating point number
		-- now: #ex==0 and #Control.word==0; all other ways are found
		--Control.word==0 -> number might have floating point
		Control.Iterator() --update op_word_sequences
		if Control.operator=="."then --floating point found
			num_data[#num_data+1]="."
			f[1]=sub(f[1],-2)
			get_number_part(num_data,f)
		end
		return num_data
	end,
	function(data,i,seq)--split_seq:function to split operator/word quences
		seq=seq and"word"or"operator"
		if data then
			data[#data+1]=i and sub(Control[seq],1,i)or Control[seq]
		end
		Control[seq]=i and sub(Control[seq],i+1)or""
		Control.index=Control.index+(i or 0)
		return i
	end
	--STRUCTURE MODULE
	insert(Control.Struct,function()
		local com,rez,mode,lvl,str=#Control.operator>0 and"operator"or"word"
		--SPACE HANDLER
		--mode,Control[com]=match(Control[com],"^(%s*)(.*)")
		--mode,com=gsub(mode,"\n","\n")--line counter
		--Control.line=Control.line+com
		--Control.Result[#Control.Result]=Control.Result[#Control.Result]..mode--return space back to place
		--STRUCTURE HANDLER
		if#Control.operator>0 then --string structures
			rez,com,lvl={},match(Control.operator,"^(-?)%1%[(=*)%[")--long strings and coments
			com=match(Control.operator,"^-%-")
			str=match(Control.operator,"^['\"]")--small strings/comments
			if lvl then --LONG BUILDER
				lvl="%]"..lvl.."()%]"
				repeat
					if split_seq(rez,match(Control.operator,lvl))then mode=com and 11 or 7 break end --structure finished
					insert(rez,Control.word)
				until Control.Iterator()
			elseif str then --STRING BUILDER
				split_seq(rez,1)--burn first simbol of structure
				str="(\\*()["..str.."\n])"
				while Control.index do
					com,mode=match(Control.operator,str)
					if split_seq(rez,mode)then--end of string found
						mode=match(com,"\n$")
						lvl = lvl or mode --line counter
						-- "ddd \
						-- abc" --still correct string because there is an "\" before "\n"
						if #com%2>0 then mode=not mode and 7 break end --end of string or \n found
					else -- operator may look like that : [[ \" \" \\"  ]] -- and algorithm will detect ALL three segms, that why this "else" is here
						if split_seq(rez,match(Control.word,"()\n"),1)then break end --unfinished string "word" mode split seq
						Control.Iterator()
					end
				end
			elseif com then --COMMENT BUILDER
				repeat
					if split_seq(rez,match(Control.operator,"()\n"))or split_seq(rez,match(Control.word,"()\n"),1)then Control.line=Control.line+1 break end --comment end found
				until Control.Iterator()
				mode=11
			else --DOT-ABLE NUMBER (posible number like this: " *code* .124E-1 *code* ")
				rez=get_number()
				mode=rez and 6 --6
			end
		elseif#Control.word>0 then --NUMBER BUILDER
			rez=get_number()
			mode=rez and 6 --6
		end
		if rez then
			rez=concat(rez)
			if lvl then
				rez,com=gsub(rez,"\n",{})
				Control.line=Control.line+com --line counter for long structures
			end
			Control.Result[#Control.Result+1]=rez
			Control.Core(mode or 12,rez)-- mode==nul or false -> unfinished structure PUSH_ERROR required
			return true --inform base that structure is found and structure_module_restart required before future processing
		end
	end)
	--RETURN LOCALS FOR FUTURE USE
	return __REZULTABLE__,get_number_part,split_seq
end
,
},--Close lua
syntax_loader=function()--simple function to load syntax data
	return 2,function(str,f)
		local mode,t=placeholder_func,{}
		for o,s in gmatch(str,"(.-)(%s)")do
			t[#t+1]=o
			if s=="\n"then
				mode=#t==1 and f[o]or mode(unpack(t))or mode
				t={}
			end
		end
	end
end,
},--Close code
common={event=function(Control)--EVENT SYSTEM
	local clr,e
	clr=function()e.temp={}end
	e={main={},
	reg=function(name,func,id,gl)--id here to control order
		local l=gl and e.temp[name] or e.main[name] or{}
		id=id or#l+1
		--print("EVreg:", id)
		if"number"==type(id)then insert(l,id,func)else l[id]=func end
		e[gl and"main"or"temp"][name]=l
		return id
	end,
	run=function(name,...)--run all registered functions with args
		local l,rm=e.temp[name]or{},{}
		for k,v in pairs(e.main[name]or{})do v(...)end--global events
		for k,v in pairs(l)do rm[k]=v(...)end--local events
		for k in pairs(rm)do 
			if"number"==type(k)then remove(l,k)else l[k]=nil end--events cleanup
		end
	end}
	clr()--make temp event table
	Control.Event=e
	insert(Control.Clear,clr)
end
,
level=function(Control,level_hash)--LEVELING SYSTEM
	--Control:load_lib"common.event"
	local a,clr,l={["main"]=1}
	clr=function()for i=1,#l do l[i]=nil end l[1]={type="main",index=1,ends=a}end
	--level_hash[a]={a}--setup main level finalizer
	l={{type="main",index=1,ends=a},
	data=level_hash,
	fin=function()
		if#l<2 then l.close("main",nil,a)
		else Control.error("Can't close 'main' level! Found (%d) unfinished levels!",#l-1)end
	end,
	close=function(obj,nc,f)
		f=f==a and a or{}
		local lvl,e,r=remove(l)
		if f~=a and#l<1 then Control.error("Attempt to close 'main'(%d) level with '%s'!",#l+1,obj) insert(l,lvl) return end
		e=lvl.ends or f--setup level ends/fins
		if e[obj]then Control.Event.run("lvl_close",lvl,obj)return --Level end found! Invoke close event and return!
		elseif nc then return end -- level is standalone [like "do" kwrd] and can be opened without closeing prewious
		--Unexpected end! Push error
		r="'"for k in pairs(e)do r=r..k.."' or '"end r=sub(r,1,-6)
		Control.error(#r>0 and"Expected %s to close '%s' but got '%s'!"or"Attempt to close level with no ends!",r,lvl.type,obj)
	end,
	open=function(obj,ends,i)
		if#l<1 then Control.error("Attempt to open new level '%s' after closing 'main'!",obj)return end
		local lvl={type=obj,index=i or #Control.Result,ends=ends or(l.data[obj]or{})[1]}
		Control.Event.run("lvl_open",lvl)
		insert(l,lvl)
	end,
	ctrl=function(obj)
		local t=l.data[obj]
		_=t and(t[2]and l.close(obj,t[3])or t[1]and l.open(obj,t[1]))
		if not t and l[#l].ends[obj]then l.close(obj)end --custom ends
	end}
	Control.Level=l
	clr()
	
	insert(Control.Clear,clr)
end
,
},--Close common
text={dual_queue={base=function(Control)--base API for text/code related data
	Control.Operators={}
	Control.operator=""
	Control.word=""
	Control.Words={}
	Control.Result[1]=""
	Control.max_op_len=3
	Control.line=1
	Control.Return=function()return concat(Control.Result)end
	insert(Control.Clear,function()Control.Result={""}Control.operator=""Control.word=""end)
end,
init=function(Control)--default initer placer (has no Control)
	return 2,function(Control,mod)
		Control:load_lib"text.dual_queue.base"
		for k,v in pairs(mod.operators or{})do
			Control.Operators[k]=v
		end
		for k,v in pairs(mod.words or{})do
			Control.Words[k]=v
		end
	end
end,
iterator=function(Control,seq)-- default text system interator
	insert(Control.PreRun,function()
		local s=gmatch(Control.src,seq or"()([%s!-/:-@[-^{-~`]*)([%P_]*)")--default text iterator
		Control.Iterator=function(m)
			if m and(#(Control.operator or'')>0 or#(Control.word or'')>0)then return end --blocker for main cycle (m) can be anything
			Control.index,Control.operator,Control.word=s()
			return not Control.index
		end
	end)
end,
make_react=function(Control)--function that created sefault reactions to different tokens
	return 2, function(s,i,t,j) -- s -> replacer string, i - type of reaction, t - type of sequnece, j - local length
		t=t or match(s,"%w")and"word"or"operator"
		j=j or#s
		return function(Control)
			insert(Control.Result,s)
			Control[t]=sub(Control[t],j+1)
			Control.index=Control.index+j
			Control.Core(i,s)
		end
	end
end,
parcer=function(Control)
	local func=function(react_obj,t,j,i,po)
		if"string"==type(react_obj)then Control.Result[#Control.Result+1]=react_obj
		else react_obj=react_obj(Control,po) end --MAIN ACTION
		
		if react_obj then -- default reaction to string (functions can have default reactions if they return anything(expected string!))
			Control[t]=sub(Control[t],j+1)
			Control.index=Control.index+j
			Control.Core(i,react_obj)
		end
	end
	Control.Struct.final=function() --base handler for two sequences
		local posible_obj,react_obj
		if#Control.operator>0 then --OPERATOR PROCESSOR
			for j=Control.max_op_len,1,-1 do --split the operator_seq
				posible_obj=sub(Control.operator,1,j)
				react_obj=Control.Operators[posible_obj]
				if react_obj or j<2 then func(react_obj or posible_obj,"operator",j,react_obj and 2 or 1,posible_obj)break end
			end
		elseif#Control.word>0 then--WORD PROCESSOR
			posible_obj=match(Control.word,"^%S+") --split the word_seq temp=#posible_object
			react_obj=Control.Words[posible_obj]or posible_obj
			func(react_obj,"word",#posible_obj,3,posible_obj)
		end
	end
end,
space_handler=function(Control)-- function to proccess spaces
	insert(Control.Struct,function()--SPACE HANDLER
		local temp,space = #Control.operator>0 and"operator"or"word"
		space,Control[temp]=match(Control[temp],"^(%s*)(.*)")
		space,temp=gsub(space,"\n",{})--line counter
		Control.line=Control.line+temp
		Control.Result[#Control.Result]=Control.Result[#Control.Result]..space--return space back to place
	end)
end,
},--Close dual_queue
},--Close text
}--END OF FEATURES

end
do
--__PREPARE_MODULES__

Modules={cssc={[_init]=function(Control)
	--code parceing system
	Control:load_lib"text.dual_queue.base"
	Control:load_lib"text.dual_queue.parcer"
	Control:load_lib"text.dual_queue.iterator"
	Control:load_lib"text.dual_queue.space_handler"
	
	--base lua data (structs/operators/keywords)
	local lvl, opt, kwrd = Control:load_lib("code.lua.base",Control.Operators,Control.Words)
	Control.get_num_prt,Control.split_seq=Control:load_lib"code.lua.struct"
	
	--load analisys systems
	Control:load_lib("code.cdata",opt,lvl,placeholder_func)
	Control:load_lib("common.event")
	Control:load_lib("common.level",lvl)

	--code editing basic api
	Control.inject = function(id,obj,type,...)
		if id then insert(Control.Result,id,obj) else insert(Control.Result,obj)end
		Control.Cdata.reg(type,id,...)
	end
	Control.eject = function(id)
		return {remove(Control.Result,id),unpack(remove(Control.Cdata,id))}
	end

	--important lua code markers
	local meta_reg = Control:load_lib("code.lua.meta_opt",
		function(mark)
			--temporaly remove last text element
			local temp = remove(Control.Result)
			--insert markers
			Control.inject(nil,"" -- .."--[["..(mark>0 and"cl"or"st").." mrk]]"
			,2,mark>0 and opt[":"][1] or 0)

			--init events
			Control.Event.run(2,"",2)
			Control.Event.run("all","",2)

			--return prewious text element back
			insert(Control.Result,temp)
		end)
	
	--core setup
	--DEPRECATED: local t={3,4,6,7,8}
	local tb=t_swap{11}
	--t=t_swap(t)
	Control.Core=function(tp,obj)--type_of_text_object,object_it_self
		local id_prew,c_prew,spifc=Control.Cdata.tb_while(tb)
		--if c_prew[1]==4 and match(Control.Result[id_prew],"^end") then print(id_prew,c_prew[2],Control.Result[id_prew],Control.Result[c_prew[2]])end
		spifc = c_prew[1]==4 and match(Control.Result[id_prew]or"","^end") and match(Control.Result[c_prew[2]]or"","^function")
		meta_reg(c_prew[1],tp,spifc)--reg *call*/*stat_end* operator markers (injects before last registered CData)
		Control.Cdata.run(obj,tp)--reg previous result CData

		Control.Event.run(tp,obj,tp)--single event for single struct
		--DEPRECATED: if t[tp]then Control.Event.run("text",obj,tp)end --for any text code values
		Control.Event.run("all",obj,tp)-- event for all structs
		
		Control.Level.ctrl(obj)--level ctrl
	end

	insert(Control.PostRun,function()
		Control.inject(nil,"",2,0)
		Control.Event.run(2,"",2)
		Control.Event.run("all","",2)
		Control.Level.fin()
	end)--fin level

	Control.cssc_load=function(x,name,mode,env)
		x=x==Control and Control.Return()or x
		env=Control.Runtime and Control.Runtime.mk_env(env) or env --Runtime Env support
		return native_load(x,name,mode,env)
	end

	--TODO:RUNTIME DATA PUSH API (inject cssc functions at the start of file to work with them)
end
,
[_modules]={BO={[_init]=function(Control,direct)--bitwize operators (lua53 - backport feature) and idiv
    if not bit32 then Control.error("Unable to load bitwize operators feature! Bit/Bit32 libruary not found!")return end
    direct=false--TODO:temporal solution rework
    Control:load_lib"code.cssc.pdata"
    Control:load_lib"code.cssc.op_stack"
    local opts= Control.Cdata.opts
    local stx=[[O
|
~
&
<< >>
//
]]--last one 'bitwize not'
    local pht ={}
    local p = opts["<"][1]+1 --priority base
    local p_un = opts["#"][2] --unary priority
    local bt=t_swap{shl='<<',shr='>>',bxor='~',bor='|',band='&',idiv='//'}--bitw funcs
    local tb=t_swap{11}
    local check = t_swap{2,9,4}
    --local after = t_swap{4,10}
    local loc_base = "__cssc__bit_"
    local used_opts= {}
    local num="number"
    local idiv_func=native_load([[local p,n,t,g,e,F,f={},"number",... f=function(a,b)local ta,tb=t(a)==n, t(b)==n if ta and tb then return F(a/b)end e("bad argument #"..(ta and 2 or 1).." (expected 'number', got '"..(ta and t(b) or t(a)).."')")end
    return function(a,b)return((g(a)or p).__idiv or(g(b)or p).__idiv or f)(a,b)end]],"OP: '//'",nil,nil)(type,getmetatable,error,floor)
     --[[function(a,b)
        local ta,tb=type(a)==num, type(a)==num
        if ta and tb then return floor(a/b)end
        error(format("bad argument #%d",ta and 1 or 2,ta and type(a) or type(b)))
    end]]

    Control:load_lib"code.syntax_loader"(stx,{O=function(...)--reg syntax
        for k,v,tab,has_un in pairs{...}do
            has_un=v=="~"
            k= v=="//" and opts["*"][1] or p --calc actual priority
            opts[v]=has_un and{k,p_un}or{k}
            tab={{loc_base..bt[v],3}}
            
            has_un=has_un and {{loc_base.."bnot",3}}
            local bit_name,bit_func
            --try get metatables from a and b and select function to run (probably it's better to check their type before, but the smaller the function the faster it will be)    
            if not direct then
                local func =bit32[bt[v]] and native_load(format([[local p,g,f={},... return function(a,b)return((g(a)or p).%s or(g(b)or p).%s or f)(a,b)end]],"__"..bt[v],"__"..bt[v])
                ,"OP: '"..v.."'",nil,nil)(getmetatable,bit32[bt[v]])or idiv_func --this function creates ultra fast & short pice of runtime working code
                --prewious code is equivalent of: function(a,b)
                --    return((getmetatable(a)or pht)[bit_name] or (getmetatable(b)or pht)[bit_name] or bit_func)(a,b)
                --end
                Control.Runtime.build("bit."..bt[v],func,1)
            else Control.Runtime.build("bitD."..bt[v],func,1) end
            
            Control.Operators[v]=function()--operator detected!
                local id,prew,is_un = Control.Cdata.tb_while(tb)

                is_un = has_un and prew[1]==2 or prew[1]==9

                local i,d=Control.Cdata.tb_while(tb)
                if not is_un and check[d[1]] then Control.error("Unexpected '%s' after '%s'!",v,Control.Result[i])end--error check before

                if not used_opts[is_un and "bnot"or v] then used_opts[is_un and "bnot"or v]=1  Control.Runtime.reg(is_un and loc_base.."bnot" or loc_base..bt[v],is_un and "bit.bnot" or "bit."..bt[v])end
                Control.inject(nil,is_un and ""or",",2,not is_un and k or nil, is_un and p_un or nil)--inject found operator Control.Cdata.opts[","][1]
                Control.split_seq(nil,#v)--remove bitwize from queue
                Control.Event.run(2,v,2,1)--send events to fin opts in OP_st
                Control.Event.run("all",v,2,1)

                Control.Event.reg("all",function(obj,tp)--error check after
                    if tp==4 and not match(Control.Result[#Control.Result],"^function") or  tp==10 or tp==2 and not Control.Cdata[#Control.Cdata][3] then Control.error("Unexpected '%s' after '%s'!",obj,v) end
                    return tp~=11 and 1 
                end)
                --reg operator data
                Control.inject_operator(is_un and has_un or tab,is_un and p_un or k,is_un,nil,nil) --including stat_end
            end
            --TODO: opts
        end
        p=p+1
    end})
    if not direct then
        local func = native_load([[local p,g,f={},... return function(a)return((g(a)or p).__bnot or f)(a)end]],"__cssc_bit_bnot",nil,nil)(getmetatable,bit32.bnot)
        Control.Runtime.build("bit.bnot",func,1)
    else
        Control.Runtime.build("bitD.bnot",bit32.bnot,1)
    end
    insert(Control.Clear,function()used_opts={}end)
end},
CA={[_init]=function(Control)--C/C++ additional asignment operators
    Control:load_lib"code.cssc.pdata"
    Control:load_lib"code.cssc.op_stack"
    local prohibited_area = t_swap{"(","{","[","for","while","if","elseif","until"}
    local cond ={["&&"]="and",["||"]="or"}
    local bitw

    local b_func={}
    local s=1
    local used
    local stx=[[O
+ - * / % .. ^ ?
&& ||
]]--TODO: add support 
    if Control.Operators["~"] then stx=stx.."| & >> <<\n" 
        bitw={["|"]="__cssc__bit_bor",["&"]="__cssc__bit_band",[">>"]="__cssc__bit_shr",["<<"]="__cssc__bit_shl"} --last one:questionable_addition
    end--TODO: temporal solution! rework!
    Control.Runtime.build("op.qad",function(a,b)
        return a~=nil and a or b
    end)


    Control:load_lib"code.syntax_loader"(stx,{O=function(...)
        for k, v, t,p in pairs{...}do
            t=s==2 and cond[v] or v
            p=s==3 and bitw[v] or v=="?" and "__cssc__op_qad"
            Control.Operators[v.."="]=function()
                if  v=="?" and not used then used =1 Control.Runtime.reg("__cssc__op_qad","op.qad")end
                local lvl=Control.Level[#Control.Level]
                if prohibited_area[lvl.type] or #(lvl.OP_st or"")>0 then
                    Control.error("Attempt to use additional asignment in prohibited area!")
                end
                --action
                local cur_i,cur_d = #Control.Cdata
                Control.inject(nil,"=",2,Control.Cdata.opts["="][1])--insert assignment

                Control.split_seq(nil,#v+1)--clear queue

                Control.Event.run(2,v.."=",2,1)--send events to fin opts in OP_st
                Control.Event.run("all",v.."=",2,1)


                local i,last=Control.inject_operator(nil,Control.Cdata.opts[","][1]+1,false,1,false,#Control.Cdata-1)--add ")" to fin on, or stat end
                
                --print(i,last[1],last[1]==2,last[2], last[2]==Control.Cdata.opts[","][1])
                if last[1]==2 and last[2]==Control.Cdata.opts[","][1] then --TODO: Temporal solution! Rework!
                    Control.error("Additional asignment do not support multiple additions in this version of lua_mc!")
                end
                if last[1]==2 and last[2]==0 and i-1>0 and Control.Cdata[i-1][1]==4 and match(Control.Result[i-1],"^local")then
                    Control.error("Attempt to perform additional asignment to local variable constructor!")
                end

                if p then
                    Control.inject(nil,p,3)--bitw func call
                    Control.inject(nil,"(",9)--open breaket
                    cur_d = #Control.Cdata 
                end

                for k=i+1,cur_i do --insert local var copy
                    Control.inject(nil,Control.Result[k],unpack(Control.Cdata[k]))
                end

                if not p then --insert operator/coma
                    if match(t,"^[ao]")then Control.Result[#Control.Result]=Control.Result[#Control.Result].." "end --add spaceing
                    Control.inject(nil,t,2,Control.Cdata.opts[t][1])
                    Control.inject(nil,"(",9)
                    cur_d = #Control.Cdata 
                else
                    Control.inject(nil,",",2,Control.Cdata.opts[","][1]+1)--comma with higher priority --TODO: temporal solution! rework!
                end

                lvl.OP_st[#lvl.OP_st][3]= cur_d--correct operator start/breaket values
                lvl.OP_st[#lvl.OP_st][4]= cur_d


                Control.Event.reg("all",function(obj,tp)--error check after
                    if tp==4 and not match(Control.Result[#Control.Result],"^function") or  tp==10 or tp==2 and not Control.Cdata[#Control.Cdata][3] then Control.error("Unexpected '%s' after '%s'!",obj,v.."=") end
                    return tp~=11 and 1 
                end)
            end
        end
        s=s+1
    end})
    insert(Control.Clear,function()used=nil end)
end},
DA={[_init]=function(Control)
    Control:load_lib"code.cssc.pdata"
    Control:load_lib"code.cssc.typeof"
    local l,pht,ct = Control.Level,{},t_swap{11}
    local used
    local mt=setmetatable({},{__index=function(s,i)return i end})
    local typeof=Control.typeof
    local def_arg_runtime_func = function(data)
        local res,val,tp,def,ch={}
        for i=1,#data,4 do
            val=data[i+1]
            def=data[i+3]
            if val==nil and def then insert(res,def)--arg not inited, replace with default
            else
                ch =data[i+2]
                if ch then --type check
                    tp=typeof(val) --actual typeof
                    ch=ch==1 and {[typeof(def)]=1} or t_swap{(native_load("return "..ch,nil,nil,mt)or placeholder_func)()}--> dynamic type! must be equal to def_arg type OR parce type val
                    ch=not ch[tp] and error(format("bad argument #%d (%s expected, got %s)",data[i],data[i+2],tp),2)
                end
                insert(res,val)
            end
        end
        return unpack(res)
    end
    Control.Runtime.build("func.def_arg",def_arg_runtime_func)

    Control.Event.reg("lvl_open",function(lvl)-- def_arg initer
        --print("DA lo")
        if lvl.type=="function" then lvl.DA_np=1 end --set Def_Args_next_posible true
        if lvl.type=="(" and l[#l].DA_np then lvl.DA_d={c_a=1} end--init Def_Args_data for "()" level
        l[#l].DA_np=nil--set Def_Args_next_posible false
    end,"DA_lo",1)


    --DEF ARG DATA STRUCT: {strict_typeing, start_of_def_arg,end_of_def_arg, name_of_arg}
    Control.Event.reg(2,function(obj)
        --print("DA op")
        local da,i,err=l[#l].DA_d
        if da then i=da.c_a --DA data found
            if obj==":"then
                --Control.log("nm :'%s'",Control.Result[Control.Cdata.tb_while(ct,#Control.Cdata-1)])
                da[i]=da[i]or{[4]=Control.Result[Control.Cdata.tb_while(ct,#Control.Cdata-1)]}
                if not da[i][2]then --block if inside def_arg
                    err,da[i][1]=da[i][1],#Control.Cdata--this arg has strict typing!
                end
            elseif obj=="="then da[i]=da[i]or{[4]=Control.Result[Control.Cdata.tb_while(ct,#Control.Cdata-1)]} err,da[i][2]=da[i][2],#Control.Cdata--def arg start
            elseif obj==","then da.c_a=da.c_a+1 (da[i]or pht)[3]=#Control.Cdata-1 --next possible arg; arg state end
            elseif not da[i] or not da[i][2] then err=1 end
            if err then
                Control.error("Unexpected '%s' operator in function arguments defenition.",obj)
                l[#l].DA_d=nil--delete defective DA
            end
        end
    end,"DA_op",1)
    
    local err_text = "Unexpected '%s' in function argument type definition! Function argument type must be set using single name or string!"
    Control.Event.reg("lvl_close",function(lvl)-- def_arg injector
        --print("DA lc")
        if lvl.DA_d then --level had default_args
            local da,arr,name,pr,val,obj,tej,ac=lvl.DA_d,{},{},Control.Cdata.opts[","][1]
            for i=da.c_a,1,-1 do --parce args
                if da[i]then val=da[i] ac,tej=0,nil --def_arg exist
                    insert(name,{val[4],3})insert(name,{",",2,pr})
                    if not val[2] then insert(arr,{"nil",8}) insert(arr,{",",2,pr}) end --no def_arg -> insert nil -> type only
                    val[3]=val[3]or#Control.Result-1
                    --if val[3]-(val[2]or val[1])<1 then Control.error("Expected default argument after '%s'",Control.Result[val[2]or val[1]])end
                    
                    for j=val[3]or#Control.Result-1,val[1]or val[2],-1 do --to minimum value
                        obj=Control.eject(j)
                        if j==val[2] or j==val[1] then 
                            insert(arr,{",",2,pr}) --comma replace
                        elseif val[2]and j>val[2] then--def_arg
                            insert(arr,obj)
                            ac=11~=obj[2] and ac+1 or ac
                        elseif 11~=obj[2] then--strict_type (val[1] - 100% exist) val[2]--already parced
                            if not(obj[2]==3 or obj[2]==7 or match(obj[1],"^nil"))then 
                                Control.error(err_text,obj[1])
                            elseif tej then 
                                Control.error(err_text,obj[1])
                            else
                                if obj[2]==3 then obj={"'"..match(obj[1],"%S+").."'",7} end
                                insert(arr,obj)
                                tej=1
                            end
                        end
                    end
                    if val[2] and ac<1 then Control.error("Expected default argument after '%s'",val[2]and"="or":")end
                    ac=not tej and val[1]
                    if ac or not val[1] then remove(ac and arr or pht) insert(arr,{ac and"1"or "nil",8}) insert(arr,{",",2,pr}) end --no strict type inset nil
                    insert(arr,{val[4],3}) insert(arr,{",",2,pr})
                    insert(arr,{tostring(i),8}) insert(arr,{",",2,pr})--insert index
                end
            end
            if not obj then return end --obj works as marker that something was found
            if not used then used = 1 Control.Runtime.reg("__cssc__def_arg","func.def_arg")end
            remove(name)
            for i=#name,1,-1 do Control.inject(nil, unpack(remove(name)))end
            Control.inject(nil,"=",2,Control.Cdata.opts["="][1])
            Control.inject(nil,"__cssc__def_arg",3)--TODO: replace with api function
            Control.inject(nil,"{",9)
            val=#Control.Result
            remove(arr)--remove last comma
            for i=#arr,1,-1 do --inject args ([1]="," - is coma, so not needed)
                Control.inject(nil, unpack(remove(arr)))--TODO: mark internal contents as CSSC-data for other funcs to ignore
            end
            Control.inject(nil,"}",10,val)
            Control.inject(nil,"",2,0)--zero priority -> statement_end
        end
    end,"DA_lc",1)
    insert(Control.Clear,function()used = nil end)
end},
IS={[_init]=function(Control)
    Control:load_lib"code.cssc.pdata"
    Control:load_lib"code.cssc.op_stack"
    Control:load_lib"code.cssc.typeof" --typeof func -> Control.typeof
    local ltp=type
    local ltpof=Control.typeof
    local IS_func=function(obj,comp)
        local md,tp,rez = ltp(comp),ltpof(obj),false --mode,type,rez
        if md=="string"then rez=tp==comp
        elseif md=="table"then for i=1,#comp do rez=rez or tp==comp[i]end
        else error("bad argument #2 to 'is' operator (got '"..md.."', expected 'table' or 'string')",2)end
        return rez
    end
    local tab,used={{"__cssc__kw_is",3}}
    --[[Control.typeof=function(obj,comp)
        local md,tp,rez = ltp(comp),ltp(obj),false
        if md=="string"then rez=tp==comp
        elseif md=="table"then for i=1,#comp do rez=rez or tp==comp[i]end
        else error("bad argument #2 to 'is' operator (got '"..md.."', expected 'table' or 'string')",2)end
        return rez
    end]]
    local tb = t_swap{11}
    local check = t_swap{2,9,4}
    local after = t_swap{4,10}
    Control.Runtime.build("kwrd.is",IS_func)
    Control.Words["is"]=function()
        if not used then Control.Runtime.reg("__cssc__kw_is","kwrd.is") end

        local i,d=Control.Cdata.tb_while(tb)
        if check[d[1]] then Control.error("Unexpected 'is' after '%s'!",Control.Result[i])end--error check before

        Control.inject(nil,",",2,Control.Cdata.opts["^"][1])
        Control.split_seq(nil,2,1)
        Control.Event.run(2,"is",2,1)--send events to fin opts in OP_st
        Control.Event.run("all","is",2,1)

        Control.Event.reg("all",function(obj,tp)--error check after
            if after[tp] or tp==2 and not Control.Cdata[#Control.Cdata][3] then Control.error("Unexpected '%s' after 'is'!",obj) end
            return tp~=11 and 1 
        end)

        Control.inject_operator(tab,Control.Cdata.opts["^"][1])
        --local st=Control.Level[#Control.Level].OP_st
        --st[#st][2]=st[#st][2]-1

    end
    insert(Control.Clear,function()used=nil end)
end},
KS={[_init]=function(Control,mod,arg)--keyword shorcuts
	--require"cc.pretty".pretty_print(arg)
    local stx = [[O
|| or
&& and
@ local
$ return
]]
	for _,v in pairs(arg or{})do
		if v=="sc_end" then --include semicolon to end conversion basic ; can be placed with \;
			stx=stx.."; end\n\\; ;\n"
		end
		if v=="pl_cond" then --platform condition... the most cursed feature... so probably will be removed in future
			stx=stx..[[? then
/| if
:| elseif
\| else
]]
		end
	end
	--specific make react with space addition
    local make_react=function(s,i,j) -- s -> replacer string, i - type of reaction, t - type of sequnece, j - local length
		return function(Control)
            Control.Result[#Control.Result]= Control.Result[#Control.Result].." "
			insert(Control.Result,s.." ")
			Control.operator=sub(Control.operator,j+1)
			Control.index=Control.index+j
			Control.Core(i,s)
		end
	end
    Control:load_lib"code.syntax_loader"(stx,{O=function(k,v)
        Control.Operators[k]=make_react(v,match(v,"^[ao]") and 2 or 4,#k)
    end})
end},
LF={[_init]=function(Control)
	local ct,fk = t_swap{11},"function"--mk hash table
	Control.Operators["->"]=function(Control)
		local s,ei,ed,cor,br=3,Control.Cdata.tb_while(ct)--get last esenshual_index,esenshual_data
		if match(Control.Result[ei],"^%)")then--breaket located
			ei=ed[2]
			--Control.log("EI:%d - %s;%s;%s;",ei,Control.Result[ei],match(Control.Result[ei],"^[=%(,]"), ei and match(Control.Result[ei],"^[=%(,]"))
			cor = ei and match(Control.Result[Control.Cdata.tb_while(ct,ei-1)]or"","^[=%(,]")--coma is acceptable here 
			--Control.log("COR:%s",cor)
		else--default args
			while ei>0 and(ed[1]==11 or ed[1]==s or s~=3 and ((ed[2]or-1)==Control.Cdata.opts[","][1] and match(Control.Result[ei],"^%,")))do
				ei,s=ei-1,s*(ed[1]~=11 and-1 or 1)--com skip/swap state 3/2(coma)
				ed=Control.Cdata[ei]
			end
			ei,br,cor=ei+1,1,ei>0 and s~=3 and match(Control.Result[ei],"^[=%(]")
		end
		if not cor then Control.error("Corrupted lambda arguments at line %d !",Control.line)Control.split_seq(nil,2) return end
		
		--Control.inject(ei,""  .."--[[cl mrk]]"
		--,2,Control.Cdata.opts[":"][1])--call mark
		Control.inject(ei,fk,4)--inject function kwrd
		if br then --place breakets
			Control.inject(ei+1,"(",9)--inject open breaket
			Control.inject(nil,")",10,ei+1)--inject closeing breaket
		end
		if"-"==sub(Control.operator,1,1)then Control.inject(nil,"return ",4) end--inject return kwrd

		Control.Event.run(2,"->",2,1)--Iinform core about insertet operators (1 means cssc_generated)
		Control.Event.run("all",sub(Control.operator,1,1)..">",tp,1)

		Control.Level.open(fk,nil,ei)--open new function level (auto end set)
		Control.Level[#Control.Level].DA_np=nil --prevent DEF ARGS
		Control.split_seq(nil,2)-- remove ->/=> from Control.operator
	end
	Control.Operators["=>"]=Control.Operators["->"]
end},
NC={[_init]=function(Control)--nil check (nil forgiving operator feature)
    Control:load_lib"code.cssc.pdata"
    Control:load_lib"code.cssc.op_stack"
    local stx = [[O
?. ?: ?( ?{ ?[ ?" ?'
]] --all posible operators in current version
    local phf=function()end
    local b_used,a_used

    local runtime_meta=setmetatable({},{__call=function()end,__newindex=function()end})
    local runtime_func=function(obj) return obj==nil and runtime_meta or obj end

    local runtime_dual_meta={__index=function()return phf end}--TODO: TEMPORAL SOLUTION! REWORK!
    local runtime_dual_func=function(obj) return obj==nil and runtime_dual_meta or setmetatable({},{__index=function(self,i)return obj[i] or phf end}) end
    Control.Runtime.build("nilF.dual",runtime_dual_func)
    Control.Runtime.build("nilF.basic",runtime_func)
    local tb = t_swap{11}
    local check=t_swap{7,3,10}

    Control:load_lib"code.syntax_loader"(stx,{O=function(...)
        for k,v in pairs{...}do
            Control.Operators[v]=function() --shadow operator
                local tp = sub(v,2)
                --todo prew ":" check on calls/indexing

                local i,d=Control.Cdata.tb_while(tb)
                if not check[d[1]] then Control.error("Unexpected '?' after '%s'!",Control.Result[i])end--error check before

                Control.Event.run(2,"?x",2,1)--send events to fin opts in OP_st
                Control.Event.run("all","?x",2,1)
                if tp==":" then --dual operatiom -> index -> call
                    if not a_used then a_used=1 Control.Runtime.reg("__cssc__op_d_nc","nilF.dual")end
                    Control.inject_operator({{"__cssc__op_d_nc",3}},Control.Cdata.opts["."][1],false,false,true)
                else
                    if not b_used then b_used=1 Control.Runtime.reg("__cssc__op_nc","nilF.basic")end
                    Control.inject_operator({{"__cssc__op_nc",3}},Control.Cdata.opts["."][1],false,false,true)
                end
                Control.split_seq(nil,1)--del "?"
            end
        end
    end})
    insert(Control.Clear,function()b_used,a_used=nil end)
end},
NF={[_init]=function(Control)
	local e,nan="Number '%s' isn't a valid number!",-(0/0)
	local fin_num=function(nd,c)
		--Control.log("CSSC Number format located. System: '%s'", c=='b' and 'binary' or 'octal')
		nd=concat(nd)
		local f,s,ex=match(nd,"..(%d*)%.?(%d*)(.*)")
		--print("ND:",nd)
		--print("EX:",ex,match(ex,"^[Ee]"))
		if match(ex,"^[Ee]") then Control.error(e,nd) end --Ee exponenta is prohibited!
		c=(c=="b" or c=="B") and 2 or 8 --bin/oct
		--Control.log("Num src: F'%s' f'%s' exp'%s'",f,s,ex)
		f=tonumber(#f>0 and f or 0,c)--base
		--if #s>0 then s=(tonumber(s,c)or nan)/c/#s else s=0 end--float
		if #s>0 then --float
			local r=0
			for i,k in gmatch(s,"()(.)") do
				if tonumber(k)>=c then s=nan break end  --if number is weird
				r=r+k*c^(#s-i)
			end
			s=s==s and tostring(r/c^#s)
			--[[for i,k in gmatch(b,"()(.)") do
				if k>=t then err(Ctrl,"This is not a valid number: 0"..a..b..c) end  --if number is weird
				r=r+k*t^(#b-i) -- t: number base system, r - result, i - current position in number string
			 end]]
		else s=0 end
		ex=tonumber(#ex>0 and sub(ex,2) or 0,c)--exp
		--Control.log("Num out: F'%s' f'%s' exp'%s'",f,s,ex)
		nd =(f and s==s and ex)and ""..(f+s)*(2^ex)or Control.error(e,nd)or nd
		--insert(Control.Result,""..(f+s)*(2^ex))
		insert(Control.Result,nd)
		Control.Core(6,nd)
	end
	
	insert(Control.Struct,2,function()--this stuff must run before lua_struct and after space_handler parts.
		local c =#Control.operator<1 and match(Control.word,"^0([OoBb])%d")
		if c then
			local num_data,f = {},{0 ..c.."%d","PpEe"}
			if Control.get_num_prt(num_data,f)then fin_num(num_data,c)return true end
			Control.Iterator()
			if Control.operator=="."then
				num_data[#num_data+1]="."
				f[1]="%d"
				Control.get_num_prt(num_data,f)
			end
			fin_num(num_data,c)
			return true
		end
	end)
end},
},--Close modules
},--Close cssc
sys={[_modules]={dbg_hl={[_init]=function(Control,mod, arg)
	--OperatorWordSystem-debug utilite
	if "string"~=type(_HOST) or not match(_HOST,"^ComputerCraft") then
		--this module desingned only for CraftOS testing purposes! Loading it outside of CraftOS - prohibited!
		Control.error("Attempt to load debug hilighting module outside of CraftOS environment!")
		return
	end


	
	
	--blit control
	local rep = string.rep --rep func import
	local blit_ctrl={
	space={colors.toBlit(colors.white)," "},
	[3]={colors.toBlit(colors.white)," "},
	[4]={colors.toBlit(colors.yellow)," "},
	[2]={colors.toBlit(colors.lightBlue)," "},
	[1]={colors.toBlit(colors.lightBlue)," "},
	[11]={colors.toBlit(colors.green)," "},
	[8]={colors.toBlit(colors.cyan)," "},
	[9]={colors.toBlit(colors.magenta)," "},
	[10]={colors.toBlit(colors.magenta)," "},
	[6]={colors.toBlit(colors.lime)," "},
	[7]={colors.toBlit(colors.red)," "},
	[12]={colors.toBlit(colors.purple)," "},
	}
	Control.BlitBack={}
	Control.BlitFront={}
	local burn_blit=function(tp,len)
		tp=blit_ctrl[tp]or{" "," "}
		len=len or #Control.Result[#Control.Result]
		Control.BlitFront[#Control.BlitFront+1]=rep(tp[1],len)
		Control.BlitBack[#Control.BlitBack+1]=rep(tp[2],len)
	end
	
	--load base lib
	Control:load_lib"text.dual_queue.base"
	Control:load_lib"text.dual_queue.parcer"
	Control:load_lib"text.dual_queue.iterator"
	--Control:load_lib"text.dual_queue.make_react"
	Control:load_lib"text.dual_queue.space_handler"
	--lua syntax loading
	for _,v in pairs(arg or{})do
		if v=="lua" then
			Control:load_lib("code.lua.base",Control.Operators,Control.Words)
			--Control:load_lib"text.dual_queue.space_handler"
			Control:load_lib"code.lua.struct"
		end
	end
	
	--edit space handler
	local sp_h=remove(Control.Struct,1)
	insert(Control.Struct,1,function()
		local pl=#Control.Result[#Control.Result]
		sp_h(Control)
		burn_blit("space",#Control.Result[#Control.Result]-pl)
	end)
	Control.Core=function(tp)
		local len =#Control.Result[#Control.Result]
		if (to==9) then print(br)end
		burn_blit(tp)
	end
	Control.BlitData={}
	insert(Control.PostRun,function()
		Control.BlitData={}
		local rez,blit,back=concat(Control.Result).."\n",concat(Control.BlitFront).." ",concat(Control.BlitBack).." "
		rez=sub(rez,-1)=="\n"and rez or rez.."\n"
		gsub(rez,"()(.-()\n)",function(st,con,nd)
			insert(Control.BlitData,{gsub(con,".$","\x14"),
				sub(blit,st,nd-1)..colors.toBlit(colors.lightBlue),
				sub(back,st,nd)})--back color
		end)
	end)
	local min = function(a,b) return a<b and a or b end
	Control.debug_highlight=function(st,nd)
		local fn = #Control.BlitData
		nd = min(nd or fn,fn)
		st = (st or 0)>0 and st or 1
		for i=st,nd do
			term.blit(unpack(Control.BlitData[i]))
			print()--new line
		end
	end
	Control.Return=function() if (Control.args[1]=="l_now") then Control.debug_highlight()end return Control.BlitData end
	insert(Control.Clear,function()Control.BlitBack={}Control.BlitFront={}end)
end},
err={[_init]=function(Control)--TODO: rework
	Control.error = function(str,...)
		local l={...}
		Control.Iterator=function()
			error("lua_mc["..(Control.line or"X").."]:"..format(str,unpack(l)),3)
		end
	end
end},
},--Close modules
},--Close sys
}--END OF MODULES

end

lua_mc={make=make,run=run,clear=clear,Features=Features,Modules=Modules,Configs=Configs,dev={init=_init,modules=_modules}}
 lua_mc.continue=continue --curently in testing 
 _G.lua_mc=lua_mc
-- _G.lua_mc.test=read_control_string
return lua_mc

