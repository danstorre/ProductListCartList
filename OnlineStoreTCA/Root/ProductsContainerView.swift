
import SwiftUI
import ComposableArchitecture

struct ProductsContainerView: View {
    let store: Store<ProductsContainerDomain.State,ProductsContainerDomain.Action>
    private let productListView: () -> ProductListView
    private let cartListView: () -> IfLetStore<CartListDomain.State, CartListDomain.Action, CartListView?>
    
    init(productListView: @escaping () -> ProductListView,
         cartListView: @escaping () -> IfLetStore<CartListDomain.State, CartListDomain.Action, CartListView?>,
         store: Store<ProductsContainerDomain.State,ProductsContainerDomain.Action>) {
        self.productListView = productListView
        self.cartListView = cartListView
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                productListView()
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
                .sheet2(
                    isPresented: viewStore.binding(
                        get: \.shouldOpenCart,
                        send: ProductsContainerDomain.Action.setCartView(isPresented:)
                    )
                ) {
                    cartListView()
                }
            }
            .onAppear {
                viewStore.send(.fetchProducts)
            }
        }
        .tag("anyView")
    }
}


extension View {
    func sheet2<Sheet>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Sheet
    ) -> some View where Sheet: View {
        return self.modifier(InspectableSheet(isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
    }
}

struct InspectableSheet<Sheet>: ViewModifier where Sheet: View {
    
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let popupBuilder: () -> Sheet
    
    func body(content: Self.Content) -> some View {
        content.sheet(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
    }
}
