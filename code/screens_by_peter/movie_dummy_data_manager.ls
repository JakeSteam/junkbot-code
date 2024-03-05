global glob

on initDummy
  glob[#keyrequired] = 2
  glob[#current] = [#building: 1, #level: 1, #moves: 30]
  glob[#building] = []
  repeat with i = 1 to 4
    temp = []
    repeat with j = 1 to 15
      temp.add([#title: "Dummy TITLE HAHA", #goal: 20, #moves: 0])
    end repeat
    state = #locked
    if i = 1 then
      state = #open
    end if
    glob[#building].add([#state: state, #LEVELS: temp])
  end repeat
end

on updateDummyData data
  tempLevel = glob[#building][data[1]][#LEVELS][data[2]]
  if not voidp(data[#title]) then
    tempLevel[#title] = data[#title]
  end if
  if not voidp(data[#goal]) then
    tempLevel[#goal] = data[#goal]
  end if
  if not voidp(data[#moves]) then
    tempLevel[#moves] = data[#moves]
  end if
end

on updateBuilding data
  glob[#building][data[1]][#state] = data[2]
end
