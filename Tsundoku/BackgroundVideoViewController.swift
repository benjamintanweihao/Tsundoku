import UIKit
import AVKit
import AVFoundation

class BackgroundVideoViewController: UIViewController {
    
    @IBOutlet weak var scanBarcodeButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanBarcodeButton.layer.cornerRadius = 4
        libraryButton.layer.cornerRadius = 4
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
        navigationBar?.isTranslucent = true
        
        let path = Bundle.main.path(forResource: "backgroundVideo", ofType: "mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        player?.actionAtItemEnd = .none
        player?.isMuted = true
     
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = self.view.frame
        
        view.layer.addSublayer(playerLayer)
        
        player?.play()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(BackgroundVideoViewController.loopVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    func loopVideo() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
}
