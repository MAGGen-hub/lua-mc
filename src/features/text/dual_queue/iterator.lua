function(Control,seq)-- default text system interator
	insert(Control.PreRun,function()
		local s=gmatch(Control.src,seq or"()([%s!-/:-@[-^{-~`]*)([%P_]*)")--default text iterator
		Control.Iterator=function(m)
			if m and(#(Control.operator or'')>0 or#(Control.word or'')>0)then return end --blocker for main cycle (m) can be anything
			Control.index,Control.operator,Control.word=s()
			return not Control.index
		end
	end)
end