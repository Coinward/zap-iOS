//
//  LightningTests
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

@testable import Lightning
import SwiftBTC
@testable import SwiftLnd
import XCTest

final class MockBackupService: StaticChannelBackupServiceType {
    func save(data: Result<Data, LndApiError>, nodePubKey: String, fileName: String) {}
}

extension RPCCredentials {
    // swiftlint:disable:next force_unwrapping
    static var mock: RPCCredentials = RPCCredentials(certificate: nil, macaroon: Macaroon(hexadecimalString: "deadbeef")!, host: URL(string: "127.0.0.1")!)
}

class InvoiceTests: XCTestCase {

    func createInvoice(address: String, network: Network, decodedPaymentRequest: Lnrpc_PayReq, testAssertions: @escaping (Result<BitcoinInvoice, InvoiceError>) -> Void) {
        let api = LightningApi(connection: MockLightningConnection(
            getInfo: network == .mainnet ? Lnrpc_GetInfoResponse.Template.mainnet : Lnrpc_GetInfoResponse.Template.testnet,
            decodePayReq: decodedPaymentRequest
        ))

        let testConnection = LightningConnection.remote(RPCCredentials.mock)
        let mockService = LightningService(api: api, connection: testConnection, backupService: MockBackupService())

        let expectation = self.expectation(description: "Decoding")

        BitcoinInvoiceFactory.create(from: address, lightningService: mockService) {
                testAssertions($0)
                expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUnsupportedAddressType() {
        let paymentRequest = Lnrpc_PayReq.Template.testnet
        createInvoice(address: "abc", network: .mainnet, decodedPaymentRequest: paymentRequest) {
            if case let .failure(error) = $0,
                case .unknownFormat = error {
                // pass
            } else {
                XCTFail("Should be an error")
            }
        }
    }

    func testLightningPaymentWrongNetwork() {
        let paymentRequest = Lnrpc_PayReq.Template.testnetFallback
        createInvoice(address: "lnbc1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdpl2pkx2ctnv5sxxmmwwd5kgetjypeh2ursdae8g6twvus8g6rfwvs8qun0dfjkxaq8rkx3yf5tcsyz3d73gafnh3cax9rn449d9p5uxz9ezhhypd0elx87sjle52x86fux2ypatgddc6k63n7erqz25le42c4u4ecky03ylcqca784w", network: .mainnet, decodedPaymentRequest: paymentRequest) {
            switch $0 {
            case .success:
                XCTFail("Should Fail")
            case .failure(let error):
                if case let .wrongNetworkError(linkNetwork, expectedNetwork) = error,
                    linkNetwork == .testnet,
                    expectedNetwork == .mainnet {
                    // pass
                } else {
                    XCTFail("Wrong Error Type")
                }
            }
        }
    }

    func testBitcoinURI() {
        let paymentRequest = Lnrpc_PayReq.Template.testnet
        createInvoice(address: "mzMD4CTKR6Essspredb5MSBPECtJrnVgBC", network: .testnet, decodedPaymentRequest: paymentRequest) {
            switch $0 {
            case .success(let invoice):
                XCTAssertNotNil(invoice.bitcoinURI)
                XCTAssertEqual(invoice.bitcoinURI?.address, "mzMD4CTKR6Essspredb5MSBPECtJrnVgBC")
                XCTAssertNil(invoice.lightningPaymentRequest)
            case .failure:
                XCTFail("Should Succeed")
            }
        }
    }

    func testBitcoinURIWithFallback() {
        let address = "bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=50&message=Donation%20for%20project%20xyz&lightning=lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4"
        let paymentRequest = Lnrpc_PayReq.Template.testnet

        createInvoice(address: address, network: .testnet, decodedPaymentRequest: paymentRequest) {
            switch $0 {
            case .success(let invoice):
                XCTAssertNotNil(invoice.bitcoinURI)
                XCTAssertEqual(invoice.bitcoinURI?.address, "mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p")
                XCTAssertNotNil(invoice.lightningPaymentRequest)
//                XCTAssertEqual(invoice.lightningPaymentRequest?.raw, paymentRequest.)
            case .failure:
                XCTFail("Should Succeed")
            }
        }
    }

    func testBitcoinURIWrongNetwork() {
        let address = "bitcoin:mioi9QugUZFSsSm61Gx4u43s6jYkes2L9p?amount=50&message=Donation%20for%20project%20xyz&lightning=lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4"
        let paymentRequest = Lnrpc_PayReq.Template.testnet
        createInvoice(address: address, network: .mainnet, decodedPaymentRequest: paymentRequest) {
            switch $0 {
            case .success:
                XCTFail("Should Fail")
            case .failure(let error):
                if case let .wrongNetworkError(linkNetwork, expectedNetwork) = error,
                    linkNetwork == .testnet,
                    expectedNetwork == .mainnet {
                    // pass
                } else {
                    XCTFail("Wrong Error Type")
                }
            }
        }
    }
}
