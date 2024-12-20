import UIKit

class DotAnimationView: UIView {

    private var dots = [UIView]()
    private var animationDuration: TimeInterval = 0.6
    private var dotSpacing: CGFloat = 10.0
    private let minimumDotSize: CGFloat = 3.0  // 最小尺寸
    private let initialDotSize: CGFloat = 10.0  // 初始尺寸

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDots()
    }
    
    private func setupDots() {
        for i in 0..<3 {
            let dot = createDot()
            let xPosition = dot.frame.size.width * CGFloat(i) + dotSpacing * CGFloat(i)
            dot.center = CGPoint(x: xPosition, y: self.bounds.midY)
            self.addSubview(dot)
            dots.append(dot)
        }
    }
    
    private func createDot() -> UIView {
        let dot = UIView(frame: CGRect(x: 0, y: 0, width: minimumDotSize, height: minimumDotSize))
        dot.backgroundColor = UIColor.gray
        dot.layer.cornerRadius = dot.frame.size.width / 2
        return dot
    }
    
    func startAnimation() {
        for (index, dot) in dots.enumerated() {
            let delay = Double(index) * (animationDuration / 3)
            UIView.animate(withDuration: animationDuration, delay: delay, options: [.autoreverse, .repeat], animations: {
                dot.transform = CGAffineTransform(scaleX: (self.initialDotSize / self.minimumDotSize), y: (self.initialDotSize / self.minimumDotSize))
            }, completion: nil)
        }
    }
    
    func stopAnimation() {
        for dot in dots {
            UIView.animate(withDuration: 0.25) {
                dot.transform = .identity
            }
        }
    }
}


