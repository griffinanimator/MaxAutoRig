--struct bp_info (bp_name, bpChild_name, bp_xform)

-- Function to get all the children of a defined object
fn addChildren obj hierarchy =
(
	-- add object to the array
	append hierarchy obj
	-- loop over children and recursively add their children
	for child in obj.children do
		addChildren child hierarchy
	hierarchy
)


fn drawBones = 
(
	local data = #()
	c = addChildren  $BP_SplineRoot #()
	for i in c where i.children[1] != undefined do append data #(i, i.children[1])
	return data
)

--drawBones()


fn doStuff =
(
	newBoneData = drawBones
	print newBoneData
)


doStuff()
