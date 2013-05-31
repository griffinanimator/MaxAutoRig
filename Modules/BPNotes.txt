--Create a struct t store information...
-- BP Object
--BP Name will cme from the name attribute on the BP_Root
--Bone and control names will be determined by replacing BP with (Bone, Ctrl, IKBone, FKBone), and by adding the control name and the suffix from the BP

--Create a function that will collect all the BP objects in the scene and collect data such as name, and transform.

--Create a new struct or append this new information.
	--Ik Bone names
	--FK bone names
	--Bone names
	
--Create a function to build the FK 
--Create a function to build the IK.  Need Stretchy
--Create a function to build the Rig Chain
--Create a function to build the Bind Chain
--Create a function to build MocapNodes
--Create a function to tie all of the chains together

--Notes
	-- IK FK switch should be accessable with IK or FK selected
	--IK FK Blending
	--Control ammount of stretch


--Create a struct to store information
struct module_info (bp_name, parent_name, bp_xform)

-- recursive function to get biped children objects
fn get_bp_children bp_obj bp_data=
(	
	
	-- make sure the current biped object has children
	if (bp_obj.children != undefined) do (
		
		-- loop through all of the current bone's children
		for child in bp_obj.children do (

				-- create an object for the current child bone
				new_bone = bp_info child.name bp_obj.name child.transform			
				
				-- update the bone_data array with the current child
				append bp_data new_bone
				
				-- see if the current child has children
				if (child.children != undefined) do (
					get_bp_children child bp_data
			)
			
		)	
	)
	
	return bp_data
)





-- recursive function to get blueprint children objects
fn get_bp_objects sel=
(
	local bp_data = #()	
	
	bp_members = get_bp_children sel
	
	return bp_members

)	


	
fn buildBones objs prefix=
(
	-- make sure bone data is valid
	if (objs.count > 0) do
	(
		print b
		for b in objs do
			(
			a = b.name
			print a
			-- Get the bone position and define a name for the bone.
			bp_xform = b.transform
			bp_name = substitutestring a "BP" prefix
			-- Create a point object to use as the bone.
			new_bone = point name:bp_name transform:bp_xform size:5 box:on cross:off
			)
		)
	)

	
	

if (selection.count == 1)  then 
--To Do:  Check for class type or name
(
		-- collect the blueprint objects
		get_bp_objects selection[1] 
		print bp_objects
	
		--Build the bind bones
		bindBones = buildBones bp_objects "Bind"
		
	) 
	else 
	(
		messageBox "Select a single biped node" title:"Create Skeleton"
	)
	
	
	
	

