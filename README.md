linux-system-roles.github.io web page
***

For more information about the roles/collection please refer to our website [linux-system-roles.github.io](https://linux-system-roles.github.io/)

A more direct readme concerning the roles/collection can be found [here](index.md)

This page bases on the [slim-pickins-jekyll-theme](http://chrisanthropic.github.io/slim-pickins-jekyll-theme/) with several changes on top.

When including examples of Ansible code with jinja2 templating,
you will typically have to tell jekyll and its templating engine
to disable brace expansion.  One technique is to use `{% raw %}`
at the beginning of the file and `{% endraw %}` at the end of
the file, or use
```
<!-- {% raw %} -->
Ansible/jinja2 goes here
<!-- {% endraw %} -->
```
blocks.

## Build

This site is a [Jekyll](https://jekyllrb.com/) project. You can build it locally for
testing, and you can also build it with the same Jekyll version and plugins that
[GitHub Pages](https://pages.github.com/versions/) uses before pushing changes.

### Prerequisites

- Ruby (3.3.x recommended for GitHub Pages parity; 3.4.x usually works)
- Bundler: `gem install bundler`

### Local development

Install dependencies and build with the project `Gemfile` (currently Jekyll 4.x):

```bash
bundle install
bundle exec jekyll build
```

Output is written to `_site/`.

Run a local server for interactive testing:

```bash
bundle exec jekyll serve --livereload --force_polling
```

Then open [http://127.0.0.1:4000/](http://127.0.0.1:4000/). Use `--force_polling` so
Jekyll notices changes under `_data/` (for example `nav.yml`).

The `rake build` task also minifies HTML with `html_compressor`. GitHub Pages does
not run that step, so prefer `bundle exec jekyll build` when checking whether a
change will deploy successfully.

### GitHub Pages build (recommended before pushing)

GitHub Pages does not use this repository's `Gemfile`. It builds with the
[`github-pages`](https://github.com/github/pages-gem) gem (Jekyll 3.10.0 and related
plugin versions). To reproduce that environment locally, use `Gemfile.github-pages`:

```bash
BUNDLE_GEMFILE=Gemfile.github-pages bundle install --path .vendor/github-pages

JEKYLL_ENV=production \
PAGES_REPO_NWO=linux-system-roles/linux-system-roles.github.io \
BUNDLE_GEMFILE=Gemfile.github-pages \
bundle exec jekyll build
```

- `JEKYLL_ENV=production` matches the GitHub Pages build environment.
- `PAGES_REPO_NWO` is required by `jekyll-github-metadata` (set automatically on
  GitHub).

List the exact dependency versions GitHub Pages uses:

```bash
BUNDLE_GEMFILE=Gemfile.github-pages bundle exec github-pages versions
```

Serve locally with the GitHub Pages toolchain:

```bash
JEKYLL_ENV=production \
PAGES_REPO_NWO=linux-system-roles/linux-system-roles.github.io \
BUNDLE_GEMFILE=Gemfile.github-pages \
bundle exec jekyll serve --livereload --force_polling
```

If this build succeeds, the site is very likely to build on GitHub Pages as well.

**Note:** GitHub Pages runs Jekyll 3.10, while local development uses Jekyll 4.x from
the main `Gemfile`. Some features (for example `render_with_liquid: false`) behave
differently between versions. When a change touches Liquid-heavy content, run the
GitHub Pages build above in addition to the local development build.

