# Mighty Cohadar's Tanks of Harmony and Love
Network Multiplayer tank game in Love2D engine.

Currently in development. ETA: 9 days.

<img src="https://github.com/cohadar/tanks-of-harmony-and-love/blob/master/screenshot.png">

### day1 goal: make tank move and turret turn.
  * basic game loop done
  * basic angle/drawing done
  * camera/tarrain code is more complex than I presumed.

### day2 goal: finish tank move/velocities code
  * safe map bounds
  * implemented tank and turret controls
  * driving tank around looks awesome :)
  * remember to draw sprites in zero angle direction

### day3 goal: basic networking
  * created a luasocket server that flips tank x/y every 5 sec
  * replaced raw luasocket with lua-enet + serpent 

### day4 goal: two player networking
  * you can see enemy tanks!!! \o/ \o/ \o/

### day5 goal: client-side prediction and lag compensation
  * prediction working, but not efficient
  * visualizing server desync
  * finally made decent prediction, netcode is a lot harder that I thought
  * well I guess this one will take more than a day :)

### day6 goal: finish netcode
  * server fps: 10, client command fps: 30, client draw fps: 60
  * better debugging support, screen scaling
  
### day7 goal: GUI & HUD
  * picked Quickie over LoveFrames
  

