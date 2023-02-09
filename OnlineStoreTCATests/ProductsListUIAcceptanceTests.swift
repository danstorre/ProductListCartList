
import XCTest
import ViewInspector
import ComposableArchitecture
@testable import OnlineStoreTCA

extension InspectableSheet: PopupPresenter {}

final class ProductsListUIAcceptanceTests: XCTestCase {

    func test_onCartListSelection_WithNonSelectedItems_displaysEmptyCarList() {
        let cartList = showEmptyCartList()
        
        XCTAssertEqual(cartList.numberOfDisplayedItems, 0)
    }
    
    @MainActor
    func test_onCartListSelection_PreviousSelectedItems_displaysNonEmptyCarList() async throws {
        // show cart list from mainView
        let cartListView = try await showLoadedCartList()
        
        XCTAssertEqual(cartListView.numberOfDisplayedProducts(), 1)
    }
    
    // MARK: - Helpers
    @MainActor
    private func showLoadedCartList() async throws -> CartListView {
        // launch the screen with needed stubbed infrastructure and state given.
        let (effect, op) = createEffectFetchProducts()
        let (effect2, op2) = createEffectFetchListProducts()
        
        let app = OnlineStoreTCAApp(effectFetchProducts: effect,
                                    effectFetchProductsFromList: effect2)
        
        let mainView = app.mainView
        
        // load the main view.
        mainView.simulateAppearance()
        
        try await waitFor(operation: op)
        try await waitFor(operation: op2)
        
        // assert one item is presented.
        XCTAssertEqual(mainView.numberOfDisplayedProducts(), 1)
        
        // add an item to the cart from the list.
        mainView.simulateAddItemToCart()
        
        // select cart list button.
        mainView.simulateCartListButton()
        
        let cartListView = try mainView.presentedView()
        
        return cartListView
    }
    
    private func createEffectFetchProducts() -> (effect: EffectTask<ProductListDomain.Action>,
                                                 op: @Sendable (Send<ProductListDomain.Action>) async throws -> Void){
        let op: @Sendable (Send<ProductListDomain.Action>) async throws -> Void =  { send in
            await send(.fetchProductsResponse(
                TaskResult { [anyProduct()] }
            ))
        }
        let effect = EffectTask<ProductListDomain.Action>.run(operation: op)
        return (effect, op)
    }
    
    private func createEffectFetchListProducts() -> (effect: EffectTask<ProductsContainerDomain.Action>,
                                                 op: @Sendable (Send<ProductsContainerDomain.Action>) async throws -> Void){
        let op: @Sendable (Send<ProductsContainerDomain.Action>) async throws -> Void =  { send in
            await send(.fetchProductsResponse(
                TaskResult { [anyProduct()] }
            ))
        }
        let effect = EffectTask<ProductsContainerDomain.Action>.run(operation: op)
        return (effect, op)
    }
    
    private func waitFor<T>(operation: @Sendable (Send<T>) async throws -> Void) async throws {
        try await operation(Send<T>(send: { _ in }))
    }
    
    func showEmptyCartList() -> CartListView {
        CartListView(store: Store<CartListDomain.State, CartListDomain.Action>
            .init(
                initialState: CartListDomain.State(cartItems: []),
                reducer: CartListDomain(sendOrder: { _ in "" })
            )
        )
    }
}

func anyProduct() -> Product {
    return Product(id: 0, title: "any", price: 0, description: "any", category: "any", imageString: "any")
}

extension CartListView {
    var numberOfDisplayedItems: Int {
        0
    }
}

extension TabViewContainer {
    
    func numberOfDisplayedProducts() -> Int {
        let productListView = try? inspect()
            .find(TabViewContainer.self)
            .find(viewWithTag: "anyView")
            .tabView()
            .find(ProductsContainerView.self)
            .find(viewWithTag: "anyView")
            .find(ProductListView.self)
            .find(viewWithTag: "anyView")
            .group()
        
        let listProductItems = try? productListView?
            .find(ViewType.List.self)
        
        let allItems = listProductItems?
            .findAll(ProductCell.self)
        
        return allItems?.count ?? 0
    }
    
    func simulateAppearance() {
        
        let productContainerView = try? inspect()
            .find(TabViewContainer.self)
            .find(viewWithTag: "anyView")
            .tabView()
            .find(ProductsContainerView.self)
            .find(viewWithTag: "anyView")
        
        let productListView = try? productContainerView?
            .find(ProductListView.self)
            .find(viewWithTag: "anyView")
            .group()
        
        _ = try? productListView?.callOnAppear()
        
        let navigationView = try? productContainerView?
            .find(ViewType.NavigationView.self)
        
        _ = try? navigationView?.callOnAppear()
    }
    
    func simulateAddItemToCart() {
        let productListView = try? inspect()
            .find(TabViewContainer.self)
            .find(viewWithTag: "anyView")
            .tabView()
            .find(ProductsContainerView.self)
            .find(viewWithTag: "anyView")
            .find(ProductListView.self)
            .find(viewWithTag: "anyView")
            .group()
        
        let listProductItems = try? productListView?
            .find(ViewType.List.self)
        
        let allItems = listProductItems?
            .findAll(ProductCell.self)
        
        
        let addItemButton = try? allItems?.first?
            .find(viewWithTag: "anyView")
            .find(AddToCartButton.self)
            .find(viewWithTag: "anyView")
            .find(ViewType.Button.self)
        
        try? addItemButton?.tap()
    }
    
    func simulateCartListButton() {
        let showCartListButton = try? inspect()
            .find(TabViewContainer.self)
            .find(viewWithTag: "anyView")
            .tabView()
            .find(ProductsContainerView.self)
            .find(viewWithTag: "anyView")
            .find(ViewType.Button.self)
        
        try? showCartListButton?.tap()
    }
    
    func presentedView() throws -> CartListView {
        let cartListView = try inspect()
            .find(TabViewContainer.self)
            .find(viewWithTag: "anyView")
            .tabView()
            .find(ProductsContainerView.self)
            .find(viewWithTag: "anyView")
            .find(ViewType.Sheet.self)
            .find(CartListView.self)
        
        return try cartListView.actualView()
    }
}

extension CartListView {
    func numberOfDisplayedProducts() -> Int? {
        guard let count = try? inspect()
        .find(ViewType.List.self)
        .count else {
            return 0
        }
        
        return count
    }
}
