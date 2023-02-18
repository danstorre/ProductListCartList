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
        
        var productListDomainState: ProductListDomain.State = .init()
        
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case fetchProductsResponse(TaskResult<[Product]>)
        case setCartView(isPresented: Bool)
        case cart(CartListDomain.Action)
        case closeCart
        case resetProduct(product: Product)
        
        case productList(action: ProductListDomain.Action)
        case addProduct(action: AddToCartDomain.Action, id: UUID)
    }
    
    struct Environment {
        var sendOrder:  (@Sendable ([CartItem]) async throws -> String)?
        var uuid: (@Sendable () -> UUID)?
    }
    
    let uuid: (@Sendable () -> UUID)
    private let effectFetchProducts: EffectTask<ProductsContainerDomain.Action>
    
    init(uuid: @escaping (@Sendable () -> UUID),
         effectFetchProducts: EffectTask<ProductsContainerDomain.Action>
    ) {
        self.uuid = uuid
        self.effectFetchProducts = effectFetchProducts
    }
    
    private static func closeCart(
        state: inout State
    ) -> EffectTask<Action> {
        state.shouldOpenCart = false
        state.cartState = nil
        
        return .none
    }
    
    private static func resetProductsToZero(
        state: inout State
    ) {
        for id in state.productListDomainState.productListState.map(\.id)
        where state.productListDomainState.productListState[id: id]?.count != 0  {
            state.productListDomainState.productListState[id: id]?.addToCartState.count = 0
        }
    }
}


extension ProductsContainerDomain: ReducerProtocol {
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .fetchProductsResponse(.success(let products)):
            state.dataLoadingStatus = .success
            state.productListDomainState.productListState = IdentifiedArrayOf(
                uniqueElements: products.map {
                    ProductDomain.State(
                        id: uuid(),
                        product: $0
                    )
                }
            )
            return .none
        case .fetchProductsResponse(.failure(let error)):
            state.dataLoadingStatus = .error
            print(error)
            print("Error getting products, try again later.")
            return .none
        case .cart(let action):
            switch action {
            case .didPressCloseButton:
                return ProductsContainerDomain.closeCart(state: &state)
            case .dismissSuccessAlert:
                ProductsContainerDomain.resetProductsToZero(state: &state)
                
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
            return ProductsContainerDomain.closeCart(state: &state)
        case .resetProduct(let product):
            
            guard let index = state.productListDomainState.productListState.firstIndex(
                where: { $0.product.id == product.id }
            )
            else { return .none }
            let productStateId = state.productListDomainState.productListState[index].id
            
            state.productListDomainState.productListState[id: productStateId]?.addToCartState.count = 0
            return .none
        case .setCartView(let isPresented):
            state.shouldOpenCart = isPresented
            state.cartState = isPresented
            ? CartListDomain.State(
                cartItems: IdentifiedArrayOf(
                    uniqueElements: state
                        .productListDomainState
                        .productListState
                        .compactMap { state in
                            state.count > 0
                            ? CartItemDomain.State(
                                id: uuid(),
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
        case .productList(action: let action):
            if case .fetchProducts = action {
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }
                
                state.dataLoadingStatus = .loading
                
                return effectFetchProducts
            }
            return .none
        case .addProduct(action: let action, id: let id):
            switch action {
            case .didTapPlusButton:
                state.productListDomainState.productListState[id: id]?.addToCartState.count += 1
            case .didTapMinusButton:
                state.productListDomainState.productListState[id: id]?.addToCartState.count -= 1
            }
            return .none
        }
    }
}
