//
//  MKCircle+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 11/11/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import MapKit.MKCircle

public extension MKCircle {
  /// Returns Bool to check if given `coordinate` exists in circle
  func contains(coordinate: CLLocationCoordinate2D) -> Bool {
    let circleRenderer = MKCircleRenderer(circle: self)
    let currentMapPoint = MKMapPoint(coordinate)
    let polygonViewPoint = circleRenderer.point(for: currentMapPoint)
    return circleRenderer.path.contains(polygonViewPoint, using: .evenOdd, transform: .identity)
  }
}
