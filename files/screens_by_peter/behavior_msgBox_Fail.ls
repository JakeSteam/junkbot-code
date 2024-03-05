property Prop, myNum
global glob

on beginSprite me
  myNum = me.spriteNum
  glob[#fail_msg_obj] = me
  Prop = [:]
  Prop[#state] = #hide
  Prop[#loc] = [#Start: point(100, -190), #show: point(100, 130), #end: point(-300, 130)]
  Prop[#speed] = [#move1: [0, 40], #move2: [-40, 0]]
  Prop[#sprites] = [#ouch: myNum + 1, #but1: myNum + 2, #but2: myNum + 3, #but3: myNum + 4, #msg: myNum + 5]
end

on updateData me
  msg = ["I hate Mondays.", "I knew that was going to happen.", "Why me?", "There's got to be a better way."]
  member("fail_msg").text = msg[random(msg.count)]
  setCursor(#none)
  sendAllSprites(#getOut)
  Prop[#state] = #move1
  me.fixLocZ()
end

on exitFrame me
  case Prop[#state] of
    #hide:
    #move1:
      temp = me.doMove(Prop[#loc][#show], Prop[#speed][#move1])
      if temp then
        Prop[#state] = #show
        if random(2) = 1 then
          SndSFX("voice_ouch")
        else
          SndSFX("voice_uhoh")
        end if
      end if
    #show:
      setCursor(#none)
    #move2:
      temp = me.doMove(Prop[#loc][#end], Prop[#speed][#move2])
      if temp then
        Prop[#state] = #hide
        me.updateLoc(Prop[#loc][#Start])
        if not voidp(Prop[#callback]) then
          Prop.callback.object.callback(Prop.callback.parameter)
          Prop.callback = VOID
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

on getOut me
  if not (Prop[#state] = #hide) and not (Prop[#state] = #move2) then
    Prop[#state] = #move2
  end if
end

on updateState me, state, callback
  Prop[#callback] = callback
  Prop[#state] = state
end

on reportState me
  return Prop[#state]
end

on updateLoc me, newloc
  sprite(myNum).loc = newloc
  repeat with sn = 1 to 4
    sprite(Prop[#sprites][sn]).loc = sprite(myNum).loc
  end repeat
  sprite(Prop[#sprites][5]).loc = sprite(myNum).loc + point(77, 50)
end

on fixLocZ me
  sprite(myNum).locZ = 1000000000
  repeat with sn in Prop[#sprites]
    sprite(sn).locZ = 1000000001
  end repeat
end
