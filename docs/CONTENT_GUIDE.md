# Content Guide for Field Guide for Philanthropy & Civic Action

This guide explains how the Field Guide website uses YAML frontmatter in markdown files to control page rendering through Liquid templates. The architecture separates content (frontmatter + markdown) from presentation (Liquid templates), enabling consistent, maintainable page structures.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Layouts Reference](#layouts-reference)
- [Frontmatter Fields](#frontmatter-fields)
- [Specialized Includes](#specialized-includes)
- [Content Organization](#content-organization)
- [Examples](#examples)
- [Creating New Pages](#creating-new-pages)

---

## Overview

The Field Guide website uses a **content-driven architecture** where:

1. **Content** lives in Markdown files with YAML frontmatter
2. **Structure** is defined by specialized Liquid templates (`_layouts/*.html`)
3. **Navigation** is controlled by `_data/nav.yml`
4. **Dynamic components** are auto-populated from data files in `_data/`

This separation allows:
- Content updates without touching templates
- Consistent styling across all pages
- Data-driven navigation and supplementary content
- Flexible page structures through layout selection

---

## Architecture

### File Structure

```
catalytic-funding/
└── planning-preparing/
    ├── program-design.md       # Content (frontmatter + markdown)
    └── fundraising.md

community-building/
├── experiences/
│   └── ideation.md
├── techniques/
└── voices-from-the-field/
    └── adam-kenney.md

_layouts/
├── default.html                # Base HTML structure
├── docs.html                   # Main documentation pages
├── experiences.html            # Community building events
├── techniques.html             # Facilitation techniques
└── voices-from-the-field.html  # Biography pages

_includes/
├── navbar.html, footer.html
├── sidebar.html, toc.html
└── docs/                       # Doc-specific includes
    ├── thinking-questions.html
    ├── templates-downloads.html
    └── related-external-links.html

_data/
├── nav.yml                     # Site navigation
├── templates-downloads/        # Downloadable resources
├── related-external-links/     # External resources
└── checklists/                 # Task lists
```

### Layout Hierarchy

All layouts extend `default.html`, which provides the base HTML structure:

```
default.html (base structure)
├── docs.html (documentation pages)
├── experiences.html (event guides)
├── techniques.html (facilitation methods)
├── voices-from-the-field.html (biographies)
├── home.html (homepage)
└── templates-downloads.html (resource pages)
```

---

## Layouts Reference

### 1. docs.html

**Purpose:** Main documentation layout for guides and how-to content

**Use for:** Catalytic funding guides, community building guides, general documentation

**Features:**
- Sidebar navigation (auto-populated from `_data/nav.yml`)
- Optional table of contents
- Templates/downloads section (auto-populated based on page slug)
- Related external links (auto-populated based on page slug)
- Reading time display

**Required frontmatter:**
```yaml
layout: docs
title: "Page Title"
subtitle: "Brief description"
description: "Full SEO description"
section: catalytic-funding | community-building
group: planning-preparing | cultivating-applicants | making-decisions | managing-funded-projects | sustaining-sunsetting | campaigns | experiences | techniques
```

**Optional frontmatter:**
```yaml
toc: true | false                # Show table of contents (default: false)
redirect_from:                   # Legacy URL redirects
  - /old-url
  - /another-old-url
```

**Template location:** `_layouts/docs.html`

---

### 2. experiences.html

**Purpose:** Community building event guides with specialized formatting

**Use for:** Event types (ideation, showcase, knowledge-sharing, etc.)

**Features:**
- Special icon display
- Auto-populated content from `_data/community-building-experiences.yml`
- Sidebar navigation
- Optional table of contents

**Required frontmatter:**
```yaml
layout: experiences
icon: 💡                         # Emoji icon for the experience
title: "Experience Name"
subtitle: "Brief description"
description: "SEO description"
section: community-building
group: experiences
experience: "Experience Name"    # Must match key in community-building-experiences.yml
```

**Optional frontmatter:**
```yaml
toc: true | false
```

**Template location:** `_layouts/experiences.html`

**Note:** The actual content is pulled from `_data/community-building-experiences.yml`, not from the markdown file body.

---

### 3. techniques.html

**Purpose:** Facilitation technique documentation

**Use for:** Generate, prioritize, reflect techniques

**Features:**
- Auto-populated content from `_data/community-building-techniques.yml`
- Sidebar navigation
- Special technique formatting

**Required frontmatter:**
```yaml
layout: techniques
title: "Technique Name"
subtitle: "Brief description"
description: "SEO description"
section: community-building
group: techniques
technique: "Technique Name"     # Must match key in community-building-techniques.yml
```

**Template location:** `_layouts/techniques.html`

**Note:** Like experiences, content is pulled from data files, not markdown body.

---

### 4. voices-from-the-field.html

**Purpose:** Practitioner biography pages

**Use for:** Featured contributor profiles and perspectives

**Features:**
- Biography content in markdown body
- "Learn more" sidebar with contact information
- Integration with `_data/voices.yml`

**Required frontmatter:**
```yaml
layout: voices-from-the-field
title: "Person Name"
subtitle: "Role/Organization"
section: community-building
group: voices-from-the-field
```

**Optional frontmatter:**
```yaml
voices-learn-more:
  text: "Learn more about..."
  email: "email@example.com"
  twitter: "handle"              # Without @ symbol
  website: "https://url.com"
```

**Template location:** `_layouts/voices-from-the-field.html`

**Note:** Content is written in the markdown body, not pulled from data files.

---

### 5. home.html

**Purpose:** Homepage layout

**Template location:** `_layouts/home.html`

---

### 6. templates-downloads.html

**Purpose:** Template and resource download pages

**Template location:** `_layouts/templates-downloads.html`

---

## Frontmatter Fields

### Universal Fields

These fields are used across all layouts:

```yaml
layout: [layout-name]           # Required: Which layout to use
title: "Page Title"             # Required: Main heading
subtitle: "Brief description"   # Optional: Subheading
description: "Full description" # Optional but recommended: SEO meta description
section: catalytic-funding | community-building  # Required: Top-level section
group: [group-name]             # Required: Sub-section grouping
```

### Navigation Fields

Control where the page appears in site navigation:

```yaml
section: catalytic-funding | community-building    # Primary section
group: planning-preparing | cultivating-applicants | making-decisions |
       managing-funded-projects | sustaining-sunsetting |
       campaigns | experiences | techniques | voices-from-the-field
```

The combination of `section` and `group` determines:
- Sidebar navigation context
- Breadcrumb trail
- URL structure

### Display Options

```yaml
toc: true | false               # Show table of contents (docs, experiences, techniques)
icon: 💡                        # Emoji icon (experiences only)
```

### Redirects

```yaml
redirect_from:                  # Legacy URL redirects (jekyll-redirect-from plugin)
  - /old-url-1
  - /old-url-2
  - /old-url-3
```

### Experience/Technique Specific

```yaml
experience: "Experience Name"   # For experiences layout - must match data file key
technique: "Technique Name"     # For techniques layout - must match data file key
```

### Voices from the Field Specific

```yaml
voices-learn-more:
  text: "Custom learn more text"
  email: "contact@email.com"
  twitter: "twitterhandle"      # Without @ symbol
  website: "https://url.com"
```

---

## Specialized Includes

### thinking-questions.html

**Purpose:** Display styled alert box with reflection questions

**Usage:**
```liquid
{% capture thinking-questions %}
### Thinking Questions

* What are your goals for the program?
* Who is your target audience?
* What resources do you have available?
{% endcapture %}
{% include docs/thinking-questions.html content=thinking-questions %}
```

**Renders:** Bootstrap alert box with custom styling

**Template location:** `_includes/docs/thinking-questions.html`

---

### templates-downloads.html

**Purpose:** Auto-populate downloadable resources for the current page

**Usage:**
```liquid
{% include docs/templates-downloads.html %}
```

**How it works:**
- Looks up current page's slug in `_data/templates-downloads/[section].yml`
- Renders list of downloads with icons, titles, descriptions
- Automatically includes download/external link icons

**Template location:** `_includes/docs/templates-downloads.html`

**Data structure:** See [DATA.md](DATA.md#templates-downloads) for details

---

### related-external-links.html

**Purpose:** Auto-populate external resource links for the current page

**Usage:**
```liquid
{% include docs/related-external-links.html %}
```

**How it works:**
- Similar to templates-downloads
- Looks up page slug in `_data/related-external-links/[section].yml`
- Renders list with external link icons

**Template location:** `_includes/docs/related-external-links.html`

---

### checklist.html

**Purpose:** Render structured task lists from data files

**Usage:**
```liquid
{% include docs/checklist.html data=site.data.checklists.catalytic-funding_application-components %}
```

**Template location:** `_includes/docs/checklist.html`

**Data structure:** See [DATA.md](DATA.md#checklists) for details

---

### example.html

**Purpose:** Render styled example boxes

**Template location:** `_includes/docs/example.html`

---

### sidebar.html

**Purpose:** Render left sidebar navigation

**How it works:**
- Reads `_data/nav.yml`
- Highlights current section/group
- Generates hierarchical navigation menu

**Template location:** `_includes/sidebar.html`

---

### toc.html

**Purpose:** Render table of contents from page headings

**How it works:**
- Automatically extracts headings from page content
- Generates linked navigation
- Only shown if `toc: true` in frontmatter

**Template location:** `_includes/toc.html`

---

## Content Organization

### URL Structure

Pages use Jekyll's pretty permalinks:

```
Production:  https://fieldguide.sproutfund.org/section/group/page-name/
Development: http://localhost:4000/field-guide/section/group/page-name/
```

**Examples:**
- `catalytic-funding/planning-preparing/program-design.md` → `/catalytic-funding/planning-preparing/program-design/`
- `community-building/voices-from-the-field/adam-kenney.md` → `/community-building/voices-from-the-field/adam-kenney/`

### Asset References

Always use `{{ site.baseurl }}` for asset paths:

```liquid
![Photo]({{ site.baseurl }}/assets/img/photo.jpg)
<a href="{{ site.baseurl }}/downloads/template.pdf">Download Template</a>
```

This ensures assets work in both development (`/field-guide`) and production (`/`) environments.

### Navigation Hierarchy

The site navigation is controlled by `_data/nav.yml`, which defines:
- Top-level sections (Catalytic Funding, Community Building)
- Groups within sections
- Page ordering within groups

**See [DATA.md](DATA.md#navigation) for complete navigation structure documentation.**

---

## Examples

### Example 1: Documentation Page (docs layout)

**File:** `catalytic-funding/planning-preparing/program-design.md`

**Frontmatter:**
```yaml
---
layout: docs
title: Program Design
subtitle: Comprehensive planning strategies to coordinate and inform the various funding program components.
description: An overview of areas to consider when designing a new funding program...
section: catalytic-funding
group: planning-preparing
redirect_from: /catalytic-funding/planning-preparing/
toc: true
---
```

**Content features:**
- Table of contents enabled
- Thinking questions section
- Templates/downloads auto-populated from data file
- Markdown body with headings, lists, links

---

### Example 2: Voices from the Field (biography)

**File:** `community-building/voices-from-the-field/adam-kenney.md`

**Frontmatter:**
```yaml
---
layout: voices-from-the-field
title: Adam Kenney
subtitle: Crafting Businesses, Supporting Makers
section: community-building
group: voices-from-the-field
voices-learn-more:
  text: "Learn more about Adam and Monmade"
  email: "Akenney@bridgewaycapital.org"
  twitter: "monmadepgh"
  website: "http://monmade.org"
---
```

**Content:** Biography written in markdown body

**Features:**
- "Learn more" sidebar with contact info
- Full markdown formatting in body
- No data file dependency

---

### Example 3: Experience Page

**File:** `community-building/experiences/ideation.md`

**Frontmatter:**
```yaml
---
layout: experiences
icon: 💡
title: "Ideation"
subtitle: "Develop ideas for new projects and programs."
description:
section: community-building
group: experiences
experience: Ideation
toc: true
---
```

**Note:** Content is empty or minimal in the markdown file. Actual content is pulled from `_data/community-building-experiences.yml` based on the `experience: Ideation` key.

---

## Creating New Pages

### Step-by-Step Guide

1. **Choose the appropriate layout:**
   - `docs` - For guides, how-tos, general documentation
   - `experiences` - For community building event guides (requires data file entry)
   - `techniques` - For facilitation methods (requires data file entry)
   - `voices-from-the-field` - For practitioner biographies

2. **Create markdown file in appropriate directory:**
   ```bash
   catalytic-funding/[group]/page-name.md
   community-building/[group]/page-name.md
   ```

3. **Add minimal frontmatter:**
   ```yaml
   ---
   layout: docs
   title: "Page Title"
   subtitle: "Brief description"
   description: "Full SEO description"
   section: catalytic-funding
   group: planning-preparing
   toc: true
   ---
   ```

4. **Write content in Markdown:**
   ```markdown
   ## Section Heading

   Content goes here...

   ### Subsection

   More content...
   ```

5. **Add to navigation** (if needed):
   - Edit `_data/nav.yml`
   - Add page to appropriate section/group
   - Order determines menu position

6. **Build and preview:**
   ```bash
   bundle exec jekyll serve --config "_config.yml,_config_dev.yml" --livereload
   ```

7. **View at:** `http://localhost:4000/field-guide/section/group/page-name/`

### Tips

- **Keep frontmatter minimal:** Only include fields you need
- **Use descriptive filenames:** Filename becomes URL slug
- **Test both baseurls:** Check production and development builds
- **Validate YAML:** Use a YAML validator if frontmatter isn't rendering
- **Reading time:** Automatically calculated and displayed on docs pages
- **Table of contents:** Only enable (`toc: true`) if page has multiple sections

### Common Patterns

**Documentation page with thinking questions:**
```markdown
---
layout: docs
title: "Guide Title"
subtitle: "Brief description"
section: catalytic-funding
group: planning-preparing
toc: true
---

## Overview

Introduction to the topic...

{% capture thinking-questions %}
### Thinking Questions

* Question 1?
* Question 2?
{% endcapture %}
{% include docs/thinking-questions.html content=thinking-questions %}

## Main Content

Rest of the guide...
```

**Biography page:**
```markdown
---
layout: voices-from-the-field
title: "Person Name"
subtitle: "Role/Organization"
section: community-building
group: voices-from-the-field
voices-learn-more:
  text: "Learn more about their work"
  email: "email@example.com"
  twitter: "handle"
  website: "https://url.com"
---

Biography content in markdown format...
```

**Page with legacy redirects:**
```yaml
---
layout: docs
title: "Page Title"
redirect_from:
  - /old-url
  - /another-old-url
  - /catalytic-funding/old-section/page
---
```

---

## Troubleshooting

### Common Issues

**Frontmatter not rendering:**
- Ensure frontmatter is between `---` markers at the top of the file
- Check YAML syntax (indentation must be consistent, use spaces not tabs)
- Validate YAML with an online validator

**Page not appearing in navigation:**
- Check that page is listed in `_data/nav.yml`
- Verify `section` and `group` match navigation structure
- Rebuild Jekyll to regenerate navigation

**Assets not loading:**
- Verify you're using `{{ site.baseurl }}/path` syntax
- Check that assets exist in the correct directory
- Test with both development and production baseurls

**Table of contents not showing:**
- Ensure `toc: true` is set in frontmatter
- Check that page has heading elements (`##`, `###`, etc.)
- Verify layout supports TOC (docs, experiences, techniques)

**Templates/downloads not appearing:**
- Check that page slug matches key in `_data/templates-downloads/[section].yml`
- Verify data file syntax
- Rebuild Jekyll after data file changes

**Experience/technique content not showing:**
- Ensure `experience` or `technique` field matches key in data file
- Check `_data/community-building-experiences.yml` or `_data/community-building-techniques.yml`
- Verify data file structure

### Debugging Tips

1. **Check Jekyll build output:**
   ```bash
   bundle exec jekyll build --config "_config.yml,_config_dev.yml" --verbose
   ```

2. **Validate frontmatter:**
   ```bash
   ruby -ryaml -e "puts YAML.load_file('path/to/file.md')"
   ```

3. **View generated HTML:**
   ```bash
   open _site/section/group/page-name/index.html
   ```

4. **Check navigation data:**
   ```bash
   ruby -ryaml -e "puts YAML.load_file('_data/nav.yml')"
   ```

---

## Additional Resources

- **Jekyll Documentation:** https://jekyllrb.com/docs/
- **Liquid Template Language:** https://shopify.github.io/liquid/
- **kramdown Syntax:** https://kramdown.gettalong.org/syntax.html
- **Bootstrap 4 Documentation:** https://getbootstrap.com/docs/4.1/
- **YAML Syntax:** https://yaml.org/spec/1.2/spec.html

---

## Summary

The Field Guide's content system provides:

- **Separation of concerns:** Content in frontmatter/markdown, presentation in Liquid templates
- **Data-driven navigation:** Centralized control via `_data/nav.yml`
- **Flexible layouts:** Specialized templates for different content types
- **Auto-populated components:** Downloads, links, and resources based on page context
- **Consistent styling:** All pages share common structure and theme

By understanding frontmatter fields and layout options, you can create rich, well-structured documentation pages without writing HTML.
