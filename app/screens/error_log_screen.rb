class ErrorLogScreen < PM::Screen
  title "Error Log"

  def on_load
    @_player ||= HLSPlayer.sharedPlayer()

    set_attributes self.view, {
      background_color: hex_color("cccccc")
    }

    @_errorLog = UITextView.new()

    add @_errorLog, {
      text:         "",
      font:         UIFont.systemFontOfSize(12.0),
      editable:     false,
      text_color:   hex_color("999999"),
      frame: CGRectMake(10,30,self.bounds.size.width - 20,self.bounds.size.height - 100),
      resize: [ :left, :right, :bottom ]
    }
  end

  def will_appear
    p = @_player.getPlayer()
    @_errorLog.text = @_player.last_error_log || "No error log data."
  end
end