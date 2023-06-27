//
//  Utils.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 01/01/2023.
//

import Foundation
import AVFoundation

class Utils {
    
    private var player: AVAudioPlayer!
    var lastSound: String?
    private var soundTimer: Timer?
    
    func playSound(resourceTitle: String, completion: @escaping () -> Void) {
        let url = Bundle.main.url(forResource: resourceTitle, withExtension: "mp3")
        
        guard url != nil else {
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.play()
            checkIfTrackIsFinished(completion: completion)
        } catch {
            print("error")
        }
    }
    
    func checkIfTrackIsFinished(completion: @escaping () -> Void) {
        if !player.isPlaying {
            completion()
        } else {
            // vérifier de nouveau dans une seconde
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.checkIfTrackIsFinished(completion: completion)
            }
        }
    }
    
    func getNextSound(sounds: inout [String]) -> String {
        for i in (1..<sounds.count).reversed() {
            let j = Int.random(in: 0..<i)
            sounds.swapAt(i, j)
        }
        while true {
            let randomSound = sounds.popLast()
            if lastSound == nil || lastSound != randomSound {
                lastSound = randomSound
                sounds.append(randomSound!)
                return randomSound!
            }
        }
    }
    
    
    func playSoundInLoop(interval: TimeInterval, completion: (() -> Void)? = nil) {
        soundTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            self.playSound(resourceTitle: "phone") {
                
            }
        }
        completion?()
    }
    
    func stopSoundInLoop() {
        soundTimer?.invalidate()
        soundTimer = nil
        //stopSound()
    }
}
