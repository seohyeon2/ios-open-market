//
//  ModificationViewController.swift
//  OpenMarket
//
//  Created by seohyeon park on 2022/08/06.
//

import UIKit

class ModificationViewController: RegistrationViewController {

    var product: SaleInformation?
    
    init(product: SaleInformation) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let product = product else {
            return
        }
        
        self.title = "상품 수정"
    }
}
