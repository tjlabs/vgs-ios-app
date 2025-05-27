import Foundation
import CoreGraphics

class PerspectiveMapper {

    init() { }
    
//    private let transformMatrix: [[Double]] = [
//        [7801.398146736883, -10.938422963634329, -990640.9241791785],
//        [42.67445470878247, -9899.733501158895, 365799.3646746052],
//        [-0.014504797022594064, 0.023491112233748085, 1.0]
//    ]
    
    private let transformMatrix: [[Double]] = [
        [1272.1591514208205,3.8783567935236087,-162095.18888680055],
        [-3.442391516896324,-1599.9859910583111,59906.5352484425],
        [-0.015784608602696846,0.028327485964021286,1.0]
    ]
    
    func latLonToPixel(lat: Double, lon: Double) -> CGPoint {
        let src: [Double] = [lon, lat, 1.0]
        var res: [Double] = [0.0, 0.0, 0.0]
            
        for i in 0..<3 {
            for j in 0..<3 {
                res[i] += transformMatrix[i][j] * src[j]
            }
        }

        let x = res[0] / res[2]
        let y = res[1] / res[2]
        return CGPoint(x: x, y: y)
    }
}
