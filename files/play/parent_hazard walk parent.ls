property playfield_manager, play_manager, part, myWidth, speed, last_step, dir
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  myWidth = 2
  if part.state = "WALK_L" then
    dir = -1
  else
    dir = 1
  end if
  speed = 4
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
    if notes[#pos] <> VOID then
      part.pos = notes[#pos]
    end if
  end if
end

on step me
  playfield_manager.erasePiece(part.pos)
  pos = part.pos + point(dir, 0)
  Ok = 0
  fg = playfield_manager.checkFitOrMinifig(pos, part.type)
  if fg = 1 then
    ms = the milliSeconds
    if playfield_manager.checkFloor(pos, myWidth) > 1 then
      Ok = 1
      part.pos = pos
    end if
  end if
  if not Ok then
    dir = -dir
    if dir > 0 then
      part.state = #WALK_R
    else
      part.state = #walk_l
    end if
  end if
  if ilk(fg) = #propList then
    SndSFX("robottouch4")
    fg.behavior.notify([#damage: #walker])
  end if
  playfield_manager.placePiece(part)
end

on stepAnim me
  if part.frame = 1 then
    part.frame = 2
  else
    part.frame = 1
  end if
end

on stepFrame me
  if part.frame = 2 then
    step(me)
  end if
  playfield_manager.erasePiece(part.pos)
  me.stepAnim()
  playfield_manager.placePiece(part)
end
