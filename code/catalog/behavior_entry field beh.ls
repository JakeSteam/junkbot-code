property fld, maxchars

on new me
  fld = sprite(me.spriteNum).member
end

on keyDown me
  k = the key
  if k = RETURN then
    return 
  end if
  if (fld.text.length >= maxchars) and (the selection = EMPTY) and (charToNum(k) <> 8) then
    return 
  end if
  pass()
end

on getPropertyDescriptionList me
  return [#maxchars: [#comment: "Max chars:", #format: #integer, #default: 30]]
end
