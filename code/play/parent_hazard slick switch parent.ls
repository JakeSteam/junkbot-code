property play_manager, playfield_manager, part, stepped_on
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  stepped_on = 0
  return me
end

on notify me, args
  if not voidp(args[#switch]) then
    part.state = args[#switch]
    me.redrawPart()
  end if
end

on done me
  play_manager.actorDone(me)
end

on stepFrame me
  me.checkMiniFig()
end

on checkMiniFig me
  fig = playfield_manager.checkFitOrMinifig(part.pos + point(0, -1), #BRICK_01)
  fig2 = playfield_manager.checkFitOrMinifig(part.pos + point(1, -1), #BRICK_01)
  if (fig = fig2) and (ilk(fig) = #propList) then
    if not stepped_on then
      stepped_on = 1
      if part.state = #off then
        part.state = #on
        SndSFX("switch_on")
        SndSFX("switch_click")
      else
        part.state = #off
        SndSFX("switch_off")
        SndSFX("switch_click")
      end if
      play_manager.doSwitch([#label: part.label, #state: part.state])
      part.frame = 1
    end if
  else
    stepped_on = 0
  end if
end

on redrawPart me
  playfield_manager.erasePiece(part.pos)
  playfield_manager.placePiece(part)
end
