//
//  ViewController.swift
//  CoreTextWrapperTest
//
//  Created by huse on 11/08/20.
//  Copyright © 2020 huse. All rights reserved.
//


/*
 
 https://developer.apple.com/documentation/quartzcore/cashapelayer
 
 Core Animation > CAShapeLayer
 
 > strokeStart
 
 The relative location at which to begin stroking the path. Animatable.
 
 The value of this property must be in the range 0.0 to 1.0. The default value of this property is 0.0.
 Combined with the strokeEnd property, this property defines the subregion of the path to stroke. The value in this property indicates the relative point along the path at which to begin stroking while the strokeEnd property defines the end point. A value of 0.0 represents the beginning of the path while a value of 1.0 represents the end of the path. Values in between are interpreted linearly along the path length.
 
 > strokeEnd
 
 The relative location at which to stop stroking the path. Animatable.
 
 The value of this property must be in the range 0.0 to 1.0. The default value of this property is 1.0.
 Combined with the strokeStart property, this property defines the subregion of the path to stroke. The value in this property indicates the relative point along the path at which to finish stroking while the strokeStart property defines the starting point. A value of 0.0 represents the beginning of the path while a value of 1.0 represents the end of the path. Values in between are interpreted linearly along the path length.
 */


/* Defines how the timed object behaves outside its active duration.
 * Local time may be clamped to either end of the active duration, or
 * the element may be removed from the presentation. The legal values
 * are `backwards', `forwards', `both' and `removed'. Defaults to
 * `removed'. */

/*
 extension CAMediaTimingFillMode {

     @available(iOS 2.0, *)
     public static let forwards: CAMediaTimingFillMode

     @available(iOS 2.0, *)
     public static let backwards: CAMediaTimingFillMode

     @available(iOS 2.0, *)
     public static let both: CAMediaTimingFillMode

     @available(iOS 2.0, *)
     public static let removed: CAMediaTimingFillMode
 }


 (1). kCAFillModeForwards（swift中为CAMediaTimingFillMode.forwards）：保持结束时状态，需要保持结束时的状态，需要将removedOnCompletion的设置为false，removedOnCompletion的为true，即动画完成后移除
 (2). kCAFillModeBackwards（swift中为CAMediaTimingFillMode.backwards）：保持开始时状态，设置为该值，将会立即执行动画的第一帧，不论是否设置了 beginTime属性。
 (3). kCAFillModeBoth（swift中为CAMediaTimingFillMode.both）：保持两者，实际使用中与kCAFillModeBackwards相同
 (4). kCAFillModeRemoved（swift中为CAMediaTimingFillMode.removed）：移除，默认为这个值，动画将在设置的 beginTime 开始执行（如没有设置beginTime属性，则动画立即执行），动画执行完成后将会layer的改变恢复原状。
 */
import UIKit

class ViewController: UIViewController {
    
    let ctView = TextBoxesView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(ctView)
        ctView.isHidden = true
    }
    
    var charLayers = [CAShapeLayer]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for layer in self.charLayers {
            layer.removeFromSuperlayer()
        }
        
        let stringAttributes = [ NSAttributedString.Key.font: UIFont(name: "Futura-CondensedExtraBold", size: 64.0)! ]
        let attributedString = NSMutableAttributedString(string: "Hello World", attributes: stringAttributes )
        let charPaths = self.characterPaths(attributedString: attributedString, position: CGPoint(x: 24, y: 192))
        
        self.charLayers = charPaths.map { path -> CAShapeLayer in
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 2
            shapeLayer.path = path
            return shapeLayer
        }
        
        let serialQueue = DispatchQueue(label: "Serial")
        let semaphore = DispatchSemaphore(value: 1)
        for (index, layer) in self.charLayers.enumerated() {
            serialQueue.async {
                semaphore.wait()
                
                print("this is NO.\(index), current thread name is \(Thread.current)")
                print("index:\(index), layer:\(layer)")

                DispatchQueue.main.sync {
                    let animation = CABasicAnimation(keyPath: "strokeEnd")//strokeEnd、strokeStart
                    animation.fromValue = 0
                    animation.toValue = 1.0
                    animation.duration = 1
                    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    animation.fillMode = .forwards
                    animation.isRemovedOnCompletion = true
                    //animation.beginTime = animation.duration * Double(index)
                    layer.add(animation, forKey: "charAnimation")
                    
                    layer.opacity = 0
                    
                    let animation2 = CABasicAnimation(keyPath: "opacity")//strokeEnd、strokeStart
                    animation2.fromValue = 0
                    animation2.toValue = 1.0
                    animation2.duration = 1
                    animation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    animation2.fillMode = .forwards
                    animation2.isRemovedOnCompletion = false
                    //animation2.beginTime = animation.duration * Double(index)
                    layer.add(animation2, forKey: "opacityAnimation")
                    
                    self.view.layer.addSublayer(layer)

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animation.duration) {
                        semaphore.signal()
                    }
                }
            }
        }
        
        for (index, layer) in self.charLayers.enumerated().reversed() {
            serialQueue.async {
                semaphore.wait()
                
                print("this is NO.\(index), current thread name is \(Thread.current)")
                print("index:\(index), layer:\(layer)")

                DispatchQueue.main.sync {
                    let animation = CABasicAnimation(keyPath: "strokeStart")//strokeEnd、strokeStart
                    animation.fromValue = 1.0
                    animation.toValue = 0
                    animation.duration = 1
                    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    animation.fillMode = .forwards
                    animation.isRemovedOnCompletion = true
                    //animation.beginTime = animation.duration * Double(index)
                    layer.add(animation, forKey: "charAnimation")
                    
                    layer.opacity = 0
                    
                    let animation2 = CABasicAnimation(keyPath: "opacity")//strokeEnd、strokeStart
                    animation2.fromValue = 1.0
                    animation2.toValue = 0
                    animation2.duration = 1
                    animation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    animation2.fillMode = .forwards
                    animation2.isRemovedOnCompletion = true
                    //animation2.beginTime = animation.duration * Double(index)
                    layer.add(animation2, forKey: "opacityAnimation")

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animation.duration) {
                        layer.removeFromSuperlayer()
                        
                        semaphore.signal()
                    }
                }
            }
        }
        
        serialQueue.async {
            semaphore.wait()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.ctView.isHidden = false
                
                semaphore.signal()
            }
        }
    }
    
    func characterPaths(attributedString: NSAttributedString, position: CGPoint) -> [CGPath] {
        
        let line = CTLineCreateWithAttributedString(attributedString)
        
        guard let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun] else { return []}
        
        var characterPaths = [CGPath]()
        
        for glyphRun in glyphRuns {
            guard let attributes = CTRunGetAttributes(glyphRun) as? [String:AnyObject] else { continue }
            let font = attributes[kCTFontAttributeName as String] as! CTFont
            
            for index in 0..<CTRunGetGlyphCount(glyphRun) {
                let glyphRange = CFRangeMake(index, 1)
                
                var glyph = CGGlyph()
                CTRunGetGlyphs(glyphRun, glyphRange, &glyph)
                
                var characterPosition = CGPoint()
                CTRunGetPositions(glyphRun, glyphRange, &characterPosition)
                characterPosition.x += position.x
                characterPosition.y += position.y
                
                if let glyphPath = CTFontCreatePathForGlyph(font, glyph, nil) {
                    var transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: characterPosition.x, ty: characterPosition.y)
                    if let charPath = glyphPath.copy(using: &transform) {
                        characterPaths.append(charPath)
                    }
                }
            }
        }
        return characterPaths
    }
    
}




///Todo: Put this on a separate file:

class TextBoxesView: UIView {
    
    
    let font = UIFont.systemFont(ofSize: 40)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        
        context.textMatrix = .identity
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        
        //       let string = "｜優勝《ゆうしょう》の｜懸《か》かった｜試合《しあい》。｜Test《テスト》.\nThe quick brown fox jumps over the lazy dog. 12354567890 @#-+"
        
        let string = "| été à | Śledź swoją przesyłkę | 龍飛鳳舞 | 優勝《ゆうしょう》の｜懸《か》かった｜試合《しあい》。｜Test《テスト》.\nThe quick brown fox jumps over the lazy dog. 12354567890 @#-+"
        
        
        let attributedString = Utility.sharedInstance.furigana(String: string)
        
        let range = attributedString.mutableString.range(of: attributedString.string)
        
        attributedString.addAttribute(.font, value: font, range: range)
        
        
        let framesetter = attributedString.framesetter()
        
        let textBounds = self.bounds.insetBy(dx: 20, dy: 30)
        let frame = framesetter.createFrame(textBounds)
        
        //Draw the frame text:
        
        frame.draw(in: context)
        
        let origins = frame.lineOrigins()
        
        let lines = frame.lines()
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.7)
        
        for i in 0 ..< origins.count {
            
            let line = lines[i]
            
            for run in line.glyphRuns() {
                
                let font = run.font
                let glyphPositions = run.glyphPositions()
                let glyphs = run.glyphs()
                
                let glyphsBoundingRects =  font.boundingRects(of: glyphs)
                
                //DRAW the bounding box for each glyph:
                
                for k in 0 ..< glyphPositions.count {
                    let point = glyphPositions[k]
                    let gRect = glyphsBoundingRects [k]
                    
                    var box = gRect
                    box.origin +=  point + origins[i] + textBounds.origin
                    context.stroke(box)
                    
                }// for k
                
            }//for run
            
        }//for i
        
    }//func draw
    
}//class


extension TextBoxesView : Autosizable {
    
    override func didMoveToSuperview() {
        setupConstrains()
    }
    
}
