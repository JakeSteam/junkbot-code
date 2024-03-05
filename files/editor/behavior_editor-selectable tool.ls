property mytoolmode, mytoolparam, mytoolstate, mytoolframe, s

on beginSprite me
  s = sprite(me.spriteNum)
end

on mouseUp me
  global glob
  if glob.EDITOR[#edit_manager] <> VOID then
    glob.EDITOR[#edit_manager].settoolmode(symbol(mytoolmode), symbol(mytoolparam), symbol(mytoolstate), integer(mytoolframe))
  end if
  if glob.EDITOR[#tool_highlight_box] <> VOID then
    glob.EDITOR[#tool_highlight_box].highlight(s)
  end if
end

on getPropertyDescriptionList me
  return [#mytoolmode: [#comment: "Tool mode:", #format: #symbol, #default: #none], #mytoolparam: [#comment: "Tool param:", #format: #symbol, #default: VOID], #mytoolstate: [#comment: "Tool state:", #format: #symbol, #default: VOID], #mytoolframe: [#comment: "Tool frame:", #format: #integer, #default: VOID]]
end
