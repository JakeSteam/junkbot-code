property mylocz

on beginSprite me
  sprite(me.spriteNum).locZ = mylocz
end

on getPropertyDescriptionList me
  return [#mylocz: [#comment: "LocZ:", #format: #integer, #default: 999999]]
end
