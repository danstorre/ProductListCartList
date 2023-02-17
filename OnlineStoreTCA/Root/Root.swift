//
//  Root.swift
//  OnlineStoreTCA
//
//  Created by Daniel Torres on 1/20/23.
//

import Foundation
import ComposableArchitecture

final class Root {
    private lazy var productListContainerDomainStore = Store(
        initialState: ProductsContainerDomain.State(),
        reducer: ProductsContainerDomain(uuid: { UUID() }, effectFetchProducts: EffectTask.task {
            await .fetchProductsResponse(
                TaskResult { try await APIClient.live.fetchProducts() }
            )
        })
    )
    
    init() {}
    
    init(effectFetchProducts: EffectTask<ProductsContainerDomain.Action>) {
        self.productListContainerDomainStore = Store(
            initialState: ProductsContainerDomain.State(),
            reducer: ProductsContainerDomain(uuid: { UUID() },
                                             effectFetchProducts: effectFetchProducts)
        )
    }
    
    func createMainView() -> TabViewContainer {
        TabViewContainer(
            store: Store(
                initialState: TabViewDomain.State(),
                reducer: TabViewDomain.reducer,
                environment: TabViewDomain.Environment()
            ),
            profileStore: Store(
                initialState: ProfileDomain.State(),
                reducer: ProfileDomain.reducer,
                environment: Self.profileDependencies()
            ),
            productListContainerView: createProductListContainerView
        )
    }
    
    public func createProductListContainerView() -> ProductsContainerView {
        ProductsContainerView(
            productListView: { [unowned self] in
                ProductListView(store: self.productListContainerDomainStore.scope(
                    state: \.productListDomainState,
                    action: { action in
                     return .productList(action: action)
                    }))
            },
            cartListView: { [unowned self] in
                IfLetStore(
                    self.productListContainerDomainStore.scope(
                        state: \.cartState,
                        action: ProductsContainerDomain.Action.cart
                    )
                ) {
                    CartListView(store: $0)
                }
            },
            store: productListContainerDomainStore
        )
    }
    
    private static func productListDuplicationDependencies() -> ProductListDomain.Environment {
        ProductListDomain.Environment(
            fetchProducts: APIClient.live.fetchProducts,
            uuid: { UUID() }
        )
    }
    
    private static func profileDependencies() -> ProfileDomain.Environment {
        ProfileDomain.Environment(
            fetchUserProfile: APIClient.live.fetchUserProfile
        )
    }
}
