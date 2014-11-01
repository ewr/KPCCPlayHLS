class HomeScreen < PM::Screen
  title "Player"

  def on_load
    @_player ||= HLSPlayer.sharedPlayer()

    @_initialTime = nil

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

    @_buffer = {
      label:        UILabel.new(),
      label_text:   "RewindBuffer Range",
      start:        UILabel.new(),
      end:          UILabel.new()
    }

    @_loaded = {
      label:        UILabel.new(),
      label_text:   "Loaded Range",
      start:        UILabel.new(),
      end:          UILabel.new()
    }

    start_y = 200
    [@_buffer,@_loaded].each do |group|
      [:label,:start,:end].each do |item|
        add group[item], {
          text:             group[ "#{item.to_s}_text".to_sym ] || "--",
          text_color:       hex_color("999999"),
          background_color: UIColor.clearColor,
          text_alignment:   UITextAlignmentCenter,
          font:             UIFont.systemFontOfSize(15.0),
          resize:           [ :left, :right, :bottom ],
          frame:            CGRectMake(10,start_y,300,35)
        }

        start_y += 20
      end

      start_y += 20
    end

    self._setToolbarItems()

    @_slider.addTarget self, action: :_updateSlider, forControlEvents: UIControlEventValueChanged

    @_player.onTimeChange -> do
      @_initialTime = @_player.minDate if !@_initialTime

      @_time.text = @_player.curDate.to_s
      self.setSliderValue()

      @_buffer[:start].text  = @_player.minDate.to_s
      @_buffer[:end].text    = @_player.maxDate.to_s

      if @_initialTime && loaded = @_player.getPlayer().currentItem.loadedTimeRanges[0]
        loaded = loaded.CMTimeRangeValue

        min = @_initialTime + ( loaded.start.value / loaded.start.timescale )
        max = min + ( loaded.duration.value / loaded.duration.timescale )

        @_loaded[:start].text = min.to_s
        @_loaded[:end].text   = max.to_s
      end
    end

    @_player.onStatusChange -> do
      self._setToolbarItems()

      if @_player.status == HLSPlayer::STOPPED
        @_time.text = "--:--"
        @_slider.value = 100

        [ @_buffer[:start],@_buffer[:end],@_loaded[:start],@_loaded[:end] ].each { |t|
          t.text = "--"
        }

        @_initialTime = nil

        #if @_player.last_error_log
        #  @_errorLog.text = @_player.last_error_log
        #elsif @_player.last_error
        #  @errorLog.text = @_player.last_error
        #else
        #  @_errorLog.text = "No errors."
        #end
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

    rewind1 = {
      title: "Rewind 1",
      action: :top_of_hour_back,
      system_item: :rewind
    }
    rewind2 = {
      title: "Rewind 1",
      action: :six_after_back,
      system_item: :rewind
    }

    ff1 = {
      title: "FF 1",
      action: :six_after_forward,
      system_item: :fast_forward
    }
    ff2 = {
      title: "FF 2",
      action: :top_of_hour_forward,
      system_item: :fast_forward
    }

    space = { system_item: :flexible_space }

    PM.logger.debug "Player status is #{ @_player.status }"
    case @_player.status
    when HLSPlayer::STOPPED
      set_toolbar_items [play]
    when HLSPlayer::PLAYING
      set_toolbar_items [pause,rewind1,rewind2,ff1,ff2,space,stop]
    when HLSPlayer::PAUSED
      set_toolbar_items [play,rewind1,rewind2,ff1,ff2,space,stop]
    end
  end

  def will_appear
    @view_is_set_up ||= begin

    end
  end

  def _updateSlider
    @_player.seekToPercent( @_slider.value )
  end

  def setSliderValue
    percent = (@_player.curDate-@_player.minDate)/(@_player.maxDate-@_player.minDate) * 100
    @_slider.value = percent
  end

  def play
    @_player.play()
    #@_accessLog.text = ""
    #@_errorLog.text = ""
  end

  def pause
    @_player.pause()
  end

  # rewind back to the top of the current hour, if available
  def top_of_hour_back
    @_player.seekToMinutesAfter(0,-1)
  end

  def top_of_hour_forward
    @_player.seekToMinutesAfter(0,1)
  end

  # rewind to six-minutes after the hour
  def six_after_back
    @_player.seekToMinutesAfter(6,-1)
  end

  def six_after_forward
    @_player.seekToMinutesAfter(6,1)
  end

  def stop
    # update access log display
    p = @_player.getPlayer()
    #if a = p.currentItem.accessLog
      #@_accessLog.text = a.extendedLogData.to_s
    #end

    @_player.stop()
  end

end
