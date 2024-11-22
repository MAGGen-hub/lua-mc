function(Control)--EVENT SYSTEM
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
