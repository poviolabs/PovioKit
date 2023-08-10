//
//  AudioVideoPlayer.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/10/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import AVKit

/// Enum representing the different states of media playback.
public enum MediaPlayerPlaybackState {
  /// State when the media player is not defined or initialized.
  case undefined
  /// State when the media player is actively playing media.
  case playing
  /// State when the media player is preparing to play media.
  case preparing
  /// State when the media player has paused media playback.
  case paused
  /// State when the media player has stopped media playback.
  case stopped
  /// State when the media player has ended media playback.
  case ended
}

public protocol MediaPlayerDelegate: AnyObject {
  func mediaPlayer(didBeginPlayback player: MediaPlayer)
  func mediaPlayer(didEndPlayback player: MediaPlayer)
  func mediaPlayer(didPausePlayback player: MediaPlayer)
  func mediaPlayer(didBeginReplay player: MediaPlayer)
  func mediaPlayer(didBeginBuffering player: MediaPlayer)
  func mediaPlayer(didEndBuffering player: MediaPlayer)
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double)
  func mediaPlayer(_ player: MediaPlayer, onProgressUpdate progress: Float)

  func mediaPlayer(_ player: MediaPlayer, didFailWithError: Error)
  func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState: MediaPlayerPlaybackState)
}

public extension MediaPlayerDelegate {
  func mediaPlayer(didBeginPlayback player: MediaPlayer) {}
  func mediaPlayer(didEndPlayback player: MediaPlayer) {}
  func mediaPlayer(didPausePlayback player: MediaPlayer) {}
  func mediaPlayer(didBeginReplay player: MediaPlayer) {}
  func mediaPlayer(didBeginBuffering player: MediaPlayer) {}
  func mediaPlayer(didEndBuffering player: MediaPlayer) {}
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double) {}
  func mediaPlayer(_ player: MediaPlayer, didFailWithError: Error) {}
  func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState: MediaPlayerPlaybackState) {}
  func mediaPlayer(_ player: MediaPlayer, onProgressUpdate progress: Float) {}
}

public class MediaPlayer: AVPlayer {
  public private(set) lazy var playbackInterval: (startAt: Double, endAt: Double) = (0, duration)

  // MARK: - Private properties

  private var timeObserver: Any?

  // MARK: - Public properties

  /// A Boolean value that determines whether the media player should loop playback when it reaches the end of the media.
  ///
  /// If this property is set to `true`, the media player will automatically start playing the media from the beginning once it reaches the end. If set to `false`, the media player will stop playing when it reaches the end of the media.
  /// If the custom time interval is set, it will automatically loop in the selected time interval.
  ///
  /// The default value is `false`.
  public var allowsLooping = false

  /// The time interval in milliseconds at which the player observes the playback time.
  /// This property determines how often the player updates the playback progress.
  /// When this property is set, the player removes the current time observer and sets up a new one.
  /// The default value is `500` milliseconds, which means that the progress delegate methods will get
  /// called every 500 miliseconds
  public var timeObservingMiliseconds: Int = 500 {
    didSet {
      // Remove the current time observer when the observing interval changes
      removeTimeObserver()
      // Set up a new time observer with the updated interval
      setupTimeObserver()
    }
  }

  /// The total duration of the current media item in seconds. This duration does not take into account any custom playback interval set.
  public var duration: Double {
    currentItem?.asset.duration.seconds ?? 0
  }

  /// A Boolean value indicating whether the media player is currently playing.
  public var isPlaying: Bool {
    rate != 0.0 && status == .readyToPlay
  }

  /// The current playback time of the media player in seconds.
  /// This property returns the current time of the player converted to seconds.
  public var currentTimeSeconds: Double {
    Double(CMTimeGetSeconds(currentTime()))
  }

  /// The current state of the media player.
  /// This property is of type `MediaPlayerPlaybackState` and its default value is `.undefined`.
  /// When the state changes, the media player informs its delegate by calling the `mediaPlayer(_:didUpdatePlaybackState:)` method.
  public var state: MediaPlayerPlaybackState = .undefined {
    didSet {
      delegate?.mediaPlayer(self, didUpdatePlaybackState: state)
    }
  }

  public weak var delegate: MediaPlayerDelegate?

  // MARK: - Init
  
  override public init() {
    super.init()
    setupTimeObserver()
  }

  public override init(url: URL) {
    super.init(url: url)
    setupTimeObserver()
  }

  public override init(playerItem item: AVPlayerItem?) {
    super.init(playerItem: item)
    setupTimeObserver()
  }
  
  convenience public init?(urlString: String) {
    guard let url = URL(string: urlString) else { return nil }
    self.init(url: url)
  }

  // MARK: - Public methods

  /// Starts playing the media from the current position.
  /// This function also updates the state of the media player to `.playing` and informs the delegate that the playback has started.
  public override func play() {
    super.play()
    state = .playing
    delegate?.mediaPlayer(didBeginPlayback: self)
  }

  /// Starts playing the media from a specified time.
  ///
  /// - Parameters:
  ///   - fromTime: The time from which to start playing the media. This should be less than the total duration of the media.
  ///
  /// If `fromTime` is greater than or equal to the total duration, this function will cause a fatal error.
  public func play(from fromTime: Double) {
    guard fromTime < duration else { fatalError("`fromTime` should be less than total duration") }
    playbackInterval = (fromTime, duration)
    jump(to: fromTime)
    play()
  }

  /// Starts playing the media from a specified start time to a specified end time.
  ///
  /// - Parameters:
  ///   - fromTime: The time from which to start playing the media. This should be less than `toTime`.
  ///   - toTime: The time at which to stop playing the media. This should be greater than `fromTime`.
  ///
  /// If `fromTime` is greater than or equal to `toTime`, this function will cause a fatal error.
  public func play(from fromTime: Double, to toTime: Double) {
    guard fromTime < toTime else { fatalError("`fromTime` should be less than `toTime`") }
    playbackInterval = (fromTime, toTime)
    setPlaybackPosition(to: fromTime)
    play()
  }

  /// Jumps to a specified time in the media.
  ///
  /// - Parameters:
  ///   - time: The time to which to jump. This does not start playing the media if not yet playing.
  public func jump(to time: Double) {
    setPlaybackPosition(to: time)
  }

  /// Stops the media playback and resets the playback position to the start of the playback interval.
  /// Also, updates the state of the media player to `.stopped`.
  public func stop() {
    pause()
    setPlaybackPosition(to: playbackInterval.startAt)
    state = .stopped
  }

  /// Seeks forward in the media by a specified number of seconds.
  ///
  /// - Parameters:
  ///   - seconds: The number of seconds to seek forward. If the resulting time exceeds the end of the playback interval,
  ///   the function will set the playback position to the end of the interval.
  public func seekForward(seconds: Double) {
    setPlaybackPosition(to: min(currentTimeSeconds + seconds, playbackInterval.endAt))
  }

  /// Seeks backward in the media by a specified number of seconds.
  ///
  /// - Parameters:
  ///   - seconds: The number of seconds to seek backward. If the resulting time is less than the start of the playback interval,
  ///   the function will set the playback position to the start of the interval.
  public func seekBackward(seconds: Double) {
    setPlaybackPosition(to: (max(currentTimeSeconds - seconds, playbackInterval.startAt)))
  }

  /// Pauses the media playback, updates the state of the media player to `.paused`, and informs the delegate that the playback has paused.
  public override func pause() {
    super.pause()
    state = .paused
    delegate?.mediaPlayer(didPausePlayback: self)
  }

  /// Replaces the current playing item with the new given item.
  ///
  /// - Parameters:
  ///   - item: The new `AVPlayerItem` to be replaced with. Resets the playback interval to default.
  ///
  /// Note: This does not automatically play the item. To play the replaced item, call the method`play()`-
  public override func replaceCurrentItem(with item: AVPlayerItem?) {
    super.replaceCurrentItem(with: item)
    playbackInterval = (0, duration)
    setupTimeObserver()
  }

  /// Updates the playback interval with the new range.
  ///
  /// - Parameters:
  ///   - startAt: The new start of the playback range.
  ///   - endAt: The new end of the playback range.
  ///
  /// If the current time is out of new range, the playback position gets set either to the beginnig of the end respectively.
  func updatePlaybackInterval(startAt: Double, endAt: Double) {
    guard startAt < endAt else { fatalError("`startAt` should be less than `endAt`") }
    playbackInterval = (startAt, endAt)
    setupTimeObserver()

    if currentTimeSeconds < startAt || currentTimeSeconds > endAt {
      setPlaybackPosition(to: max(startAt, min(endAt, currentTimeSeconds)))
    }
  }
}

// MARK: - Extensions

// MARK: - Private Methods

private extension MediaPlayer {
  func setupTimeObserver() {
    removeTimeObserver()

    timeObserver = addPeriodicTimeObserver(
      forInterval: CMTimeMake(value: Int64(timeObservingMiliseconds), timescale: 1000),
      queue: .main
    ) { [weak self] time in
      guard let self = self else { return }

      if currentItem?.status == .failed, let error = currentItem?.error {
        self.delegate?.mediaPlayer(self, didFailWithError: error)
      }

      self.delegate?.mediaPlayer(self, didProgressToTime: time.seconds)
      self.delegate?.mediaPlayer(self, onProgressUpdate: Float(time.seconds / self.duration))
      self.timeObserverCallback(time: time)

      guard let currentItem = self.currentItem, currentItem.status == .readyToPlay else { return }
      currentItem.isPlaybackLikelyToKeepUp
      ? self.delegate?.mediaPlayer(didEndBuffering: self)
      : self.delegate?.mediaPlayer(didBeginBuffering: self)
    }
  }

  func timeObserverCallback(time: CMTime) {
    guard time.seconds >= playbackInterval.endAt else { return }

    if allowsLooping {
      setPlaybackPosition(to: playbackInterval.startAt)
      play()
      delegate?.mediaPlayer(didBeginReplay: self)
    } else {
      removeTimeObserver()
      state = .ended
      delegate?.mediaPlayer(didEndPlayback: self)
    }
  }

  func removeTimeObserver() {
    timeObserver.map(removeTimeObserver)
    timeObserver = nil
  }

  func setPlaybackPosition(to value: Double) {
    seek(to: CMTimeMakeWithSeconds(value, preferredTimescale: 6_000))
  }
}
