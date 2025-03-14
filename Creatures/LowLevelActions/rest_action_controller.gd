extends ActionController


func enter(mainAI, target = null):
	mainAI.target = null
	mainAI.path = null
	mainAI.rest()

func execute(mainAI):
	pass

func exit(mainAI):
	pass
