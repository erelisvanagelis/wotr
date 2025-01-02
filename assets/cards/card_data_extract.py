from typing import Any
from dataclasses import dataclass
from dataclasses_json import dataclass_json
import json
import os
import re

@dataclass_json
@dataclass
class Card:
    name: str
    type: str
    description: str
    number: str
    faction: str

@dataclass_json
@dataclass
class EnrichedCard:
    id: str
    name: str
    type: str
    number: int
    faction: str
    deck: str
    search_string: str
    pre_condition: str
    action: str
    discard_condition: str
    play_on_table: bool


def extract_description_parts(description: str) -> tuple[str, str, str]:
    pre_condition = ''
    action = ''
    discard_condition = ''
    description_parts = card.description.splitlines()

    if description_parts[0].startswith("Play"):
        pre_condition = description_parts.pop(0)
    
    last_part = description_parts[-1]
    if last_part.startswith('You must discard') or 'to be discarded by' in last_part:
        discard_condition = description_parts.pop()

    action = '\n'.join(description_parts)
    
    return pre_condition, action, discard_condition


base_path = os.path.dirname(__file__)
corrected_cards_file = open(base_path + '\\cards_corrected.json', encoding="utf8")
cards = Card.schema().load(json.load(corrected_cards_file), many=True)
corrected_cards_file.close()

enriched_cards = []
card: Card
for card in cards:
    if card.type == "Combat":
        continue

    pre_condition, action, discard_condition = extract_description_parts(card.description)
    play_on_table = pre_condition.startswith('Play on the table')

    deck = 'Character' if card.number.startswith('C') else 'Strategy'
    number = card.number[1:]
    search_number = number
    if int(number) < 10:
        search_number = '0' + search_number

    chars_removed = re.sub(r"[’:!,.]", "", card.name.upper())
    chars_replaced = re.sub(r"[- ]", "_", chars_removed).replace('É', 'E').replace('Û', 'U').replace('Í', 'I')
    id = chars_replaced
    search_string = " ".join([card.name, chars_replaced, card.type, card.faction, search_number, deck])
    enriched_cards.append(EnrichedCard(id=id, name=card.name, type=card.type, number=number, 
                                       faction=card.faction, deck=deck, search_string=search_string,
                                       pre_condition=pre_condition, action=action, discard_condition=discard_condition, play_on_table=play_on_table))

enriched_cards_json = EnrichedCard.schema().dumps(enriched_cards, many=True)
write_file = open(base_path + "\\cards_enriched.json", "w")
write_file.write(enriched_cards_json)
write_file.close()

enum_line = "enum EventCardName {" + ', '.join([x.id for x in enriched_cards]) + "}"
print(enum_line)