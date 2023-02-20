# Online Store with TCA - Navigation proposal.

This sample Code is a proposed navigation improvement from its the original source code `OnlineStoreTCA` https://github.com/pitt500/OnlineStoreTCA

This is achieved by following these 3 steps:

1. Refactor the code to enable Dependency inejection and inject the needed side effects.
2. Adding acceptance tests so we can refactor its code and make sure nothing breaks.
3. Move all navigation logic to the main module, making a container to compose all other modules, such as Produc list and cart list.
