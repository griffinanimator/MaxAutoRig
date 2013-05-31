filename = "C:\\Users\\rgriffin\\Google Drive\\RG_ARTTOOLS\\MaxAutoRig\\Data\\test.xml"

fn saveLinkFile filename: = 
(
	if filename == unsupplied do filename = getSaveFilename caption:"Save Link Node List File" types:"Link Node List (.xml)|*.xml"
		
	if filename != undefined do
	if iskindof (doc = dotnetobject "System.Xml.XmlDocument") dotnetobject do
	(
		local nodes = owner.an.makeHierarchyOrder (objects as array)
		
		if getfilenametype filename == "" do filename += ".xml"
		global _nova = doc
		doc.AppendChild (doc.CreateComment "Link Data. Version 1.0")
		doc.AppendChild (doc.CreateComment ("File: " + maxfilepath + maxfilename))
		doc.AppendChild (doc.CreateWhitespace "\n")

		doc.AppendChild (links = doc.CreateElement "nodes")
		links.SetAttribute "count" (nodes.count as string)
		for node in nodes do
		(
			links.AppendChild (link = doc.CreateElement "link")
			link.SetAttribute "child" node.name
			link.SetAttribute "parent" (if node.parent == undefined then "" else node.parent.name)
		)
		doc.Save filename
		doc.Normalize()
		filename
	)
)
fn loadLinkFile filename: = 
(
	if filename == unsupplied do filename = getOpenFilename caption:"Load Link Node List File" types:"Link Node List (.xml)|*.xml"
		
	if filename != undefined do
	if iskindof (doc = dotnetobject "System.Xml.XmlDocument") dotnetobject do
	(
		doc.Load filename
		local links = doc.selectnodes "//link"
		for k=0 to links.count-1 do
		(
			child = links.item[k].getattribute "child"
			parent = links.item[k].getattribute "parent"
			if (c = getnodebyname child) != undefined and (p = getnodebyname parent) != undefined and c.parent != p do c.parent = p
		)
		doc.Normalize()
	)
)

saveLinkFile()