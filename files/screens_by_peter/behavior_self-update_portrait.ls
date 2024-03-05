global glob

on beginSprite me
  if glob[#rankdata][#keys] < glob[#hof] then
    sprite(me.spriteNum).member = member("portrait_1")
    sprite(me.spriteNum).width = 148
    sprite(me.spriteNum).height = 130
    sprite(me.spriteNum).loc = point(566, 88)
  else
    sprite(me.spriteNum).member = member("portrait_2")
    sprite(me.spriteNum).width = 135
    sprite(me.spriteNum).height = 120
    sprite(me.spriteNum).loc = point(560, 83)
  end if
end
