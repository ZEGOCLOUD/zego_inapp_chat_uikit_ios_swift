import UIKit
import Foundation

class LoadingView: UIView {

    private let imageView = UIImageView()
    private var animation: CABasicAnimation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        let circularImageViewSize = min(bounds.width, bounds.height)
        imageView.frame = CGRect(x: 0, y: 0, width: circularImageViewSize, height: circularImageViewSize)
        imageView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        imageView.image = loadImageSafely(with: "loading")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = circularImageViewSize / 2
        imageView.clipsToBounds = true
        addSubview(imageView)
    }

    func startAnimation() {
        self.isHidden = false
        animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation?.toValue = 2 * Double.pi
        animation?.duration = 1.0
        animation?.repeatCount = .infinity
        imageView.layer.add(animation!, forKey: "rotationAnimation")
    }

    func stopAnimation() {
        self.isHidden = true
        imageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
