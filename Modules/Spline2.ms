struct bp_info (bp_name, bpChild_name, bp_xform)

fn collectBpObs =
(
	local bp_objs = #()
	--local bp_children = #()
	
	local bp_objs = $BP_Spline*
	
	bp_children = for i in bp_objs collect i.children
	
	print bp_children
	--return bp_children 

)


fn buildSpline =
(
	splineBPs = collectBpObs()
	--print splineBPs

)
	
buildSpline()




	-- Make a bone for each blueprint object
	for bp in splineBPs do
		(
		childBp = bp.children
		bone_name = substitutestring bp.name "BP" "Bone"
		--child_bone_name = substitutestring childBp.name "BP" "Bone"
			
		local bpBone = bone name:bone_name
	)