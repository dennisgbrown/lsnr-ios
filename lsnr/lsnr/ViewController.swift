//
//  ViewController.swift
//  lsnr
//
//  Created by Dennis Brown on 8/16/19.
//  Copyright © 2019 Dennis Brown. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var waveView: UIImageView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    private var audioEngine: AVAudioEngine!
    
    private var mic: AVAudioInputNode!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "lsnr"
        
        var isAudioRecordingGranted = false;
        
        AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
            if allowed {
                isAudioRecordingGranted = true
            } else {
                isAudioRecordingGranted = false
            }
        })
        
        print("Can listen? ", isAudioRecordingGranted)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
        audioEngine = AVAudioEngine()
        mic = audioEngine.inputNode
        
        print("Number of inputs: ", mic.numberOfInputs)
        
        // This use of AVAudioEngine & mic tap inspired by https://stackoverflow.com/questions/30957434/how-to-capture-audio-samples-in-ios-with-swift
        // More on completion handlers: https://blog.bobthedeveloper.io/completion-handlers-in-swift-with-bob-6a2a1a854dc4
        
        // Install mic tap completion handler
        print("Installing mic tap")
        let micFormat = mic.inputFormat(forBus: 0)
        mic.installTap(onBus: 0, bufferSize: 2048, format: micFormat) { (buffer, when) in
            let sampleData = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
            print(sampleData.count)
            for crud in sampleData {
                print(". ", crud)
            }
        }
        
        
        // for example of timers and AVAudioRecorder (which does not seem to allow access to raw inputs), see https://stackoverflow.com/questions/31230854/ios-detect-blow-into-mic-and-convert-the-results-swift
        
        
        statusLabel.text = "Press START to listen"
    }
    
    //MARK: Actions
    
    @IBAction func startListening(_ sender: Any) {
        statusLabel.text = "LISTENING"
        
        // Start audio engine
        print("Starting audio engine")
        do {
            try audioEngine.start()
        } catch { }
    }
    
    
    @IBAction func stopListening(_ sender: Any) {
        statusLabel.text = "Press START to listen"

        print("Stopping audio engine")
        audioEngine.stop()
    }
}

