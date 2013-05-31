--Create a struct to store information
struct module_info (bp_name, parent_name, bp_xform)

-- create a skeleton from a blueprint
fn create_skeleton bp prefix =
(
	local bp_data = #()
	
	bp_root = bp
	--Storing the root info to the struct
	root_bp = module_info bp_root.name undefined bp.transform
	
	-- get data (names and hierarchy) from the blueprint
	bp_data = get_bp_children bp_root bp_data
	
	-- make sure bone data is valid
	if (bp_data.count > 0) do (
		
		-- create the bones
		for b in bp_data do (
			bone_name = substitutestring b.bp_name "BP" prefix
			-- Create a point object to serve as a bone
			new_bone = point name:bone_name size:5 box:on cross:off
		)
		
		-- update the hierarchy and set the transforms on the newly created bones
		for b in bp_data do (
			
			-- only update the bone parent if it actually has a parent
			if (b.parent_name != undefined) then (
				
				bone_name = substitutestring b.bp_name "BP" prefix
				parent_name = substitutestring b.parent_name "BP" prefix
			
				bone_node = getnodebyname bone_name
				parent_node = getnodebyname parent_name
				
				-- set the bone parent then set the transform
				if (isvalidnode bone_node) and (isvalidnode parent_node) do (
					bone_node.parent = parent_node
					bone_node.transform = b.bp_xform
				)
				
			) else (
				
				-- get the bone object
				bone_name = substitutestring b.bp_name "BP" prefix
				bone_node = getnodebyname bone_name
				
				-- set the bone transform without a parent
				if (isvalidnode bone_node) do (
					bone_node.transform = b.bp_xform
				)
				
			)
			
		)
		
		
	)
)
	

	
-- recursive function to get biped children objects
fn get_bp_children bp_obj bp_data =
(	
	
	-- make sure the current object has children
	if (bp_obj.children != undefined) do (
		
		-- loop through all of the current objects children
		for child in bp_obj.children do (
			
				-- create an object for the current child bone
				new_bone = module_info child.name bp_obj.name child.transform			
				
				-- update the bp_data array with the current child
				append bp_data new_bone
				
				-- see if the current child has and children
				if (child.children != undefined) do (
					get_bp_children child bp_data
			)
			
		)	
	)
	
	return bp_data
)


--Create a struct to store information
struct bones_info (bind_bones, rig_bones, ik_bones, fk_bones, mocap_bones )


fn create_hinge =
(
if (selection.count == 1)  then 
--To Do:  Check for class type or name
(
		-- collect the blueprint objects
		--TODO: As bones are created, add them to layers
		bind_bones = create_skeleton selection[1]  "Bone"
		rig_bones = create_skeleton selection[1]  "Rig"
		--ik_bones = create_skeleton selection[1]  "IK"
		--fk_bones = create_skeleton selection[1]  "FK"
		--mocap_bones = create_skeleton selection[1]  "Mocap"
	
		bp_bones = bones_info bind_bones rig_bones 
	--ik_bones fk_bones mocap_bones
	
		messageBox "Creating Skeleton Complete!" title:"Create Skeleton"
		
		-- Setup the connections between bone chains
	
		a = bones_info
		print a
		
	) 
	else 
	(
		messageBox "No BP_Root Selected" title:"Create Hinge"
	)
)


--fn 



create_hinge()