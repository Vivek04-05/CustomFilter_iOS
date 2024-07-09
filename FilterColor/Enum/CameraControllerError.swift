//
//  CameraControllerError.swift
//  FilterColor
//
//  Created by Vivek Patel on 08/07/24.
//

import Foundation

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}
