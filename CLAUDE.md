# AGENTS.md / CLAUDE.md

This file provides guidance to coding assistants and agents (such as Claude Code) when working with files in this repository.

## Project Overview

This is The Sprout Fund's Field Guide for Philanthropy & Civic Action, built with Jekyll and GitHub Pages. The site documents best practices, lessons learned, and practical guidance for catalytic funding and community building.

**Live URL:** https://fieldguide.sproutfund.org
**Repository:** https://github.com/sproutfund/field-guide

## Development Commands

### Preferred: VS Code Devcontainer

The recommended development approach uses VS Code with devcontainers, which provides a consistent Docker-based environment. This allows you to run Jekyll in a container while using command-line `claude` from the host machine.

**Setup:**
1. Open folder in VS Code
2. Click "Reopen in Container" (or F1 → "Dev Containers: Reopen in Container")
3. Press `Cmd+Shift+B` / `Ctrl+Shift+B` to start Jekyll server
4. Access site at `http://localhost:4000/field-guide/`

**Configuration files:**
- `.devcontainer/devcontainer.json`: Devcontainer configuration with auto port forwarding (4000, 35729)
- `.vscode/tasks.json`: VS Code tasks for starting Jekyll with keyboard shortcuts

**Workflow benefits:**
- Both VS Code (in container) and command-line `claude` (on host) see the same files
- Jekyll livereload works seamlessly across both
- No need to install Ruby or Jekyll on host machine

### Docker Development

The project includes a comprehensive Dockerfile:
- **Base**: Ubuntu 24.04 LTS
- **Ruby**: 3.3.4 (matches GitHub Pages exactly)
- **Node.js/npm**: Included for potential future Lunr.js search functionality
- **Jekyll**: 3.10.0
- **GitHub Pages gem**: 232

**Build image:**
```bash
docker build -t field-guide-jekyll .
```

**Run development server:**
```bash
docker run --rm -it \
  -v "$(pwd):/srv/jekyll" \
  -p 4000:4000 \
  field-guide-jekyll \
  bundle exec jekyll serve --config "_config.yml,_config_dev.yml" \
  --host 0.0.0.0 --livereload
```

**Note:** WORKDIR is set to `/srv/jekyll` in the Dockerfile, so volume mounts work correctly.

### Local Development (Without Docker)

If developing without Docker, install dependencies locally:

```bash
# Install dependencies (requires Ruby 3.3.4)
bundle install

# Development server with live reload (uses both config files)
bundle exec jekyll serve --config "_config.yml,_config_dev.yml" --livereload

# Development server with incremental builds
bundle exec jekyll serve --config "_config.yml,_config_dev.yml" --livereload --incremental

# Build for development
bundle exec jekyll build --config "_config.yml,_config_dev.yml"

# Build for production
bundle exec jekyll build
```

**Note:** Only `bundle install` is currently required. Node.js/npm support is available for future enhancements (e.g., Lunr.js search).

## Architecture

### Content Organization

The site uses a **hierarchical content structure** organized around two main program areas:

- **Catalytic Funding**: Guides for grantmaking and funding programs
  - `catalytic-funding/planning-preparing/`: Program design, fundraising
  - `catalytic-funding/cultivating-applicants/`: Application design, outreach, prospect management
  - `catalytic-funding/making-decisions/`: Committee management, review processes
  - `catalytic-funding/managing-funded-projects/`: Grant administration, reporting, grantee support
  - `catalytic-funding/sustaining-sunsetting/`: Program feedback and wrap-up

- **Community Building**: Guides for participatory events and community engagement
  - `community-building/campaigns/`: Campaign planning and execution
  - `community-building/experiences/`: Event types (ideation, knowledge-sharing, showcase, etc.)
  - `community-building/techniques/`: Facilitation methods (generate, prioritize, reflect)
  - `community-building/voices-from-the-field/`: Practitioner biographies and perspectives

### Key Directories

- **_layouts/**: Page templates (docs.html, experiences.html, techniques.html, voices-from-the-field.html, etc.)
- **_includes/**: Reusable components (navbar, footer, sidebar, toc, specialized doc components)
- **_includes/docs/**: Documentation-specific includes (thinking-questions, templates-downloads, checklists, etc.)
- **_data/**: Structured data files (nav.yml, voices.yml, templates-downloads/, checklists/, etc.)
- **_plugins/**: Custom Jekyll plugins (reading_time.rb, shuffle.rb)
- **assets/**: Static assets (brand logos, CSS/SCSS, images)

### Configuration

- **_config.yml**: Production configuration (baseurl: empty string for root)
- **_config_dev.yml**: Development overrides (baseurl: `/field-guide`)
- **Gemfile**: Uses `github-pages` gem (pinned to version 232) for consistency with GitHub Pages deployment

### Layouts and Their Purpose

The site uses specialized layouts for different content types:

1. **docs.html**: Main documentation pages with sidebar navigation, table of contents, and optional templates/downloads sections
2. **experiences.html**: Community building event guides with special formatting
3. **techniques.html**: Facilitation technique documentation
4. **voices-from-the-field.html**: Practitioner biography pages with "learn more" sidebar
5. **templates-downloads.html**: Template and resource download pages
6. **home.html**: Homepage layout
7. **default.html**: Base HTML structure

**See [docs/CONTENT_GUIDE.md](docs/CONTENT_GUIDE.md) for complete documentation** on layouts, frontmatter fields, and content structure.

### Data-Driven Components

Several site features are driven by YAML data files:

- **_data/nav.yml**: Hierarchical site navigation structure
- **_data/voices.yml**: Ordered list of featured contributors for the Voices from the Field section
- **_data/templates-downloads/**: Downloadable resources organized by section
- **_data/related-external-links/**: External resource links organized by section
- **_data/checklists/**: Structured task lists for guides
- **_data/community-building-experiences.yml**: Event type definitions
- **_data/community-building-techniques.yml**: Facilitation technique descriptions

**See [docs/DATA.md](docs/DATA.md) for complete documentation** on data file structures and usage.

### Custom Jekyll Plugins

- **reading_time.rb**: Calculates and displays estimated reading time (180 words/minute)
- **shuffle.rb**: Randomizes arrays (useful for rotating examples/testimonials)

### Standard GitHub Pages Plugins

- jekyll-redirect-from
- jekyll-seo-tag
- jekyll-sitemap
- jemoji
- jekyll-relative-links

## Content Structure Conventions

### Documentation Pages (layout: docs)

Documentation pages use frontmatter to control navigation, display options, and dynamic content:

```yaml
layout: docs
title: "Page Title"
subtitle: "Brief description"
description: "Full SEO description"
section: catalytic-funding | community-building
group: planning-preparing | cultivating-applicants | experiences | etc.
toc: true | false
```

Key sections within documentation pages:
- **Thinking Questions**: Styled alert boxes for reflection prompts (via `thinking-questions.html` include)
- **Templates & Downloads**: Auto-populated from `_data/templates-downloads/` based on page slug
- **Related External Links**: Auto-populated from `_data/related-external-links/` based on page slug
- **Checklists**: Structured task lists from `_data/checklists/`

### Voices from the Field Pages

Biography pages for featured practitioners:

```yaml
layout: voices-from-the-field
title: "Person Name"
subtitle: "Role/Title"
section: community-building
group: voices-from-the-field
voices-learn-more:
  text: "Learn more about their work"
  email: "email@example.com"
  twitter: "handle"
  website: "https://url.com"
```

### Experiences and Techniques Pages

Community building guides with specialized formatting:

```yaml
layout: experiences | techniques
title: "Experience/Technique Name"
subtitle: "Brief description"
section: community-building
group: experiences | techniques
```

## Exporting Content for LLM Ingestion

The site includes functionality to export all content to consolidated Markdown files optimized for LLM ingestion. This is useful for creating comprehensive references or training data.

**Export command:**
```bash
bundle exec jekyll build --config "_config.yml,_config_export.yml"
```

**Export files generated in `_site/`:**
- `FIELDGUIDE_all.md` - Complete export of all content
- `FIELDGUIDE_catalytic-funding.md` - Catalytic funding section only
- `FIELDGUIDE_community-building.md` - Community building section only

**Export characteristics:**
- Follows `_data/nav.yml` navigation hierarchy with flat structure
- Sections marked with `---` horizontal rules and **BOLD UPPERCASE** text (not headings)
- Groups noted with italicized text (`_**Group Name**_`) between related pages
- Pages use `#` level-1 headings with subtitle below
- Page content rendered with original heading structure (`##`, `###`, etc.) preserved
- Creates natural hierarchy: Page (`#`) → Content sections (`##`) → Subsections (`###`)
- Renders data file content inline for experiences/techniques pages
- Optimal for LLM ingestion with clear, consistent heading hierarchy

**Configuration:**
- Export layout: `_layouts/fieldguide_export.md`
- Export config: `_config_export.yml`
- Source files: `export_all.md`, `export_catalytic-funding.md`, `export_community-building.md`

## Important Notes

- **Baseurl difference**: Production uses empty baseurl (root `/`) while development uses `/field-guide`
- **Asset paths**: Always use `{{ site.baseurl }}/path` in templates for proper URL generation
- **Navigation hierarchy**: Controlled by `_data/nav.yml` - changes here affect the entire site navigation
- **Reading time**: Automatically calculated and displayed on documentation pages via custom plugin
- **Development workflow**: Preferred approach is VS Code devcontainer + command-line `claude` on host machine for seamless file sharing and live reload
- **Future enhancements**: Node.js/npm are installed in the Docker environment to support potential Lunr.js search implementation

## URL Structure

The site uses Jekyll's default pretty permalinks:
- Production: `https://fieldguide.sproutfund.org/section/group/page-name/`
- Development: `http://localhost:4000/field-guide/section/group/page-name/`

Redirects from legacy URLs are managed via `jekyll-redirect-from` plugin using `redirect_from:` frontmatter.
