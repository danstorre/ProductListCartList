//
//  ProductListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
    let store: Store<ProductListDomain.State,ProductListDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                if viewStore.isLoading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                } else if viewStore.shouldShowError {
                    ErrorView(
                        message: "Oops, we couldn't fetch product list",
                        retryAction: { viewStore.send(.fetchProducts) }
                    )
                    
                } else {
                    List {
                        ForEachStore(
                            self.store.scope(
                                state: \.productListState,
                                action: ProductListDomain.Action
                                    .product(id: action:)
                            )
                        ) {
                            ProductCell(store: $0)
                        }
                    }
                }
            }
            .task {
                viewStore.send(.fetchProducts)
            }
        }
    }
}

struct ProductListViewDuplication_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(
            store: Store(
                initialState: ProductListDomain.State(),
                reducer: ProductListDomain.reducer,
                environment: ProductListDomain.Environment(
                    fetchProducts: { Product.sample },
                    uuid: { UUID() }
                )
            )
        )
    }
}
