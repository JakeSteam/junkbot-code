global glob

on beginSprite me
  if glob.authorMode then
    nothing()
  else
    sprite(me.spriteNum).loc = point(1000, 1000)
  end if
end
