//
//  CartItemDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 22/08/22.
//

import Foundation
import ComposableArchitecture

struct CartItemDomain {
    struct State: Equatable, Identifiable {
        let id: UUID
        let cartItem: CartItem
    }
    
    enum Action: Equatable {
        case deleteCartItem(product: Product)
    }
}
