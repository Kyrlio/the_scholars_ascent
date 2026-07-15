extends Resource
class_name ShopItem

@export var item: ItemData
@export var stock: int = -1 ## -1 = infinite, 1 = unique, > 1 = limited quantity

@export_group("Costs")
@export var gold_price: int = 0
@export var required_item: ItemCost ## Can add items to the price
