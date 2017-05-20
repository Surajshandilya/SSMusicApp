//
//  AudioPlayer.swift
//  MusicAppSample
//
//  Created by Suraj on 18/05/17.
//  Copyright © 2017 Suraj. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit

struct AudioPlayer {
    
    static let shared = AudioPlayer()
    private let audioPlayer: MPMusicPlayerController = MPMusicPlayerController.systemMusicPlayer()
    
    let songs = MPMediaQuery.songs().items ?? []
    
    // MARK: - Computed properties
    
    var currentPlayingItemTitle: String? {
        return audioPlayer.nowPlayingItem?.title
    }
    
    var currentPlayingItem: MPMediaItem? {
        return audioPlayer.nowPlayingItem
    }
    
    var isAudioPlaying: Bool {
        if audioPlayer.playbackState == .playing {
            return true
        }
        return false
    }
    
    var currentPlayingTime: Float {
        return Float(audioPlayer.currentPlaybackTime)
    }
    
    // Forcing class to strict Singleton
    private init() {
        func intializeLibrary() {
            self.audioPlayer.beginGeneratingPlaybackNotifications()
            let songsCollection = MPMediaItemCollection(items: self.songs)
            audioPlayer.setQueue(with: songsCollection)
        }
        
        if #available(iOS 9.3, *) {
            MPMediaLibrary.requestAuthorization { (status) in
                intializeLibrary()
                // Not Handling the status You should allow the Music base access 
                switch status {
                case .authorized: break
                case .denied: break
                case .notDetermined: break
                case .restricted: break
                }
            }
        }
    }
    
    // MARK: - Utility methods
    
    func prepareToPlay(item: MPMediaItem) {
        audioPlayer.nowPlayingItem = item
        if audioPlayer.playbackState == .playing {
            audioPlayer.prepareToPlay()
        }
        audioPlayer.play()
    }
    
    func playBack() {
        if audioPlayer.playbackState == .playing {
           audioPlayer.pause()
        }
        else if audioPlayer.playbackState == .paused {
            audioPlayer.play()
        }
    }
    
    func previous() {
        audioPlayer.skipToPreviousItem()
    }
    
    func next() {
        audioPlayer.skipToNextItem()
    }
    
    func stop() {
        audioPlayer.stop()
    }
    
    func seekToTime(time: Float) {
        audioPlayer.currentPlaybackTime = TimeInterval(time)
    }
    
}
