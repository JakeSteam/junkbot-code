property m
global glob

on beginSprite me
  m = sprite(me.spriteNum).member
  m.hilite = (the environment).internetConnected = #offline
end

on mouseUp me
  if (the environment).internetConnected = #offline then
    m.hilite = 0
  end if
  glob.catalog.catalog_manager.localmode = m.hilite
  glob.catalog.catalog_manager.catalog()
end
