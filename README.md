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
- For future CMS/admin integration, `script.js` exposes `window.IDEAL_FOODZ_ADMIN` as a placeholder.

WhatsApp number

- WhatsApp order opens: https://wa.me/918985562963 with a pre-filled message containing cart items.

Notes

- Images are hotlinked to Unsplash for lightweight scaffolding; replace with optimized local images for production.
- For SEO and performance: add meta images, compress assets, and enable server-level caching when deploying.

Image generation

- Prompts for premium image generation are in `prompts/image-prompts.md`.
- There are two helper scripts in `scripts/`:
	- `generate_images_template.ps1` — a PowerShell template showing example API calls (OpenAI-style) you can adapt and run after setting your API key in `$env:OPENAI_API_KEY`.
	- `download_placeholders.ps1` — downloads current placeholder Unsplash images into `images/` (run locally; some URLs may fail due to remote restrictions).

To generate and save images locally (recommended flow):

```powershell
# 1. Run placeholder download if you want current remote images cached
.\scripts\download_placeholders.ps1

# 2. Or generate premium images with your provider. Set your key and run the template commands
$env:OPENAI_API_KEY = 'sk-...'
.\scripts\generate_images_template.ps1
# edit the generated curl commands for your provider and run them in a compatible shell
```

Replace the generated images in `images/` and update `index.html` (the file already points to local `images/` filenames if present).

If you'd like, I can:

- Replace image placeholders with provided photos.
- Build a tiny admin JSON editor to edit the menu in-browser.
- Package this as a deployable static site (Netlify/Vercel) and add CI instructions.

GitHub Pages deployment

This project includes a GitHub Actions workflow at `.github/workflows/deploy.yml` which will publish the repository contents to the `gh-pages` branch on every push to `main` or `master`.

To enable GitHub Pages for this repo:

1. Create a GitHub repository and add it as a remote, or set your existing remote:

```powershell
git remote add origin https://github.com/<your-username>/<repo>.git
git push -u origin main
```

2. The workflow will run automatically and deploy the repository root to the `gh-pages` branch. GitHub Pages will serve from that branch.

3. If you prefer to publish only a `docs/` folder, change `publish_dir` in `.github/workflows/deploy.yml` to `./docs` and move the built site there.

Notes:
- The workflow uses the built-in `GITHUB_TOKEN` so no extra secrets are required for standard deployments.
- If you want the site on a custom domain, configure the `CNAME` file in the repo and update GitHub Pages settings.

