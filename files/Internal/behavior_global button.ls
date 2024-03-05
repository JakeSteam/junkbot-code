property myMessage

on mouseUp me
  gbutton(myMessage)
end

on getPropertyDescriptionList
  return [#myMessage: [#comment: "Button message:", #format: #symbol, #default: #none]]
end
