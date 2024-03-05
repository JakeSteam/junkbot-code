property Prop, myNum
global glob

on beginSprite me
  myNum = me.spriteNum
  glob[#hint_obj] = me
  Prop = [:]
  Prop[#state] = #hide
  Prop[#loc] = [#Start: point(275, -125), #show: point(275, 215), #end: point(-195, 215)]
  Prop[#speed] = [#move1: [0, 40], #move2: [-40, 0]]
end

on dropBox me
  building = glob[#current][#building]
  level = glob[#current][#level]
  hint = glob.building[building].LEVELS[level].info.hint
  member("hint_text").text = "level " & level & " hint:" & RETURN & hint
  Prop[#state] = #move1
  Prop[#gameState] = glob.PLAYER.play_manager.activeState
  glob.PLAYER.play_manager.activeState = #pause
end

on updateState me, state
  Prop[#state] = state
end

on reportState me
  return Prop[#state]
end

on exitFrame me
  case Prop[#state] of
    #hide:
    #move1:
      temp = me.doMove(Prop[#loc][#show], Prop[#speed][#move1])
      if temp then
        Prop[#state] = #show
      end if
    #show:
      setCursor(#none)
    #move2:
      temp = me.doMove(Prop[#loc][#end], Prop[#speed][#move2])
      if temp then
        Prop[#state] = #done
        me.updateLoc(Prop[#loc][#Start])
        if Prop[#gameState] = #pause then
          gbutton(#main_play)
        else
          glob.PLAYER.play_manager.activeState = #Run
        end if
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

on updateLoc me, newloc
  sprite(myNum).loc = newloc
  sprite(myNum + 1).loc = sprite(myNum).loc + point(0, 53)
  sprite(myNum + 2).loc = sprite(myNum).loc + point(-139, -83)
end

on fixLocZ me
end

on mouseUp me
  Prop[#state] = #move2
end

on getOut me
  if Prop[#state] = #show then
    Prop[#state] = #move2
  end if
end
