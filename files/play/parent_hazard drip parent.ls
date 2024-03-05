property playfield_manager, play_manager, part, pipe, s, driploc, dripstate, top_locz
global glob

on new me, mypipe, mypart
  pipe = mypipe
  part = mypart
  dripstate = #falling
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  top_locz = playfield_manager.posToLocZ(point(50, 1))
  driploc = playfield_manager.getLoc(part.pos) + point(0, 17)
  return me
end

on done me
  pipe.dripDone(me)
end

on stepFrame me
  s = playfield_manager.getASprite()
  part.auxSprites[#myDrip] = s
  s.ink = 8
  s.visible = 1
  if dripstate = #falling then
    newloc = driploc + point(0, 18)
    posloc = playfield_manager.getPos(newloc)
    if voidp(posloc) then
      fit = 0
    else
      fit = playfield_manager.checkFitOrMinifig(posloc[1], #BRICK_02)
    end if
    if fit = 1 then
      driploc = newloc
    else
      dripstate = 1
      if ilk(fit) = #propList then
        fit.behavior.notify([#damage: #drip])
        SndSFX("electricity1")
      else
        SndSFX("drip" & random(3))
      end if
    end if
    s.member = member("drip_falling_1")
    s.rect = s.member.rect
  else
    s.member = member("drip_splashing_" & dripstate)
    s.rect = s.member.rect
    dripstate = dripstate + 1
    if dripstate > 5 then
      me.done()
    end if
  end if
  s.loc = driploc
  s.locZ = top_locz
end
