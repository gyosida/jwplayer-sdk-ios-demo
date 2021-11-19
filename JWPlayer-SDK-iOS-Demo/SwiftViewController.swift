//
//  SwiftViewController.swift
//  JWPlayer-SDK-iOS-Demo
//
//  Created by Amitai Blickstein on 2/26/19.
//  Copyright © 2019 JWPlayer. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController {
    
    @IBOutlet var tabBarContainerView: UIView?
    
    var tabBarVC: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarVC = UITabBarController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "playerVC")
        vc.tabBarItem = UITabBarItem(title: "Player", image: nil, selectedImage: nil)
        
        tabBarVC?.viewControllers = [
            buildDummyTabVC(index: 0),
            buildDummyTabVC(index: 1),
            // only this tab will hold a player, the others don't
            vc,
            buildDummyTabVC(index: 3),
            buildDummyTabVC(index: 4)
        ]
        tabBarContainerView?.addSubview(tabBarVC!.view)
        tabBarVC!.view.constrainToSuperview()
    }
    
    private func buildDummyTabVC(index: Int) -> WelcomeVC {
        let vc = WelcomeVC()
        vc.index = index
        vc.tabBarItem = UITabBarItem(title: "Welcome", image: nil, selectedImage: nil)
        return vc
    }
}

class PlayerVC: UIViewController, JWCastingDelegate {
    
    @IBOutlet weak var playerContainerView: UIView!
    var player: JWPlayerController!
    var chromecast: JWCastController!
    
    var casting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config: JWConfig  = JWConfig()
        let playList = JWPlaylistItem(config: config)
        playList.file = "http://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
        config.autostart = true
        config.playlist = [playList]
        
        // the player and the cast controller
        // only live in this context
        player = JWPlayerController(config: config)
        chromecast = JWCastController(player: player!)
        
        // scan for devices and suppose it was correctly
        // setup if want to understand the logic of casting bool
        chromecast.scanForDevices()
        
        playerContainerView.addSubview(player.view!)
        player.view!.constrainToSuperview()
    }
    
    func onCastingDevicesAvailable(_ devices: [JWCastingDevice]) {
        
    }
    
    func onCastingFailed(_ error: Error) {
        casting = false
    }
    
    func onCastingEnded(_ error: Error?) {
        casting = false
    }
    
    func onDisconnected(fromCastingDevice error: Error?) {
        casting = false
    }
    
    func onCasting() {
        casting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !casting {
            player.play()
        }
        print(">>>>>> view will appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // we need to know if is not casting to pause the player
        // and avoid playing playback on background while
        // another tab is selected
        if !casting {
            // we need to pause the playback
            // otherwise on the other tabs the audio stream will
            // be on background. A behavior we don't want.
            player.pause()
        }
        // we also need to know if the player is airplaying
        // content to manage the player in the same way
        print(">>>>>> view will dissapear")
    }
}

class WelcomeVC: UIViewController {
    
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = UILabel()
        text.text = "JWPlayer Test \(index)"
        text.bounds = CGRect(x: 50, y: 300, width: 150, height: 50)
        
        self.view.addSubview(text)
    }
}


// MARK: - Helper method

extension UIView {
    /// Constrains the view to its superview, if it exists, using Autolayout.
    /// - precondition: For player instances, JWP SDK 3.3.0 or higher.
    @objc func constrainToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])
        
        let verticalConstraints   = NSLayoutConstraint.constraints(withVisualFormat: "V:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
}
