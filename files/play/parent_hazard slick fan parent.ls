property playfield_manager, play_manager, part, myWidth, last_step, switch, airjet_cycle, partloc, top_locz, dir
global glob

on new me, p
  part = p
  part[#behavior] = me
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  partloc = part.sprite[1].loc
  myWidth = 2
  last_step = the ticks
  switch = 0
  airjet_cycle = random(7)
  top_locz = playfield_manager.posToLocZ(point(50, 1))
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
  me.checkMiniFig()
end

on stepAnim me
  if part.state = #on then
    part.frame = (part.frame mod 4) + 1
  else
    part.frame = 1
  end if
end

on checkMiniFig me
  y = -1
  gotMinifig = 0
  airjet_height = [0, 0]
  if part.state = #on then
    repeat while 1
      fig = playfield_manager.checkFitOrMinifig(part.pos + point(1, y), #BRICK_01)
      case fig of
        0:
          exit repeat
        1:
        otherwise:
          gotMinifig = fig
          exit repeat
      end case
      y = y - 1
      airjet_height[1] = airjet_height[1] + 1
    end repeat
    y = -1
    repeat while 1
      fig = playfield_manager.checkFitOrMinifig(part.pos + point(2, y), #BRICK_01)
      case fig of
        0:
          exit repeat
        1:
        otherwise:
          gotMinifig = fig
          exit repeat
      end case
      y = y - 1
      airjet_height[2] = airjet_height[2] + 1
    end repeat
    if gotMinifig <> 0 then
      if not switch then
        SndSFX("fan")
        switch = 1
      end if
      gotMinifig.behavior.notify([#FAN: part])
    else
      switch = 0
    end if
    airjet_cycle = airjet_cycle + 1
    if airjet_cycle > 7 then
      airjet_cycle = 1
    end if
    sprs = [playfield_manager.getASprite(), playfield_manager.getASprite()]
    part[#auxSprites] = [:]
    part.auxSprites[#airjet1] = sprs[1]
    part.auxSprites[#airjet2] = sprs[2]
    repeat with i = 1 to sprs.count
      s = sprs[i]
      s.ink = 8
      if airjet_height[i] > 0 then
        s.visible = 1
        s.member = member("fanAir_" & airjet_height[i] & "_" & airjet_cycle)
        s.rect = s.member.rect
      else
        s.visible = 0
      end if
      s.loc = partloc + point((i * 15) + 2, -19)
      s.locZ = top_locz
    end repeat
  end if
end

on updatePart me
  playfield_manager.erasePiece(part.pos)
  playfield_manager.placePiece(part)
end
