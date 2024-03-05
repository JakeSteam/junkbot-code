global glob

on beginSprite me
  if glob[#rankdata][#keys] < glob[#hof] then
    exit
  end if
  sprite(me.spriteNum).member.text = string(glob[#rankdata][#moves])
end
