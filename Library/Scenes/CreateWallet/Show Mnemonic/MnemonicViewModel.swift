//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

final class MnemonicViewModel {
    private let walletService: WalletService
    private var mnemonic: [String]? {
        didSet {
            guard let mnemonic = mnemonic else { return }
            updatePageWords(with: mnemonic)
        }
    }

    let pageWords = Observable<[[MnemonicWord]]?>(nil)

    var confirmMnemonicViewModel: ConfirmMnemonicViewModel? {
        guard let mnemonic = mnemonic else { return  nil }
        return ConfirmMnemonicViewModel(walletService: walletService, mnemonic: mnemonic)
    }

    init(connection: LightningConnection) {
        walletService = WalletService(connection: connection)

        walletService.generateSeed { [weak self] result in
            guard let mnemonic = try? result.get() else { return }
            self?.mnemonic = mnemonic
        }
    }

    func updatePageWords(with mnemonic: [String]) {
        let maxWordCount = 12
        var subArrays = [[String]]()
        var array = mnemonic

        while !array.isEmpty {
            let prefix = array.prefix(maxWordCount)
            subArrays.append(Array(prefix))
            array.removeFirst(maxWordCount)
        }

        var index = 0

        pageWords.value = subArrays.map {
            $0.map {
                defer { index += 1 }
                return MnemonicWord(index: index, word: $0)
            }
        }
    }
}

struct MnemonicWord: Equatable {
    let index: Int
    let word: String
}
