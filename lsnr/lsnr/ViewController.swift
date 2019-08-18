//
//  ViewController.swift
//  lsnr
//
//  Created by Dennis Brown on 8/16/19.
//  Copyright © 2019 Dennis Brown. All rights reserved.
//

import UIKit

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
    }


}

