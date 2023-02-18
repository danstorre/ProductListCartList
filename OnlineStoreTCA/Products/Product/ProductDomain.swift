//
//  ProductDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 21/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductDomain {
    struct State: Equatable, Identifiable {
        let id: UUID
        let product: Product
        var addToCartState = AddToCartDomain.State()
        
        var count: Int {
            addToCartState.count
        }
    }
    
    enum Action: Equatable {
        case addToCart(AddToCartDomain.Action)
    }
}
