property s, b

on beginSprite me
  s = sprite(me.spriteNum)
  b = s.member.name
  id = the itemDelimiter
  the itemDelimiter = "_"
  delete char -30002 of b
  the itemDelimiter = id
end

on editor_setcolor me, c
  m = member(b & "_" & c)
  if m.memberNum > 0 then
    s.member = m
  else
    put b && c && #failed
  end if
end
