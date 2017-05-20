//
//  ViewController.swift
//  MusicAppSample
//
//  Created by Suraj on 18/05/17.
//  Copyright © 2017 Suraj. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {

    // Here using SSAVPlayer which build upon the AVPlayer
    fileprivate var audioPlayer = SSAVPlayer.shared
    private var audioTimer: Timer?

    
    @IBOutlet weak var audioPlayerListTable: UITableView!
    @IBOutlet weak var bottomViewContainer: UIView!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    var selectedIndex = -1
    //MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 9.3, *) {
            MPMediaLibrary.requestAuthorization { (state) in
                DispatchQueue.main.async {
                    self.audioPlayer.songs = MPMediaQuery.songs().items ?? []
                    self.audioPlayerListTable.reloadData()
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
        // Adding observer for did change the current playing song
        NotificationCenter.default.addObserver(self, selector: #selector(playNotificationMethod), name: NSNotification.Name(rawValue: NSNotification.Name.TMAVPlayerSongDidStartPlaying), object: nil)
        
        // Catch the play state changed actions
        NotificationCenter.default.addObserver(self, selector: #selector(playBackStateChanged), name: NSNotification.Name(rawValue: NSNotification.Name.TMAVPlayerPlayStateChanged), object: nil)
        
        // Timer to update the song progress
        self.audioTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentPlayTime), userInfo: nil, repeats: true)
    }
    
    
    deinit {
        // Remove observer for the class here
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - PlayBack Button Actions -
    @IBAction func playAndPause(_ sender: Any) {
        // Change play and pause button titles
        let button = sender as! UIButton
        button.isSelected = !(button.isSelected)
        if selectedIndex > -1 {
            if button.isSelected {
                playAndPauseButton.setImage(UIImage.init(named: "pausePlayer"), for: .normal)
            } else {
                playAndPauseButton.setImage(UIImage.init(named: "videoPLayer"), for: .normal)
            }
            
            audioPlayer.playBack()
        }
        
    }
    
    @IBAction func playNextButton(_ sender: UIButton) {
        if selectedIndex > -1 {
            playAndPauseButton.setImage(UIImage.init(named: "pausePlayer"), for: .normal)
            audioPlayer.next()
        }
        
    }
    
    @IBAction func playPreviousButton(_ sender: UIButton) {
        if selectedIndex > -1 {

            playAndPauseButton.setImage(UIImage.init(named: "pausePlayer"), for: .normal)
            audioPlayer.previous()
        }
    }
    
    @IBAction func seekSlderAction(_ sender: UISlider) {
        if selectedIndex > -1 {
            audioPlayer.seekToTime(time: sender.value)
        }
        
    }
    
    @IBAction func volumeChangeSlider(_ sender: UISlider) {
       let volumeView = MPVolumeView()
        volumeView.volumeSlider.value = sender.value
    }
    
    // MARK: - Observer method
    func playNotificationMethod() {
        songLabel.text = audioPlayer.currentPlayingItemTitle
        // Change play button state if audio is already playing
        if audioPlayer.isAudioPlaying {
            playAndPauseButton.isSelected = true
        }
        // Intialize the slider every time when new song is getting played
        seekSlider.minimumValue = 0.0
        seekSlider.maximumValue = Float(audioPlayer.currentPlayingItem?.playbackDuration ?? 0.0)
        seekSlider.value = audioPlayer.currentPlayingTime
    }
    
    func playBackStateChanged() {
        if audioPlayer.isAudioPlaying {
            playAndPauseButton.isSelected = true
        }
        else {
            playAndPauseButton.isSelected = false
        }
    }
    
    func updateCurrentPlayTime() {
        if audioPlayer.isAudioPlaying {
            seekSlider.value = audioPlayer.currentPlayingTime
            
            let totalDuration = self.audioPlayer.getTotalPlayingItemDuration()
            let remainingTime = totalDuration - ((audioPlayer.currentPlayingTime)/60.0)
            debugPrint(totalDuration)
            debugPrint("seekslider: \(remainingTime)")
            self.remainingTimeLabel.text =  String.init(format: "-%.2f",remainingTime)
        }
    }
    
    //MARK: - Memory Warning -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioPlayer.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SongCell"
        var songCell: UITableViewCell!
        songCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if nil == songCell {
            songCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            songCell.textLabel?.textColor = .black
            songCell.selectionStyle = .none
        }
        songCell.textLabel?.text = audioPlayer.songs[indexPath.row].title
        
        return songCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        audioPlayer.prepareToPlay(songIndex: indexPath.row)
        
        self.currentTimeLabel.text = String.init(format: "%.2f", self.audioPlayer.getTotalPlayingItemDuration())
       
        playAndPauseButton.setImage(UIImage.init(named: "pausePlayer"), for: .normal)
        playAndPauseButton.isSelected = true
    }
    
}


