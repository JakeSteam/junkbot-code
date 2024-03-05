property myColor

on getPropertyDescriptionList me
  return [#myColor: [#comment: "Color:", #format: #string, #range: ["RED", "GREEN", "BLUE", "YELLOW", "BLACK", "WHITE", "GRAY"]]]
end

on mouseUp me
  global glob
  if glob.EDITOR[#edit_manager] <> VOID then
    glob.EDITOR.edit_manager.settoolcolor(myColor)
  end if
  sendAllSprites(#editor_setcolor, myColor)
end
