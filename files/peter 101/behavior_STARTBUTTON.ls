property my, myName
global glob

on beginSprite me
  my = sprite(me.spriteNum)
  myName = my.member.name
  my.blend = 100
end

on mouseUp me
  if not (glob[#memo] = #DidIt) then
    glob[#memo] = #show
  end if
  my.member = member(myName)
  SndMusicEnd()
  go("levels")
end

on mouseDown me
  SndSFX("h_button1")
end

on mouseWithin me
  my.member = member(myName & "_ro")
end

on mouseLeave me
  my.member = member(myName)
end
