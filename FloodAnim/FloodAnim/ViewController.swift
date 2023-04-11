//
//  ViewController.swift
//  FloodAnim
//
//  Created by Don Mag on 4/5/23.
//

import UIKit

class demoViewController: UIViewController {
	
	let imgView = UIImageView()

	// the image view will be completely clear to begin with
	//	so we need a view to show where to tap
	let tapView = UIView()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		guard let img = UIImage(named: "sample") else {
			fatalError("Could not load image!")
		}
		
		let g = view.safeAreaLayoutGuide
		
		tapView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tapView)
		imgView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(imgView)
		
		NSLayoutConstraint.activate([
			
			// center the image view
			imgView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			imgView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
			// let's give it a width of 240
			imgView.widthAnchor.constraint(equalToConstant: 240.0),
			// use original image aspect ratio
			imgView.heightAnchor.constraint(equalTo: imgView.widthAnchor, multiplier: img.size.height / img.size.width),
			
			// "tap view" same frame as the image view
			tapView.topAnchor.constraint(equalTo: imgView.topAnchor),
			tapView.leadingAnchor.constraint(equalTo: imgView.leadingAnchor),
			tapView.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
			tapView.bottomAnchor.constraint(equalTo: imgView.bottomAnchor),

		])

		// so we can see the tap view frame
		tapView.backgroundColor = .systemBlue
		
		imgView.image = img
		
		// Image View starts with empty mask (so it is completely clear)
		imgView.layer.mask = CALayer()

		// tap gesture recognizer
		let tg = UITapGestureRecognizer(target: self, action: #selector(gotTap(_:)))
		tapView.addGestureRecognizer(tg)
	
		tapView.layer.cornerRadius = 20.0
		tapView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		
	}

	@objc func gotTap(_ gr: UITapGestureRecognizer) {
		// run the animation, using the tap point as the oval center
		animMask(imgView, pt: gr.location(in: tapView))
	}
	
	func animMask(_ v: UIView, pt: CGPoint) {

		// final oval mask has to cover the entire view
		let largeOvalRadius: CGFloat = sqrt((v.bounds.width * v.bounds.width) + (v.bounds.height * v.bounds.height))
		
		// small oval rect is 4x1 points, centered on the tapped point
		let smallOvalRect: CGRect = .init(x: pt.x - 2.0, y: pt.y, width: 4.0, height: 1.0)
		
		// large oval rect is small oval rect inset by the calculated radius
		let largeOvalRect: CGRect = smallOvalRect.insetBy(dx: -largeOvalRadius, dy: -largeOvalRadius)
		
		// shape layer to use as the layer mask
		let shape = CAShapeLayer()
		// can be any solid color
		shape.fillColor = UIColor.black.cgColor
		
		// set initial path to oval that covers entire view
		let pth = UIBezierPath(ovalIn: largeOvalRect).cgPath
		shape.path = pth
		shape.frame = v.bounds
		v.layer.mask = shape
		
		// animate the path on the mask layer
		let morphAnimation = CABasicAnimation(keyPath: "path")
		// from very small oval
		morphAnimation.fromValue = UIBezierPath(ovalIn: smallOvalRect).cgPath
		// to very large oval
		morphAnimation.toValue = UIBezierPath(ovalIn: largeOvalRect).cgPath
		// 3/4 second animation (for example)
		morphAnimation.duration = 0.75
		// we don't want any easing
		morphAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
		
		// start the animation
		shape.add(morphAnimation, forKey: nil)
		
	}
	
}


class dViewController: UIViewController {
	
	let imgViewA = UIImageView()
	let imgViewB = UIImageView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		guard let img0 = UIImage(named: "floodMe0"), let img1 = UIImage(named: "floodMe1") else {
			fatalError("Could not load image!")
		}
		
		let g = view.safeAreaLayoutGuide
		
		[imgViewA, imgViewB].forEach { v in
			v.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(v)
			
			NSLayoutConstraint.activate([
				v.centerXAnchor.constraint(equalTo: g.centerXAnchor),
				v.centerYAnchor.constraint(equalTo: g.centerYAnchor),
				v.widthAnchor.constraint(equalToConstant: img0.size.width),
				v.heightAnchor.constraint(equalToConstant: img0.size.height),
			])
			
		}
		
		imgViewA.image = img0
		imgViewB.image = img1
		
		// "top" image starts with empty mask (so it is completely clear)
		imgViewB.layer.mask = CALayer()
		
	}
	
	func animMask(_ v: UIView, pt: CGPoint) {
		
		
		let sz: CGSize = .init(width: 2.0, height: 1.0)
		let r1: CGRect = .init(origin: pt, size: sz)
		let r2: CGRect = r1.insetBy(dx: -v.bounds.width * 1.5, dy: -v.bounds.height)
		
		// shape layer to use as the layer mask
		let shape = CAShapeLayer()
		// can be any solid color
		shape.fillColor = UIColor.black.cgColor

		// set initial path to oval that covers entire view
		let pth = UIBezierPath(ovalIn: r2).cgPath
		shape.path = pth
		shape.frame = v.bounds
		v.layer.mask = shape
		
		// animate the path on the mask layer
		let morphAnimation = CABasicAnimation(keyPath: "path")
		// from very small oval (2 x 1 points)
		morphAnimation.fromValue = UIBezierPath(ovalIn: r1).cgPath
		// to very large oval
		morphAnimation.toValue = UIBezierPath(ovalIn: r2).cgPath
		// one-second animation
		morphAnimation.duration = 1.0
		// we don't want any easing
		morphAnimation.timingFunction = CAMediaTimingFunction(name: .linear)

		// start the animation
		shape.add(morphAnimation, forKey: nil)
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		animMask(imgViewB, pt: .init(x: 30.0, y: 90.0))
	}
	
}


class fViewController: UIViewController, CAAnimationDelegate {

	let imgViewA = FloodFillImageView()
	let imgViewB = UIImageView()
	let infoLabel = UILabel()
	
	var colors: [UIColor] = [
		.systemRed, .cyan, .yellow,
		.systemGreen, .systemBlue,
	]
	
	var origImage: UIImage = UIImage()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		guard let img = UIImage(named: "floodMe") else {
			fatalError("Could not load image!")
		}
		
		origImage = img
		
		let g = view.safeAreaLayoutGuide
		
		[imgViewA, imgViewB].forEach { v in
			v.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(v)
			
			NSLayoutConstraint.activate([
				v.centerXAnchor.constraint(equalTo: g.centerXAnchor),
				v.centerYAnchor.constraint(equalTo: g.centerYAnchor),
				v.widthAnchor.constraint(equalToConstant: img.size.width),
				v.heightAnchor.constraint(equalToConstant: img.size.height),
			])
			
			v.image = img
			
		}
		
		infoLabel.text = "Processing..."
		infoLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(infoLabel)
		NSLayoutConstraint.activate([
			infoLabel.topAnchor.constraint(equalTo: imgViewA.bottomAnchor, constant: 20.0),
			infoLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
		])
		
		infoLabel.isHidden = true

		imgViewA.tolorance = 16
		imgViewA.isUserInteractionEnabled = true
		imgViewB.isUserInteractionEnabled = false

		imgViewA.newcolor = nextColor()
		
		let tg = UITapGestureRecognizer(target: self, action: #selector(gotTap(_:)))
		imgViewA.addGestureRecognizer(tg)

	}

	func nextColor() -> UIColor {
		let c: UIColor = colors.removeFirst()
		colors.append(c)
		return c
	}
	@objc func gotTap(_ gr: UITapGestureRecognizer) {
		
		guard let img = imgViewB.image else { return }
		
		infoLabel.isHidden = false
		
		imgViewA.isUserInteractionEnabled = false
		
		imgViewB.layer.mask = CAShapeLayer()

		imgViewB.image = imgViewA.image
		imgViewA.image = img
		
		animMask(imgViewB, pt: gr.location(in: imgViewB))

		imgViewA.newcolor = nextColor()

	}
	
	func animMask(_ v: UIView, pt: CGPoint) {
		let shape = CAShapeLayer()
		shape.fillColor = UIColor.red.cgColor
		
		let sz: CGSize = .init(width: 2.0, height: 1.0)
		let r1: CGRect = .init(origin: pt, size: sz)
		let r2: CGRect = r1.insetBy(dx: -v.bounds.width * 1.5, dy: -v.bounds.height)
		
		let pth = UIBezierPath(ovalIn: r2).cgPath
		shape.path = pth
		shape.frame = v.bounds
		v.layer.mask = shape
		
		let morphAnimation = CABasicAnimation(keyPath: "path")
		morphAnimation.duration = 1.0
		morphAnimation.fromValue = UIBezierPath(ovalIn: r1).cgPath
		morphAnimation.toValue = UIBezierPath(ovalIn: r2).cgPath
		morphAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
		morphAnimation.delegate = self
		shape.add(morphAnimation, forKey: "reveal")
		
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		imgViewA.image = imgViewB.image
		imgViewA.isUserInteractionEnabled = true
		infoLabel.isHidden = true
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		imgViewA.image = origImage
		imgViewB.image = origImage
	}
}

class ViewController: UIViewController, CAAnimationDelegate {
	
	let imgViewA = UIImageView()
	let imgViewB = UIImageView()
	let infoLabel = UILabel()
	
	let bView = UIView()
	
	var colors: [UIColor] = [
		.systemRed, .cyan, .yellow,
		.systemGreen, .systemBlue,
	]
	
	var origImage: UIImage = UIImage()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		guard let img = UIImage(named: "floodMe") else {
			fatalError("Could not load image!")
		}
		
		origImage = img
		
		let g = view.safeAreaLayoutGuide
		
		[imgViewA, imgViewB].forEach { v in
			v.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(v)
			
			NSLayoutConstraint.activate([
				v.centerXAnchor.constraint(equalTo: g.centerXAnchor),
				//v.centerYAnchor.constraint(equalTo: g.centerYAnchor),
				v.topAnchor.constraint(equalTo: g.topAnchor, constant: 40.0),
				v.widthAnchor.constraint(equalToConstant: img.size.width),
				v.heightAnchor.constraint(equalToConstant: img.size.height),
			])
			
			v.image = img
			
		}
		
		infoLabel.text = "Processing..."
		infoLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(infoLabel)
		NSLayoutConstraint.activate([
			infoLabel.topAnchor.constraint(equalTo: imgViewA.bottomAnchor, constant: 20.0),
			infoLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
		])
		
		infoLabel.isHidden = true
		
		//imgViewA.tolorance = 16
		imgViewA.isUserInteractionEnabled = true
		imgViewB.isUserInteractionEnabled = false
		
		//imgViewA.newcolor = nextColor()
		
		let tg = UITapGestureRecognizer(target: self, action: #selector(gotTap(_:)))
		imgViewA.addGestureRecognizer(tg)
		
		bView.backgroundColor = .black.withAlphaComponent(0.5)
		bView.isUserInteractionEnabled = false
		view.addSubview(bView)
		bView.isHidden = true
		
	}
	
	func nextColor() -> UIColor {
		let c: UIColor = colors.removeFirst()
		colors.append(c)
		return c
	}
	@objc func gotTap(_ gr: UITapGestureRecognizer) {
		
		guard let img = imgViewB.image else { return }
//		imgViewA.image = img

		infoLabel.isHidden = false
		
		imgViewA.isUserInteractionEnabled = false
		
		imgViewB.layer.mask = CAShapeLayer()
		
		var thisRect: CGRect = .zero
		img.rTest(&thisRect)
		
		print()
		

		let newImg = img.floodFill(from: gr.location(in: imgViewA), with: nextColor(), andTolerance: 16, useAntiAlias: false, boundsRect: &thisRect)
		thisRect = thisRect.insetBy(dx: -1.0, dy: -1.0).offsetBy(dx: 1.0, dy: 1.0)
		print("thisRect:", thisRect)
	
		bView.frame = thisRect.offsetBy(dx: imgViewA.frame.origin.x, dy: imgViewA.frame.origin.y)
		
		imgViewB.image = newImg
		
		animMask(imgViewB, pt: gr.location(in: imgViewB), maskRect: thisRect)
		
	
		
		//imgViewA.newcolor = nextColor()
		
	}
	
	func xanimMask(_ v: UIView, pt: CGPoint) {
		let shape = CAShapeLayer()
		shape.fillColor = UIColor.red.cgColor
		
		let sz: CGSize = .init(width: 8.0, height: 1.0)
		let r1: CGRect = .init(origin: .init(x: pt.x - 4.0, y: pt.y), size: sz)
		let r2: CGRect = r1.insetBy(dx: -v.bounds.width * 1.5, dy: -v.bounds.height)
		
		let pth = UIBezierPath(ovalIn: r2).cgPath
		shape.path = pth
		shape.frame = v.bounds
		v.layer.mask = shape
		
		let morphAnimation = CABasicAnimation(keyPath: "path")
		morphAnimation.duration = 0.75
		morphAnimation.fromValue = UIBezierPath(ovalIn: r1).cgPath
		morphAnimation.toValue = UIBezierPath(ovalIn: r2).cgPath
		morphAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
		morphAnimation.delegate = self
		shape.add(morphAnimation, forKey: "reveal")
		
	}
	
	func animMask(_ v: UIView, pt: CGPoint, maskRect: CGRect? = .zero) {
		
		var bRect: CGRect = v.bounds
		if let r = maskRect {
			bRect = r
		}
		
		// final oval mask has to cover the entire view
		let largeOvalRadius: CGFloat = sqrt((bRect.width * bRect.width) + (bRect.height * bRect.height))
		
		// small oval rect is 4x1 points, centered on the tapped point
		let smallOvalRect: CGRect = .init(x: pt.x - 4.0, y: pt.y, width: 8.0, height: 1.0)
		
		// large oval rect is small oval rect inset by the calculated radius
		let largeOvalRect: CGRect = smallOvalRect.insetBy(dx: -largeOvalRadius, dy: -largeOvalRadius)
		
		// shape layer to use as the layer mask
		let shape = CAShapeLayer()
		// can be any solid color
		shape.fillColor = UIColor.black.cgColor
		
		// set initial path to oval that covers entire view
		let pth = UIBezierPath(ovalIn: largeOvalRect).cgPath
		shape.path = pth
		shape.frame = v.bounds
		v.layer.mask = shape
		
		let d = (bRect.width * bRect.height) / (v.bounds.width * v.bounds.height)
		
		// animate the path on the mask layer
		let morphAnimation = CABasicAnimation(keyPath: "path")
		// from very small oval
		morphAnimation.fromValue = UIBezierPath(ovalIn: smallOvalRect).cgPath
		// to very large oval
		morphAnimation.toValue = UIBezierPath(ovalIn: largeOvalRect).cgPath
		// 3/4 second animation (for example)
		morphAnimation.duration = 0.75 * d
		// we don't want any easing
		morphAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
		// we want to know when the animation finishes
		morphAnimation.delegate = self

		// start the animation
		shape.add(morphAnimation, forKey: nil)
		
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		imgViewA.image = imgViewB.image
		imgViewA.isUserInteractionEnabled = true
		imgViewB.layer.mask = CALayer()
		infoLabel.isHidden = true
	}
	
//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print("touch")
//		imgViewA.image = origImage
//		imgViewB.image = origImage
//	}
}

