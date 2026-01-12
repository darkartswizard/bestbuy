const { expect } = require('@playwright/test');

class LandingPage {
  constructor(page) {
    this.page = page;
    this.searchBar = 'input[name="st"]'; // Example selector for the search bar
    this.cartIcon = 'a[href="/cart"]'; // Example selector for the cart icon
  }

  async navigate() {
    await this.page.goto('https://www.bestbuy.com');
  }

  async searchForItem(item) {
    await this.page.fill(this.searchBar, item);
    await this.page.press(this.searchBar, 'Enter');
  }

  async openCart() {
    await this.page.click(this.cartIcon);
  }
}

module.exports = LandingPage;