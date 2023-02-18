
import XCTest
import ViewInspector
import ComposableArchitecture
@testable import OnlineStoreTCA

extension InspectableSheet: PopupPresenter {}

final class ProductsListUIAcceptanceTests: XCTestCase {

    @MainActor
    func test_onCartListSelection_WithNonSelectedItems_displaysEmptyCarList() async throws {
        let mainView = try await showMainScreenWithStubbedProducts()
        let cartList = try showEmptyCartList(from: mainView)
        
        XCTAssertEqual(cartList.numberOfDisplayedItems, 0)
    }
    
    @MainActor
    func test_onAddProductUserInteraction_shouldShowCorrectCartListOnCartListScreenDisplay() async throws {
        let cartListView = try await showCartListWithProducts()
        
        XCTAssertEqual(cartListView.numberOfDisplayedProducts(), 1)
    }
    
    // MARK: - Helpers
    @MainActor
    private func showCartListWithProducts() async throws -> CartListView {
        let mainView = try await showMainScreenWithStubbedProducts()
        
        XCTAssertEqual(mainView.numberOfDisplayedProducts(), 1)
        
        return try simulateCartListWithProductsDisplayed(from: mainView)
    }
    
    @MainActor
    private func showMainScreenWithStubbedProducts() async throws -> TabViewContainer {
        // launch the screen with needed stubbed infrastructure and state given.
        let (effect, op) = createEffectFetchListProducts()
        
        let app = OnlineStoreTCAApp(effectFetchProducts: effect)
        
        let mainView = app.mainView
        
        // load the main view.
        mainView.simulateAppearance()
        
        try await waitFor(operation: op)
        
        return mainView
    }
    
    private func simulateCartListWithProductsDisplayed(from mainView: TabViewContainer) throws  -> CartListView {
        // add an item to the cart from the list.
        mainView.simulateAddItemToCart()
        
        // select cart list button.
        mainView.simulateCartListButton()
        
        return try mainView.presentedView()
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
    
    func showEmptyCartList(from mainView: TabViewContainer) throws -> CartListView {
        // select cart list button.
        mainView.simulateCartListButton()
        
        return try mainView.presentedView()
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
