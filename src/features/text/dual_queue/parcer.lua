function(Control)
	local func=function(react_obj,t,j,i,po)
		if"string"==type(react_obj)then Control.Result[#Control.Result+1]=react_obj
		else react_obj=react_obj(Control,po) end --MAIN ACTION
		
		if react_obj then -- default reaction to string (functions can have default reactions if they return anything(expected string!))
			Control[t]=sub(Control[t],j+1)
			Control.index=Control.index+j
			Control.Core(i,react_obj)
		end
	end
	Control.Struct.final=function() --base handler for two sequences
		local posible_obj,react_obj
		if#Control.operator>0 then --OPERATOR PROCESSOR
			for j=Control.max_op_len,1,-1 do --split the operator_seq
				posible_obj=sub(Control.operator,1,j)
				react_obj=Control.Operators[posible_obj]
				if react_obj or j<2 then func(react_obj or posible_obj,"operator",j,react_obj and __OPERATOR__ or __SYMBOL__,posible_obj)break end
			end
		elseif#Control.word>0 then--WORD PROCESSOR
			posible_obj=match(Control.word,"^%S+") --split the word_seq temp=#posible_object
			react_obj=Control.Words[posible_obj]or posible_obj
			func(react_obj,"word",#posible_obj,__WORD__,posible_obj)
		end
	end
end