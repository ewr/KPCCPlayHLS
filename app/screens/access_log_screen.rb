class AccessLogScreen < PM::Screen
  title "Access Log"

  def on_load
    @_player ||= HLSPlayer.sharedPlayer()

    set_attributes self.view, {
      background_color: hex_color("cccccc")
    }

    @_accessLog = UITextView.new()

    add @_accessLog, {
      text:         "",
      font:         UIFont.systemFontOfSize(12.0),
      editable:     false,
      text_color:   hex_color("999999"),
      frame: CGRectMake(10,30,self.bounds.size.width - 20,self.bounds.size.height - 100),
      resize: [ :left, :right, :bottom ]
    }

    set_nav_bar_button :right, {
      title: "Reload",
      system_item: :refresh,
      action: :reload
    }
  end

  def will_appear
    self.reload()
  end

  def reload
    p = @_player.getPlayer()

    text = nil

    if a = p.currentItem.accessLog
      text = a.extendedLogData.to_s
    end

    @_accessLog.text = text || "No access log data."
  end
end