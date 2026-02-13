# Ideal Foodz — Static Website

Minimal, mobile-first landing page for the Ideal Foodz cloud kitchen. Features:

- Hero with CTAs
- Menu with categories and prices (INR)
- Client-side cart (localStorage)
- WhatsApp checkout with prefilled order message
- Contact details and embedded map
- Sticky order button, smooth scrolling, responsive layout

Quick start

1. Open the folder in your browser or a static server.

For a quick local preview using Python 3:

```bash
cd "d:/deekshith ck/ideal-foodz"
python -m http.server 8000
# then open http://localhost:8000
```

How to edit the menu

- Menu items are defined as `.card` elements in `index.html` with `data-name` and `data-price` attributes. Edit or add new cards for admin changes.
- For future CMS/admin integration, `script.js` exposes `window.IDEAL_FOODZ_ADMIN` as a placeholder.

WhatsApp number

- WhatsApp order opens: https://wa.me/918985562963 with a pre-filled message containing cart items.

Notes

- Images are hotlinked to Unsplash for lightweight scaffolding; replace with optimized local images for production.
- For SEO and performance: add meta images, compress assets, and enable server-level caching when deploying.

If you'd like, I can:

- Replace image placeholders with provided photos.
- Build a tiny admin JSON editor to edit the menu in-browser.
- Package this as a deployable static site (Netlify/Vercel) and add CI instructions.
