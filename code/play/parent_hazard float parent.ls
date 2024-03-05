property part, play_manager, playfield_manager, pLoc, pBaseLoc, pDir, pSpeed, pCounter, pLocZ, pTarget, pTimer
global glob

on new me, p
  part = p
  pDir = [1, 0]
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
  if pTarget then
    part.state = #Active
  else
    part.state = #inactive
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
  x = pos[1]
  y = pos[2]
  repeat with r = x to mW
    myObj = playfield_manager.getPart(point(r, y))
    if voidp(myObj) then
      next repeat
    end if
    myPartType = myObj[#type]
    if not (myPartType = #MINIFIG) then
      exit repeat
      next repeat
    end if
    if myPartType = #MINIFIG then
      pTarget = 1
      pTimer = the timer
      pDir = [1, 0]
      SndSFX("siren")
      flag = VOID
    end if
  end repeat
  repeat with r = x down to 1
    myObj = playfield_manager.getPart(point(r, y))
    if voidp(myObj) then
      next repeat
    end if
    myPartType = myObj[#type]
    if not (myPartType = #MINIFIG) then
      exit repeat
      next repeat
    end if
    if myPartType = #MINIFIG then
      pTarget = 1
      pTimer = the timer
      pDir = [-1, 0]
      SndSFX("siren")
      flag = VOID
    end if
  end repeat
  repeat with c = y to mH
    myObj = playfield_manager.getPart(point(x, c))
    if voidp(myObj) then
      next repeat
    end if
    myPartType = myObj[#type]
    if not (myPartType = #MINIFIG) then
      exit repeat
      next repeat
    end if
    if myPartType = #MINIFIG then
      pTarget = 1
      pTimer = the timer
      pDir = [0, 1]
      SndSFX("siren")
      flag = VOID
    end if
  end repeat
  repeat with c = y down to 1
    myObj = playfield_manager.getPart(point(x, c))
    if voidp(myObj) then
      next repeat
    end if
    myPartType = myObj[#type]
    if not (myPartType = #MINIFIG) then
      exit repeat
      next repeat
    end if
    if myPartType = #MINIFIG then
      pTarget = 1
      pTimer = the timer
      pDir = [0, -1]
      SndSFX("siren")
      flag = VOID
    end if
  end repeat
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
