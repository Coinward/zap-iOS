//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SelectWalletCreationMethodViewController: UIViewController {

    @IBOutlet private weak var createWalletButton: UIButton!
    @IBOutlet private weak var recoverWalletButton: UIButton!
    
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.darkBackground

        Style.button.apply(to: createWalletButton, recoverWalletButton)
        
        createWalletButton.setTitle("new wallet", for: .normal)
        recoverWalletButton.setTitle("recover wallet", for: .normal)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let viewModel = viewModel,
            let destination = segue.destination as? MnemonicViewController
            else { return }
        destination.mnemonicViewModel = MnemonicViewModel(viewModel: viewModel)
    }
}