extends Resource
class_name ShopItem

@export var item: ItemData
@export var price: int
@export var stock: int = -1 ## -1 = infinite, 1 = unique, > 1 = limited quantity
@export var currency_item: ItemData ## If empty, the item will cost gold instead of this item
