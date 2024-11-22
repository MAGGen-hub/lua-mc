function(Control)-- function to proccess spaces
	insert(Control.Struct,function()--SPACE HANDLER
		local temp,space = #Control.operator>0 and"operator"or"word"
		space,Control[temp]=match(Control[temp],"^(%s*)(.*)")
		space,temp=gsub(space,"\n",{})--line counter
		Control.line=Control.line+temp
		Control.Result[#Control.Result]=Control.Result[#Control.Result]..space--return space back to place
	end)
end