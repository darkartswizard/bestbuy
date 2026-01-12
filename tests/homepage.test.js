const { test, expect } = require('@playwright/test');

test('Homepage loads successfully', async ({ page }) => {
  await page.goto('https://www.bestbuy.com');
  const title = await page.title();
  console.log(`Page title: ${title}`);
  expect(title).toBeTruthy();
});