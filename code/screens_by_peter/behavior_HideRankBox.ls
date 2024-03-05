global glob

on beginSprite me
  glob.PLAYER[#game_manager].TotalKeys()
  if glob[#rankdata][#keys] = glob[#hof] then
    sprite(me.spriteNum).loc = point(1000, 1000)
  else
    sprite(me.spriteNum).loc = point(487, 220)
  end if
end
