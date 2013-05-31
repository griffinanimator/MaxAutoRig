/*
XML Reading Tutorial
*/

docPath = "C:\\Users\\rgriffin\\Google Drive\\RG_ARTTOOLS\\MaxAutoRig\\Data\\test.xml"

--Load the xml assemply
dotNet.loadAssembly "system.xml"
--Create an xml document object.
xmlDoc=dotNetObject "system.xml.xmlDocument"

--Open the file in Max to see the file. 
xmlPath=docPath
-- edit xmlPath

fn formatProps ele=
(
	clearListener()
	
	format "Props:\n"
	showProperties ele
	
	format "Methods\n"
	showMethods ele
)

fn recurseXml ele parent:undefined=
(
	--Loop through all the children
	for i = 0 to ele.childNodes.count-1 do
	(
		--Get the attribute value called class
		objClassStr=(ele.ChildNodes.itemOf[i].GetAttributeNode "class").value
		--Get the attribute value called name
		objNameStr=(ele.ChildNodes.itemOf[i].GetAttributeNode "name").value
		
		--Check if the class value can be turned into a max class object and is creatable.
		objClass=(execute objClassStr)
		if objClass!=undefined and objClass.creatable then 
		(
			--Create the object
			n=objClass()
			print n
			--Name the object
			n.name=objNameStr
			--Set the parent of the object if there is one. 
			n.parent=parent
		)
		
		--recurse the xml tree
		recurseXml ele.ChildNodes.itemOf[i] parent:n
	)
)

--If the file exists then load it.
if doesFileExist xmlPath then
(
	--Load the XML file.
	xmlDoc.load xmlPath
	--Check to make sure the xmlDoc has a root element. 
	docEle=xmlDoc.documentElement
	
	--If the root element exists continue. 
	if docEle!=undefined and docEle.name=="Root" then
	(
		--Recurse the XML tree.
		recurseXml docEle
	)
)



