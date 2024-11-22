{[_init]=function(Control,mod, arg)
	--OperatorWordSystem-debug utilite
	if "string"~=type(_HOST) or not match(_HOST,"^ComputerCraft") then
		--this module desingned only for CraftOS testing purposes! Loading it outside of CraftOS - prohibited!
		Control.error("Attempt to load debug hilighting module outside of CraftOS environment!")
		return
	end


	
	
	--blit control
	local rep = string.rep --rep func import
	local blit_ctrl={
	space={colors.toBlit(colors.white)," "},
	[__WORD__]={colors.toBlit(colors.white)," "},
	[__KEYWORD__]={colors.toBlit(colors.yellow)," "},
	[__OPERATOR__]={colors.toBlit(colors.lightBlue)," "},
	[__SYMBOL__]={colors.toBlit(colors.lightBlue)," "},
	[__COMMENT__]={colors.toBlit(colors.green)," "},
	[__VALUE__]={colors.toBlit(colors.cyan)," "},
	[__OPEN_BREAKET__]={colors.toBlit(colors.magenta)," "},
	[__CLOSE_BREAKET__]={colors.toBlit(colors.magenta)," "},
	[__NUMBER__]={colors.toBlit(colors.lime)," "},
	[__STRING__]={colors.toBlit(colors.red)," "},
	[__UNFINISHED__]={colors.toBlit(colors.purple)," "},
	}
	Control.BlitBack={}
	Control.BlitFront={}
	local burn_blit=function(tp,len)
		tp=blit_ctrl[tp]or{" "," "}
		len=len or #Control.Result[#Control.Result]
		Control.BlitFront[#Control.BlitFront+1]=rep(tp[1],len)
		Control.BlitBack[#Control.BlitBack+1]=rep(tp[2],len)
	end
	
	--load base lib
	Control:load_lib"text.dual_queue.base"
	Control:load_lib"text.dual_queue.parcer"
	Control:load_lib"text.dual_queue.iterator"
	--Control:load_lib"text.dual_queue.make_react"
	Control:load_lib"text.dual_queue.space_handler"
	--lua syntax loading
	for _,v in pairs(arg or{})do
		if v=="lua" then
			Control:load_lib("code.lua.base",Control.Operators,Control.Words)
			--Control:load_lib"text.dual_queue.space_handler"
			Control:load_lib"code.lua.struct"
		end
	end
	
	--edit space handler
	local sp_h=remove(Control.Struct,1)
	insert(Control.Struct,1,function()
		local pl=#Control.Result[#Control.Result]
		sp_h(Control)
		burn_blit("space",#Control.Result[#Control.Result]-pl)
	end)
	Control.Core=function(tp)
		local len =#Control.Result[#Control.Result]
		if (to==__OPEN_BREAKET__) then print(br)end
		burn_blit(tp)
	end
	Control.BlitData={}
	insert(Control.PostRun,function()
		Control.BlitData={}
		local rez,blit,back=concat(Control.Result).."\n",concat(Control.BlitFront).." ",concat(Control.BlitBack).." "
		rez=sub(rez,-1)=="\n"and rez or rez.."\n"
		gsub(rez,"()(.-()\n)",function(st,con,nd)
			insert(Control.BlitData,{gsub(con,".$","\x14"),
				sub(blit,st,nd-1)..colors.toBlit(colors.lightBlue),
				sub(back,st,nd)})--back color
		end)
	end)
	local min = function(a,b) return a<b and a or b end
	Control.debug_highlight=function(st,nd)
		local fn = #Control.BlitData
		nd = min(nd or fn,fn)
		st = (st or 0)>0 and st or 1
		for i=st,nd do
			term.blit(unpack(Control.BlitData[i]))
			print()--new line
		end
	end
	Control.Return=function() if (Control.args[1]=="l_now") then Control.debug_highlight()end return Control.BlitData end
	insert(Control.Clear,function()Control.BlitBack={}Control.BlitFront={}end)
end}