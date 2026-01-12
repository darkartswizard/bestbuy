const { test, expect } = require('@playwright/test');

test('navigate to BestBuy.com', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL(/.*bestbuy.com/);
  await expect(page).toHaveTitle(/Best Buy/);
});
