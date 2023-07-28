//
//  AudioVideoPlayer.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/10/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import AVKit

public enum MediaPlayerPlaybackState {
  case undefined
  case playing
  case preparing
  case paused
  case stopped
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

  public var allowsLooping = false

  public var timeObservingMiliseconds: Int = 500 {
    didSet {
      removeTimeObserver()
      setupTimeObserver()
    }
  }

  public var duration: Double {
    currentItem?.asset.duration.seconds ?? 0
  }

  public var isPlaying: Bool {
    rate != 0.0 && status == .readyToPlay
  }

  public var currentTime: Double {
    Double(CMTimeGetSeconds(currentTime()))
  }

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

  public override func play() {
    super.play()
    state = .playing
    delegate?.mediaPlayer(didBeginPlayback: self)
  }

  public func play(from fromTime: Double) {
    guard fromTime < duration else { fatalError("`fromTime` should be less than total duration") }
    playbackInterval = (fromTime, duration)
    jump(to: fromTime)
    play()
  }

  public func play(from fromTime: Double, to toTime: Double) {
    guard fromTime < toTime else { fatalError("`fromTime` should be less than `toTime`") }
    playbackInterval = (fromTime, toTime)
    setPlaybackPosition(to: fromTime)
    play()
  }

  public func jump(to time: Double) {
    setPlaybackPosition(to: time)
  }

  public func stop() {
    pause()
    setPlaybackPosition(to: playbackInterval.startAt)
    state = .stopped
  }

  public func seekForward(seconds: Double) {
    setPlaybackPosition(to: min(currentTime + seconds, playbackInterval.endAt))
  }

  public func seekBackward(seconds: Double) {
    setPlaybackPosition(to: (max(currentTime - seconds, playbackInterval.startAt)))
  }

  public override func pause() {
    super.pause()
    state = .paused
    delegate?.mediaPlayer(didPausePlayback: self)
  }

  public override func replaceCurrentItem(with item: AVPlayerItem?) {
    super.replaceCurrentItem(with: item)
    playbackInterval = (0, duration)
    setupTimeObserver()
    play()
  }

  /// Update the current playback interval, but keep playing at the current position.
  func updatePlaybackInterval(startAt: Double, endAt: Double) {
    guard startAt < endAt else { fatalError("`startAt` should be less than `endAt`") }
    playbackInterval = (startAt, endAt)
    setupTimeObserver()

    if currentTime < startAt || currentTime > endAt {
      setPlaybackPosition(to: max(startAt, min(endAt, currentTime)))
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
