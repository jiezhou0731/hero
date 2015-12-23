//
//  GameViewController.swift
//  Pierre Penguin Escapes the Antarctic
//

import UIKit
import SpriteKit
import AVFoundation
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
    if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {

        var sceneData: NSData?
        // Error occurs on the following line:
        do {
            sceneData = try  NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
        } catch _ as NSError {

        }

        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    } else {
        return nil
    }
}}

class GameViewController: UIViewController {
    var musicPlayer = AVAudioPlayer()
    let btn = UIButton(type: UIButtonType.Custom)
    
    func clickMe(sender:UIButton!)
    {
          let menuScene = GameScene()
        let skView = self.view as! SKView
        // Ignore drawing order of child nodes (performance increase)
        skView.ignoresSiblingOrder = true
        // Size our scene to fit the view exactly:
        menuScene.size = view.bounds.size
        // Show the menu:
        skView.presentScene(menuScene)
        btn.removeFromSuperview()
    }
    override func viewDidLoad() {
      
    
      btn.frame = CGRectMake(100, 100, 200, 100)
      btn.setImage(UIImage(named: "startButton"), forState: UIControlState.Normal)
      btn.addTarget(self, action: "clickMe:", forControlEvents: UIControlEvents.TouchUpInside)
      self.view.addSubview(btn)
      
     
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        ObjectPool.gameViewController = self
        // Build the menu scene:
       
        
        // Start the background music:
        /*
        let musicUrl = NSBundle.mainBundle().URLForResource("Sound/BackgroundMusic.m4a", withExtension: nil)
        if let url = musicUrl {
            do {
                try musicPlayer = AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
            }   catch  let error as NSError {
                print(error)
            }
            musicPlayer.numberOfLoops = -1
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        }
        */
       // authenticateLocalPlayer(menuScene)
    }
    
    // Create a function to authenticate the Game Center account
    // Because the authenticate response comes back asynchronously,
    // we will pass in the MenuScene instance so we can create a leaderboard
    // button if the player authenticates succesfully.
    func authenticateLocalPlayer(menuScene:MenuScene) {
        // Create a new Game Center localPlayer instance:
        let localPlayer = GKLocalPlayer.localPlayer();
        // Create a function to check if they are already authenticated
        // or show them the log in screen:
        localPlayer.authenticateHandler = {
            (viewController : UIViewController?, error : NSError?) -> Void in
            if viewController != nil {
                // They are not logged in, show the log in screen:
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
            else if localPlayer.authenticated {
                // They authenticated succesfully
                menuScene.createLeaderboardButton()
            }
            else {
                // They were not able to authenticate, we'll skip Game Center features
            }
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Landscape, UIInterfaceOrientationMask.LandscapeLeft]
        return orientation;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
