-- This is the set of main functions used to build the rig.
fn mainFunction =
(
	local bp_data = #()
	if  $ != undefined do sel = $

	if sel.name == "BP_Root" do(
		bpRoot = sel
		local bpBoneData = addChildren(bpRoot)
	)
	local bindBones = buildBones bpBoneData "bone_"
	
	-- Find the PV position
	local pvInfo = getPVInfo bpBoneData[2]

	-- Build the ik chain
	local ikBones = buildBones bpBoneData "ikBone_"
	
	-- Build the fk chain
	local fkBones = buildBones bpBoneData "fkBone_"
	
	-- Setup stretchy ik
	local ikInfo = createStretchyIk ikBones 
	
	-- Connect bone chains
	local conInfo = connectBoneChains bindBones ikBones fkBones
	
	-- Create the ik control
	local ikControlInfo = setupIkControls ikBones ikInfo pvInfo
	
	--Cleanup
	--delete bpBoneData
	--delete sel
	
)

fn getPVInfo pv = 
(
	local pvInfo = #()
	local pvChildren =  pv.children
	for pv in pvChildren do(
		append pvInfo pv
	)
		
	return pvInfo[1]
)


-- Function to get all the children of a defined object
fn addChildren obj =
(
	local bpObjs = #()

	-- loop over children and recursively add their children
	for child in obj.children do(
		append bpObjs child
	)
	print bpObjs
	return bpObjs	
)



-- Build the bones
fn buildBones bpBoneData prefix =
(
	local bindBones = #()
	for i=1 to bpBoneData.count do(
		bone_name = substitutestring bpBoneData[i].name "Ctrl_BP_" prefix
		--tmp_bpName = substitutestring item[1].name "BP_" prefix
		if i != 1 do bone_parent = getnodebyname (substitutestring bpBoneData[i-1].name "Ctrl_BP_" prefix)
		new_bone = point name:bone_name size:5 box:on cross:off
		new_bone.transform = bpBoneData[i].transform
		new_bone.parent = bone_parent  
		append bindBones new_bone
	)
	return bindBones
)

fn createStretchyIk ikBones =
(
	local ikSolvers = #()

	solverName = substitutestring ikBones[1].name "ikBone" "IKH"
	IKChain = IKSys.ikChain ikBones[1] ikBones[3] "IKHISolver"
	IKChain.name = solverName
	append ikSolvers IKChain
	return ikSolvers
)

fn connectBoneChains bindBones ikBones fkBones =
(
	for bn=1 to bindBones.count do(
		bindBones[bn].pos.controller = Position_Constraint()
		bindBones[bn].pos.controller.appendTarget ikBones[bn] 100
		bindBones[bn].pos.controller.appendTarget fkBones[bn] 0
		
		bindBones[bn].rotation.controller = Orientation_Constraint()
		bindBones[bn].rotation.controller.appendTarget ikBones[bn]100
		bindBones[bn].rotation.controller.appendTarget fkBones[bn]0
	)
)


fn setupIkControls ikBones ikInfo pvInfo=
(
	ctrlName = substitutestring ikBones[3].name "ikBone_" "ctrl_ik_"
	ctrlPos = ikBones[3].transform
	ikCtrl = point name:ctrlName size:25 box:on cross:off
	ikCtrl.transform = ctrlPos
	ikInfo[1].parent = ikCtrl 
	
	-- Do the pole vector
	pvName = substitutestring pvInfo.name "Ctrl_BP_" "ctrl_"
	pvPos = pvInfo.pos
	pvCtrl = point name:pvName size:25 box:off cross:on
	pvCtrl.pos = pvPos
	ikInfo[1].transform.controller.VHTarget = pvCtrl 
)


	
	



mainFunction()
