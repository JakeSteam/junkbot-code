property sp, mem, highlight, mwi, dir, hof_sprite

on getPropertyDescriptionList me
  return [#dir: [#format: #symbol, #range: [#prev, #next], #default: #prev]]
end

on beginSprite me
  sp = sprite(me.spriteNum)
  mem = sp.member.name
  highlight = 0
  hof_sprite = sprite(8)
end

on mouseWithin me
  if hof_sprite.pageP(dir) then
    sp.member = member(mem & "_x")
    mwi = 1
  end if
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

on mouseDown me
  if hof_sprite.pageP(dir) then
    SndSFX("h_button1")
  end if
end

on mouseUp me
  if hof_sprite.pageP(dir) then
    hof_sprite.page(dir)
  end if
end
