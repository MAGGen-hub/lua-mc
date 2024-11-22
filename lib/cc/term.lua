
local width=92
local heigth=24
return{
	getSize=function()return 92,24 end,
	getTextColour=function()return 1 end,
	setTextColour=function()end,
	getCursorPos=function()return 0,0 end,
	setCursorPos=function(x,y)io.stdout:write((y>0 and"\n"or"")..string.rep(" ",x))end,
	scroll=function()end,
}