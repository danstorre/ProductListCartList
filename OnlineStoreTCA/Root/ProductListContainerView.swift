
import SwiftUI
import ComposableArchitecture

struct ProductListContainerView: View {
    let store: Store<ProductListContainerDomain.State,ProductListContainerDomain.Action>
    private let productListView: ProductListView
    
    init(productListView: ProductListView, store: Store<ProductListContainerDomain.State,ProductListContainerDomain.Action>) {
        self.productListView = productListView
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                productListView
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.setCartView(isPresented: true))
                        } label: {
                            Text("Go to Cart")
                        }
                    }
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.shouldOpenCart,
                        send: ProductListContainerDomain.Action.setCartView(isPresented:)
                    )
                ) {
                    IfLetStore(
                        self.store.scope(
                            state: \.cartState,
                            action: ProductListContainerDomain.Action.cart
                        )
                    ) {
                        CartListView(store: $0)
                    }
                }
                
            }
        }
    }
}
