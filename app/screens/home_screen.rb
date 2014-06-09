class HomeScreen < PM::Screen
  title "KPCC HLS"

  def on_load
    @_player ||= HLSPlayer.sharedPlayer()

    set_attributes self.view, {
      background_color: hex_color("cccccc")
    }

    @_time = UILabel.new()

    add @_time, {
      text: "--:--",
      text_color: hex_color("999999"),
      background_color: UIColor.clearColor,
      #shadow_color: UIColor.blackColor,
      text_alignment: UITextAlignmentCenter,
      font: UIFont.systemFontOfSize(15.0),
      resize: [ :left, :right, :bottom ],
      frame: CGRectMake(10,100,300,35)
    }

    @_slider = UISlider.new()

    add @_slider, {
      minimum_value:  0,
      maximum_value:  100,
      value:          100,
      resize: [ :left, :right, :bottom ],
      frame: CGRectMake(10,150,300,35)
    }

    @_accessLog = UITextView.new()

    add @_accessLog, {
      text:         "",
      font:         UIFont.systemFontOfSize(12.0),
      editable:     false,
      text_color:   hex_color("999999"),
      frame: CGRectMake(10,200,300,150)
    }

    @_errorLog = UITextView.new()

    add @_errorLog, {
      text:         "",
      font:         UIFont.systemFontOfSize(12.0),
      editable:     false,
      text_color:   hex_color("999999"),
      frame: CGRectMake(10,360,300,150)
    }

    self._setToolbarItems()

    @_slider.addTarget self, action: :_updateSlider, forControlEvents: UIControlEventValueChanged

    @_player.onTimeChange -> do
      @_time.text = @_player.curDate.to_s
    end

    @_player.onStatusChange -> do
      self._setToolbarItems()

      if @_player.status == HLSPlayer::STOPPED
        @_time.text = "--:--"
        @_slider.value = 100

        if @_player.last_error_log
          @_errorLog.text = @_player.last_error_log
        elsif @_player.last_error
          @errorLog.text = @_player.last_error
        else
          @_errorLog.text = "No errors."
        end
      end
    end
  end

  def _setToolbarItems
    play = {
      title: "Play",
      action: :play,
      system_item: :play,
    }

    pause = {
      title: "Pause",
      action: :pause,
      system_item: :pause
    }

    stop = {
      title: "Stop",
      action: :stop,
      system_item: :stop
    }

    space = { system_item: :flexible_space }

    case @_player.status
    when HLSPlayer::STOPPED
      set_toolbar_items [play]
    when HLSPlayer::PLAYING
      set_toolbar_items [pause,space,stop]
    when HLSPlayer::PAUSED
      set_toolbar_items [play,space,stop]
    end
  end

  def will_appear
    @view_is_set_up ||= begin

    end
  end

  def _updateSlider
    @_player.seekToPercent( @_slider.value )
  end

  def play
    @_player.play()
    @_accessLog.text = ""
    @_errorLog.text = ""
  end

  def pause
    @_player.pause()
  end

  def stop
    # update access log display
    p = @_player.getPlayer()
    if a = p.currentItem.accessLog
      @_accessLog.text = a.extendedLogData.to_s
    end

    @_player.stop()
  end

end
