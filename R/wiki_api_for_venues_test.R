library(jsonlite)
venues_from_wiki <- fromJSON("https://en.wikipedia.org/w/api.php?action=parse&page=List%20of%20music%20venues&format=json")

foo <- venues_from_wiki[["parse"]][["text"]][["*"]]

library(xml2)
bar <- read_html(foo)

xml_child(xml_child(xml_child(xml_child(xml_child(bar, 1), 1), 153), 1), 2)
xml_child(xml_child(xml_child(xml_child(bar, 1), 1), 153), 1)
xml_child(xml_child(xml_child(xml_child(xml_child(bar, 1), 1), 155), 1), 4)
xml_child(xml_child(xml_child(xml_child(bar, 1), 1), 155), 1)
xml_child(xml_child(xml_child(xml_child(xml_child(bar, 1), 1), 157), 1), 3)
xml_child(xml_child(xml_child(xml_child(bar, 1), 1), 157), 1)