$IK_Spline3.transform.controller.swivelAngle.controller = Float_Expression ()
splineFloatExpression = "(chestCtrl + hipCtrl) / 2"
$IK_Spline3.transform.controller.swivelAngle.controller.AddScalarTarget"hipCtrl" $Ctrl_Spline_Top.rotation.controller.Z_Rotation.controller
$IK_Spline3.transform.controller.swivelAngle.controller.AddScalarTarget"chestCtrl" $Ctrl_Spline_Root.rotation.controller.Z_Rotation.controller
$IK_Spline3.transform.controller.swivelAngle.controller.setExpression splineFloatExpression








This should do what you need, this is step by step. For cleaner code I would set variables as needed to shorten/optimize the code.--Make sure Crank has its height set as a bezier_float()
$Crank.height.controller = bezier_float()
--Set the controller for the Z position of "point A"
$'point A'.position.controller[3].controller = float_expression()
--Set the Crank.height controller as the scalar target "r"
$'point A'.position.controller[3].controller.AddScalarTarget "r" $Crank.height.controller
--Set the expression for the Expression controller to "r"
$'point A'.position.controller[3].controller.setExpression "r"-Eric