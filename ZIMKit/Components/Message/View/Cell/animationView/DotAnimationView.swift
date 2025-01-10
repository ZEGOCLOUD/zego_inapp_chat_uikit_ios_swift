import UIKit

class DotAnimationView: UIView {

    private var dots = [UIView]()
    private var animationDuration: TimeInterval = 0.6
    private var dotSpacing: CGFloat = 5.0
    private let minimumDotSize: CGFloat = 3.0  // 最小尺寸
    private let initialDotSize: CGFloat = 6.0  // 初始尺寸

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
        dot.backgroundColor = UIColor(hex: 0x2A2A2A, a: 1)
        dot.layer.cornerRadius = dot.frame.size.width / 2
        return dot
    }
    
    func startAnimation() {
        for (index, dot) in dots.enumerated() {
            let delay = Double(index) * (animationDuration / 3)
            let alphaColor: CGFloat = (index == 0) ? 1 : 1 - (CGFloat(index) * 0.2 + 0.1);
            UIView.animate(withDuration: animationDuration, delay: delay, options: [.autoreverse, .repeat], animations: {
                dot.transform = CGAffineTransform(scaleX: (self.initialDotSize / self.minimumDotSize), y: (self.initialDotSize / self.minimumDotSize))
                dot.backgroundColor = UIColor(hex: 0x2A2A2A, a: alphaColor)

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


