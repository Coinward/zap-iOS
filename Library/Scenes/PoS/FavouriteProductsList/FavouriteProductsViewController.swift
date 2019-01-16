//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

extension UIStoryboard {
    static func instantiateFavouriteProductsViewController(transactionService: TransactionService, productsViewModel: ProductsViewModel, shoppingCartViewModel: ShoppingCartViewModel) -> ZapNavigationController {
        let productViewController = StoryboardScene.PoS.productViewController.instantiate()
        productViewController.transactionService = transactionService
        productViewController.productsViewModel = productsViewModel
        productViewController.shoppingCartViewModel = shoppingCartViewModel
        
        let navigationController = ZapNavigationController(rootViewController: productViewController)
        navigationController.tabBarItem.image = Asset.tabbarFavourites.image
        navigationController.tabBarItem.title = "Favorites"

        return navigationController
    }
}

final class FavouriteProductsViewController: UIViewController, ShoppingCartPresentable, ChargePresentable {
    @IBOutlet private weak var payButton: UIButton!

    // swiftlint:disable implicitly_unwrapped_optional
    fileprivate var productsViewModel: ProductsViewModel!
    fileprivate var shoppingCartViewModel: ShoppingCartViewModel!
    fileprivate var transactionService: TransactionService!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = UIImageView(image: Asset.posFavouritesLogo.image)
        
        view.backgroundColor = UIColor.Zap.background
        
        navigationItem.largeTitleDisplayMode = .never

        setupShoppingCartBarButton(shoppingCartViewModel: shoppingCartViewModel, selector: #selector(presentShoppingCart))
        
        setupChargeButton(button: payButton, amount: shoppingCartViewModel.totalAmount)
    }
    
    @IBAction private func presentTipViewController(_ sender: Any) {
        presentChargeViewController(transactionService: transactionService, fiatValue: shoppingCartViewModel.totalAmount.value, shoppingCartViewModel: shoppingCartViewModel)
    }
    
    @objc func presentShoppingCart() {
        presentShoppingCart(shoppingCartViewModel: shoppingCartViewModel, transactionService: transactionService)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? FavouritePageViewController {
            pageViewController.productsViewModel = productsViewModel
            pageViewController.shoppingCartViewModel = shoppingCartViewModel
        }
    }
}