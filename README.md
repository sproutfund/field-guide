# Sprout Field Guide for Philanthropy & Civic Action

Ideas and resources to seed innovation, make community-advised decisions, host participatory events, communicate effectively, and catalyze local change. Created by [The Sprout Fund](https://www.sproutfund.org/).

**Live Site:** [fieldguide.sproutfund.org](https://fieldguide.sproutfund.org)

## Overview

This Jekyll-based static site documents The Sprout Fund's accumulated knowledge in catalytic funding and community building. The site serves as a practical guide for philanthropic organizations, community foundations, and civic leaders looking to implement participatory grantmaking and community engagement programs.

**Key Technologies:**
- Jekyll 3.10.0 (static site generator)
- GitHub Pages 232
- Ruby 3.3.4
- Bootstrap 4 (theme framework)
- kramdown (Markdown processor)

## Quick Start with Docker (Recommended)

The best way to develop this site is using **VS Code with devcontainers**, which provides a consistent Docker-based environment without installing Ruby, Jekyll, or dependencies on your local machine. This approach also allows you to use agentic command-line tools (like `claude`) from your host machine while the development server runs in the container.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed
- [Visual Studio Code](https://code.visualstudio.com/) installed (or compatible alternative like Cursor)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code

### Preferred Workflow: VS Code Devcontainer + Command-line Claude

1. **Open in VS Code (or compatible)**:
   ```bash
   code .
   ```

2. **Reopen in Container**:
   - When prompted, click "Reopen in Container"
   - Or: Press `F1` → "Dev Containers: Reopen in Container"
   - First-time setup will build the Docker image and install dependencies automatically

3. **Start Jekyll server**:
   - Press `Cmd+Shift+B` (Mac) or `Ctrl+Shift+B` (Windows/Linux)
   - Select "Serve Jekyll (Dev)" from the task list
   - Or manually run in the VS Code terminal:
     ```bash
     bundle exec jekyll serve --config "_config.yml,_config_dev.yml" --host 0.0.0.0 --livereload
     ```

4. **Access the site**:
   - Open your browser to `http://localhost:4000/field-guide/`
   - Changes will auto-reload thanks to `--livereload`

5. **Use Claude Code from your host machine** (optional):
   - In a separate terminal on your host machine, run `claude`
   - Make changes via Claude Code CLI
   - Changes are immediately visible in the devcontainer
   - Jekyll livereload automatically refreshes your browser

**Why this workflow?** The devcontainer handles all Jekyll dependencies, while you can use command-line `claude` from your host machine. Both see the same files, and livereload works seamlessly across both.

### Alternative: Docker CLI Commands (Without VS Code)

If you prefer not to use VS Code, you can run Docker commands directly:

1. **Build the Docker image** (first time only):
   ```bash
   docker build -t field-guide-jekyll .
   ```

2. **Run the development server**:
   ```bash
   docker run --rm -it \
     -v "$(pwd):/srv/jekyll" \
     -p 4000:4000 \
     field-guide-jekyll \
     bundle exec jekyll serve --config "_config.yml,_config_dev.yml" \
     --host 0.0.0.0 --livereload
   ```

3. **Access the site**:
   - Open your browser to `http://localhost:4000/field-guide/`
   - Changes will auto-reload thanks to `--livereload`

### Additional Docker Commands

```bash
# Build for development (faster, useful for testing)
docker run --rm -v "$(pwd):/srv/jekyll" field-guide-jekyll \
  bundle exec jekyll build --config "_config.yml,_config_dev.yml"

# Build for production
docker run --rm -v "$(pwd):/srv/jekyll" field-guide-jekyll \
  bundle exec jekyll build

# Incremental builds (faster for small changes)
docker run --rm -it -v "$(pwd):/srv/jekyll" -p 4000:4000 field-guide-jekyll \
  bundle exec jekyll serve --config "_config.yml,_config_dev.yml" \
  --host 0.0.0.0 --livereload --incremental
```

## Local Development (Alternative)

If you prefer to develop without Docker, you can install dependencies locally.

### Prerequisites

- Ruby 3.3.4 (recommended) or compatible version
- Bundler gem

### Setup

1. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

### Development Commands

```bash
# Development server with live reload (recommended)
bundle exec jekyll serve --config "_config.yml,_config_dev.yml" --livereload

# Development server with incremental builds (faster for large sites)
bundle exec jekyll serve --config "_config.yml,_config_dev.yml" --livereload --incremental

# Build for development
bundle exec jekyll build --config "_config.yml,_config_dev.yml"

# Build for production
bundle exec jekyll build
```

The development server will be available at `http://localhost:4000/field-guide/`

## Project Structure

### Content Organization

The site is organized around two main program areas:

```
catalytic-funding/          # Grantmaking and funding programs
├── planning-preparing/     # Program design, fundraising
├── cultivating-applicants/ # Application design, outreach
├── making-decisions/       # Committee management, review
├── managing-funded-projects/ # Grant administration
└── sustaining-sunsetting/  # Feedback, wrap-up

community-building/         # Participatory events and engagement
├── campaigns/              # Campaign planning
├── experiences/            # Event types (ideation, showcase, etc.)
├── techniques/             # Facilitation methods
└── voices-from-the-field/  # Practitioner biographies
```

### Key Directories

```
_data/                      # Structured data files
├── nav.yml                 # Site navigation structure
├── voices.yml              # Featured contributors
├── templates-downloads/    # Downloadable resources
├── related-external-links/ # External resource links
├── checklists/             # Task lists
├── community-building-experiences.yml
└── community-building-techniques.yml

_layouts/                   # Page templates
├── default.html            # Base HTML structure
├── docs.html               # Main documentation pages
├── experiences.html        # Community building events
├── techniques.html         # Facilitation techniques
├── voices-from-the-field.html  # Biography pages
├── home.html               # Homepage
└── ...

_includes/                  # Reusable components
├── header.html, navbar.html, footer.html
├── sidebar.html, toc.html
└── docs/                   # Documentation-specific includes
    ├── thinking-questions.html
    ├── templates-downloads.html
    ├── related-external-links.html
    └── ...

_plugins/                   # Custom Jekyll plugins
├── reading_time.rb         # Calculate reading time
└── shuffle.rb              # Randomize arrays

assets/                     # Static assets
├── brand/                  # Logos and brand assets
├── css/                    # Stylesheets
└── img/                    # Images
```

### Configuration Files

- **_config.yml**: Production configuration (baseurl: empty for root)
- **_config_dev.yml**: Development overrides (baseurl: `/field-guide`)
- **Gemfile**: Ruby dependencies (uses `github-pages` gem pinned to version 232)

## Architecture Details

### Content Pages and Frontmatter

All content pages use YAML frontmatter to control their rendering:

```yaml
---
layout: docs                # Layout to use
title: "Page Title"         # Page heading
subtitle: "Brief description"
description: "SEO description"
section: catalytic-funding  # Top-level section
group: planning-preparing   # Sub-section
toc: true                   # Show table of contents
---

Page content in Markdown...
```

**📖 For complete documentation on frontmatter fields, layouts, and content structure, see [docs/CONTENT_GUIDE.md](docs/CONTENT_GUIDE.md)**

### Data-Driven Features

The site uses YAML data files to drive navigation, downloads, and other dynamic content:

- **Navigation**: `_data/nav.yml` defines the entire site hierarchy
- **Templates/Downloads**: Auto-populated on relevant pages based on page slug
- **Checklists**: Structured task lists rendered from YAML
- **Voices**: Ordered list of featured contributors

**📖 For complete documentation on data file structures, see [docs/DATA.md](docs/DATA.md)**

### Custom Plugins

**Reading Time (`reading_time.rb`):**
- Automatically calculates estimated reading time for pages
- Assumes 180 words per minute
- Usage: `{{ content | reading_time }}`

**Shuffle (`shuffle.rb`):**
- Randomizes arrays for rotating testimonials or examples
- Usage: `{{ array | shuffle }}`

### Specialized Layouts

**docs.html** - Main documentation layout with:
- Sidebar navigation
- Table of contents (optional)
- Templates/downloads section (auto-populated)
- Related external links (auto-populated)

**experiences.html** - Community building event guides

**techniques.html** - Facilitation technique documentation

**voices-from-the-field.html** - Biography pages with "learn more" sidebar

## Important Development Notes

- **Baseurl Difference**: Production uses empty baseurl (root `/`), development uses `/field-guide`
- **Asset Paths**: Always use `{{ site.baseurl }}/path` in templates for proper URL generation
- **Navigation Changes**: Updates to `_data/nav.yml` affect the entire site hierarchy
- **Reading Time**: Automatically displayed on documentation pages
- **URL Structure**: Uses Jekyll pretty permalinks (`/section/group/page-name/`)

## Jekyll Plugins

**Standard GitHub Pages plugins:**
- **jekyll-redirect-from**: URL redirects via `redirect_from:` frontmatter
- **jekyll-seo-tag**: SEO meta tags
- **jekyll-sitemap**: Sitemap generation
- **jekyll-relative-links**: Convert relative links to work in Jekyll
- **jemoji**: Emoji support

**Custom plugins:**
- **reading_time.rb**: Reading time calculation
- **shuffle.rb**: Array randomization

## Exporting Content

The site includes functionality to export all content to Markdown files optimized for LLM ingestion. This consolidates the entire Field Guide into structured documents that preserve the navigation hierarchy.

### Export Files Generated

- **FIELDGUIDE_all.md**: Complete export of all content
- **FIELDGUIDE_catalytic-funding.md**: Catalytic funding section only
- **FIELDGUIDE_community-building.md**: Community building section only

### Running the Export

**Using VS Code:**
1. Press `Cmd+Shift+P` / `Ctrl+Shift+P`
2. Select "Tasks: Run Task"
3. Choose "Export Field Guide to Markdown"
4. Exported files will be in `exports/` directory

**Using command line:**
```bash
bundle exec jekyll build --config "_config.yml,_config_export.yml"
mkdir -p exports
cp _site/FIELDGUIDE_*.md exports/
```

**Export Features:**
- Follows `_data/nav.yml` hierarchy with flat structure
- Sections marked with horizontal rules and bold uppercase text
- Pages use `#` headings (top level)
- Groups are noted with italicized text between pages
- Includes full markdown content from all pages with original heading structure
- Renders data file content inline for experiences/techniques
- Page content headings (`##`, `###`, etc.) preserved as-is for natural hierarchy

**Export Structure Example:**
```markdown
---
**CATALYTIC FUNDING**

_**Planning & Preparing**_

# Program Design

**Subtitle**

## Overview
[Content from page's ## Overview section...]

## Recommendations
[Content from page's ## Recommendations section...]

# Fundraising

**Subtitle**

## Getting Started
[Content...]

_**Cultivating Applicants**_

# Application Design

**Subtitle**

## Overview
...
```

## Contributing

When making changes:

1. Test locally using Docker or local development setup
2. Verify both development and production builds
3. Ensure navigation hierarchy updates properly
4. Check that asset paths work with both baseurls
5. Validate frontmatter in new or modified pages

## Documentation

- **[CLAUDE.md](CLAUDE.md)**: Guide for AI coding assistants working with this repository
- **[docs/CONTENT_GUIDE.md](docs/CONTENT_GUIDE.md)**: Complete guide to frontmatter, layouts, and content structure
- **[docs/DATA.md](docs/DATA.md)**: Documentation for data file structures and usage

## License

See [LICENSE.md](LICENSE.md) for details.

## Repository

[github.com/sproutfund/field-guide](https://github.com/sproutfund/field-guide)
