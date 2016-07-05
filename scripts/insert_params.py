import sys
from xml.etree.ElementTree import ElementTree, dump

tree = ElementTree()
tree.parse(sys.argv[1])

tree.find('module/param[@name="whiteList"]')[0].text = sys.argv[2]

dump(tree)
