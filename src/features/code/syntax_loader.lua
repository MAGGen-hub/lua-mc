function()--simple function to load syntax data
	return __RESULTABLE__,function(str,f)
		local mode,t=placeholder_func,{}
		for o,s in gmatch(str,"(.-)(%s)")do
			t[#t+1]=o
			if s=="\n"then
				mode=#t==1 and f[o]or mode(unpack(t))or mode
				t={}
			end
		end
	end
end