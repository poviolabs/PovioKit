//
//  AudioVideoPlayer.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/10/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import AVKit

public protocol AudioVideoPlayerDelegate: AnyObject {
  func audioVideoPlayer(didBeginPlayback player: AudioVideoPlayer)
  func audioVideoPlayer(didEndPlayback player: AudioVideoPlayer)
  func audioVideoPlayer(didPausePlayback player: AudioVideoPlayer)
  func audioVideoPlayer(didBeginReplay player: AudioVideoPlayer)
  func audioVideoPlayer(didBeginBuffering player: AudioVideoPlayer)
  func audioVideoPlayer(didEndBuffering player: AudioVideoPlayer)
  func audioVideoPlayer(_ player: AudioVideoPlayer, didProgressToTime seconds: Double)
}

public extension AudioVideoPlayerDelegate {
  func audioVideoPlayer(didBeginPlayback player: AudioVideoPlayer) {}
  func audioVideoPlayer(didEndPlayback player: AudioVideoPlayer) {}
  func audioVideoPlayer(didPausePlayback player: AudioVideoPlayer) {}
  func audioVideoPlayer(didBeginReplay player: AudioVideoPlayer) {}
  func audioVideoPlayer(didBeginBuffering player: AudioVideoPlayer) {}
  func audioVideoPlayer(didEndBuffering player: AudioVideoPlayer) {}
  func audioVideoPlayer(_ player: AudioVideoPlayer, didProgressToTime seconds: Double) {}
}

public class AudioVideoPlayer: AVPlayer {
  public static let defaultTimescale = CMTimeScale(10)

  public private(set) lazy var playbackInterval: (startAt: Double, endAt: Double) = (0, duration)
  public var allowLooping = true
  public var periodicTimeObserverTimeInterval: CMTime = .init(value: 1, timescale: AudioVideoPlayer.defaultTimescale) {
    didSet {
      removeTimeObserver()
      setupTimeObserver()
    }
  }
  public weak var delegate: AudioVideoPlayerDelegate?
  
  private var timeObserver: Any?
  
  override public init() {
    super.init()
    setupTimeObserver()
  }

  public init(
    url: URL,
    periodicTimeObserverTimeInterval timeInterval: CMTime = CMTimeMake(value: 1, timescale: AudioVideoPlayer.defaultTimescale)
  ) {
    super.init(url: url)
    setupTimeObserver()
  }

  public init(
    playerItem item: AVPlayerItem?,
    periodicTimeObserverTimeInterval timeInterval: CMTime = CMTimeMake(value: 1, timescale: AudioVideoPlayer.defaultTimescale)
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
public extension AudioVideoPlayer {
  override func play() {
    super.play()
    delegate?.audioVideoPlayer(didBeginPlayback: self)
  }
  
  
  /// Start playing at `startAt` timestamp.
  func play(
    startAt: Double,
    timescale: CMTimeScale = AudioVideoPlayer.defaultTimescale
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
    timescale: CMTimeScale = AudioVideoPlayer.defaultTimescale
  ) {
    guard startAt < endAt else { fatalError("`startAt` should be less than `endAt`") }
    setPlaybackPosition(startAt: startAt)
    playbackInterval = (startAt, endAt)
  }
  
  override func pause() {
    super.pause()
    delegate?.audioVideoPlayer(didPausePlayback: self)
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
private extension AudioVideoPlayer {
  func setupTimeObserver() {
    guard timeObserver == nil else { return }

    timeObserver = addPeriodicTimeObserver(
      forInterval: periodicTimeObserverTimeInterval,
      queue: .main
    ) { [weak self] time in
      guard let self = self else { return }

      self.delegate?.audioVideoPlayer(self, didProgressToTime: time.seconds)
      self.timeObserverCallback(time: time)

      guard let currentItem = self.currentItem, currentItem.status == .readyToPlay else { return }
      currentItem.isPlaybackLikelyToKeepUp
        ? self.delegate?.audioVideoPlayer(didEndBuffering: self)
        : self.delegate?.audioVideoPlayer(didBeginBuffering: self)
    }
  }

  func timeObserverCallback(time: CMTime) {
    let (startAt, endAt) = playbackInterval
    guard time.seconds >= endAt else { return }

    if allowLooping {
      setPlaybackPosition(startAt: startAt)
      play()
      delegate?.audioVideoPlayer(didBeginReplay: self)
    } else {
      removeTimeObserver()
      delegate?.audioVideoPlayer(didEndPlayback: self)
    }
  }

  func removeTimeObserver() {
    timeObserver.map(removeTimeObserver)
    timeObserver = nil
  }
}
