-- This is the set of main functions used to build the rig.
fn mainFunction =
(
	local bp_data = #()
	if  $ != undefined do sel = $

	if sel.name == "BP_Root" do(
		bpRoot = sel
		local bpBoneData = addSubChild(bpRoot)
	)
	local bindBones = buildBones bpBoneData "bone_"
	
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


-- Get the children of the root
fn addSubChild bpRoot = 
(
	bpData = #()
	c = addChildren  bpRoot #()

	for i in c where i.children[1] != undefined do append bpData #(i, i.children[1])

	return bpData
)

-- Build the bones
fn buildBones bpBoneData prefix =
(
	for item in bpBoneData do(
		print item[2]
		bone_name = substitutestring item[2].name "BP_" prefix
		tmp_bpName = substitutestring item[1].name "BP_" prefix
		bone_parent = getnodebyname tmp_bpName
		new_bone = point name:bone_name size:5 box:on cross:off
		new_bone.transform = item[2].transform
		new_bone.parent = bone_parent  
	)
)

mainFunction()
