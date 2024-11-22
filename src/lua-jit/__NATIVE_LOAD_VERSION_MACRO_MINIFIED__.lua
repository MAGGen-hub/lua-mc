do
local Lt,Ll,Ls=A(loadstring,E),A(load,E),A(setfenv,E)
NL=function(x,name,mode,env)local r,e=(Gt(x)=="string"and Lt or Ll)(x,name)if env and r then Ls(r,env)end return r,e end
end