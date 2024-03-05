property snum
global glob

on beginSprite me
  glob[#boss] = me
  snum = me.spriteNum
  glob.PLAYER[#game_manager].TotalKeys()
  glob[#memo] = #show
  if glob[#rankdata][#keys] > 0 then
    glob[#memo] = #DidIt
  end if
  if glob[#memo] = #show then
    sprite(snum).loc = point(233, 209)
    sprite(snum + 1).loc = point(27, 23)
    sprite(snum + 2).loc = point(33, 104)
    sprite(snum + 3).loc = point(234, 354)
    glob[#memo] = #DidIt
  else
    me.hide()
  end if
end

on hide me
  sprite(snum).loc = point(1000, 209)
  sprite(snum + 1).loc = point(1000, 23)
  sprite(snum + 2).loc = point(1000, 104)
  sprite(snum + 3).loc = point(1000, 354)
  updateStage()
end
