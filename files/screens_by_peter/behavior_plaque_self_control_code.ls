property snum, myPlaque
global glob

on beginSprite me
  snum = me.spriteNum
  myPlaque = glob[#plaque]
  glob.PLAYER[#game_manager].updatePlaque()
  sprite(snum).member = member("plaque_" & glob[#plaque])
end

on exitFrame me
  if not (myPlaque = glob[#plaque]) then
    myPlaque = glob[#plaque]
    sprite(snum).member = member("plaque_" & glob[#plaque])
  end if
end
