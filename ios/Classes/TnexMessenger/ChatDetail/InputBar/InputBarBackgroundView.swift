//
//  InputBarBackgroundView.swift
//  tnexchat
//
//  Created by MacOS on 05/03/2022.
//

import Foundation

class InputBarBackgroundView: UIView {
    var shapeLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow(on: self)
    }
    
    func updateShadow(on background: UIView) {
        self.shapeLayer?.removeFromSuperlayer()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curveShapePath(postion: 20, offset: 2)
            shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.fromHex("#01072F").cgColor
        self.layer.addSublayer(shapeLayer)
        shapeLayer.shadowRadius = 5.0
        shapeLayer.shadowColor = UIColor(red: 0.325, green: 0.853, blue: 1, alpha: 1).cgColor
        shapeLayer.shadowOpacity = 0.1
        self.shapeLayer = shapeLayer
    }

    func curveShapePath(postion: CGFloat, offset: CGFloat) -> CGPath {
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: postion, y: offset + postion), radius: postion, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3.0 / 2.0, clockwise: true)
        path.addArc(withCenter: CGPoint(x: self.bounds.width - postion, y: postion + offset), radius: postion, startAngle: CGFloat.pi * 3.0 / 2.0, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: self.frame.width, y: postion))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        return path.cgPath
    }
}
