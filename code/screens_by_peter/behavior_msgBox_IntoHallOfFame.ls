property myNum, Prop, waiting
global glob

on beginSprite me
  myNum = me.spriteNum
  glob[#master_obj] = me
  Prop = [:]
  Prop[#state] = #hide
  Prop[#loc] = [#Start: point(275, -220), #show: point(265, 210), #end: point(-455, 210)]
  Prop[#speed] = [#move1: [0, 40], #move2: [-40, 0]]
  glob.PLAYER[#game_manager].TotalKeys()
end

on dropBox me
  building = glob[#current][#building]
  level = glob[#current][#level]
  moves = glob[#current][#moves]
  data = glob[#building][building][#LEVELS][level][#moves]
  glob.PLAYER[#game_manager].TotalKeys()
  if (glob[#rankdata][#keys] + 1) < glob[#hof] then
    glob[#award_obj].dropBox()
  else
    if glob[#rankdata][#AlreadySawHOF] = #YES then
      glob[#award_obj].dropBox()
    else
      if data > 0 then
        glob[#award_obj].dropBox()
      else
        if not (glob[#rankdata][#AlreadySawHOF] = #YES) then
          glob[#rankdata][#AlreadySawHOF] = #YES
          Prop[#state] = #move1
          setCursor(#none)
          me.updateScreen()
          me.fixLocZ()
        end if
      end if
    end if
  end if
end

on updateScreen me
  member("total.moves").text = string(glob[#rankdata][#moves])
  if glob[#rankdata][#serverState] = #READY then
    barwidth = 125
    rank = glob[#rankdata][#rank]
    total = glob[#rankdata][#players]
    if rank = 0 then
      mybar = barwidth
    else
      ratio = total / rank
      mybar = barwidth - (barwidth / ratio)
    end if
    sprite(myNum + 1).width = mybar
    member("rank_box1").text = string(glob[#rankdata][#rank])
    member("rank_box2").text = "out of " & string(glob[#rankdata][#players])
  else
    member("rank_box1").text = "processing"
    member("rank_box2").text = EMPTY
  end if
end

on exitFrame me
  case glob[#master_obj].Prop[#state] of
    #hide:
    #move1:
      temp = me.doMove(Prop[#loc][#show], Prop[#speed][#move1])
      if temp = 1 then
        glob[#master_obj].Prop[#state] = #show
        waiting = the timer
      end if
    #show:
      setCursor(#none)
      me.updateScreen()
      if the timer > (waiting + 300) then
        sprite(myNum + 3).loc = point(1000, 1000)
      end if
    #move2:
      temp = me.doMove(Prop[#loc][#end], Prop[#speed][#move2])
      if temp then
        glob[#master_obj].Prop[#state] = #done
        me.updateLoc(Prop[#loc][#Start])
      end if
  end case
end

on doMove me, toWhere, speed
  case glob[#master_obj].Prop[#state] of
    #move1:
      if sprite(myNum).locV < toWhere[2] then
        newloc = sprite(myNum).loc + point(speed[1], speed[2])
        me.updateLoc(newloc)
        return 0
      else
        return 1
      end if
    #move2:
      if sprite(myNum).locH > toWhere[1] then
        newloc = sprite(myNum).loc + point(speed[1], speed[2])
        me.updateLoc(newloc)
        return 0
      else
        return 1
      end if
  end case
end

on getOut me
  if Prop[#state] = #show then
    Prop[#state] = #move2
  end if
end

on reportState me
  return Prop[#state]
end

on updateLoc me, newloc
  sprite(myNum).loc = newloc
  sprite(myNum + 1).loc = sprite(myNum).loc + point(-189, 125)
  sprite(myNum + 2).loc = sprite(myNum).loc + point(146, 150)
  if not (glob[#master_obj].Prop[#state] = #move2) then
    sprite(myNum + 3).loc = sprite(myNum).loc + point(0, -1)
  end if
end

on fixLocZ me
  sprite(myNum).locZ = 1000000000
  sprite(myNum + 1).locZ = 1000000001
  sprite(myNum + 2).locZ = 1000000001
  sprite(myNum + 3).locZ = 1000000002
end
