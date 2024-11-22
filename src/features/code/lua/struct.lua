function(Control)--comment/string/number detector
	local get_number_part=function(nd,f) --function that collect number parts into num_data. 
		local ex                            --Returns 1 if end of number found or nil if floating point posible
		nd[#nd+1],ex,Control.word=match(Control.word,format("^(%s*([%s]?%%d*))(.*)",unpack(f)))--get number part
		--print(format("^(%s*([%s]?%%d*))(.*)",unpack(f)))
		--print(nd[#nd],ex)
		Control.operator="" -- dot-able number protection (reset operator)
		if#Control.word>0 or#ex>1 then return 1 end--finished number or finished exponenta
		if#ex>0 then--unfinished exponenta #ex==1
			Control.Iterator()-- update op_word_seq
			ex=match(Control.operator or"","^[+-]$")
			if ex then
				nd[#nd+1]=ex
				nd[#nd+1],Control.word=match(Control.word,"^(%d*)(.*)")
				Control.operator=""
			end --TODO: else push_error() end -> incorrect exponenta prohibited by lua
			return 1
		end --unfinished exponenta #ex==1
	end
	local get_number,split_seq=function()--get_number:function to locate numbers with floating point;
		local c,d=match(Control.word,"^0([Xx])")d=Control.operator=="."and not c--dot-able number detection (t-> dot located | c->hex located)
		if not match(Control.word,"^%d")or not d and#Control.operator>0 then return end --number not located... return
		local num_data,f=d and{"."}or{},c and{"0"..c.."%x","Pp"}or{"%d","Ee"}
		if get_number_part(num_data,f)or"."==num_data[1]then return num_data end--fin of number or dot-able floating point number
		-- now: #ex==0 and #Control.word==0; all other ways are found
		--Control.word==0 -> number might have floating point
		Control.Iterator() --update op_word_sequences
		if Control.operator=="."then --floating point found
			num_data[#num_data+1]="."
			f[1]=sub(f[1],-2)
			get_number_part(num_data,f)
		end
		return num_data
	end,
	function(data,i,seq)--split_seq:function to split operator/word quences
		seq=seq and"word"or"operator"
		if data then
			data[#data+1]=i and sub(Control[seq],1,i)or Control[seq]
		end
		Control[seq]=i and sub(Control[seq],i+1)or""
		Control.index=Control.index+(i or 0)
		return i
	end
	--STRUCTURE MODULE
	insert(Control.Struct,function()
		local com,rez,mode,lvl,str=#Control.operator>0 and"operator"or"word"
		--SPACE HANDLER
		--mode,Control[com]=match(Control[com],"^(%s*)(.*)")
		--mode,com=gsub(mode,"\n","\n")--line counter
		--Control.line=Control.line+com
		--Control.Result[#Control.Result]=Control.Result[#Control.Result]..mode--return space back to place
		--STRUCTURE HANDLER
		if#Control.operator>0 then --string structures
			rez,com,lvl={},match(Control.operator,"^(-?)%1%[(=*)%[")--long strings and coments
			com=match(Control.operator,"^-%-")
			str=match(Control.operator,"^['\"]")--small strings/comments
			if lvl then --LONG BUILDER
				lvl="%]"..lvl.."()%]"
				repeat
					if split_seq(rez,match(Control.operator,lvl))then mode=com and __COMMENT__ or __STRING__ break end --structure finished
					insert(rez,Control.word)
				until Control.Iterator()
			elseif str then --STRING BUILDER
				split_seq(rez,1)--burn first simbol of structure
				str="(\\*()["..str.."\n])"
				while Control.index do
					com,mode=match(Control.operator,str)
					if split_seq(rez,mode)then--end of string found
						mode=match(com,"\n$")
						lvl = lvl or mode --line counter
						-- "ddd \
						-- abc" --still correct string because there is an "\" before "\n"
						if #com%2>0 then mode=not mode and __STRING__ break end --end of string or \n found
					else -- operator may look like that : [[ \" \" \\"  ]] -- and algorithm will detect ALL three segms, that why this "else" is here
						if split_seq(rez,match(Control.word,"()\n"),1)then break end --unfinished string "word" mode split seq
						Control.Iterator()
					end
				end
			elseif com then --COMMENT BUILDER
				repeat
					if split_seq(rez,match(Control.operator,"()\n"))or split_seq(rez,match(Control.word,"()\n"),1)then Control.line=Control.line+1 break end --comment end found
				until Control.Iterator()
				mode=__COMMENT__
			else --DOT-ABLE NUMBER (posible number like this: " *code* .124E-1 *code* ")
				rez=get_number()
				mode=rez and __NUMBER__ --__NUMBER__
			end
		elseif#Control.word>0 then --NUMBER BUILDER
			rez=get_number()
			mode=rez and __NUMBER__ --__NUMBER__
		end
		if rez then
			rez=concat(rez)
			if lvl then
				rez,com=gsub(rez,"\n",{})
				Control.line=Control.line+com --line counter for long structures
			end
			Control.Result[#Control.Result+1]=rez
			Control.Core(mode or __UNFINISHED__,rez)-- mode==nul or false -> unfinished structure PUSH_ERROR required
			return true --inform base that structure is found and structure_module_restart required before future processing
		end
	end)
	--RETURN LOCALS FOR FUTURE USE
	return __REZULTABLE__,get_number_part,split_seq
end
