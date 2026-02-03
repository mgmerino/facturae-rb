# Docs Site Implementation Plan

This plan covers the static site used for the landing page and API docs.
The site uses Jekyll for layout and YARD for API documentation generation,
and is published via GitHub Pages.

## Goals

- Provide a polished landing page for the project.
- Publish API documentation generated from Ruby comments.
- Deploy via GitHub Pages using GitHub Actions.
- Keep build output out of the repository.

## Scope

- Landing page only (no guides yet).
- API docs from YARD.
- Canonical site URL: https://mgmerino.github.io/facturae-rb/

## Architecture

- Source: `docs-site/` (Jekyll input)
- Output: `public/`
- API docs: `public/api/` (YARD output)
- Build script: `bin/build-docs`

## Implementation Steps

1) Add Jekyll site skeleton
   - `docs-site/_config.yml`
   - `docs-site/_layouts/default.html`
   - `docs-site/index.md`
   - `docs-site/assets/styles.css`
   - `docs-site/robots.txt` and `docs-site/sitemap.xml`

2) Configure YARD
   - Add `.yardopts` to build into `public/api`.

3) Add build script
   - `bin/build-docs` to run Jekyll and YARD.
   - Ensure it cleans `public/` before generating outputs.

4) Configure GitHub Pages deployment
   - Workflow `.github/workflows/pages.yml` builds and deploys `public/`.

5) Update README
   - Add documentation site link and note YARD usage.

## Testing and Verification

- Local build:
  - `bundle exec jekyll build -s docs-site -d public`
  - `bundle exec yard doc`
- Check:
  - `public/index.html`
  - `public/api/index.html`
- Validate that GitHub Pages deployment succeeds on `main`.

## Maintenance Notes

- Keep `docs-site/_config.yml` updated with repo URL and baseurl.
- Update landing content as major features ship.
