property snum, roLineNum
global glob

on beginSprite me
  snum = me.spriteNum - 1
  glob[#levelList] = me
end

on mouseWithin me
  roLineNum = (the mouseV - 87) / 21
  if roLineNum > 14 then
    exit
  end if
  sprite(snum).locV = 87 + (roLineNum * 21)
end

on mouseDown me
  roLineNum = (the mouseV - 87) / 21
  if (roLineNum > 14) or (roLineNum < 0) then
    exit
  end if
  glob.current.level = roLineNum + 1
  SndSFX("jump2")
  glob.PLAYER.game_manager.startGame()
end
