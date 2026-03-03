const puppeteer = require('puppeteer');

const url = process.argv[2];
const pdfPath = process.argv[3];
const title = process.argv[4] || '';

if (!url || !pdfPath) {
  console.error('Usage: node export-to-pdf.js <url> <output.pdf> [title]');
  process.exit(1);
}

console.log('Generating PDF from', url, '->', pdfPath);

const headerHtml = `
<div style="font-size: 9px; width: 100%; padding: 0 30px; display: flex; justify-content: space-between;">
  <span style="color: #666;">${title}</span>
  <span style="color: #666;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></span>
</div>`;

const footerHtml = `
<div style="font-size: 8px; width: 100%; text-align: center; color: #999; padding: 0 30px;">
  <span>&copy; Nobl9, Inc.</span>
</div>`;

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-gpu', '--disable-dev-shm-usage']
  });

  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 60000 });

  await page.pdf({
    path: pdfPath,
    format: 'Letter',
    displayHeaderFooter: true,
    printBackground: true,
    headerTemplate: headerHtml,
    footerTemplate: footerHtml,
    scale: 0.9,
    margin: {
      top: '80px',
      bottom: '60px',
      left: '30px',
      right: '30px'
    }
  });

  console.log('PDF saved to', pdfPath);
  await browser.close();
})();
