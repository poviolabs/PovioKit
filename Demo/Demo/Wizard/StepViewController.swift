//
//  StepViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 14.04.2022..
//

import Foundation
import PovioKit

protocol StepViewController: BottomSheetStep {
  var wizard: MainBottomSheet? { get set }
  
  func didTapNextButton()
  func didTapPreviousButton()
}
