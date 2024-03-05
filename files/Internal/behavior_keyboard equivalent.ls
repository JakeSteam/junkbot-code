property mykeys, myMessage

on equiv_keydown me, k
  if mykeys contains k then
    sendSprite(me.spriteNum, myMessage)
  end if
end

on getPropertyDescriptionList me
  return [#mykeys: [#comment: "List matching keys:", #format: #string, #default: EMPTY], #myMessage: [#comment: "Message:", #format: #symbol, #default: #mouseUp]]
end
