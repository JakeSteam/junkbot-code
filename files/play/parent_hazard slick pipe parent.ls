property playfield_manager, play_manager, part, myWidth, last_step, last_drip, drip_cycle, myDrip, dir
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  part[#auxSprites] = [:]
  myWidth = 2
  last_step = the ticks
  last_drip = the ticks + random(240)
  drip_cycle = random(3)
  return me
end

on done me
  play_manager.actorDone(me)
  if not voidp(myDrip) then
    myDrip.done(me)
  end if
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

on stepFrame me
  playfield_manager.erasePiece(part.pos)
  me.stepAnim()
  if not voidp(myDrip) then
    myDrip.stepFrame()
  end if
  playfield_manager.placePiece(part)
end

on stepAnim me
  t = the ticks
  case part.state of
    #DRY:
      if drip_cycle = 1 then
        drip_time = 160 + random(40)
      else
        drip_time = 80 + random(20)
      end if
      if ((t - last_drip) > drip_time) and voidp(myDrip) then
        part.state = #wet
        last_drip = t
        drip_cycle = drip_cycle + 1
        if drip_cycle = 4 then
          drip_cycle = 1
        end if
      end if
      part.frame = 1
    #wet:
      part.frame = part.frame + 1
      if part.frame = 8 then
        part.frame = 1
        part.state = #DRY
        myDrip = new(script("hazard drip parent"), me, part)
      end if
  end case
end

on dripDone me, d
  myDrip = VOID
end

on checkMiniFig me
  fig = playfield_manager.checkFitOrMinifig(part.pos + point(1, -1), #BRICK_02)
  if ilk(fig) = #propList then
    SndSFX("fire")
    fig.behavior.notify([#damage: #drip])
  end if
end
