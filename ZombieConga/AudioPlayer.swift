//
//  AudioPlayer.swift
//  ZombieConga
//
//  Created by Josh Cormier on 3/5/20.
//  Copyright © 2020 Josh Cormier. All rights reserved.
//

import AVFoundation

class AudioPlayer{
    private var audioPlayer: AVAudioPlayer!
    let filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    func play()
    {
        let resourceURL = Bundle.main.url(forResource: self.filename, withExtension: nil)
        guard let url = resourceURL else {
            print("Failed to load audio")
            return
        }
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        
        } catch {
            print("Could not create audio player")
            return
        }
    }
    
    func stop()
    {
        self.audioPlayer.stop()
    }
    
    
}
