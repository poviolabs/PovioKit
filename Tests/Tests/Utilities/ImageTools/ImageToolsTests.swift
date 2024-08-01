//
//  ImageToolsTests.swift
//
//
//  Created by Borut Tomazin on 01/08/2024.
//

import XCTest
import PovioKitUtilities

final class ImageToolsTests: XCTestCase {
  private let imageTools = ImageTools()
  private let image: UIImage? = UIImage(named: "PovioKit", in: .module, with: nil)
  
  func testDownsizeToTargetSize() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Downsizing...")
    
    Task {
      do {
        let downsizedImage = try await imageTools.downsize(image: image, toTargetSize: .init(size: 200))
        XCTAssertLessThanOrEqual(downsizedImage.size.width, 200, "The width of the downsized image should be 200")
        XCTAssertLessThanOrEqual(downsizedImage.size.height, 200, "The height of the downsized image should be 200")
      } catch {
        XCTFail("The image failed to downsize.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testDownsizeByPercentage() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Downsizing...")
    let originalSize = image.size
    
    Task {
      do {
        let downsizedImage = try await imageTools.downsize(image: image, byPercentage: 50)
        XCTAssertEqual(downsizedImage.size.width, originalSize.width / 2, "The width of the downsized image should be 200")
        XCTAssertEqual(downsizedImage.size.height, originalSize.height / 2, "The height of the downsized image should be 200")
      } catch {
        XCTFail("The image failed to downsize.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testCompressWithPngFormat() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Compressing...")
    
    Task {
      do {
        let downsizedImage = try await imageTools.compress(image: image, withFormat: .png)
        // verify the image format by checking the PNG signature
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        let downsizedImageSignature = [UInt8](downsizedImage.prefix(pngSignature.count))
        
        XCTAssertEqual(downsizedImageSignature, pngSignature, "The image was not compressed as PNG.")
      } catch {
        XCTFail("The image failed to compress.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testCompressWithJpgFormat() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Compressing...")
    
    Task {
      do {
        let downsizedImage = try await imageTools.compress(image: image, withFormat: .jpeg(compressionRatio: 0.5))
        // verify the image format by checking the JPEG signature
        let jpegSignature: [UInt8] = [0xFF, 0xD8]
        let downsizedImageSignature = [UInt8](downsizedImage.prefix(jpegSignature.count))
        
        XCTAssertEqual(downsizedImageSignature, jpegSignature, "The image was not compressed as JPEG.")
      } catch {
        XCTFail("The image failed to compress.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testCompressToMaxSize() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Compressing...")
    
    let targetKB = 10.0
    
    Task {
      do {
        let downsizedImage = try await imageTools.compress(image: image, toMaxKbSize: targetKB)
        // Check if the size is 1KB or less
        let imageSizeInKB = Double(downsizedImage.count) / 1024.0
        XCTAssertLessThanOrEqual(imageSizeInKB, targetKB, "The compressed image size is greater than 1KB.")
      } catch {
        XCTFail("The image failed to compress. \(error)")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
}
