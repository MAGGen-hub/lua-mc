function(Control)--function that created sefault reactions to different tokens
	return __RESULTABLE__, function(s,i,t,j) -- s -> replacer string, i - type of reaction, t - type of sequnece, j - local length
		t=t or match(s,"%w")and"word"or"operator"
		j=j or#s
		return function(Control)
			insert(Control.Result,s)
			Control[t]=sub(Control[t],j+1)
			Control.index=Control.index+j
			Control.Core(i,s)
		end
	end
end