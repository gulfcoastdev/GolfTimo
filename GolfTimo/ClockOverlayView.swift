import UIKit

class ClockOverlayView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 20
        
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
        context.setLineWidth(2)
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.strokePath()
        
        drawClockNumbers(context: context, center: center, radius: radius)
//        drawCenterDot(context: context, center: center)
    }
    
    private func drawClockNumbers(context: CGContext, center: CGPoint, radius: CGFloat) {
        let numberRadius = radius - 25
        let font = UIFont.systemFont(ofSize: 18, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        
        for i in 1...12 {
            let angle = CGFloat(i) * .pi / 6 - .pi / 2
            let numberX = center.x + numberRadius * cos(angle)
            let numberY = center.y + numberRadius * sin(angle)
            
            let text = "\(i)"
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: numberX - textSize.width / 2,
                y: numberY - textSize.height / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    
//    private func drawCenterDot(context: CGContext, center: CGPoint) {
//        context.setFillColor(UIColor.white.cgColor)
//        context.addArc(center: center, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
//        context.fillPath()
//    }
//    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
}
