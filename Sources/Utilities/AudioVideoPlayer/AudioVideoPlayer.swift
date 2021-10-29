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
  public static let defaultTimescale = CMTimeScale(kCMTimeMaxTimescale)

  public private(set) lazy var playbackInterval: (startAt: Double, endAt: Double) = (0, duration)
  public var allowLooping = true
  public var periodicTimeObserverTimeInterval: CMTime = CMTimeMake(value: 1, timescale: AudioVideoPlayer.defaultTimescale)
  public weak var delegate: AudioVideoPlayerDelegate?
  
  private var timeObserver: Any?

  public override init() {
    super.init()
    setupTimeObserver()
  }

  public override init(url: URL) {
    super.init(url: url)
    setupTimeObserver()
  }

  override init(playerItem item: AVPlayerItem?) {
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

  override func pause() {
    super.pause()
    delegate?.audioVideoPlayer(didPausePlayback: self)
  }

  override func replaceCurrentItem(with item: AVPlayerItem?) {
    super.replaceCurrentItem(with: item)
    playbackInterval = (0, duration)
    setupTimeObserver()
  }

  /// Set `playbackInterval` and force player to start playing from the `startAt` timestamp.
  func setPlaybackInterval(
    startAt: Double,
    endAt: Double,
    timescale: CMTimeScale = AudioVideoPlayer.defaultTimescale
  ) {
    guard startAt < endAt else { fatalError("`startAt` should be less than `endAt`") }
    setPlaybackPosition(startAt: startAt)
    playbackInterval = (startAt, endAt)
  }

  /// Update `playbackInterval` and keep playing from the current location.
  func updatePlaybackInterval(startAt: Double, endAt: Double) {
    guard startAt < endAt else { fatalError("`startAt` should be less than `endAt`") }
    playbackInterval = (startAt, endAt)
    setupTimeObserver()
  }

  func setPlaybackPosition(
    startAt: Double,
    timescale: CMTimeScale = AudioVideoPlayer.defaultTimescale
  ) {
    removeTimeObserver()
    seek(to: CMTime(seconds: startAt, preferredTimescale: timescale)) { _ in
      self.setupTimeObserver()
    }
  }

  var duration: Double {
    currentItem?.asset.duration.seconds ?? 0
  }
  
  var isPlaying: Bool {
    rate != 0.0
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
      delegate?.audioVideoPlayer(didEndBuffering: self)
    }
  }

  func removeTimeObserver() {
    guard let timeObserver = timeObserver else { return }
    removeTimeObserver(timeObserver)
    self.timeObserver = nil
  }
}
