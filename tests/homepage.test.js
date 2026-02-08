const { test, expect } = require('@playwright/test');

/**
 * @param {import('@playwright/test').Page} page
 */
async function handlePopups(page) {
  // Close feedback survey popup if present
  try {
    const surveyPopup = page.getByRole('button', { name: 'No, Thanks' });
    if (await surveyPopup.isVisible({ timeout: 2000 }).catch(() => false)) {
      await surveyPopup.click();
      console.log('Dismissed feedback survey popup');
    }
  } catch (e) {
    // Popup not present, continue
  }
  
  // Close location permission popup if present
  try {
    const locationPopup = page.getByRole('button', { name: 'Never allow' });
    if (await locationPopup.isVisible({ timeout: 2000 }).catch(() => false)) {
      await locationPopup.click();
      console.log('Dismissed location popup');
    }
  } catch (e) {
    // Popup not present, continue
  }
}

/**
 * @param {import('@playwright/test').Page} page
 */
async function performHiddenNavigation(page) {
  await page.waitForTimeout(3050);
  await handlePopups(page);
  await page.getByRole('link', { name: 'HP OMEN - Transcend 14" 120Hz' }).first().click();
  await page.waitForTimeout(1200);
  await page.getByRole('link', { name: 'BestBuy.com' }).click();
  await page.waitForTimeout(1090);
  await page.getByRole('link', { name: 'Cart, 0 item' }).click();
}

test('Homepage loads successfully', async ({ page }) => {
  await page.goto('https://www.bestbuy.com');
  const title = await page.title();
  console.log(`Page title: ${title}`);
  expect(title).toBeTruthy();
});

test('too many waits', async ({ page }) => {
  // Navigate to Best Buy homepage
  await page.waitForTimeout(1350);
  await page.goto('https://www.bestbuy.com');
  await page.waitForTimeout(1000);
  await page.getByTestId('SearchBarExtendable-TestID').click();
  await page.waitForTimeout(500);
  await page.getByTestId('SearchBarExtendable-TestID').fill('laptop');
  await page.waitForTimeout(1070);
  await page.getByTestId('TermSuggestion-3').getByTestId('SuggestionLink-TestID').click();
  await page.waitForTimeout(540);
  await performHiddenNavigation(page);
  await page.waitForTimeout(1380);
  await page.getByRole('link', { name: 'Returns & Exchanges' }).first().click();
  await page.waitForTimeout(20);
  
  console.log('Test completed with multiple hard-coded waits');
});