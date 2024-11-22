{[_init]=function(Control)--nil check (nil forgiving operator feature)
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
    local tb = t_swap{__COMMENT__}
    local check=t_swap{__STRING__,__WORD__,__CLOSE_BREAKET__}

    Control:load_lib"code.syntax_loader"(stx,{O=function(...)
        for k,v in pairs{...}do
            Control.Operators[v]=function() --shadow operator
                local tp = sub(v,2)
                --todo prew ":" check on calls/indexing

                local i,d=Control.Cdata.tb_while(tb)
                if not check[d[1]] then Control.error("Unexpected '?' after '%s'!",Control.Result[i])end--error check before

                Control.Event.run(__OPERATOR__,"?x",__OPERATOR__,__TRUE__)--send events to fin opts in OP_st
                Control.Event.run("all","?x",__OPERATOR__,__TRUE__)
                if tp==":" then --dual operatiom -> index -> call
                    if not a_used then a_used=__TRUE__ Control.Runtime.reg("__cssc__op_d_nc","nilF.dual")end
                    Control.inject_operator({{"__cssc__op_d_nc",__WORD__}},Control.Cdata.opts["."][1],false,false,true)
                else
                    if not b_used then b_used=__TRUE__ Control.Runtime.reg("__cssc__op_nc","nilF.basic")end
                    Control.inject_operator({{"__cssc__op_nc",__WORD__}},Control.Cdata.opts["."][1],false,false,true)
                end
                Control.split_seq(nil,1)--del "?"
            end
        end
    end})
    insert(Control.Clear,function()b_used,a_used=nil end)
end}