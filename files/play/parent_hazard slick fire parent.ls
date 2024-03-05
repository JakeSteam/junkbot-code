property playfield_manager, play_manager, part, myWidth, last_step, dir
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  myWidth = 2
  last_step = the ticks
  return me
end

on done me
  play_manager.actorDone(me)
end

on notify me, notes
  if notes[#destroyed] = 1 then
    me.done()
  else
    if not voidp(notes[#pos]) then
      part.pos = notes[#pos]
    else
      if not voidp(notes[#switch]) then
        part.state = notes[#switch]
        me.stepAnim()
        me.updatePart()
      end if
    end if
  end if
end

on stepFrame me
  me.stepAnim()
  me.updatePart()
  if part.state = #on then
    me.checkMiniFig()
  end if
end

on updatePart me
  playfield_manager.erasePiece(part.pos)
  playfield_manager.placePiece(part)
end

on stepAnim me
  if part.state = #on then
    part.frame = (part.frame mod 7) + 1
  else
    part.frame = 1
  end if
end

on checkMiniFig me
  fig = playfield_manager.checkFitOrMinifig(part.pos + point(1, -1), #BRICK_02)
  if ilk(fig) = #propList then
    SndSFX("fire")
    fig.behavior.notify([#damage: #fire])
  end if
end
