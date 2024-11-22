{[_init]=function(Control)
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
		Control.Core(__NUMBER__,nd)
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
end}