//
//  ProductListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductListDomain {
    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var productListState: IdentifiedArrayOf<ProductDomain.State> = []
        
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case fetchProducts
        case product(id: ProductDomain.State.ID, action: ProductDomain.Action)
    }
}
