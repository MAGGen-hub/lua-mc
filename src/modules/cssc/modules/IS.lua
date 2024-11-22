{[_init]=function(Control)
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
    local tab,used={{"__cssc__kw_is",__WORD__}}
    --[[Control.typeof=function(obj,comp)
        local md,tp,rez = ltp(comp),ltp(obj),false
        if md=="string"then rez=tp==comp
        elseif md=="table"then for i=1,#comp do rez=rez or tp==comp[i]end
        else error("bad argument #2 to 'is' operator (got '"..md.."', expected 'table' or 'string')",2)end
        return rez
    end]]
    local tb = t_swap{__COMMENT__}
    local check = t_swap{__OPERATOR__,__OPEN_BREAKET__,__KEYWORD__}
    local after = t_swap{__KEYWORD__,__CLOSE_BREAKET__}
    Control.Runtime.build("kwrd.is",IS_func)
    Control.Words["is"]=function()
        if not used then Control.Runtime.reg("__cssc__kw_is","kwrd.is") end

        local i,d=Control.Cdata.tb_while(tb)
        if check[d[1]] then Control.error("Unexpected 'is' after '%s'!",Control.Result[i])end--error check before

        Control.inject(nil,",",__OPERATOR__,Control.Cdata.opts["^"][1])
        Control.split_seq(nil,2,__TRUE__)
        Control.Event.run(__OPERATOR__,"is",__OPERATOR__,__TRUE__)--send events to fin opts in OP_st
        Control.Event.run("all","is",__OPERATOR__,__TRUE__)

        Control.Event.reg("all",function(obj,tp)--error check after
            if after[tp] or tp==__OPERATOR__ and not Control.Cdata[#Control.Cdata][3] then Control.error("Unexpected '%s' after 'is'!",obj) end
            return tp~=__COMMENT__ and __TRUE__ 
        end)

        Control.inject_operator(tab,Control.Cdata.opts["^"][1])
        --local st=Control.Level[#Control.Level].OP_st
        --st[#st][2]=st[#st][2]-1

    end
    insert(Control.Clear,function()used=nil end)
end}