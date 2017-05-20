//
//  TMAVPlayer.swift
//  MusicAppSample
//
//  Created by Suraj on 18/05/17.
//  Copyright © 2017 Suraj. All rights reserved.
//

import Foundation
import MediaPlayer

class SSAVPlayer: NSObject {
    
    private var audioPlayer: AVPlayer = AVPlayer()
    static let shared = SSAVPlayer()
    
    var songs : [MPMediaItem] = []
    private var currentSongIndex: Int! = nil
    
    override private init() {
        // Register app for background play
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            debugPrint("Background mode is not supporting")
        }
        
        if #available(iOS 9.3, *) {
            MPMediaLibrary.requestAuthorization { (status) in
                // For now not Handling the status You should allow the Music base access
                switch status {
                case .authorized: break
                case .denied: break
                case .notDetermined: break
                case .restricted: break
                }
            }
        }
    }
    
    // MARK: - Computed properties
    
    var currentPlayingItem: MPMediaItem? {
        return songs[currentSongIndex]
    }
    
    var currentPlayingItemTitle: String? {
        return songs[currentSongIndex].title
    }
    
    var isAudioPlaying: Bool {
        if audioPlayer.rate == 0.0 {
            return false
        }
        return true
    }
    
    var currentPlayingTime: Float {
        return Float(CMTimeGetSeconds(audioPlayer.currentTime()))
    }
    
    // MARK: - Utility methods
    
    func prepareToPlay(songIndex: Int) {
        // Check songs availablility, terminate on fail condition
        if songIndex < 0 || songIndex >= songs.count {
            return
        }
        // Check is asset url is available or not
        if let assetURL = songs[songIndex].assetURL {
            // Maintains the current playing song media item
            currentSongIndex = songIndex
            // Creating player item upon the media item
            let playerItem = AVPlayerItem(url: assetURL)
            
            // Remove early added observers
            NotificationCenter.default.removeObserver(self)
            
            // Post start song notification here
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.TMAVPlayerSongDidStartPlaying), object: nil)
            
            // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            audioPlayer.replaceCurrentItem(with: playerItem)
            audioPlayer.play()

            // Update the control center
            configureNowPlayingInfo()
        }
    }
    
    func playBack() {
        // Check audio is playing
        if isAudioPlaying {
            audioPlayer.pause()
        }
        else {
            audioPlayer.play()
        }
        // Update control center
        configureNowPlayingInfo()
        
        // Post play state changed notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.TMAVPlayerPlayStateChanged), object: nil)
    }
    
    func previous() {
        let previousSongIndex = currentSongIndex - 1
        if previousSongIndex >= 0 {
            prepareToPlay(songIndex: previousSongIndex)
        }
    }
    
    func next() {
        let nextSongIndex = currentSongIndex + 1
        if nextSongIndex < songs.count {
            prepareToPlay(songIndex: nextSongIndex)
        }
    }
    
    func stop() {
        audioPlayer.rate = 0.0
    }
    
    func seekToTime(time: Float) {
        audioPlayer.seek(to: CMTimeMake(Int64(time), 1))
        //Update control center
        configureNowPlayingInfo()
    }
    
    // MARK: - Observer methods
    
    func itemDidFinishPlaying() {
        // After finishing song play next song
        next()
    }
    
    
    //
    func getTotalPlayingItemDuration() -> Float {
        let duration = audioPlayer.currentItem?.asset.duration.seconds
        debugPrint("duration: \(String(describing: duration))")
        return Float(duration!/60.0)
    }
    
    // MARK: - Control center methods
    
    func configureNowPlayingInfo() {
        let currentMediaItem = self.currentPlayingItem
        var albumImage = UIImage()
        var currentArtwork:MPMediaItemArtwork
        if #available(iOS 10, *) {
            // Support 10 or above.
            albumImage = UIImage(named: "noPlaylistImage")!
            currentArtwork = MPMediaItemArtwork.init(boundsSize: albumImage.size, requestHandler: { (size) -> UIImage in
                return albumImage
            })
        } else {
            // support lower version
            albumImage = UIImage.init(named: "noPlaylistImage")!
            currentArtwork = MPMediaItemArtwork.init(image: albumImage)
        }
        
        
        if let artWork = currentPlayingItem?.artwork {
            currentArtwork = artWork
        }
        
        // Updates the control centre data here
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: currentMediaItem?.title ?? "",
                                                                 MPMediaItemPropertyArtist: currentMediaItem?.artist ?? "",
                                                                 MPMediaItemPropertyArtwork: currentArtwork,
                                                                 MPNowPlayingInfoPropertyPlaybackRate: 1.0, MPMediaItemPropertyPlaybackDuration: self.currentPlayingItem?.playbackDuration ?? 0.0,
                                                                 MPNowPlayingInfoPropertyElapsedPlaybackTime: currentPlayingTime]
    }
}

// Extending the Notification name on the basis of new song did start playing
extension NSNotification.Name {
    
    static var TMAVPlayerSongDidStartPlaying: String {
        return "TMAVPlayerSongDidStartPlaying"
    }
    
    static var TMAVPlayerPlayStateChanged: String {
        return "TMAVPlayerPlayStateChanged"
    }
    
}

// Show volume slider on screen when we change the volume.
extension MPVolumeView {
     var volumeSlider:UISlider {
        self.showsRouteButton = false
        self.showsVolumeSlider = false
        var slider = UISlider()
        for subview in self.subviews {
            if subview is UISlider {
                slider = subview as! UISlider
                (subview as! UISlider).value = AVAudioSession.sharedInstance().outputVolume
                return slider
            }
        }
        return slider
    }
}
