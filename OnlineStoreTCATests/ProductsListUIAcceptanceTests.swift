
import XCTest
import ViewInspector
import ComposableArchitecture
@testable import OnlineStoreTCA

extension InspectableSheet: PopupPresenter { }

final class ProductsListUIAcceptanceTests: XCTestCase {

    func test_onCartListSelection_WithNonSelectedItems_displaysEmptyCarList() {
        let cartList = showEmptyCartList()
        
        XCTAssertEqual(cartList.numberOfDisplayedItems, 0)
    }
    
    @MainActor
    func test_onCartListSelection_SelectedItems_displaysNonEmptyCarList() async throws {
        // launch mainView
        let mainView = try await showLoadedMainView()
        
        // assert one item is presented.
        XCTAssertEqual(mainView.numberOfDisplayedProducts(), 1)
        
        // add an item to the cart from the list.
        mainView.simulateAddItemToCart()
        
        // select cart list button.
        mainView.simulateCartListButton()
        
        // return the cart list view.
        
        // assert presented values.
    }
    
    // MARK: - Helpers
    @MainActor
    private func showLoadedMainView() async throws -> TabViewContainer {
        // launch the screen with needed stubbed infrastructure and state given.
        let (effect, op) = createEffectFetchProducts()
        
        let app = OnlineStoreTCAApp(effectFetchProducts: effect)
        
        let mainView = app.mainView
        
        // load the main view.
        mainView.simulateAppearance()
        
        try await waitFor(operation: op)
        
        return mainView
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
    
    private func waitFor(operation: @Sendable (Send<ProductListDomain.Action>) async throws -> Void) async throws {
        try await operation(Send<ProductListDomain.Action>(send: { _ in }))
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
        let productListView = try? inspect()
            .find(TabViewContainer.self)
            .find(viewWithTag: "anyView")
            .tabView()
            .find(ProductsContainerView.self)
            .find(viewWithTag: "anyView")
            .find(ProductListView.self)
            .find(viewWithTag: "anyView")
            .group()
        
        _ = try? productListView?.callOnAppear()
        
    }
    
    func simulateAddItemToCart() {
        
    }
    
    func simulateCartListButton() {
        
    }
}
