//
//  Logger.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import os

public protocol Logging {
    func log(_ message: String)
    func log(_ message: String, level: OSLogType)
}

public struct OSLogger: Logging {
    private let logger: Logger

    public init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func log(_ message: String) {
        logger.log("\(message, privacy: .public)")
    }

    public func log(_ message: String, level: OSLogType) {
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .fault:
            logger.fault("\(message, privacy: .public)")
        default:
            logger.log("\(message, privacy: .public)")
        }
    }
}
