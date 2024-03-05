property playfield_manager, play_manager, part, myWidth, speed, climb_up, jump_over, last_step, dir, climbstart, oldhoriz
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  myWidth = 2
  if part.state = #walk_l then
    dir = point(-1, 0)
  else
    if part.state = #WALK_R then
      dir = point(1, 0)
    else
      if part.state = #FLOAT_UP then
        dir = point(0, -1)
      else
        dir = point(0, 1)
      end if
    end if
  end if
  oldhoriz = 1
  speed = 4
  climb_up = 3
  jump_over = 1
  climbstart = part.pos[2]
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
  glob.PLAYER[#minifigHit] = VOID
  playfield_manager.erasePiece(part.pos)
  case part.state of
    #FLOAT_UP:
      tdir = point(oldhoriz, 0)
      if (part.pos[2] = climbstart) and playfield_manager.checkFitMiniFigHit(part.pos + dir, part.type) then
        part.pos = part.pos + dir
      else
        if playfield_manager.checkFitMiniFigHit(part.pos + tdir, part.type) and (playfield_manager.checkFloor(part.pos + tdir, myWidth) > 0) then
          dir = tdir
          part.pos = part.pos + dir
        else
          if playfield_manager.checkFitMiniFigHit(part.pos - tdir, part.type) and (playfield_manager.checkFloor(part.pos - tdir, myWidth) > 0) then
            dir = -tdir
            part.pos = part.pos + dir
          else
            if (climbstart - part.pos[2]) >= climb_up then
              dir = -dir
            else
              if playfield_manager.checkFitMiniFigHit(part.pos + dir, part.type) then
                part.pos = part.pos + dir
              else
                dir = -dir
              end if
            end if
          end if
        end if
      end if
    #FLOAT_DOWN:
      tdir = point(oldhoriz, 0)
      if playfield_manager.checkFitMiniFigHit(part.pos + dir, part.type) then
        part.pos = part.pos + dir
      else
        if playfield_manager.checkFitMiniFigHit(part.pos + tdir, part.type) then
          dir = tdir
          part.pos = part.pos + dir
        else
          if playfield_manager.checkFitMiniFigHit(part.pos - tdir, part.type) then
            dir = -tdir
            part.pos = part.pos + dir
          else
            dir = point(0, -1)
            climbstart = part.pos[2]
          end if
        end if
      end if
    #walk_l, #WALK_R:
      if (playfield_manager.checkFloor(part.pos, myWidth) = 0) and playfield_manager.checkFitMiniFigHit(part.pos + point(0, 1), part.type) then
        oldhoriz = dir[1]
        dir = point(0, 1)
        part.pos = part.pos + dir
      else
        if not playfield_manager.checkFitMiniFigHit(part.pos + dir, part.type) then
          oldhoriz = dir[1]
          dir = point(0, -1)
          climbstart = part.pos[2]
        else
          part.pos = part.pos + dir
        end if
      end if
  end case
  if dir[1] < 0 then
    part.state = #walk_l
  else
    if dir[1] > 0 then
      part.state = #WALK_R
    else
      if dir[2] < 0 then
        part.state = #FLOAT_UP
      else
        part.state = #FLOAT_DOWN
      end if
    end if
  end if
  if not voidp(glob.PLAYER[#minifigHit]) then
    SndSFX("robottouch4")
    glob.PLAYER[#minifigHit].behavior.notify([#damage: #climber])
  end if
  playfield_manager.placePiece(part)
end

on stepAnim me
  part.frame = (part.frame mod 6) + 1
end

on stepFrame me
  if part.frame = 6 then
    step(me)
  end if
  playfield_manager.erasePiece(part.pos)
  me.stepAnim()
  playfield_manager.placePiece(part)
end
