# Mighty Cohadar's Tanks of Harmony and Love
Network Multiplayer tank game in Love2D engine.

Currently in development. ETA: 3 days.

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
  
### day7 goal: GUI 
  * picked Quickie over LoveFrames
  * server can now be started from ingame
  * replaced serpent with (modified) smallfolk

### day8 goal: gameplay, lets add some bullets
  * basic bullet drawing
  * better tank_command & tank velocity controls
  * perfected netcode 
  
### day9 goal: basic collision detection
  * major code cleanup
  * server sync of bullets
  * collision detection & basic effect 
  
### day10 goal: better gui
  * decided to spend a day to learn how to write custom immediate mode gui
  * I assume it will also be handy for doing HUD graphics
    
### day11 goal: more gui
  * lost too much time on a colors sideproject, but it is wort it.
  * custom GUI is hard! but hard things have worth.

### day12 goal: take a break
  * it is important to relax from time to time, no computers today.
  
### day13 goal: teams, hp/death, leaderboard
  * did teams and hp/death
  * have bugs, need better multiplayer debugging!

### day14 goal: debugging, abd finish the job from yesterday

  