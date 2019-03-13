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
        button.setImage(#imageLiteral(resourceName: "circle"), for: .normal)
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
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        takePhotoButton.pin(.trailing, to: view, offsetBy: 15)
        takePhotoButton.size(width: 200, height: 200)
        
    }
    
    func updatePreviewLayer() {
        self.videoPreviewLayer.frame = self.view.layer.frame
        self.videoPreviewLayer.connection?.videoOrientation = UIDevice.current.orientation.avCaptureOrientation
        
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
        let cgimage = photo
            .cgImageRepresentation()?
            .takeUnretainedValue()
            //.cropping(to: cutoutFrame)
        if let image = cgimage.map(UIImage.init) {
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
}




extension UIDeviceOrientation {
    public var avCaptureOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .unknown, .faceUp, .faceDown:
            return .portrait
        }
    }
}
