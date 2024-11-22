{[_init]=function(Control,direct)--bitwize operators (lua53 - backport feature) and idiv
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
    local tb=t_swap{__COMMENT__}
    local check = t_swap{__OPERATOR__,__OPEN_BREAKET__,__KEYWORD__}
    --local after = t_swap{__KEYWORD__,__CLOSE_BREAKET__}
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
            tab={{loc_base..bt[v],__WORD__}}
            
            has_un=has_un and {{loc_base.."bnot",__WORD__}}
            local bit_name,bit_func
            --try get metatables from a and b and select function to run (probably it's better to check their type before, but the smaller the function the faster it will be)    
            if not direct then
                local func =bit32[bt[v]] and native_load(format([[local p,g,f={},... return function(a,b)return((g(a)or p).%s or(g(b)or p).%s or f)(a,b)end]],"__"..bt[v],"__"..bt[v])
                ,"OP: '"..v.."'",nil,nil)(getmetatable,bit32[bt[v]])or idiv_func --this function creates ultra fast & short pice of runtime working code
                --prewious code is equivalent of: function(a,b)
                --    return((getmetatable(a)or pht)[bit_name] or (getmetatable(b)or pht)[bit_name] or bit_func)(a,b)
                --end
                Control.Runtime.build("bit."..bt[v],func,__TRUE__)
            else Control.Runtime.build("bitD."..bt[v],func,__TRUE__) end
            
            Control.Operators[v]=function()--operator detected!
                local id,prew,is_un = Control.Cdata.tb_while(tb)

                is_un = has_un and prew[1]==__OPERATOR__ or prew[1]==__OPEN_BREAKET__

                local i,d=Control.Cdata.tb_while(tb)
                if not is_un and check[d[1]] then Control.error("Unexpected '%s' after '%s'!",v,Control.Result[i])end--error check before

                if not used_opts[is_un and "bnot"or v] then used_opts[is_un and "bnot"or v]=__TRUE__  Control.Runtime.reg(is_un and loc_base.."bnot" or loc_base..bt[v],is_un and "bit.bnot" or "bit."..bt[v])end
                Control.inject(nil,is_un and ""or",",__OPERATOR__,not is_un and k or nil, is_un and p_un or nil)--inject found operator Control.Cdata.opts[","][1]
                Control.split_seq(nil,#v)--remove bitwize from queue
                Control.Event.run(__OPERATOR__,v,__OPERATOR__,__TRUE__)--send events to fin opts in OP_st
                Control.Event.run("all",v,__OPERATOR__,__TRUE__)

                Control.Event.reg("all",function(obj,tp)--error check after
                    if tp==__KEYWORD__ and not match(Control.Result[#Control.Result],"^function") or  tp==__CLOSE_BREAKET__ or tp==__OPERATOR__ and not Control.Cdata[#Control.Cdata][3] then Control.error("Unexpected '%s' after '%s'!",obj,v) end
                    return tp~=__COMMENT__ and __TRUE__ 
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
        Control.Runtime.build("bit.bnot",func,__TRUE__)
    else
        Control.Runtime.build("bitD.bnot",bit32.bnot,__TRUE__)
    end
    insert(Control.Clear,function()used_opts={}end)
end}