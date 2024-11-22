function(Control)--typeof function used for "DA" and "IS" modules
    local ltp,lmt,pht=type,getmetatable,{}
    Control.typeof=function(obj)
        return (lmt(obj)or pht).__type or ltp(obj)
    end
end