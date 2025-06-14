+++
title = "How to blog with Zola, a Rust-based static site generator"
date = 2024-06-02
+++

Here is how I am running this blog using Zola.

## What is Zola?

> Zola is a static site generator (SSG), similar to Hugo, Pelican, and Jekyll (for a comprehensive list of SSGs, please see Jamstack). It is written in Rust and uses the Tera template engine, which is similar to Jinja2, Django templates, Liquid, and Twig. [source](https://www.getzola.org/documentation/getting-started/overview/#markdown-content)

## Installation

```bash
brew install zola  # cargo would not work for me
zola init .  # I had a repo, else: zola init myblog
# follow the instructions
# add a theme (https://www.getzola.org/themes/)
git submodule add https://github.com/pawroman/zola-theme-terminimal themes/terminimal
zola create post "My First Post"
```

Maybe something more but these were the main steps.

## Configuration

This is my `config.toml`:

```toml
base_url = "https://rsbit.es"
title = "Bite‑sized Rust learning, powered by Pybites"
description = "Documenting the journey of a Pythonista learning Rust with bite-sized posts."
theme = "terminimal"
compile_sass = true
build_search_index = false
generate_feed = true
feed_filename = "atom.xml"

[markdown]
highlight_code = true

[extra]
logo_text = "Bite-sized Rust"
logo_home_link = "/"
author = "Bob Belderbos"

# Whether to show links to earlier and later posts
# on each post page (defaults to true).
enable_post_view_navigation = true

# The text shown at the bottom of a post,
# before earlier/later post links.
# Defaults to "Thanks for reading! Read other posts?"
post_view_navigation_prompt = "Read more"

# - "combined" -- combine like so: "page_title | main_title",
#                 or if page_title is not defined or empty, fall back to `main_title`
page_titles = "combined"
```

- `base_url` is important for the theme to work correctly (I forgot to update https://example.com at the start and it broke the theme's styling)
- `theme` is the name of the theme folder in `themes/`
- `compile_sass` - Sass compilation is required (see [theme docs](https://github.com/pawroman/zola-theme-terminimal))
- the settings under `[extra]` are theme specific.

## Writing

For each new post, you create a new markdown file in the `content` folder. The file name should be the title of the post with dashes instead of spaces.

The file should start with a TOML front matter block, which is the metadata for the post. Here is an example:

```markdown
+++
title = "How to set up Zola"
date = 2024-06-02
+++
```

If you want to add more metadata, you can add it in this front matter block. If you don't want to publish the post yet, you can add `draft = true` for example.

Then write the content in markdown beneath this block.

To make a new post I made a quick shell script:

```bash
$ cat new_post.sh
#!/bin/bash

# Prompt for the slug and title
read -p "Enter the slug (e.g., my-new-post): " slug
read -p "Enter the title: " title

# Get today's date
date=$(date +"%Y-%m-%d")

# Define the file path
file_path="content/${slug}.md"

# Create the new markdown file with front matter
cat <<EOL > $file_path
+++
title = "${title}"
date = ${date}
+++

EOL

echo "New post created at $file_path"
```

## Building

```bash
zola build
```

This will generate the static site in the `public` folder.

Then run a local server to preview the site:

```bash
zola serve
```

For convenience I made a Makefile with some aliases including a combined `dev` command:

```makefile
.PHONY: build serve dev clean checkout-theme

build:
	zola build

serve:
	zola serve

dev:
	zola build && zola serve

clean:
	rm -rf public

checkout-theme:
	git submodule update --init
```

`checkout-theme` I added later when I git clone'd this repo on a new machine and detected that the theme repo was not cloned automatically.

## Deployment

I use GitHub Actions to build and deploy the site (so nice!)

Here is the workflow file (`.github/workflows/deploy.yml`):

```yaml
# On every push this script is executed
on: push
name: Build and deploy GH Pages
jobs:
  build:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout main
        uses: actions/checkout@v4
      - name: Build and deploy
        uses: shalzz/zola-deploy-action@v0.18.0
        env:
          PAGES_BRANCH: gh-pages
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This workflow will build the site and push the changes to the `gh-pages` branch upon every push to the `main` branch.

- Interestingly ChatGPT overcomplicated this, but I found in Zola's docs that you can actually use shalzz/zola-deploy-action. I only had to update from 0.17.x to 0.18.x to make it work.

- You don't have to setup the `secrets.GITHUB_TOKEN` as it is a default secret provided by GitHub if you use your action for the same repository.

- I did have to update the "Workflow permissions" under GitHub's repo Settings > Actions, to enable "Read and write permissions" (_Workflows have read and write permissions in the repository for all scopes._), otherwise the action would fail.

- I also had to set "Build and deployment" to "Deploy form a branch" (under Settings > Pages) and set the branch to `gh-pages` + `/ (root)`.

## Static files

I did hit one issue when showing images in the post.

I thought this would work:

```
![overview mind map of how PyO3 and Maturin work to run Rust code in Python](/rust-in-python.png)
```

Having the image in my `static/` folder, but it didn't show up on the live site.

I played with the path making it relative and absolute, but in the end, I had to use the `image()` shortcode with the `src` attribute pointing to the image in the `static/` folder (just the file name, not the full path). See [theme docs](https://github.com/pawroman/zola-theme-terminimal?tab=readme-ov-file#shortcodes) as well.

## Add pages

This was a bit less straight-forward so I am adding it here as an extra. See [commit](https://github.com/bbelderbos/rust-blog/commit/29648aefb30b46a0dab7d110d833d65370c26964):

- I created a `menu_items` array in the `config.toml` with the pages I wanted to add to the menu.
- I created a `content/pages` folder and added a markdown file for each page using existing templates from the theme (about and archive).
- I also made an `content/pages/_index.md`, I cannot 100% remember but I think it would not compile without it.
- I could move the post entries to a new `content/posts` folder (and use the `content/posts/_index.md` to list the posts), but I decided to keep them in the root `content` folder for now.

OK that seems easier than it was, but I had to try a few things to get it right. 😅

## Add search

You can enable search in the theme by setting `build_search_index = true` in the `config.toml`. This will generate `search_index.json` and `elasticlunr.min.js` files in the `public` folder upon build.

`elasticlunr.js` is a lightweight full-text search engine in JavaScript for browser search. The search index is generated from the content of the site upon build, the index is stored in mentioned `search_index.json` file.

[Here](https://github.com/bbelderbos/rust-blog/commit/304d708a9454ad5d9bf43e58387803e5594c0f86) is the commit I made to get search working on this site:

- I created a `templates/search.html` file with the search form and results.

- It contains the necessary JavaScript to make this work. First we define an `idx` constant: `const idx = elasticlunr.Index.load(window.searchIndex);` which we can then use to search the index (`idx.search(query)`). It returns an array of search results which we then render in the DOM.

- I added some CSS to style the search results and added the page to the navigation menu with `{name = "Search", url = "$BASE_URL/pages/search"},` in the `config.toml`.

{{ image(src="/images/search-example1.png", alt="doing a search on this website",
         style="border-radius: 8px;") }}

{{ image(src="/images/search-example2.png", alt="another search",
         style="border-radius: 8px;") }}

## Add a custom domain

Apart from mentioned `base_url` in the `config.toml`, you also need to add a `CNAME` file in the `static/` folder with the domain you want to use, e.g.:

```bash
$ cat static/CNAME
rsbit.es
```

Then under the repo's Settings > GitHub Pages, you can add the custom domain. You can also turn on HTTPS there.

Lastly you need to update your DNS settings of your domain provider to point to GitHub's IP addresses, see [GitHub's docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site).

## Conclusion

Zola is a great SSG so far, I am happy with the setup. I like the simplicity of the tool and the speed of the generated site (Rust 📈 -> `zola build` -> `Done in 91ms.` for me) and automatic deployment with GitHub Actions. 😍

If you're looking for a Rust based SSG solution I hope this post will help you with the setup. 📈
