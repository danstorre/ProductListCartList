//
//  CartListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import Foundation
import ComposableArchitecture

struct CartListDomain {
    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var cartItems: IdentifiedArrayOf<CartItemDomain.State> = []
        var totalPrice: Double = 0.0
        var confirmationAlert: AlertState<CartListDomain.Action>?
        var errorAlert: AlertState<CartListDomain.Action>?
        var successAlert: AlertState<CartListDomain.Action>?
        var isPayButtonHidden = false
        
        var totalPriceString: String {
            let roundedValue = round(totalPrice * 100) / 100.0
            return "$\(roundedValue)"
        }
        
        init(cartItems: IdentifiedArrayOf<CartItemDomain.State>) {
            self.cartItems = cartItems
        }
        
        var isRequestInProcess: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case didPressCloseButton
        case didReceivePurchaseResponse(TaskResult<String>)
        case getTotalPrice
        case didPressPayButton
        case didCancelConfirmation
        case didConfirmPurchase
        case dismissSuccessAlert
        case dismissErrorAlert
        case deleteCartItem(id: CartItemDomain.State.ID)
        case cartItem(id: CartItemDomain.State.ID, action: CartItemDomain.Action)
    }
    
    struct Environment {
        var sendOrder: ([CartItem]) async throws -> String
    }
    
    let sendOrder: ([CartItem]) async throws -> String
    
    init(sendOrder: @escaping ([CartItem]) throws -> String) {
        self.sendOrder = sendOrder
    }
    
    static func verifyPayButtonVisibility(
        state: inout State
    ) -> EffectTask<Action> {
        state.isPayButtonHidden = state.totalPrice == 0.0
        return .none
    }
}
