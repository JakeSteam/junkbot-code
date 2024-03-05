property m, configfield

on beginSprite me
  m = sprite(me.spriteNum).member
  m.text = "EDIT"
  configfield = member("config field")
end

on mouseUp me
  global glob
  if configfield.editable then
    m.text = "EDIT"
    configfield.editable = 0
    configfield.bgColor = rgb(128, 128, 128)
    glob.EDITOR.edit_manager.setConfig()
  else
    m.text = "COMMIT"
    configfield.editable = 1
    configfield.bgColor = rgb(256, 256, 256)
  end if
end
