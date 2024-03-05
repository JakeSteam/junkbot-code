property Prop, myNum
global glob

on beginSprite me
  myNum = me.spriteNum
  glob[#title_obj] = me
  Prop = [:]
  Prop[#state] = #hide
  Prop[#loc] = [#Start: point(100, -190), #show: point(100, 130), #end: point(-300, 130)]
  Prop[#speed] = [#move1: [0, 40], #move2: [-40, 0]]
  Prop[#sprites] = [#icon: myNum + 1, #num: myNum + 2, #title: myNum + 3]
end

on updateData me, data, callback
  sprite(Prop[#sprites][#icon]).member = member("building_icon_" & data[1])
  sprite(Prop[#sprites][#num]).member = member("building_title_" & data[1])
  member("level_title").text = "LEVEL " & data[2] & ": " & data[3]
  Prop[#state] = #move1
  me.fixLocZ()
  Prop[#callback] = callback
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
        Prop[#time] = the timer
        glob[#movenum].updateMovesNum()
      end if
    #show:
      if the timer > (Prop[#time] + 120) then
        Prop[#state] = #move2
      end if
    #move2:
      temp = me.doMove(Prop[#loc][#end], Prop[#speed][#move2])
      if temp then
        Prop[#state] = #done
        me.updateLoc(Prop[#loc][#Start])
        if not voidp(Prop[#callback]) then
          Prop.callback.object.callback(Prop.callback.parameter)
          Prop.callback = VOID
        end if
      end if
  end case
end

on getOut me
  if not (Prop[#state] = #hide) and not (Prop[#state] = #move2) then
    Prop[#state] = #move2
  end if
end

on doMove me, toWhere, speed
  case Prop[#state] of
    #move1:
      sprite(myNum).locH = Prop[#loc][#show][1]
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
  sprite(Prop[#sprites][1]).loc = sprite(myNum).loc + point(48, 74) + point(30, -20)
  sprite(Prop[#sprites][2]).loc = sprite(myNum).loc + point(117, 51)
  sprite(Prop[#sprites][3]).loc = sprite(myNum).loc + point(49, 79)
end

on fixLocZ me
  sprite(myNum).locZ = 1000000000
  sprite(Prop[#sprites][1]).locZ = 1000000001
  sprite(Prop[#sprites][2]).locZ = 1000000001
  sprite(Prop[#sprites][3]).locZ = 1000000001
end

on mouseUp me
  Prop[#state] = #move2
end
