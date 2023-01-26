//
//  ProductListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductsContainerDomain {
    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var shouldOpenCart = false
        var cartState: CartListDomain.State?
        var productListState: IdentifiedArrayOf<ProductDomain.State> = []
        
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case setCartView(isPresented: Bool)
        case cart(CartListDomain.Action)
        case closeCart
        case resetProduct(product: Product)
    }
    
    struct Environment {
        var sendOrder:  (@Sendable ([CartItem]) async throws -> String)?
        var uuid: (@Sendable () -> UUID)?
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    > .combine(
        CartListDomain.reducer
            .optional()
            .pullback(
                state: \.cartState,
                action: /ProductsContainerDomain.Action.cart,
                environment: {
                    CartListDomain.Environment(
                        sendOrder: $0.sendOrder!
                    )
                }
            ),
        .init { state, action, environment in
        switch action {
        case .cart(let action):
            switch action {
            case .didPressCloseButton:
                return closeCart(state: &state)
            case .dismissSuccessAlert:
                resetProductsToZero(state: &state)
                
                return .task {
                    .closeCart
                }
            case .cartItem(_, let action):
                switch action {
                case .deleteCartItem(let product):
                    return .task {
                        .resetProduct(product: product)
                    }
                }
            default:
                return .none
            }
        case .closeCart:
            return closeCart(state: &state)
        case .resetProduct(let product):
            
            guard let index = state.productListState.firstIndex(
                where: { $0.product.id == product.id }
            )
            else { return .none }
            let productStateId = state.productListState[index].id
            
            state.productListState[id: productStateId]?.addToCartState.count = 0
            return .none
        case .setCartView(let isPresented):
            state.shouldOpenCart = isPresented
            state.cartState = isPresented
            ? CartListDomain.State(
                cartItems: IdentifiedArrayOf(
                    uniqueElements: state
                        .productListState
                        .compactMap { state in
                            state.count > 0
                            ? CartItemDomain.State(
                                id: environment.uuid!(),
                                cartItem: CartItem(
                                    product: state.product,
                                    quantity: state.count
                                )
                            )
                            : nil
                        }
                )
            )
            : nil
            return .none
        }
    }
    )
    
    private static func closeCart(
        state: inout State
    ) -> Effect<Action, Never> {
        state.shouldOpenCart = false
        state.cartState = nil
        
        return .none
    }
    
    private static func resetProductsToZero(
        state: inout State
    ) {
        for id in state.productListState.map(\.id)
        where state.productListState[id: id]?.count != 0  {
            state.productListState[id: id]?.addToCartState.count = 0
        }
    }
}