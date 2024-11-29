from typing import Any
from dataclasses import dataclass
import json

@dataclass
class Card:
    name: str
    type: str
    description: str
    number: str
    faction: str

    @staticmethod
    def from_dict(obj: dict) -> 'Card':
        _name = str(obj.get("name"))
        _type = str(obj.get("type"))
        _description = str(obj.get("description"))
        _number = str(obj.get("number"))
        _faction = str(obj.get("faction"))
        return Card(_name, _type, _description, _number, _faction)
    
def get_card_for_faction(cards, faction, card_type, destination):
    for card in cards:
        if card.faction == faction:
            if card.type == card_type:
                destination.append(card)
            elif card_type == STRATEGY and (card.type == ARMY or card.type == MUSTER):
                destination.append(card)



# Example Usage
file = open('cards_mod.json', encoding="utf8")
jsonstring = json.load(file)
cards = []
for dict in jsonstring:
    cards.append(Card.from_dict(dict))

ARMY = 'Army'
MUSTER = 'Muster'
COMBAT = 'Combat'
CHARACTER = 'Character'
STRATEGY = 'Strategy'
FREE_PEOPLE = 'Free People'
SHADOW = 'Shadow'
people = {
    'faction': FREE_PEOPLE,
    'character': [],
    'strategy': []
}
shadow = {
    'faction': SHADOW,
    'character': [],
    'strategy': []
}

output = []

get_card_for_faction(cards, FREE_PEOPLE, CHARACTER, people['character'])
get_card_for_faction(cards, FREE_PEOPLE, STRATEGY, people['strategy'])
get_card_for_faction(cards, SHADOW, CHARACTER, shadow['character'])
get_card_for_faction(cards, SHADOW, STRATEGY, shadow['strategy'])


# print(len(cards))
# print(people['character'])
for card in shadow['strategy']:
    print(card.name)
    # print(card.description)

print(len(people['character']))
print(len(people['strategy']))
print(len(shadow['character']))
print(len(shadow['strategy']))
