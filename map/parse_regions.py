from typing import List
from typing import Any
from dataclasses import dataclass
import json
import jsonpickle

@dataclass
class Region:
    name: str
    id: str
    parentId: int
    isStronghold: bool
    isCity: bool
    isTown: bool
    isFortification: bool
    neighbours: List[str]

    @staticmethod
    def from_dict(obj: Any) -> 'Region':
        _name = str(obj.get("name"))
        _id = str(obj.get("id"))
        _parentId = int(obj.get("parentId"))
        _isStronghold = obj.get("isStronghold")
        _isCity = obj.get("isCity")
        _isTown = obj.get("isTown")
        _isFortification = obj.get("isFortification")
        _neighbours = []
        return Region(_name, _id, _parentId, _isStronghold, _isCity, _isTown, _isFortification, _neighbours)

@dataclass
class Nation:
    name: str
    id: int
    color: str
    isShadows: bool
    regions: List[Region]

    @staticmethod
    def from_dict(obj: Any) -> 'Nation':
        _name = str(obj.get("name"))
        _id = int(obj.get("id"))
        _color = str(obj.get("color"))
        _isShadows = obj.get("isShadows")
        _regions = [Region.from_dict(y) for y in obj.get("regions")]
        return Nation(_name, _id, _color, _isShadows, _regions)

# Example Usage
file = open('regions.json', encoding="utf8")
jsonstring = json.load(file)

# # print(jsonstring)
nations = []

for nation in jsonstring:
    nations.append(Nation.from_dict(nation))

# # print(nations[0])
# for nation in nations:
#     nation.

with open("sample.json", "w") as outfile:
    dumped = json.dumps(nations, default=vars)
    json.dump(dumped, outfile)