property playfield_manager, play_manager, part, last_jump, active_ticks, dir, paused
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  last_jump = 0
  return me
end

on done me
  play_manager.actorDone(me)
end

on pause me
  paused = 1
end

on resume me
  paused = 0
  part.state = #dormant
  part.frame = 1
end

on notify me, notes
  if notes[#destroyed] = 1 then
    me.done()
  else
    if notes[#pos] <> VOID then
      part.pos = notes[#pos]
    else
      if notes[#stop] = 1 then
        me.pause()
      else
        if notes[#Start] = 1 then
          me.resume()
        end if
      end if
    end if
  end if
end

on stepFrame me
  if paused = 1 then
    return 
  end if
  playfield_manager.erasePiece(part.pos)
  me.stepAnim()
  me.checkMiniFig()
  playfield_manager.placePiece(part)
end

on stepAnim me
end

on checkMiniFig me
  fig = playfield_manager.checkFitOrMinifig(part.pos + point(0, -1), #BRICK_01)
  fig2 = playfield_manager.checkFitOrMinifig(part.pos + point(1, -1), #BRICK_01)
  if (fig = fig2) and (ilk(fig) = #propList) and ((the ticks - last_jump) > 60) then
    SndSFX("jump3")
    fig.behavior.notify([#jump: part])
    part.state = #Active
    part.frame = 1
    last_jump = the ticks
  else
    if part.state = #Active then
      part.frame = part.frame + 1
      if part.frame > 4 then
        part.frame = 1
        part.state = #dormant
      end if
    end if
  end if
end
