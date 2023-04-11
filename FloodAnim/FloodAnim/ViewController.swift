//
//  ViewController.swift
//  FloodAnim
//
//  Created by Don Mag on 4/5/23.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {
	
	let bottomImageView = UIImageView()
	let topImageView = UIImageView()
	let infoLabel = UILabel()
	
	var colors: [UIColor] = [
		.systemRed, .cyan, .yellow,
		.systemGreen, .systemBlue,
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		guard let img = UIImage(named: "floodMe") else {
			fatalError("Could not load image!")
		}
		
		let g = view.safeAreaLayoutGuide
		
		[bottomImageView, topImageView].forEach { v in
			
			v.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(v)
			
			NSLayoutConstraint.activate([
				v.centerXAnchor.constraint(equalTo: g.centerXAnchor),
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
			infoLabel.topAnchor.constraint(equalTo: bottomImageView.bottomAnchor, constant: 20.0),
			infoLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
		])
		
		infoLabel.isHidden = true
		
		bottomImageView.isUserInteractionEnabled = true
		topImageView.isUserInteractionEnabled = false
		
		let tg = UITapGestureRecognizer(target: self, action: #selector(gotTap(_:)))
		bottomImageView.addGestureRecognizer(tg)
		
	}
	
	func nextColor() -> UIColor {
		let c: UIColor = colors.removeFirst()
		colors.append(c)
		return c
	}
	
	@objc func gotTap(_ gr: UITapGestureRecognizer) {
		
		guard let img = bottomImageView.image else { return }

		infoLabel.isHidden = false
		
		// we're not allowing another tap until we've finished revealing the new image
		bottomImageView.isUserInteractionEnabled = false
		
		// empty mask for top image view (so it's clear)
		topImageView.layer.mask = CALayer()
		
		var thisRect: CGRect = .zero

		// flood fill
		let newImg = img.floodFill(from: gr.location(in: bottomImageView), with: nextColor(), andTolerance: 16, useAntiAlias: false, boundsRect: &thisRect)

		thisRect = thisRect.insetBy(dx: -1.0, dy: -1.0).offsetBy(dx: 1.0, dy: 1.0)
	
		// set top image view to the newly modified image
		topImageView.image = newImg
		
		// reveal animation
		animMask(topImageView, pt: gr.location(in: topImageView), maskRect: thisRect)
		
	}
	
	func animMask(_ v: UIView, pt: CGPoint, maskRect: CGRect? = .zero) {
		
		var boundingRect: CGRect = v.bounds
		if let r = maskRect {
			boundingRect = r
		}
		
		// final oval mask has to cover the entire changed area (bounding rectangle)
		let largeOvalRadius: CGFloat = sqrt((boundingRect.width * boundingRect.width) + (boundingRect.height * boundingRect.height))
		
		// small oval rect is 8x1 points, centered on the tapped point
		let smallOvalRect: CGRect = .init(x: pt.x - 4.0, y: pt.y, width: 8.0, height: 1.0)
		
		// large oval rect is small oval rect inset by the calculated radius
		let largeOvalRect: CGRect = smallOvalRect.insetBy(dx: -largeOvalRadius, dy: -largeOvalRadius)
		
		// shape layer to use as the layer mask
		let shapeLayer = CAShapeLayer()
		// can be any solid color
		shapeLayer.fillColor = UIColor.black.cgColor
		
		// set initial path to oval that covers entire view
		shapeLayer.path = UIBezierPath(ovalIn: largeOvalRect).cgPath
		shapeLayer.frame = v.bounds
		v.layer.mask = shapeLayer
		
		// we want the animation to take 3/4 of a second (for example)
		//	for the FULL image... so,
		//	shorten the duration for smaller rectangles
		let durationAdjustment = (boundingRect.width * boundingRect.height) / (v.bounds.width * v.bounds.height)
		let duration = 0.75 * durationAdjustment
		
		// animate the path on the mask layer
		let morphAnimation = CABasicAnimation(keyPath: "path")
		// from very small oval
		morphAnimation.fromValue = UIBezierPath(ovalIn: smallOvalRect).cgPath
		// to very large oval
		morphAnimation.toValue = UIBezierPath(ovalIn: largeOvalRect).cgPath
		// animation duration
		morphAnimation.duration = duration
		// we don't want any easing
		morphAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
		// we want to know when the animation finishes
		morphAnimation.delegate = self

		// start the animation
		shapeLayer.add(morphAnimation, forKey: nil)
		
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		// update bottom image view
		bottomImageView.image = topImageView.image
		// re-enable interaction
		bottomImageView.isUserInteractionEnabled = true
		// reset top image view empty mask
		topImageView.layer.mask = CALayer()
		// hide the "Processing..." label
		infoLabel.isHidden = true
	}
	
}

