{[_init]=function(Control)--C/C++ additional asignment operators
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
                if  v=="?" and not used then used =__TRUE__ Control.Runtime.reg("__cssc__op_qad","op.qad")end
                local lvl=Control.Level[#Control.Level]
                if prohibited_area[lvl.type] or #(lvl.OP_st or"")>0 then
                    Control.error("Attempt to use additional asignment in prohibited area!")
                end
                --action
                local cur_i,cur_d = #Control.Cdata
                Control.inject(nil,"=",__OPERATOR__,Control.Cdata.opts["="][1])--insert assignment

                Control.split_seq(nil,#v+1)--clear queue

                Control.Event.run(__OPERATOR__,v.."=",__OPERATOR__,__TRUE__)--send events to fin opts in OP_st
                Control.Event.run("all",v.."=",__OPERATOR__,__TRUE__)


                local i,last=Control.inject_operator(nil,Control.Cdata.opts[","][1]+1,false,__TRUE__,false,#Control.Cdata-1)--add ")" to fin on, or stat end
                
                --print(i,last[1],last[1]==__OPERATOR__,last[2], last[2]==Control.Cdata.opts[","][1])
                if last[1]==__OPERATOR__ and last[2]==Control.Cdata.opts[","][1] then --TODO: Temporal solution! Rework!
                    Control.error("Additional asignment do not support multiple additions in this version of __PROJECT_NAME__!")
                end
                if last[1]==__OPERATOR__ and last[2]==0 and i-1>0 and Control.Cdata[i-1][1]==__KEYWORD__ and match(Control.Result[i-1],"^local")then
                    Control.error("Attempt to perform additional asignment to local variable constructor!")
                end

                if p then
                    Control.inject(nil,p,__WORD__)--bitw func call
                    Control.inject(nil,"(",__OPEN_BREAKET__)--open breaket
                    cur_d = #Control.Cdata 
                end

                for k=i+1,cur_i do --insert local var copy
                    Control.inject(nil,Control.Result[k],unpack(Control.Cdata[k]))
                end

                if not p then --insert operator/coma
                    if match(t,"^[ao]")then Control.Result[#Control.Result]=Control.Result[#Control.Result].." "end --add spaceing
                    Control.inject(nil,t,__OPERATOR__,Control.Cdata.opts[t][1])
                    Control.inject(nil,"(",__OPEN_BREAKET__)
                    cur_d = #Control.Cdata 
                else
                    Control.inject(nil,",",__OPERATOR__,Control.Cdata.opts[","][1]+1)--comma with higher priority --TODO: temporal solution! rework!
                end

                lvl.OP_st[#lvl.OP_st][3]= cur_d--correct operator start/breaket values
                lvl.OP_st[#lvl.OP_st][4]= cur_d


                Control.Event.reg("all",function(obj,tp)--error check after
                    if tp==__KEYWORD__ and not match(Control.Result[#Control.Result],"^function") or  tp==__CLOSE_BREAKET__ or tp==__OPERATOR__ and not Control.Cdata[#Control.Cdata][3] then Control.error("Unexpected '%s' after '%s'!",obj,v.."=") end
                    return tp~=__COMMENT__ and __TRUE__ 
                end)
            end
        end
        s=s+1
    end})
    insert(Control.Clear,function()used=nil end)
end}