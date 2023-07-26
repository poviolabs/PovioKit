//
//  AudioVideoPlayer.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/10/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import AVKit

public protocol MediaPlayerDelegate: AnyObject {
  func mediaPlayer(didBeginPlayback player: MediaPlayer)
  func mediaPlayer(didEndPlayback player: MediaPlayer)
  func mediaPlayer(didPausePlayback player: MediaPlayer)
  func mediaPlayer(didBeginReplay player: MediaPlayer)
  func mediaPlayer(didBeginBuffering player: MediaPlayer)
  func mediaPlayer(didEndBuffering player: MediaPlayer)
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double)
}

public extension MediaPlayerDelegate {
  func mediaPlayer(didBeginPlayback player: MediaPlayer) {}
  func mediaPlayer(didEndPlayback player: MediaPlayer) {}
  func mediaPlayer(didPausePlayback player: MediaPlayer) {}
  func mediaPlayer(didBeginReplay player: MediaPlayer) {}
  func mediaPlayer(didBeginBuffering player: MediaPlayer) {}
  func mediaPlayer(didEndBuffering player: MediaPlayer) {}
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double) {}
}

public class MediaPlayer: AVPlayer {
  public static let defaultTimescale = CMTimeScale(10)

  public private(set) lazy var playbackInterval: (startAt: Double, endAt: Double) = (0, duration)
  public var allowLooping = true
  public var periodicTimeObserverTimeInterval: CMTime = .init(value: 1, timescale: MediaPlayer.defaultTimescale) {
    didSet {
      removeTimeObserver()
      setupTimeObserver()
    }
  }
  public weak var delegate: MediaPlayerDelegate?
  
  private var timeObserver: Any?
  
  override public init() {
    super.init()
    setupTimeObserver()
  }

  public init(
    url: URL,
    periodicTimeObserverTimeInterval timeInterval: CMTime = CMTimeMake(value: 1, timescale: MediaPlayer.defaultTimescale)
  ) {
    super.init(url: url)
    setupTimeObserver()
  }

  public init(
    playerItem item: AVPlayerItem?,
    periodicTimeObserverTimeInterval timeInterval: CMTime = CMTimeMake(value: 1, timescale: MediaPlayer.defaultTimescale)
  ) {
    super.init(playerItem: item)
    setupTimeObserver()
  }
  
  convenience public init?(urlString: String) {
    guard let url = URL(string: urlString) else { return nil }
    self.init(url: url)
  }
}

// MARK: - API
public extension MediaPlayer {
  override func play() {
    super.play()
    delegate?.MediaPlayer(didBeginPlayback: self)
  }
  
  
  /// Start playing at `startAt` timestamp.
  func play(
    startAt: Double,
    timescale: CMTimeScale = MediaPlayer.defaultTimescale
  ) {
    removeTimeObserver()
    seek(to: CMTime(seconds: startAt, preferredTimescale: timescale)) { _ in
      self.setupTimeObserver()
    }
  }

  /// Update the current playback interval and force the player to start playing at `startAt` timestamp.
  func play(
    startAt: Double,
    endAt: Double,
    timescale: CMTimeScale = MediaPlayer.defaultTimescale
  ) {
    guard startAt < endAt else { fatalError("`startAt` should be less than `endAt`") }
    setPlaybackPosition(startAt: startAt)
    playbackInterval = (startAt, endAt)
  }
  
  override func pause() {
    super.pause()
    delegate?.mediaPlayer(didPausePlayback: self)
  }

  override func replaceCurrentItem(with item: AVPlayerItem?) {
    super.replaceCurrentItem(with: item)
    playbackInterval = (0, duration)
    removeTimeObserver()
    setupTimeObserver()
  }

  /// Update the current playback interval, but keep playing at the current position.
  func updatePlaybackInterval(startAt: Double, endAt: Double) {
    guard startAt < endAt else { fatalError("`startAt` should be less than `endAt`") }
    playbackInterval = (startAt, endAt)
    removeTimeObserver()
    setupTimeObserver()
  }

  var duration: Double {
    currentItem?.asset.duration.seconds ?? 0
  }
  
  var isPlaying: Bool {
    rate != 0.0 && status == .readyToPlay
  }
}

// MARK: - Private Methods
private extension MediaPlayer {
  func setupTimeObserver() {
    guard timeObserver == nil else { return }

    timeObserver = addPeriodicTimeObserver(
      forInterval: periodicTimeObserverTimeInterval,
      queue: .main
    ) { [weak self] time in
      guard let self = self else { return }

      self.delegate?.mediaPlayer(self, didProgressToTime: time.seconds)
      self.timeObserverCallback(time: time)

      guard let currentItem = self.currentItem, currentItem.status == .readyToPlay else { return }
      currentItem.isPlaybackLikelyToKeepUp
        ? self.delegate?.mediaPlayer(didEndBuffering: self)
        : self.delegate?.mediaPlayer(didBeginBuffering: self)
    }
  }

  func timeObserverCallback(time: CMTime) {
    let (startAt, endAt) = playbackInterval
    guard time.seconds >= endAt else { return }

    if allowLooping {
      setPlaybackPosition(startAt: startAt)
      play()
      delegate?.mediaPlayer(didBeginReplay: self)
    } else {
      removeTimeObserver()
      delegate?.mediaPlayer(didEndPlayback: self)
    }
  }

  func removeTimeObserver() {
    timeObserver.map(removeTimeObserver)
    timeObserver = nil
  }
}
