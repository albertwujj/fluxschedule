//
//  TouchDownGestureRecognizer.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 3/11/18.
//  Copyright © 2018 Old Friend. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class SingleTouchDownGestureRecognizer: UIGestureRecognizer {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    if self.state == .possible {
      self.state = .recognized
    }
  }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    self.state = .failed
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    self.state = .failed
  }
}
