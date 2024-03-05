property sp, mem, highlight, mwi

on beginSprite me
  sp = sprite(me.spriteNum)
  mem = sp.member.name
  highlight = 0
end

on mouseWithin me
  sp.member = member(mem & "_x")
  mwi = 1
end

on mouseLeave me
  if not highlight then
    sp.member = member(mem)
  end if
  mwi = 0
end

on updateProp me
  mem = sp.member.name
end

on highlight me, flag
  highlight = flag
  if flag or mwi then
    sp.member = member(mem & "_x")
  else
    sp.member = member(mem)
  end if
end
