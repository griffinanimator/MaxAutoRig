/*
XML Tutorial
*/

--Load the xml assemply
dotNet.loadAssembly "system.xml"
--Create an xml document object.
xmlDoc=dotNetObject "system.xml.xmlDocument"

--Format properties and methods to the listener.
clearListener()
format "Properties\n"
showProperties xmlDoc
format "\nMethods\n"
showMethods xmlDoc

--Create a root element for the xml doc and add it to the xmlDocument.
root=xmlDoc.createElement "Root"
xmlDoc.appendChild root
--show the properties for the new element.
showMethods root

--Define  a document path
docPath = "C:\\Users\\rgriffin\\Google Drive\\RG_ARTTOOLS\\MaxAutoRig\\Data\\test.xml"

/* Write To XML ---------------------------------------------------------------------------------*/
--Recurse hierarchy and add xml elements
fn recurseHierarchy obj ele =
(
	for i = 1 to obj.children.count do		--Loop through each of the children
	(
		--Create a new element for the object.
		newElement=xmlDoc.createElement "node"
		--Set attributes on the new elements for the name of the object and the class of it.
		newElement.setAttribute "name" obj.children[i].name
		newElement.setAttribute "class" (classOf obj.children[i] as string)
		
		--Append the new element to the root element. 
		ele.appendChild newElement
		
		recurseHierarchy obj.children[i] newElement
	)
)

--Names for elements can't include anything but alpha characters.
for x in objects do
(
	if x.parent==undefined then
	(
		--Create a new element for the object.
		newElement=xmlDoc.createElement "node"
		--Set attributes on the new elements for the name of the object and the class of it.
		newElement.setAttribute "name" x.name
		newElement.setAttribute "class" (classOf x as string)
		
		--Append the new element to the root element. 
		root.appendChild newElement
		
		recurseHierarchy x newElement
	)
)

--Save the xmlDoc object to a file. 
xmlDoc.save docPath
--Open the file in Max to see the result. 
edit docPath





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