extends Resource
class_name ShopItem

@export var item: ItemData
@export var price: int

## If empty, the item will cost gold instead of this item
@export var currency_item: ItemData
