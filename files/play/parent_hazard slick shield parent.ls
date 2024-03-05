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
end

on done me
  play_manager.actorDone(me)
end

on stepFrame me
  if part.state = #on then
    me.checkMiniFig()
  end if
end

on checkMiniFig me
  fig = playfield_manager.checkFitOrMinifig(part.pos + point(0, -1), #BRICK_01)
  fig2 = playfield_manager.checkFitOrMinifig(part.pos + point(1, -1), #BRICK_01)
  if (fig = fig2) and (ilk(fig) = #propList) then
    fig.behavior.notify([#SHIELD: 1])
    part.state = #off
    me.redrawPart()
  end if
end

on redrawPart me
  playfield_manager.erasePiece(part.pos)
  playfield_manager.placePiece(part)
end
