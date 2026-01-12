# BestBuy Playwright Project

A base Playwright project that navigates to www.bestbuy.com

## Setup

1. Install dependencies:
```bash
npm install
```

2. Install Playwright browsers:
```bash
npx playwright install chromium
```

## Running Tests

Run tests in headless mode:
```bash
npm test
```

Run tests in headed mode (with browser UI):
```bash
npm run test:headed
```

Run tests in UI mode (interactive):
```bash
npm run test:ui
```

## Project Structure

- `tests/` - Contains test files
- `playwright.config.js` - Playwright configuration
- `package.json` - Project dependencies and scripts
