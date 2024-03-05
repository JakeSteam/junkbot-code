property kind, s, m
global glob

on beginSprite me
  s = sprite(me.spriteNum)
  m = s.member
end

on mouseDown me
  glob.EDITOR.edit_manager.bg_edit_item(kind, m)
end

on getPropertyDescriptionList
  L = [:]
  L[#kind] = [#comment: "Kind", #format: #symbol, #range: [#backdrop, #decal], #default: #decal]
  return L
end
