//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile

public enum LocalLnd {
    public private(set) static var isRunning = false
    
    static var path: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { fatalError("lnd path not found") }
        return url
    }
    
    public static func start() {
        isRunning = true
        LocalLndConfiguration.standard.save(at: path)

        guard !Environment.isRunningTests else { return }
        LndmobileStart(LocalLnd.path.path, EmptyStreamCallback())
    }
    
    public static func stop() {
        isRunning = false
        LndmobileStopDaemon(nil, EmptyStreamCallback())
    }
}

#endif
