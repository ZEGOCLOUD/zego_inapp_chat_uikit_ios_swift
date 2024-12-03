import UIKit

class CircularProgressView: UIView {
    
    var progress: Double = 0.0 {
        didSet {
            setNeedsDisplay()
            self.percentageLabel.text = "\(Int(progress * 100))%"
        }
    }
    
    lazy var percentageLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .center
        label.text = "\(Int(progress * 100))%"
        label.font = UIFont.systemFont(ofSize: 10, weight:.medium)
        label.textColor = .zim_textBlack1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(percentageLabel)
        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.pin(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.pin(equalTo: centerYAnchor),
            percentageLabel.heightAnchor.pin(equalToConstant: 16),
            percentageLabel.widthAnchor.pin(equalToConstant: 36)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.clear(rect)
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = 18.0
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)
        UIColor(hex: 0xD9D9D9).setStroke()
        circlePath.lineWidth = 2
        context.addPath(circlePath.cgPath)
        context.strokePath()
        
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi * CGFloat(min(progress, 1)) - CGFloat.pi / 2, clockwise: true)
        UIColor(hex: 0x3478FC).setStroke()
        progressPath.lineWidth = 2
        context.addPath(progressPath.cgPath)
        context.strokePath()
        
        let middlePath = UIBezierPath(ovalIn: CGRect(x: center.x - radius + 0.5, y: center.y - radius + 0.5, width: radius * 2 - 1, height: radius * 2 - 1))
        UIColor.white.setFill()
        context.addPath(middlePath.cgPath)
        context.fillPath()
        
        context.restoreGState()
    }
}
