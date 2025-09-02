import Foundation
import CoreGraphics

struct Constants {
    // Page dimensions (in points - 72 points = 1 inch)
    static let pageWidth: CGFloat = 4 * 72  // 4 inches
    static let pageHeight: CGFloat = 6 * 72 // 6 inches
    
    // Photo dimensions on page (4x2.9 inches each)
    static let photoWidth: CGFloat = 4 * 72  // 4 inches (full page width)
    static let photoHeight: CGFloat = 2.9 * 72 // 2.9 inches
    
    // Gap between photos (0.2 inches to fit 2.9 + 0.2 + 2.9 = 6 inches)
    static let photoGap: CGFloat = 0.2 * 72 // 0.2 inches
    
    // Margins
    static let pageMargin: CGFloat = 0.25 * 72 // 0.25 inches
}
