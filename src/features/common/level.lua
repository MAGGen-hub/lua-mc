function(Control,level_hash)--LEVELING SYSTEM
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
