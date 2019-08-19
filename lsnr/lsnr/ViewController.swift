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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "lsnr"
        
        statusLabel.text = "Press START to listen"
    }

    //MARK: Actions
    
    
    @IBAction func startListening(_ sender: Any) {
        
        statusLabel.text = "LISTENING"
        
        print("HELLO!!!!!!!!!!")
        
        
        // Create the capture session.
        let captureSession = AVCaptureSession()

        print("DERP")

        // Add audio input.
        do {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                print("it's still garbage")
                return
            }
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if captureSession.canAddInput(audioDeviceInput) {
                captureSession.addInput(audioDeviceInput)
            }
            else {
                print("Could not add audio device input to the session")
            }
        }
        catch {
            print("Could not create audio device input: \(error)")
        }
        
        print("DERP2")
        

        print("Start running...")
        captureSession.startRunning()
        print("Finished start running...")

        while(true){
            print("derp ", captureSession.outputs.count)
        }
    }
    
    
    @IBAction func stopListening(_ sender: Any) {
        
        statusLabel.text = "Press START to listen"
    }
    
}

