//
//  CreateCardCameraViewController.swift
//  CardsKit
//
//  Created by Luke Street on 3/8/19.
//

import UIKit
import AVFoundation

public protocol LockLandscape: class {}

internal class CreateCardCameraViewController: UIViewController, LockLandscape {
    
    private var session: AVCaptureSession = {
        let sess = AVCaptureSession()
        sess.sessionPreset = .photo
        return sess
    }()
    
    private let photoOutput = AVCapturePhotoOutput()
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return layer
    }()
    
    private lazy var overlayLayer: CAShapeLayer = {
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = view.backgroundColor?.cgColor
        fillLayer.opacity = 0.5
        return fillLayer
    }()
    
    private var takePhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(#imageLiteral(resourceName: "circle"), for: .normal)
        button.addTarget(self, action: #selector(tappedTakePhotoButton), for: .touchUpInside)
        return button
    }()
    
    private var cutoutFrame: CGRect {
        let height = self.view.layer.frame.height * 0.8
        let width = (height * 3.0) / 2.0
        let x = (self.view.layer.frame.width / 2.0) - (width / 2.0)
        let y = (self.view.layer.frame.height / 2.0) - (height / 2.0)
        return CGRect.init(x: x, y: y, width: width, height: height)
    }
    
    private var completion: (Card) -> Void
    
    init(completion: @escaping (Card) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        guard
            let backCamera =  AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: backCamera),
            session.canAddInput(input),
            session.canAddOutput(photoOutput) == true
        else {
            print("Could no set up camera!")
            return
        }
        
        updatePreviewLayer()
        
        session.addInput(input)
        session.addOutput(photoOutput)
        view.layer.addSublayer(videoPreviewLayer)
        view.layer.addSublayer(overlayLayer)
        session.startRunning()
        
        view.addSubview(takePhotoButton)
        takePhotoButton.center(.vertically, in: view)
        takePhotoButton.pin(.trailing, to: view, offsetBy: 25)
        takePhotoButton.size(width: 75, height: 75)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func updatePreviewLayer() {
        self.videoPreviewLayer.frame = self.view.layer.frame
        self.videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        
        let path = UIBezierPath(rect: self.view.layer.frame)
        
        let innerPath = UIBezierPath.init(rect: cutoutFrame)
        path.append(innerPath)
        path.usesEvenOddFillRule = true
        
        
        self.overlayLayer.path = path.cgPath
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.updatePreviewLayer()
        }, completion: nil)
        
        
    }
    
    @objc
    private func tappedTakePhotoButton() {
        photoOutput.capturePhoto(with: .init(), delegate: self)
        
    }
}

extension CreateCardCameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let outputRect = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: cutoutFrame)
        guard
            let cgImage = photo
                .cgImageRepresentation()?
                .takeUnretainedValue()
        else { return }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return }
        let image = UIImage(cgImage: croppedCGImage)//.imageRotatedByDegrees(degrees: 180, flip: false)
        
        Alien.convert(image) { result in
            do {
                let builder = try Current.createCardBuilder(try result.get())
                let createCardVC = CreateCardViewController(cardBuilder: builder, completion: self.completion)
                self.navigationController?.pushViewController(createCardVC, animated: true)
            } catch {
                print(error)
            }

        }
    }
}

extension UIImage {
    
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        //        let radiansToDegrees: (CGFloat) -> CGFloat = {
        //            return $0 * (180.0 / CGFloat.pi)
        //        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat.pi
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees))
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        
        bitmap?.draw(cgImage!, in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


extension UIDeviceOrientation {
    public var avCaptureOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .unknown, .faceUp, .faceDown:
            return .portrait
        }
    }
}

extension UIDevice {
    public func makePortrait() {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    public func makeLandscape() {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}
