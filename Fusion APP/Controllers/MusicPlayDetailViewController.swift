//
//  MusicPlayDetailViewController.swift
//  Fusion APP
//
//  Created by Cooper on 2020/11/15.
//

import UIKit
import AVFoundation


class MusicPlayDetailViewController: UIViewController {
    
    
    var songs = [MusicInfo]()
    var songIndex: Int!
    
    //MARK: PLAYER
    var player = AVPlayer()
    var playerItem: AVPlayerItem!
    var timeObserverToken: Any?
    
    var isPlaying = true
    
    //MARK: for progressBar's time
    var timer = Timer()
    var currentTimeInSec: Float!
    var totalTimeInSec: Float!
    var remainingTimeInSec: Float!
    
    //MARK: OUTLETS
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    
    @IBOutlet var trackTimeLabel: [UILabel]!
    
    @IBOutlet var playButtons: [UIButton]!
    
    @IBOutlet weak var songProgress: UIProgressView!
    
    
    
    
    // MARK: - Volume Setting
    @IBAction func volumeButtons(_ sender: UIButton) {
        if sender.tag == 11 {
            player.isMuted = true
        } else {
            player.isMuted = false
        }
    }
    
    @IBAction func volumeSlider(_ sender: UISlider) {
        let sliderValue = sender.value
        player.volume = sliderValue
    }
    
  
    //MARK:Play Buttons Action
    @IBAction func musicControlButtons(_ sender: UIButton) {
        switch sender.tag {
        //左邊的倒退
        case 1:
            if songIndex == 0 {
                songIndex = songs.count - 1
            } else {
                songIndex -= 1
            }
            
            playButtons[1].setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playMusic()
            
        //中間的播放/暫停
        case 2:
            isPlaying ? player.pause() : player.play()
            sender.setImage(UIImage(systemName: isPlaying ? "play.fill" :  "pause.fill"), for: .normal)
            isPlaying = !isPlaying
           
        //右邊的快進
        case 3:
            if songIndex == songs.count - 1 {
                songIndex = 0
            } else {
                songIndex += 1
            }
            
            playButtons[1].setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playMusic()

            
        default:
            print("playButton error")
        }
    }
    
    
    func playMusic () {
        removePeriodicTimeObserver()
        
        //Play Music
        let songURL = songs[songIndex].previewUrl
        playerItem = AVPlayerItem(url: songURL)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        // Update song info
        DispatchQueue.main.async {
            self.updateInfo()
        }
        
        //FetchAlbumImage
        URLSession.shared.dataTask(with: songs[songIndex].artworkUrl1000) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    self.albumImage.image = UIImage(data: data)
                }
            }
        }.resume()
        
        // Time observer
        addPeriodicTimeObserver()
        
    }
    
    func updateInfo() {
        let currentSong = songs[songIndex]
        songName.text = currentSong.trackName
        artistName.text = currentSong.artistName
    }
    
    // MARK: - Music Progress
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            let duration = self?.playerItem.asset.duration
            let second = CMTimeGetSeconds(duration!)
            self!.totalTimeInSec = Float(second)
            
            let songCurrentTime = self?.player.currentTime().seconds
            self!.currentTimeInSec = Float(songCurrentTime!)
            
            self!.updateProgressUI()
            
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func updateProgressUI() {
        
        if currentTimeInSec == totalTimeInSec {
            removePeriodicTimeObserver()
        } else {
            remainingTimeInSec = totalTimeInSec - currentTimeInSec
            trackTimeLabel[0].text = timeConverter(currentTimeInSec)
            trackTimeLabel[1].text = "-\(timeConverter(remainingTimeInSec))"
            songProgress.progress = currentTimeInSec / totalTimeInSec
        }
        
    }
    
    func timeConverter(_ timeInSecond: Float) -> String {
        let minute = Int(timeInSecond) / 60
        let second = Int(timeInSecond) % 60
        
        return second < 10 ? "\(minute):0\(second)" : "\(minute):\(second)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MusicController.shared.fetchMusic { (music) in
            self.songs = music!
            self.playMusic()
        }
        
        // AV Player的監聽音樂是否播放完畢
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] (notification) in
            
            if self?.songIndex == (self?.songs.count)! - 1 {
                self?.songIndex = 0
            } else {
                self?.songIndex += 1
            }
            
            self?.playMusic()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removePeriodicTimeObserver()
    }
}
