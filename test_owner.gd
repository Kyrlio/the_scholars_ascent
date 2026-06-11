extends SceneTree

func _init():
	var scene = load("res://Levels/Rooms/Room_1A.tscn").instantiate()
	var coins = scene.find_children("", "RigidBody2D", true, false)
	for c in coins:
		print("Coin name: ", c.name)
		var o = c.owner
		if o:
			print("Owner name: ", o.name)
			print("Owner path: ", o.scene_file_path)
			print("Coin id: ", o.scene_file_path + "::" + str(o.get_path_to(c)))
		else:
			print("No owner")
	quit()
