//
//  RatingSystem.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/2/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit

class RatingSystem: UIView {
    
    var numStars: Int?
    
    init(numStars: Int?, rect: CGRect){
        self.numStars = numStars
        super.init(frame: rect)
        var x = 0
        let y = 0
        
        for i in 1...5 {
            let starLayer = CAShapeLayer()
            starLayer.path = drawStar(x:x, y:y).cgPath
            starLayer.lineWidth = 1
            starLayer.strokeColor = UIColor.black.cgColor
            if numStars == nil {
                starLayer.fillColor = UIColor.gray.cgColor
            }
            else if i <= numStars! {
                starLayer.fillColor = UIColor(red: 255, green: 194, blue: 0, alpha: 1.0).cgColor
            }
            else{
                starLayer.fillColor = UIColor.clear.cgColor
            }
            self.layer.addSublayer(starLayer)
            x+=45
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.numStars = 0
        super.init(coder: aDecoder)
    }
    
    func drawStar(x: Int, y: Int) -> UIBezierPath {
        let starOne = UIBezierPath()
        starOne.move(to: CGPoint(x: x+20, y: 0))
        starOne.addLine(to: CGPoint(x: x+15, y: 10))
        starOne.addLine(to: CGPoint(x: x+0, y: 10))
        starOne.addLine(to: CGPoint(x: x+10, y: 20))
        starOne.addLine(to: CGPoint(x: x+5, y: 35))
        starOne.addLine(to: CGPoint(x: x+20, y: 25))
        starOne.addLine(to: CGPoint(x: x+35, y: 35))
        starOne.addLine(to: CGPoint(x: x+30, y: 20))
        starOne.addLine(to: CGPoint(x: x+40, y: 10))
        starOne.addLine(to: CGPoint(x: x+25, y: 10))
        starOne.addLine(to: CGPoint(x: x+20, y: 0))
        starOne.close()
        starOne.lineWidth = 1
        starOne.stroke(with: CGBlendMode.normal, alpha: CGFloat(1.0))
        return starOne
    }
}
