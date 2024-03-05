property playfield_manager, play_manager, part, myWidth, speed, step_up, step_down, fall_down, jump_over, last_step, painmode, painTicks, frameMax, frameCounter, fanMode, mode, SHIELD, shieldticks, cause_of_death, jump_trajectory_r, jump_index, dir
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  painmode = 0
  fanMode = 0
  mode = #WALK
  myWidth = 2
  SHIELD = 0
  shieldticks = VOID
  if part.state = #WALK_R then
    dir = 1
  else
    if part.state = #walk_l then
      dir = -1
    else
      dir = (random(2) * 2) - 3
    end if
  end if
  speed = 4
  step_up = 1
  step_down = 1
  fall_down = 0
  jump_over = 1
  last_step = the ticks
  frameMax = 10
  frameCounter = 1
  jump_trajectory_r = [[#v: [0, -1], #o: point(4, 0)], [#v: [1, -1], #o: point(-2, 0)], [#v: [1, -1], #o: point(0, 0)], [#v: [1, 0], #o: point(0, 0)], [#v: [1, 1], #o: point(2, 0)], [#v: [1, 1], #o: point(-4, 0)], [#v: [0, 1], #o: point(0, 0)]]
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
      if not voidp(notes[#damage]) then
        if mode <> #DEAD then
          if SHIELD = 1 then
            if voidp(shieldticks) then
              shieldticks = the ticks + 120
            end if
          else
            frameCounter = 1
            part.frame = 1
            mode = #DEAD
            cause_of_death = notes[#damage]
            case cause_of_death of
              #drip:
                part.state = #DEAD_DRIP
              otherwise:
                part.state = #DEAD_GENERIC
            end case
          end if
        end if
      else
        if not voidp(notes[#FAN]) and voidp(cause_of_death) then
          fanMode = 1
        else
          if not voidp(notes[#jump]) then
            if mode <> #jump then
              mode = #jump
              jump_index = 1
            end if
          else
            if not voidp(notes[#SHIELD]) then
              SndSFX("h_powerup1")
              SndSFX("shieldon2")
              mode = #SHIELDON
              part.frame = 1
              frameCounter = 1
              if dir < 0 then
                part.state = #SHIELDON_L
              else
                part.state = #SHIELDON_R
              end if
              SHIELD = 1
              shieldticks = VOID
            end if
          end if
        end if
      end if
    end if
  end if
end

on step me
  pos = part.pos + point(dir, 0)
  Ok = 0
  fg = playfield_manager.checkFitOrGoal(pos, part.type)
  if fg <> 0 then
    if playfield_manager.checkFloor(pos, 2) then
      Ok = 1
      me.doWalkState()
      part.pos = pos
    end if
  end if
  if not Ok then
    repeat with s = 1 to step_down
      pos = part.pos + point(dir, 0) + point(0, s)
      fg = playfield_manager.checkFitOrGoal(pos, part.type)
      if fg <> 0 then
        if playfield_manager.checkFloor(pos, 2) then
          Ok = 1
          me.doWalkState()
          part.pos = pos
          exit repeat
        end if
      end if
    end repeat
  end if
  if not Ok then
    repeat with s = 1 to step_up
      pos = part.pos + point(dir, 0) + point(0, -s)
      fg = playfield_manager.checkFitOrGoal(pos, part.type)
      if fg <> 0 then
        if playfield_manager.checkFloor(pos, 2) then
          Ok = 1
          me.doWalkState()
          part.pos = pos
          exit repeat
        end if
      end if
    end repeat
  end if
  if not Ok then
    dir = -dir
    me.doWalkState()
    SndSFX("turn1")
  end if
  if ilk(fg) = #propList then
    SndSFX("garbage1")
    SndSFX("eat1")
    SndSFX("h_misc_1")
    mode = #EAT
    part.frame = 1
    if dir < 0 then
      if SHIELD = 1 then
        part.state = #SHIELDEAT_L
      else
        part.state = #EAT_L
      end if
    else
      if SHIELD = 1 then
        part.state = #SHIELDEAT_R
      else
        part.state = #EAT_R
      end if
    end if
    playfield_manager.erasePiece(fg.pos)
  end if
end

on doWalkState me
  if dir < 0 then
    if SHIELD = 1 then
      if not voidp(shieldticks) then
        if (integer((shieldticks - the ticks) / 6) mod 2) = 1 then
          part.state = #walk_l
        else
          part.state = #SHIELDWALK_L
        end if
      else
        part.state = #SHIELDWALK_L
      end if
    else
      part.state = #walk_l
    end if
  else
    if SHIELD = 1 then
      if not voidp(shieldticks) then
        if (integer((shieldticks - the ticks) / 10) mod 2) = 1 then
          part.state = #WALK_R
        else
          part.state = #SHIELDWALK_R
        end if
      else
        part.state = #SHIELDWALK_R
      end if
    else
      part.state = #WALK_R
    end if
  end if
end

on stepAnim me
  part.frame = frameCounter
  frameCounter = frameCounter + 1
  if frameCounter > frameMax then
    frameCounter = 1
  end if
end

on fanAnim me
  pos = part.pos + point(0, -1)
  fit = playfield_manager.checkFit(pos, part.type)
  if fit then
    part.pos = pos
  else
  end if
end

on fallAnim me
  if not playfield_manager.checkFloor(part.pos, 2) then
    pos = part.pos + point(0, 1)
    if playfield_manager.checkFit(pos, part.type) then
      part.pos = pos
    else
    end if
    if (mode <> #FALL) and (mode <> #DEAD) then
      SndSFX("fall")
      mode = #FALL
    end if
    return 1
  else
    if mode = #FALL then
      mode = #WALK
    end if
    return 0
  end if
end

on jumpAnim me
  if jump_index > jump_trajectory_r.count then
    if mode <> #FALL then
      SndSFX("fall")
    end if
    mode = #FALL
    part[#pixelOffset] = VOID
  else
    traj = jump_trajectory_r[jump_index].duplicate()
    if dir = 0 then
      dir = (random(2) * 2) - 3
      put "jumping without a known direction!"
    end if
    traj.v[1] = traj.v[1] * dir
    traj.o[1] = traj.o[1] * dir
    pos = part.pos + traj.v
    if playfield_manager.checkFit(pos, part.type) then
      part.pos = pos.duplicate()
      part[#pixelOffset] = traj.o
      if playfield_manager.checkFloor(part.pos, 2) then
        mode = #WALK
        part[#pixelOffset] = VOID
      end if
    else
      if mode <> #FALL then
        SndSFX("fall")
        SndSFX("headbonk1")
      end if
      mode = #FALL
      part[#pixelOffset] = VOID
    end if
    jump_index = jump_index + 1
  end if
end

on stepFrame me
  playfield_manager.erasePiece(part.pos)
  if ((mode = #WALK) or (mode = #FAN)) and (part.frame = 1) and not voidp(shieldticks) then
    if the ticks > shieldticks then
      SHIELD = 0
      SndSFX("h_powerdown3", VOID, 125)
      part.frame = 1
      frameCounter = 1
      shieldticks = VOID
    end if
  end if
  if mode = #jump then
    me.jumpAnim()
  else
    me.stepAnim()
    if fanMode then
      me.fanAnim()
    else
      if me.fallAnim() then
        nothing()
      end if
    end if
    if mode = #EAT then
      if dir < 0 then
        if SHIELD = 1 then
          part.state = #SHIELDEAT_L
        else
          part.state = #EAT_L
        end if
      else
        if SHIELD = 1 then
          part.state = #SHIELDEAT_R
        else
          part.state = #EAT_R
        end if
      end if
      frameMax = 19
      if frameCounter = frameMax then
        part.frame = 1
        frameCounter = 1
        mode = #WALK
        me.doWalkState()
        play_manager.addStatus(#goals, 1)
      end if
    else
      if (mode = #SHIELDON) or (mode = #SHIELDOFF) then
        if mode = #SHIELDON then
          frameMax = 14
        else
          frameMax = 11
        end if
        if frameCounter >= (frameMax - 1) then
          frameCounter = 1
          part.frame = 1
          mode = #WALK
          frameMax = 10
          me.doWalkState()
        end if
      else
        if ((mode = #WALK) or (mode = #FALL)) and not fanMode then
          frameMax = 10
          if mode = #WALK then
            if frameCounter = 6 then
              step(me)
            else
              if frameCounter = 1 then
                step(me)
              end if
            end if
          end if
          if 1 or not voidp(shieldticks) then
            me.doWalkState()
          end if
        else
          if mode = #DEAD then
            frameMax = 13
            if frameCounter >= (frameMax - 1) then
              part.frame = 1
              frameCounter = 1
              frameMax = 1
              part.state = #DEAD_STILL
              play_manager.addStatus(#damage, 1)
            end if
          end if
        end if
      end if
    end if
  end if
  if part.frame > frameMax then
    part.frame = frameMax
  end if
  playfield_manager.placePiece(part)
  fanMode = 0
end
