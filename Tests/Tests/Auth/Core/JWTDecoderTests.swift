//
//  JWTDecoderTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 12/1/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAuthCore

// To check the content of the token, please visit https://jwt.io
final class JWTDecoderTests: XCTestCase {
  func test_decode_appleToken() {
    let token = "eyJraWQiOiJmaDZCczhDIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY28ucXVldWUuYXBwLWRldiIsImV4cCI6MTY3MzYwMjQ1NywiaWF0IjoxNjczNTE2MDU3LCJzdWIiOiIwMDExNzAuNzZkN2IzMTY5M2Y1NGJjZTliNGUxOTViM2Q1YmU1ZDAuMTI0NiIsImNfaGFzaCI6ImljOTNWOGJKUnRHejFBNEtnQy0wd2ciLCJlbWFpbCI6IjRkOW5kaHY2Y3dAcHJpdmF0ZXJlbGF5LmFwcGxlaWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOiJ0cnVlIiwiaXNfcHJpdmF0ZV9lbWFpbCI6InRydWUiLCJhdXRoX3RpbWUiOjE2NzM1MTYwNTcsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.eHTX4xCoYf87v9T2rvu30AGSK1OX1pGcMocJry1ZVGYp4NJbysSGR5cDDNZ8hf14qV_TA6QCYrMemU5FhLG9GLw11orBEFOLr3DShu8Nsan_ZuBUU9Ig6lE5iQtGECKVO71GTFYDez6Ufsfp-Rf1mx-9vJe3OfRyHVeJgHfG3RUlmvn3AgeFPqJ1y3F9_T4uWm0VSQMZU-xEiEACpavO0HIKwCvTT2J-dy4j4Y4wIVtKyIFD9jOyjPZIK1YNEtMFK9XJYWJ7YYfhLwthl_EmNn-y7Pv0pCKtYvGwufMN9EXxsHXNmhzkWNbilAsuAKSRAUV-iEH7EIpEgFnhT1Tktg"
    
    do {
      let decoder = try JWTDecoder(token: token)
      XCTAssertEqual(decoder.algorithm, "RS256")
      XCTAssertEqual(decoder.issuer, "https://appleid.apple.com")
      XCTAssertEqual(decoder.subject, "001170.76d7b31693f54bce9b4e195b3d5be5d0.1246")
      XCTAssertNil(decoder.identifier)
      XCTAssertTrue(decoder.issuedAt?.compare(Date(timeIntervalSince1970: 1673516057)) == .orderedSame)
      XCTAssertTrue(decoder.expiresAt?.compare(Date(timeIntervalSince1970: 1673602457)) == .orderedSame)
      XCTAssertNil(decoder.notBefore)
      // XCTAssertFalse(decoder.isExpired)
      XCTAssertTrue(decoder.bool(for: "is_private_email") ?? false)
      XCTAssertTrue(decoder.bool(for: "email_verified") ?? false)
    } catch {
      XCTFail("Could not decode token!")
    }
  }
  
  func test_decode_randomToken() {
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
    
    do {
      let decoder = try JWTDecoder(token: token)
      XCTAssertEqual(decoder.algorithm, "HS256")
      XCTAssertNil(decoder.issuer)
      XCTAssertEqual(decoder.subject, "1234567890")
      XCTAssertNil(decoder.identifier)
      XCTAssertTrue(decoder.issuedAt?.compare(Date(timeIntervalSince1970: 1516239022)) == .orderedSame)
      XCTAssertNil(decoder.expiresAt)
      XCTAssertNil(decoder.notBefore)
      XCTAssertFalse(decoder.isExpired)
      XCTAssertEqual(decoder.string(for: "name"), "John Doe")
    } catch {
      XCTFail("Could not decode token!")
    }
  }
}
