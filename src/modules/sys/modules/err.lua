{[_init]=function(Control)--TODO: rework
	Control.error = function(str,...)
		local l={...}
		Control.Iterator=function()
			error("__PROJECT_NAME__["..(Control.line or"X").."]:"..format(str,unpack(l)),3)
		end
	end
end}