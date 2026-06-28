extern networkInit
extern writeDefaultWeights

global createNewNetwork

createNewNetwork:
  call networkInit
  call writeDefaultWeights

globaL forwardPassNetwork

forwardPassNetwork:
  call forwardPass

global trainNetwork

trainNetwork:
  call seedOutputGradient

  call createBackpropArena
  call calculateAllGradients





