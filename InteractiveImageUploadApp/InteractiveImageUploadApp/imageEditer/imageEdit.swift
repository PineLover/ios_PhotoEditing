//
//  imageEdit.swift
//  InteractiveImageUploadApp
//
//  Created by 김동환 on 2020/06/23.
//  Copyright © 2020 김동환. All rights reserved.
//
import UIKit

class imageEdit {
    
    var image : UIImage
    
    //let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.cgImage))    // 이미지에서를 Data 형태로 만듭니다.
    var pixelData : CFData
    var data : UnsafePointer<UInt8>
    
    init(){
        image = #imageLiteral(resourceName: "mySample")
        pixelData = image.cgImage!.dataProvider!.data!
        data = CFDataGetBytePtr(pixelData)    // 주소로 접근할 수 있도록 선언합니다.
    }
    
    // 특정 위치에 색상 값을 뽑아내는 함수입니다.
    func getRGBA(pData: UnsafePointer<UInt8>, _ pixel: Int) -> UIColor {
        let red = pData[pixel]
        let green = pData[(pixel + 1)];
        let blue = pData[pixel + 2];
        let alpha = pData[pixel + 3];
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }

    

    
    // 뽑아낸 색상값을 배경색으로 하는 이미지를 만드는 함수입니다.
    func renderImage(image: UIImage, andBackgroundColor backgroundColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)    // 원본 이미지 크기와 동일하게 합니다.
        backgroundColor.setFill()    // 배경색으로 칠합니다.
        
        context.fill(rect)
        image.draw(in: rect)    // 이미지를 그립니다.
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()    // 배경색이 추가된 이미지를 얻습니다.
        UIGraphicsEndImageContext()
        
        return maskedImage!
    }
    
    //renderImage(image, andBackgroundColor: findColor(data))
    func testRender() -> UIImage {
        //return renderImage(image: image, andBackgroundColor: findColor(pData: data))
        return processPixels(in: image)!
        //return image
    }
}


extension imageEdit {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        //        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image))
        //        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = Int((Int(image.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        //let pixelInfo = self.size.width
        
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func processPixels(in image: UIImage) -> UIImage? {
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }

        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        var mosaicSize : Int = 30

        for row in 0 ..< Int(height) / mosaicSize {
            for column in 0 ..< Int(width) / mosaicSize {
                let offset = row * width * mosaicSize  + column * mosaicSize
                print("offset : \(offset)")
                
                //var blended = imageEdit.RGBA32(red: 0,green: 0,blue: 0,alpha: 0)
                var blended_R : UInt32 = 0
                var blended_G : UInt32 = 0
                var blended_B : UInt32 = 0
                var blended_alpha : UInt32 = 0
                
                /*
                for r in 0...3 {
                    for c in 0...3 {
                        //blended = (pixelBuffer[offset + r*width + c])
                        blended_R += UInt32(pixelBuffer[offset + r*width + c].redComponent)
                        blended_G += UInt32(pixelBuffer[offset + r*width + c].greenComponent)
                        blended_B += UInt32(pixelBuffer[offset + r*width + c].blueComponent)
                        blended_alpha += UInt32(pixelBuffer[offset + r*width + c].alphaComponent)
                    }
                }
                
                blended_R /= 9
                blended_G /= 9
                blended_B /= 9
                blended_alpha /= 9
                */
                
                for r in 0...mosaicSize-1 {
                    for c in 0...mosaicSize-1 {
                        pixelBuffer[offset + r * width + c] = pixelBuffer[offset]
                        
                        //pixelBuffer[offset + r*width + c] = RGBA32(red : UInt8(blended_R), green : UInt8(blended_G), blue: UInt8(blended_B), alpha: UInt8(blended_alpha))
                        //pixelBuffer[offset + r*width + c] = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
                    }
                }
                
            }
        }
        
        /*
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                if pixelBuffer[offset] == .black {
                    pixelBuffer[offset] = .red
                }
            }
        }
        */

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale , orientation: image.imageOrientation)

        return outputImage
    }

    struct RGBA32: Equatable {
        private var color: UInt32

        var redComponent: UInt8 {
            return UInt8((color >> 24) & 255)
        }

        var greenComponent: UInt8 {
            return UInt8((color >> 16) & 255)
        }

        var blueComponent: UInt8 {
            return UInt8((color >> 8) & 255)
        }

        var alphaComponent: UInt8 {
            return UInt8((color >> 0) & 255)
        }

        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            let red   = UInt32(red)
            let green = UInt32(green)
            let blue  = UInt32(blue)
            let alpha = UInt32(alpha)
            color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
        }

        static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
        static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
        static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
        static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
        static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
        static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
        static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)

        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
}


