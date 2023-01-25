//
//  Root.swift
//  OnlineStoreTCA
//
//  Created by Daniel Torres on 1/20/23.
//

import Foundation
import ComposableArchitecture

final class Root {
    private lazy var productListDomainDuplicationStore = Store(
        initialState: ProductListDomainDuplication.State(),
        reducer: ProductListDomainDuplication.reducer,
        environment: Self.productListDuplicationDependencies()
    )
    
    private lazy var productListContainerDomainStore = Store(
        initialState: ProductListContainerDomain.State(),
        reducer: ProductListContainerDomain.reducer,
        environment: ProductListContainerDomain.Environment(
            sendOrder: APIClient.live.sendOrder,
            uuid: { UUID() }
        )
    )
    
    static func createView() -> TabViewContainer {
        TabViewContainer(
            store: Store(
                initialState: TabViewDomain.State(),
                reducer: TabViewDomain.reducer,
                environment: TabViewDomain.Environment()
            ),
            productListStore: Store(
                initialState: ProductListDomain.State(),
                reducer: ProductListDomain.reducer,
                environment: Self.productListDependencies()
            ),
            profileStore: Store(
                initialState: ProfileDomain.State(),
                reducer: ProfileDomain.reducer,
                environment: Self.profileDependencies()
            )
        )
    }
    
    func createNewView() -> NewTabViewContainer {
        NewTabViewContainer(
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
    
    private func createProductListContainerView() -> ProductListContainerView {
        ProductListContainerView(
            productListView: { [unowned self] in
                ProductListViewDuplication(store: self.productListDomainDuplicationStore)
            }, store: productListContainerDomainStore
        )
    }
    
    private static func productListDuplicationDependencies() -> ProductListDomainDuplication.Environment {
        ProductListDomainDuplication.Environment(
            fetchProducts: APIClient.live.fetchProducts,
            uuid: { UUID() }
        )
    }
    
    private static func productListDependencies() -> ProductListDomain.Environment {
        ProductListDomain.Environment(
            fetchProducts: APIClient.live.fetchProducts,
            sendOrder: APIClient.live.sendOrder,
            uuid: { UUID() }
        )
    }
    
    private static func profileDependencies() -> ProfileDomain.Environment {
        ProfileDomain.Environment(
            fetchUserProfile: APIClient.live.fetchUserProfile
        )
    }
}
