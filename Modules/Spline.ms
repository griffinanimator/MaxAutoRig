fn collectBpObs =
(
	local bp_objs = #()
	tmpSel = $Selection
	newSel = tmpSel as array
	print newSel
	
	-- Check to make sure we have the root
	--match_root = matchpattern newSel[1] pattern:"*Root"

	--if (match_root)do(
		--print tmpSel
	--)
	
	bp_objs = getnodebyname newSel
	print bp_objs
)		
collectBpObs()
