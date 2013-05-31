fn mainFunction =
(
local bpRoot = getBpRoot()
	print "BPRoot"
	print bpRoot
local bpChildren = addSubChild bpRoot

)

-- Collect the bp objects into an array
fn getBpRoot =
(
	local bp_data = #()
	sel = $
	if sel.name == "BP_Root" do(
		bpRoot = sel
	)
	local bpChildren = addSubChild bpRoot
)
		
	
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

fn addSubChild bpRoot = 
(
	bpData = #()
	c = addChildren  bpRoot #()

	for i in c where i.children[1] != undefined do append bpData #(i, i.children[1])
	return bpData
)

mainFunction()

-- Build the rig bones.  All the setup will be done on these.

-- Draw the IK Chain

-- Setup the control objects