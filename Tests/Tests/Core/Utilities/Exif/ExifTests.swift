//
//  ExifTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 05/05/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class ExifTests: XCTestCase {
  let image = UIImage.with(color: .blue, size: .init(width: 100, height: 100))
  
  func test_imageExifRead() {
    guard let imageData = image.jpegData(compressionQuality: 1) else {
      XCTFail("Failed to generate image data!")
      return
    }
    
    let manager = Exif(source: .data(imageData))
    let promise = expectation(description: "Wait for read...")
    
    manager
      .read()
      .finally {
        switch $0 {
        case .success(let data):
          XCTAssertFalse(data.isEmpty)
          XCTAssertTrue(data.contains(where: { $0.key == "{Exif}" }))
        case .failure(let error):
          XCTFail("Failed to read exif data! \(error.localizedDescription)")
        }
        promise.fulfill()
      }
    
    waitForExpectations(timeout: 1)
  }
  
  func test_imageExifWrite() {
    guard let imageData = image.jpegData(compressionQuality: 1) else {
      XCTFail("Failed to generate image data!")
      return
    }
    
    let writeManager = Exif(source: .data(imageData))
    let updateValue = "Test comment!"
    let updateData = [kCGImagePropertyExifUserComment: updateValue]
    
    let promise = expectation(description: "Wait for write...")
    
    writeManager
      .update(updateData)
      .flatMap {
        let readManager = Exif(source: .data($0))
        return readManager.read()
      }
      .finally {
        switch $0 {
        case .success(let data):
          XCTAssertFalse(data.isEmpty)
          guard let exifData = data["{Exif}"] as? [String: Any] else {
            XCTFail("Missing exif container!")
            return
          }
          guard let value = exifData["UserComment"] as? String else {
            XCTFail("Missing UserComment container!")
            return
          }
          XCTAssertEqual(value, updateValue)
        case .failure(let error):
          XCTFail("Failed to write and/or read exif data! \(error.localizedDescription)")
        }
        promise.fulfill()
      }
    
    waitForExpectations(timeout: 1)
  }
}
