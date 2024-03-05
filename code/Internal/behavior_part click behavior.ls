property part
global glob

on mouseEnter me
  if voidp(glob.PLAYER[#partclick_recipient]) then
    return 
  end if
  glob.PLAYER.partclick_recipient.partclick(part, #mouseEnter)
end

on mouseWithin me
  me.mouseEnter()
end

on mouseLeave me
  if voidp(glob.PLAYER[#partclick_recipient]) then
    return 
  end if
  glob.PLAYER.partclick_recipient.partclick(part, #mouseLeave)
end

on new me, p
  part = p
  return me
end
