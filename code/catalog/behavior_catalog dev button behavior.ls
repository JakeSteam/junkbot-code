property m
global glob

on beginSprite me
  m = sprite(me.spriteNum).member
  m.hilite = 0
  glob.catalog.catalog_manager.database = "alpha"
end

on mouseUp me
  if m.hilite then
    glob.catalog.catalog_manager.database = "dev"
  else
    glob.catalog.catalog_manager.database = "alpha"
  end if
  glob.catalog.catalog_manager.catalog()
end
