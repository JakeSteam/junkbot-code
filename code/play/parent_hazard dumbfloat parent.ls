property part, play_manager, playfield_manager, pLoc, pBaseLoc, pDir, pSpeed, pCounter, pLocZ, pTarget, pTimer
global glob

on new me, p
  part = p
  if part.state = #L then
    pDir = [-1, 0]
  else
    pDir = [1, 0]
  end if
  pSpeed = 2
  pCounter = 0
  pTarget = 0
  play_manager = glob.PLAYER.play_manager
  playfield_manager = play_manager.playfield_manager
  return me
end

on stepFrame me
  pCounter = (pCounter + 1) mod pSpeed
  if pCounter = 0 then
    moveMe(me)
  end if
  if pTarget and (the timer > (pTimer + 120)) then
    pTarget = 0
  end if
end

on stepAnim me
  part.frame = (part.frame mod 2) + 1
end

on moveMe me
  glob.PLAYER[#minifigHit] = VOID
  if pDir[1] < 0 then
    part.state = #L
  else
    part.state = #r
  end if
  if part.frame = 1 then
    part.frame = 2
  else
    part.frame = 1
  end if
  playfield_manager.erasePiece(part.pos)
  pos = part.pos + pDir
  fg = playfield_manager.checkFitMiniFigHit(pos, part.type)
  Ok = fg
  if not Ok then
    flag = #TURN
  else
    part.pos = pos
  end if
  mW = playfield_manager.pf_size[1]
  mH = playfield_manager.pf_size[2]
  if (pos[1] > mW) or (pos[1] < 1) or (pos[2] > mH) or (pos[2] < 1) then
    flag = #TURN
    pos = part.pos
  else
    if not voidp(playfield_manager.getPart(pos)) then
      flag = #TURN
      pos = part.pos
    end if
  end if
  if not voidp(glob.PLAYER[#minifigHit]) then
    SndSFX("robottouch4")
    glob.PLAYER.minifigHit.behavior.notify([#damage: #floater])
  end if
  if flag = #TURN then
    pDir = -pDir
  else
    pLoc = pLoc + pDir
  end if
  playfield_manager.placePiece(part)
end
