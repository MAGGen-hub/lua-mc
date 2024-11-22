function(Control)--base API for text/code related data
	Control.Operators={}
	Control.operator=""
	Control.word=""
	Control.Words={}
	Control.Result[1]=""
	Control.max_op_len=3
	Control.line=1
	Control.Return=function()return concat(Control.Result)end
	insert(Control.Clear,function()Control.Result={""}Control.operator=""Control.word=""end)
end