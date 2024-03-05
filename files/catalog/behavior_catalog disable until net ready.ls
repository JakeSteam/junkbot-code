property s, m

on new me
  s = sprite(me.spriteNum)
  m = s.member
end

on netReady me, flag
  if flag = 1 then
    s.blend = 100
  else
    s.blend = 30
  end if
end
