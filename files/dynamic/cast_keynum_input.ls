global glob

on exitFrame me
  num = integer(member("keynum_input").text)
  if num > 15 then
    member("keynum_input").text = "15"
  else
    if num <= 0 then
      member("keynum_input").text = "0"
    end if
  end if
  glob[#keyrequired] = integer(member("keynum_input").text)
end
