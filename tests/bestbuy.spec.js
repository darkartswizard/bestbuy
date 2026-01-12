const { test, expect, chromium } = require('@playwright/test');

test.use({
  browserName: 'chromium',
  launchOptions: {
    channel: 'chrome', // Explicitly use Chrome
    headless: false, // Ensure the browser is launched in headed mode
  },
});

test('navigate to BestBuy.com', async ({ page }) => {
  await page.goto('https://www.bestbuy.com'); // Use full URL
  await expect(page).toHaveURL(/.*bestbuy.com/);
  await expect(page).toHaveTitle(/Best Buy/);
});
