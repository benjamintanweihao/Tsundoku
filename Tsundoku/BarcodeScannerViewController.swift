import UIKit
import AVFoundation

class BarcodeScannerViewController : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a session object
        session = AVCaptureSession()
        
        // Set the capture device
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Create input object
        let videoInput: AVCaptureDeviceInput!
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // Add input to the session
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            scanningNotPossible()
        }
        
        // Create output object
        let metadataOutput = AVCaptureMetadataOutput()
        
        // Add output to the session
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            // Send captured data to the delegate object via a serial queue.
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Set barcode type for which to scan: EAN 13
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
        } else {
            scanningNotPossible()
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Begin the capture session
        session.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        session.startRunning()
    }
    
    func scanningNotPossible() {
        let alert = UIAlertController(title: "Can't scan barcode", message: "Device doesn't have a camera", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        session = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Get the first object from the metadataObjects array.
        if let barcodeData = metadataObjects.first {
            
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            if let readableCode = barcodeReadable {
                print("*** BARCODE ***")
                
                let readableCodeEntry = readableCode.stringValue
                
                print(readableCodeEntry!)
                
                let alert = UIAlertController(title: "Add to Library?", message: readableCodeEntry, preferredStyle: .alert)
                // TODO: Search Amazon for more information
                alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
                    let libraryVC = self.storyboard?.instantiateViewController(withIdentifier: "LibraryViewController") as! LibraryViewController
                    libraryVC.barcodeEntry = readableCodeEntry
                    self.navigationController?.pushViewController(libraryVC, animated: true)
                })
                
                self.present(alert, animated: true, completion: nil)
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            session.stopRunning()
        }
    }
    
    
}
