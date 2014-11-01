class HLSPlayer
  @@shared = nil

  def self.sharedPlayer
    @@shared ||= HLSPlayer.new()
  end

  STOPPED = 0
  PLAYING = 1
  PAUSED  = 2

  STREAM_URL = "http://streammachine-hls001.scprdev.org/sg/kpcc-aac.m3u8"
  #STREAM_URL = "http://ewr-mbp.local:8004/sg/test.m3u8"

  #----------

  attr_accessor :current_time, :_player, :minDate, :maxDate, :curDate, :status, :last_error, :last_error_log

  def initialize
    @_url = NSURL.URLWithString(STREAM_URL)

    @_statusObservers = []
    @_timeObservers   = []

    self._setStatus(STOPPED)
  end

  #----------

  def getPlayer
    if !@_player
      PM.logger.debug "Starting player."
      @_player = AVPlayer.playerWithURL @_url
      @_player.addObserver(self, forKeyPath: :status, options:0, context:nil)
      @_player.currentItem.addObserver(self, forKeyPath: :status, options:0, context:nil)
      self._startObservingTime()

      av = AVAudioSession.sharedInstance
      av.setDelegate self
      av.setCategory AVAudioSessionCategoryPlayback, error:nil
      av.setActive true, error:nil

      self.last_error = nil
      self.last_error_log = nil

    end

    @_player
  end

  def _setStatus(status)
    @status = status
    @_statusObservers.each { |o| o.call() }
  end

  def onStatusChange(proc)
    @_statusObservers << proc
  end

  #----------

  def observeValueForKeyPath(path,ofObject:object,change:change,context:context)
    if object == @_player
      PM.logger.debug "Player status :: #{ @_player.status }"

      if object.status == AVPlayerStatusFailed
        if object.error
          self.last_error = "(#{object.error.code}) #{ object.error.localizedDescription }"
        else
          self.last_error = "Unknown error."
        end

        if object.currentItem.errorLog
          self.last_error_log = object.currentItem.errorLog.extendedLogData.to_s
        end

        self._setStatus(STOPPED)
        PM.logger.error "AVPlayer error is #{ object.error }"
      end

    elsif object == @_player.currentItem
      PM.logger.debug "CurrentItem status :: #{ @_player.currentItem.status }"

      if object.status == AVPlayerItemStatusFailed

        if object.error
          self.last_error = "(#{object.error.code}) #{ object.error.localizedDescription }"
        else
          self.last_error = "Unknown error."
        end

        if object.errorLog
          self.last_error_log = object.errorLog.extendedLogData.to_s
        end

        self._setStatus(STOPPED)
        PM.logger.error "AVPlayerItem error!"
      end
    end

  end

  #----------

  def onTimeChange(proc)
    @_timeObservers << proc
  end

  #----------

  def _startObservingTime()
    return false if @_obs

    @_obs = @_player.addPeriodicTimeObserverForInterval CMTime.new(1,1,1,0), queue:nil, usingBlock:->(t) do
      @curDate = @_player.currentItem.currentDate

      if seek_range = @_player.currentItem.seekableTimeRanges[0]
        seek_range = seek_range.CMTimeRangeValue

        @minDate = NSDate.dateWithTimeInterval( ( -1 * (CMTimeGetSeconds(t) - CMTimeGetSeconds(seek_range.start))), sinceDate: @curDate)
        @maxDate = NSDate.dateWithTimeInterval( (CMTimeGetSeconds(CMTimeRangeGetEnd(seek_range)) - CMTimeGetSeconds(t)), sinceDate: @curDate)

        @_timeObservers.each { |o| o.call() }
      else
        PM.logger.debug "currentItem has no seekable range"

        if @_player.currentItem.errorLog
          self.last_error_log = @_player.currentItem.errorLog.extendedLogData.to_s
        end

        #self._setStatus(STOPPED)
      end
    end
  end

  #----------

  def play
    self._setStatus(PLAYING)
    self.getPlayer().play()
  end

  #----------

  def pause
    self._setStatus(PAUSED)
    self.getPlayer().pause()
  end

  def stop
    return false if !@_player

    player = @_player
    @_player = nil

    player.pause()

    if @_obs
      player.removeTimeObserver @_obs
      @_obs = nil
    end

    player.removeObserver self, forKeyPath: :status

    if player.currentItem
      player.currentItem.removeObserver self, forKeyPath: :status
    end

    if player.currentItem && player.currentItem.errorLog
      self.last_error_log = player.currentItem.errorLog.extendedLogData.to_s
    end

    self._setStatus(STOPPED)
    true
  end

  #----------

  def seekToMinutesAfter(offset_min,direction)
    return false if !@curDate

    player = self.getPlayer()

    target = @curDate

    if direction == -1
      # go to top or bottom of the hour, whichever is closer
      sub_min = @curDate.min > 30 ? @curDate.min - 30 : @curDate.min
      target = target - sub_min*60 - @curDate.sec + offset_min*60

      # if that wasn't a big move, do it again
      if @curDate - target < 15
        # go another 30 minutes
        target = target - 30*60
      end
    else
      # go forward...
      add_min = @curDate.min < 30 ? 60 - (@curDate.min + 30) : 60 - @curDate.min
      target = target + add_min*60 - @curDate.sec + offset_min*60

      if target - @curDate < 15
        target = target + 30*60
      end
    end

    target = target + 1

    PM.logger.debug "Seeking to #{ target }"
    player.currentItem.seekToDate target

  end

  #----------

  def seekToPercent(percent)
    player = self.getPlayer()

    seek_range = player.currentItem.seekableTimeRanges[0].CMTimeRangeValue
    seek_time = CMTimeMakeWithSeconds(
      CMTimeGetSeconds(seek_range.start) + ( CMTimeGetSeconds(seek_range.duration) * ( percent / 100 ) ),
      seek_range.start.timescale
    )

    player.currentItem.seekToTime seek_time
  end
end