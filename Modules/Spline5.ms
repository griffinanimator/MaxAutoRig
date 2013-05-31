/* Spline.ms 
Author Ryan Griffin 2012
This script will generate an IK spine rig from a set of BP objects.
*/

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

fn addSubChild = 
(
	bpData = #()
	c = addChildren  $BP_SplineRoot #()

	for i in c where i.children[1] != undefined do append bpData #(i, i.children[1])

	return bpData
)


-- Create 2 helper chains to represent each BP.  
fn drawBone = 
(
local bpBones = #()
	
stuff = addSubChild()
for item in stuff do(
	parentBP = item[1]
	childBP = item[2]

	parentBoneName = substitutestring parentBP.name "BP" "PathBone"
	childBoneName = substitutestring childBP.name "BP" "CapPathBone"
	parentPos = parentBP.transform 
	childPos = childBP.transform 
	
	new_ParentBone = point name:parentBoneName size:10 box:on cross:off
	new_ChildBone = point name:childBoneName size:5 box:on cross:off 
	new_ChildBone.parent = new_ParentBone
	new_ParentBone.transform = parentPos
	new_ChildBone.transform = childPos
	new_ParentBone.wirecolor = color 140 88 225
	new_ChildBone.wirecolor = color 196 88 225
	
	append bpBones #(new_ParentBone, new_ChildBone)

	)

return bpBones

)

fn drawIKSpline bpBoneData  =
(
	-- Draw an HIK between each parent / child grp
	-- TODO  Remove the last IK

	local ikSolvers = #()
	for i=1 to bpBoneData.count do(
		ikBone = bpBoneData[i]
		if i != bpBoneData.count then( 
		solverName = substitutestring ikBone[1].name "PathBone" "IK"
		IKChain = IKSys.ikChain ikBone[1] ikBone[2] "IKHISolver"
		IKChain.name = solverName
		append ikSolvers IKChain
		)
	)
	return ikSolvers
	
)


-- Draw a line to use as a path
fn drawLineBetweenPoints bpBoneInput =
(
	bpPositionList =  #()
	for bd in bpBoneInput do(
		pointPos = bd[1].pos
		append bpPositionList #(pointPos)
	)

	--TODO: Set line to be a smooth interpolation spline.
	ss = SplineShape pos:bpPositionList[1][1] name:"Spline_Line"
	addNewSpline ss
	for bpos in bpPositionList while bpPositionList.count > 1 do addKnot ss 1 #corner #line bpos[1]
	updateShape ss
	ss
	return ss
)


-- Create a helper for each template object.  The helpers will be set to path constraint on the line.  Divide number of bones by 100 to get path value.
fn createPathHelpers pathHelperInput lineInput=
(
	local pathHelperObjs = #()
	local splineSkinBoneArray = #()
	local pathVals = #()
	append pathVals 0.0
	-- This is redundant.  I do this in drawIKSpline.
	for k=1 to pathHelperInput.count do(
		ph = pathHelperInput[k]
		
		pathHelperName = replace ph[1].name 1 4 "SpHelper"

		pathHelper = point name:pathHelperName size:15 box:on cross:off
		pathHelper.wirecolor = color 135 6 6
		append pathHelperObjs pathHelper	
		
		pathHelper.pos.controller = Path_Constraint()
		pathHelper.pos.controller.appendTarget lineInput 100	

		deleteKeys pathHelper.pos.controller
		
		--evenly distribute helpers along the path.
		--TODO: Do I need all this?
		phiCount = pathHelperInput.count
		factor = phiCount - 1.0
		
		val = 100.0 * k / factor 
		
		append pathVals val

		pathHelper.pos.controller.percent = pathVals[k]
			
		-- Create a bone at the first and last template position.  The line will be skinned to these bones.
		
		if k == 1 or k == phiCount do( 
			splineSkinBoneName = "SplineBone" + k as string
			splineSkinBone = point name:splineSkinBoneName size:30 box:on cross:off
			kPos = pathHelperInput[k][1].pos
			splineSkinBone.pos = kPos
			append splineSkinBoneArray splineSkinBone
		)

	)
	
		
	select lineInput 
	modPanel.addModToSelection (Skin ()) ui:on
	for b in splineSkinBoneArray do(
		skinOps.addBone lineInput.modifiers[#Skin] b 0
		
		--TODO:  Better Default Weighting
	)
	#(pathHelperObjs, splineSkinBoneArray)
)


-- Link Relative IkSpline bones and ik handles to the path bones.
fn linkBones linkBoneInput ikInput phInput=
(
local linkPairs = #()
local tmpIkArray = #()
append tmpIkArray "None"
for k in ikInput do(
	append tmpIkArray k
)

	
for l=1 to linkBoneInput.count do(
	append linkPairs #(linkBoneInput[l][1], tmpIkArray[l], phInput[l])
)

for i=1 to linkPairs.count do(
	if i !=1 then linkPairs[i][2].parent = linkPairs[i][3]
	)
	
for i=1 to linkPairs.count do(
	linkPairs[i][1].parent = linkPairs[i][3]
	)


)	

-- Create a root and top spine animation control.
fn createSpineControls pathHelperInput =
(
	local splineCtrlObjs = #()
	local helperObjs = #()
	local rootCtrlObj = #()
	
	for c=1 to pathHelperInput.count do(
		LastIndex = pathHelperInput.count
		if c == 1 do(
			ctrlPos = pathHelperInput[c].pos
			-- Create a Ctrl_COG
			COGCtrl = Circle radius:40 pos:ctrlPos isSelected:on  name:"Ctrl_COG"
			append rootCtrlObj COGCtrl
	
			
			splineRootCtrl = Circle radius:25 pos:ctrlPos isSelected:on name:"Ctrl_Spline_Root"
			-- Create a node above the ctrl to be used as a hookup for mocap skeleton
			bcRBuffer = point name:"McBuf_Spline_Root" size:5 pos:ctrlPos box:off cross:on
			append splineCtrlObjs splineRootCtrl 
			append helperObjs bcRBuffer
			splineRootCtrl.parent = bcRBuffer
			bcRBuffer.parent = COGCtrl 

			-- I am going to put in the code for two types of controls.
			-- The first control is a scripted manipulator and the second is a simple circle
			--spineControl = ctrl pos:[-114.854,242.944,0] isSelected:on		
		)
		if c == lastIndex do(
			local ctrlPos = pathHelperInput[c].pos
			splineTopCtrl = Circle radius:25 pos:ctrlPos isSelected:on name:"Ctrl_Spline_Top"
		
			-- Create a node above the ctrl to be used as a hookup for mocap skeleton
			bcTBuffer = point name:"McBuf_Spline_Top" size:5 pos:ctrlPos box:off cross:on
			append splineCtrlObjs splineTopCtrl 
			append helperObjs bcTBuffer
			splineTopCtrl.parent = bcTBuffer
			bcTBuffer.parent = rootCtrlObj[1]

		)
	)
	#(splineCtrlObjs, rootCtrlObj,  helperObjs)
)

fn createSwivleExpressions splineIkInput splineCtlInput=
(
	-- Idealy I want to design a system that can account for any number of spline bones.
	-- I need to be able to change the swivel expression depending on how many ik I am hooking up
	--Ctrl_Root = splineCtlInput[1]
	--Ctrl_Top = splineCtlInput[2]
	for sp=1 to splineIkInput.count do(
		-- This makes an assumption that the root ik will always be first in the array
		if sp == 1 do(
			splineIkInput[sp].transform.controller.swivelAngle.controller = Float_Expression ()
			splineIkInput[sp].transform.controller.swivelAngle.controller.AddScalarTarget"hipCtrl" splineCtlInput[1].rotation.Zero_Euler_XYZ.Z_Rotation.controller
			splineIkInput[sp].transform.controller.swivelAngle.controller.setExpression "hipCtrl"
		)
		-- Now do the next ik in the array
		if sp == 2 do(
			addIndex = sp + 1
			splineIkInput[sp].transform.controller.swivelAngle.controller = Float_Expression ()
			splineFloatExpression = "(midSwvl + hipCtrl) / 2"
			splineIkInput[sp].transform.controller.swivelAngle.controller.AddScalarTarget"hipCtrl" splineCtlInput[1].rotation.Zero_Euler_XYZ.Z_Rotation.controller
			splineIkInput[sp].transform.controller.swivelAngle.controller.AddScalarTarget"midSwvl" splineIkInput[3].controller[1] -- Or .controller[#SwivelAngle].  Get SubAnim
			splineIkInput[sp].transform.controller.swivelAngle.controller.setExpression splineFloatExpression
		)
		-- Now do the next ik in the array
		if sp == 3 do(
			splineIkInput[sp].transform.controller.swivelAngle.controller = Float_Expression ()
			splineFloatExpression = "(chestCtrl + hipCtrl) / 2"
			splineIkInput[sp].transform.controller.swivelAngle.controller.AddScalarTarget"hipCtrl" splineCtlInput[1].rotation.Zero_Euler_XYZ.Z_Rotation.controller
			splineIkInput[sp].transform.controller.swivelAngle.controller.AddScalarTarget"chestCtrl" splineCtlInput[2].rotation.Zero_Euler_XYZ.Z_Rotation.controller
			splineIkInput[sp].transform.controller.swivelAngle.controller.setExpression splineFloatExpression
		)
		-- Now do the next ik in the array
		if sp == 4 do(
			splineIkInput[sp].transform.controller.swivelAngle.controller = Float_Expression ()
			splineFloatExpression = "(midSwvl  + chestCtrl ) / 2"
			splineIkInput[sp].transform.controller.swivelAngle.controller.AddScalarTarget"chestCtrl" splineCtlInput[2].rotation.Zero_Euler_XYZ.Z_Rotation.controller
			splineIkInput[sp].transform.controller.swivelAngle.controller.AddScalarTarget"midSwvl" splineIkInput[3].controller[1]
			splineIkInput[sp].transform.controller.swivelAngle.controller.setExpression splineFloatExpression
		)
	
	)
)

--freeze transform as function
fn FreezeTransforms item = 	
	( 		
		local CurObj = item

		if classof CurObj.rotation.controller != Rotation_Layer do
		(

			-- freeze rotation		
			CurObj.rotation.controller = Euler_Xyz() 		
			CurObj.rotation.controller = Rotation_list() 			
			CurObj.rotation.controller.available.controller = Euler_xyz() 		
			
			/* "Localization on" */  
		
			CurObj.rotation.controller.setname 1 "Frozen Rotation" 		
			CurObj.rotation.controller.setname 2 "Zero Euler XYZ" 		
		
			/* "Localization off" */  
			
			CurObj.rotation.controller.SetActive 2 		
		)
		if classof CurObj.position.controller != Position_Layer do
		(

			-- freeze position
			CurObj.position.controller = Bezier_Position() 			
			CurObj.position.controller = position_list() 			
			CurObj.position.controller.available.controller = Position_XYZ() 	

			/* "Localization on" */  
					
			CurObj.position.controller.setname 1 "Frozen Position" 	
			CurObj.position.controller.setname 2 "Zero Pos XYZ" 			
			
			/* "Localization off" */  
			
			CurObj.position.controller.SetActive 2 		

			-- position to zero
			CurObj.Position.controller[2].x_Position = 0
			CurObj.Position.controller[2].y_Position = 0
			CurObj.Position.controller[2].z_Position = 0
		)

	)


-- Parent the bones used for spline skin to the controls
fn parentSplineSkinToCtrls ctrlInput spSkinBnInput =
(
	spSkinBnInput[1].parent = ctrlInput[1]
	spSkinBnInput[2].parent = ctrlInput[2]
)


-- Make a seperate bone chain to use as the skin bones.
fn createBindBones =
(
	--Define an empty array to store the path helpers
	local boneNames = #()	
	-- Find all of the rivet helpers
	local boneNames = $PathBone_*
	
	bindBoneList = #()
	for ph in boneNames do(
		if ph != boneNames.count do(
			bindBoneName = replace ph.name 1 8 "Bone"
			bbPos = ph.pos
			bindBone = point name:bindBoneName size:30 pos:bbPos  box:on cross:off
			bindBone.pos.controller = Position_Constraint()
			bindBone.pos.controller.appendTarget ph 100
			bindBone.rotation.controller = Orientation_Constraint()
			bindBone.rotation.controller.appendTarget ph 100
			append bindBoneList bindBone
		)
	)
	return bindBoneList 
)


fn cleanupScene =
(
	-- Delete the blueprint objects used to make the spline
	delNodes = addSubChild()
	-- TODO:  Still need to delete the nub
	for d in delNodes do(
		delete d[1]
	)

)
	


-- This is the set of main functions used to build the rig.
fn mainFunction =
(
local bpBoneData = drawBone ()
	
local ikInfo = drawIKSpline bpBoneData 

local lineInfo = drawLineBetweenPoints bpBoneData
	
local pathHelperInfo = createPathHelpers bpBoneData lineInfo
	
local boneLinks = linkBones bpBoneData ikInfo pathHelperInfo[1]
	
local spineControls = createSpineControls pathHelperInfo[1]
for ctrl in spineControls do(
		for c in ctrl do(
			local freezeObjects = FreezeTransforms c
		)			
)

local ikExpressions = createSwivleExpressions ikInfo spineControls[1]

local splineToSkin = parentSplineSkinToCtrls spineControls[1] pathHelperInfo[2]
local bindBones = createBindBones() 
--TODO:  Create a list controller on each SpHelper_Bone.  Use a second set of transforms to control the spine via FK when switched.
local deleteUnusedObjs = cleanupScene()
)	



mainFunction()


--TODO



--connect the swivle angle attributes to the controller rotation via a float expression

--fn createIkExpressions =
--(
	

-- Figure out how to accuratly hook the mocap dummies into this :)

-- Make us of a struct to cut down ammount of code.



-- These are some new concepts I got.  I will save them here for later.
--data = #()
--for node in helpers while data.count == 0 where node.children[1] != undefined do append data #(node, node.children[1])

--for node in helpers collect #(node, node.children[1])

		
		--matchpattern ph[1].name pattern:"Bone*"
		--(findstring ph[1].name "Bone") == 1


	

