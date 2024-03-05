property Prop, myNum
global glob

on beginSprite me
  myNum = me.spriteNum
  glob[#award_obj] = me
  Prop = [:]
  Prop[#state] = #hide
  Prop[#loc] = [#Start: point(275, -190), #show: point(275, 210), #end: point(-325, 210)]
  Prop[#speed] = [#move1: [0, 40], #move2: [-40, 0]]
  Prop[#gotgold] = EMPTY
end

on dropBox me
  building = glob[#current][#building]
  level = glob[#current][#level]
  moves = glob[#current][#moves]
  gold = glob[#current][#gold]
  goalMoves = glob[#building][building][#LEVELS][level][#goal]
  gotgold = glob[#building][building][#LEVELS][level][#gold]
  data = glob[#building][building][#LEVELS][level][#moves]
  glob.PLAYER[#game_manager].TotalKeys()
  goldNum = glob.PLAYER[#game_manager].goldTotal()
  if (moves <= goalMoves) and (gotgold = 0) then
    flag = 1
    case goldNum + 1 of
      60:
        glob[#plaque] = "president"
      40:
        glob[#plaque] = "year"
      30:
        glob[#plaque] = "Month"
      20:
        glob[#plaque] = "week"
      10:
        glob[#plaque] = "day"
      otherwise:
        flag = 0
    end case
    if flag = 1 then
      Prop[#gotgold] = glob[#plaque]
      me.doGoldStuff()
    else
      me.doNextBox()
    end if
  else
    me.doNextBox()
  end if
end

on doGoldStuff me
  if (Prop[#gotgold] = EMPTY) or (Prop[#gotgold] = "welcome") then
    me.doNextBox()
  else
    sprite(myNum + 1).member = member("OfThe" & Prop[#gotgold])
    setCursor(#none)
    sendAllSprites(#getOut)
    Prop[#state] = #move1
    me.fixLocZ()
  end if
end

on doNextBox me
  glob[#BIG_MSG_OBJ].dropBox()
end

on exitFrame me
  case Prop[#state] of
    #hide:
    #move1:
      temp = me.doMove(Prop[#loc][#show], Prop[#speed][#move1])
      if temp then
        Prop[#state] = #show
        SndSFX("goldkey1")
      end if
    #show:
      setCursor(#none)
    #move2:
      temp = me.doMove(Prop[#loc][#end], Prop[#speed][#move2])
      if temp then
        Prop[#state] = #hide
        glob[#BIG_MSG_OBJ].dropBox()
        me.updateLoc(Prop[#loc][#Start])
      end if
  end case
end

on doMove me, toWhere, speed
  case Prop[#state] of
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

on updateState me, state
  Prop[#state] = state
end

on getOut me
  if not (Prop[#state] = #hide) and not (Prop[#state] = #move2) then
    Prop[#state] = #move2
  end if
end

on reportState me
  return Prop[#state]
end

on updateLoc me, newloc
  sprite(myNum).loc = newloc
  sprite(myNum + 1).loc = sprite(myNum).loc + point(0, 94)
  sprite(myNum + 2).loc = sprite(myNum).loc + point(0, 137)
end

on fixLocZ me
  sprite(myNum).locZ = 1000000000
  sprite(myNum + 1).locZ = 1000000001
  sprite(myNum + 2).locZ = 1000000001
end
