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
    
    private var renderer: UIGraphicsImageRenderer!
    
    private var isListening: Bool!
    
    //private var loudestAudioVal = Float(0.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "lsnr"

        isListening = false;
        
        // Set up the waveform renderer
        let width = 280  // yay, hard-coded values; fix later
        let height = 250
        renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let img = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        waveView.image = img
        print("image width: ", waveView.image!.size.width)
        print("image height: ", waveView.image!.size.height)
        
        // Check for audio recording permission but just continue on anyway for now
        var isAudioRecordingGranted = false;
        AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
            if allowed {
                isAudioRecordingGranted = true
            } else {
                isAudioRecordingGranted = false
            }
        })
        print("Can listen? ", isAudioRecordingGranted)

        // Create the audio engine and initialize mic
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
        audioEngine = AVAudioEngine()
        let mic = audioEngine.inputNode
        print("Number of inputs: ", mic.numberOfInputs)
        
        // This use of AVAudioEngine & mic tap inspired by https://stackoverflow.com/questions/30957434/how-to-capture-audio-samples-in-ios-with-swift
        // More on completion handlers: https://blog.bobthedeveloper.io/completion-handlers-in-swift-with-bob-6a2a1a854dc4
        
        // Install mic tap completion handler to draw the audio buffer
        print("Installing mic tap")
        let micFormat = mic.inputFormat(forBus: 0)
        mic.installTap(onBus: 0, bufferSize: 2048, format: micFormat) { (buffer, when) in
            DispatchQueue.main.async {
                // Draw the current audio buffer
                self.drawWaveform(buffer: buffer)
            }
        }
        
        // Personal note: for example of timers and AVAudioRecorder (which does not seem to allow access to raw inputs), see https://stackoverflow.com/questions/31230854/ios-detect-blow-into-mic-and-convert-the-results-swift
        
        statusLabel.text = "Press START to listen"
    }
    
    //MARK: Actions
    
    @IBAction func startListening(_ sender: Any) {
        if (!isListening) {
            statusLabel.text = "LISTENING"
            
            // Start audio engine.
            print("Starting audio engine")
            do {
                try audioEngine.start()
            } catch { }
            
            isListening = true;
        }
    }
    
    
    @IBAction func stopListening(_ sender: Any) {
        if (isListening) {
            statusLabel.text = "Press START to listen"
            
            // Stop audio engine.
            print("Stopping audio engine")
            audioEngine.stop()

            isListening = false;
        }
    }
    
    
    // Given an audio buffer, draw it on the waveform view.
    func drawWaveform(buffer: AVAudioPCMBuffer) {
        //print("Buffer length: ", buffer.frameLength)
        
        let width = waveView.image!.size.width
        let height = waveView.image!.size.height
        
        let audioData = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength)))

        // Length of audioData is probably not the same as the width of the canvas,
        // so determine value to increment audioBuffer index as we iterate across the canvas width.
        let incrementValue = (Float)((Float(audioData.count) / (Float(width))))
        var currElement = Int(0)

        // Set values used to scale the current audio element to the image height
        //let maxAudioValue = Float(65.97098)
        let maxAudioValue = Float(10) // some magic garbage going on here; fix later
        var drawHeight = CGFloat(0)
        
        let img = renderer.image { ctx in
            
            // For each column of the image, draw the audioData value that maps to that column
            // scaled to fit the height of the canvas.
            for i in 0...Int(width - 1) {
                //print("Data[ ", i, "]: ", audioData[i]);
                ctx.cgContext.move(to: CGPoint(x: CGFloat(i), y: (height / 2)))
                currElement = (Int)(incrementValue * (Float)(i))
                drawHeight = CGFloat(CGFloat(height / 2) + (CGFloat(height / 2) * CGFloat(audioData[currElement] / maxAudioValue)))
                ctx.cgContext.addLine(to: CGPoint(x: CGFloat(i), y: drawHeight))
                ctx.cgContext.setLineWidth(1)
                ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                ctx.cgContext.strokePath()
                
                //if (abs(audioData[(Int)(incrementValue * (Float)(i))]) > loudestAudioVal) {
                //    loudestAudioVal = abs(audioData[(Int)(incrementValue * (Float)(i))])
                //}
            }
            
            // Draw center line
            ctx.cgContext.move(to: CGPoint(x: 0, y: (height / 2)))
            ctx.cgContext.addLine(to: CGPoint(x: width - 1, y: (height / 2)))
            ctx.cgContext.setLineWidth(1)
            ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
            ctx.cgContext.strokePath()

            //print("Max audio val: ", loudestAudioVal)
        }
 
        // Set the image into the view
        waveView.image = img
    }
}

