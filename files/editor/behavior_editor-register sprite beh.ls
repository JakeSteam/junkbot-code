property myName
global glob

on beginSprite me
  glob.EDITOR[myName] = sprite(me.spriteNum)
end

on getPropertyDescriptionList
  return [#myName: [#comment: "Sprite name:", #format: #symbol, #default: VOID]]
end
