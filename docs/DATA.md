# Data Files Guide for Field Guide

This guide documents the structure and usage of YAML data files in the `_data/` directory. These files provide structured data that drives navigation, downloads, checklists, and other dynamic content across the site.

## Table of Contents

- [Overview](#overview)
- [Navigation (nav.yml)](#navigation-navyml)
- [Voices (voices.yml)](#voices-voicesyml)
- [Templates & Downloads](#templates--downloads)
- [Related External Links](#related-external-links)
- [Checklists](#checklists)
- [Community Building Experiences](#community-building-experiences)
- [Community Building Techniques](#community-building-techniques)
- [Best Practices](#best-practices)

---

## Overview

The Field Guide uses YAML data files to separate content from presentation. Data files enable:

- **Centralized navigation** management
- **Auto-populated downloads** on relevant pages
- **Structured task lists** (checklists)
- **Experience/technique definitions** for community building guides
- **Dynamic content** rendering without hardcoding in templates

**Data Directory Structure:**
```
_data/
├── nav.yml                              # Site navigation hierarchy
├── voices.yml                           # Voices from the Field order
├── community-building-experiences.yml   # Experience definitions
├── community-building-techniques.yml    # Technique definitions
├── templates-downloads/
│   ├── catalytic-funding.yml            # Downloads for catalytic funding pages
│   └── community-building.yml           # Downloads for community building pages
├── related-external-links/
│   ├── catalytic-funding.yml            # External links for catalytic funding
│   └── community-building.yml           # External links for community building
└── checklists/
    ├── catalytic-funding_application-components.yml
    ├── catalytic-funding_info-session-tasks.yml
    └── ...
```

---

## Navigation (nav.yml)

**File:** `_data/nav.yml`

**Purpose:** Defines the entire site navigation hierarchy used in the sidebar and menus

**Structure:**
```yaml
- title: Section Title           # Top-level section
  pages:                          # Pages within section (optional)
    - title: Page Title           # Direct page in section
    - title: Group Title          # Sub-group
      pages:                      # Pages within group
        - title: Page Title
        - title: Another Page
```

**Example:**
```yaml
- title: Introduction
  pages:
    - title: Foreword
    - title: How to Use This Guide

- title: Catalytic Funding
  pages:
    - title: What Is Catalytic Funding?

    - title: Planning & Preparing
      pages:
        - title: Program Design
        - title: Fundraising

    - title: Cultivating Applicants
      pages:
        - title: Application Design
        - title: Program Launch & Announcement
        - title: Applicant Outreach & Info Sessions

- title: Community Building
  pages:
    - title: What Is Community Building?

    - title: Experiences
      pages:
        - title: Planning
        - title: Ideation
        - title: Showcase
```

**Key Points:**
- **Hierarchy:** Top-level sections → Groups (optional) → Pages
- **Order matters:** Items appear in sidebar in the order defined
- **Title matching:** Page titles must exactly match the `title` field in page frontmatter
- **Nesting:** Maximum of 3 levels (section → group → page)

**How it's used:**
- Rendered by `_includes/sidebar.html`
- Determines active/highlighted navigation items
- Generates breadcrumb trails
- Defines site structure

**Modifying navigation:**
1. Edit `_data/nav.yml`
2. Add/remove/reorder pages
3. Ensure titles match page frontmatter
4. Rebuild Jekyll to see changes

---

## Voices (voices.yml)

**File:** `_data/voices.yml`

**Purpose:** Defines the display order of Voices from the Field profiles

**Structure:**
```yaml
- title: Person Name
- title: Another Person
- title: Third Person
```

**Example:**
```yaml
- title: Sarah Allen
- title: Sunanna Chand
- title: Kenny Chen
- title: Sam Dyson
- title: Nathan Darity
- title: Josiah Gilliam
- title: Cricket Fuller
- title: Christine Marty
- title: Adam Kenney
- title: Dror Yaron
```

**Key Points:**
- Simple list of names in desired display order
- Must match the `title` field in corresponding page frontmatter
- Used on the Voices from the Field index page
- Order determines sidebar display sequence

**How it's used:**
- Referenced by `_includes/docs/voices-from-the-field-more-info.html`
- Controls order of profiles on index page
- Ensures consistent ordering across the site

---

## Templates & Downloads

**Files:**
- `_data/templates-downloads/catalytic-funding.yml`
- `_data/templates-downloads/community-building.yml`

**Purpose:** Define downloadable resources for each page (auto-populated on pages)

**Structure:**
```yaml
page-slug:
  - title: "Resource Title"      # Required: Display name
    url: "https://url.com"       # Required: Download/external URL
    icon: icon-name              # Optional: Font Awesome icon (without 'fa-' prefix)
    description: "Description"   # Optional: Additional context

page-slug: false                 # Explicitly mark page as having no downloads
```

**Example:**
```yaml
program-design:
  - title: Program Budget Calculator
    url: "https://docs.google.com/spreadsheets/d/1uXr916Y8b3QHTlnnJV3SkPr42AFlxGw6MJ776rUp5Uc/view"
    icon: google-drive

  - title: Program Timeline Checklist
    url: "https://docs.google.com/document/d/1S1r7lHC4f8w3mdonfwh6xjVmTWrbbKisKIDO4TdPMFc/view"
    icon: google-drive

fundraising: false               # No downloads for this page

application-design:
  - title: Application Template
    url: "https://docs.google.com/document/d/1VH5Fwt3ggmaEVIg8QGFGE65TrjLseGYnapv01bRdAoA/view"
    icon: google-drive

  - title: Funding Opportunity Example
    url: "https://drive.google.com/file/d/0BzCiN-PkZ98fSm9udm9sRTVXRzg/view"
    icon: file-pdf
    description: "Sample funding opportunity announcement"
```

**Supported Icons:**
- `google-drive` - Google Docs/Sheets/Slides
- `file-pdf` - PDF documents
- `envelope` - Email/newsletter links
- `link` - Generic external links
- Any Font Awesome icon name (without `fa-` prefix)

**Key Points:**
- **Page slug as key:** Must match the page's URL slug (derived from filename)
- **Quote URLs:** Always quote URLs to avoid YAML parsing issues
- **No colons in unquoted text:** Colons break YAML - quote any text containing colons
- **False for empty:** Use `page-slug: false` instead of empty arrays

**How it's used:**
- Auto-populated by `{% include docs/templates-downloads.html %}`
- Looks up current page slug in appropriate section file
- Renders download list with icons and descriptions
- Only shows if downloads exist for the page

**Adding new downloads:**
1. Identify the page's slug (e.g., `program-design`)
2. Edit appropriate section file (`catalytic-funding.yml` or `community-building.yml`)
3. Add entry under the page slug key
4. Include title, URL, and optional icon/description
5. Rebuild Jekyll - downloads auto-appear on the page

---

## Related External Links

**Files:**
- `_data/related-external-links/catalytic-funding.yml`
- `_data/related-external-links/community-building.yml`

**Purpose:** Define external resource links for each page

**Structure:** Same as templates-downloads

```yaml
page-slug:
  - title: "Resource Title"
    url: "https://external-site.com"
    icon: link
    description: "Why this resource is relevant"

page-slug: false
```

**Example:**
```yaml
program-design:
  - title: "Stanford Social Innovation Review: Strategic Planning"
    url: "https://ssir.org/articles/entry/strategic_planning"
    icon: link
    description: "In-depth article on strategic planning for nonprofits"

application-design:
  - title: "Grantmakers for Effective Organizations"
    url: "https://www.geofunders.org/resources"
    icon: link
```

**How it's used:**
- Auto-populated by `{% include docs/related-external-links.html %}`
- Similar to templates-downloads but for external resources
- Helps readers find related reading and tools

---

## Checklists

**Files:** `_data/checklists/*.yml`

**Purpose:** Define structured task lists for embedding in pages

**Naming convention:** `section_checklist-name.yml`

**Structure:**
```yaml
- item: "Task Name"
  description: "Detailed description of the task"

- item: "Another Task"
  description: "More details"
```

**Example:**

**File:** `_data/checklists/catalytic-funding_application-components.yml`

```yaml
- item: Applicant Contact Information
  description: Name, daytime phone, email address, social media for person completing the application who should receive follow-up

- item: Organizational Information
  description: Affilation of the applicant or the applying organization (if applicable)

- item: Narrative Questions that align with Decisionmaking Criteria
  description: Questions you want your applicants to answer

- item: Budget
  description: Form or upload

- item: Timeline
  description: Form or upload

- item: References and/or Letters of Support
  description: Form or upload

- item: Terms and Conditions
  description: Fine print and/or verification person has authorization to submit on behalf of org
```

**How it's used:**

In content pages:
```liquid
{% include docs/checklist.html data=site.data.checklists.catalytic-funding_application-components %}
```

**Key Points:**
- Each item has a name and description
- Rendered as styled checklist by `_includes/docs/checklist.html`
- File naming: use underscores (`_`), not hyphens, before checklist name
- Reference with dot notation: `site.data.checklists.filename` (without `.yml`)

**Creating new checklists:**
1. Create file in `_data/checklists/`
2. Name it: `section_checklist-name.yml`
3. Add items with `item` and `description` fields
4. Include in page with: `{% include docs/checklist.html data=site.data.checklists.filename %}`

---

## Community Building Experiences

**File:** `_data/community-building-experiences.yml`

**Purpose:** Define all content for community building experience pages

**Structure:**
```yaml
- experience: Experience Name   # Must match frontmatter `experience` field
  goal: "I want to..."          # User goal statement
  icon: 💡                       # Emoji icon
  adjectives: "Adj1, Adj2, Adj3"# Descriptive adjectives
  tagline: "Short description"  # One-line summary
  size: "50-100 people"         # Typical event size
  process: "Step 1 > Step 2 > Step 3"  # Process description
  protips:                      # Array of pro tips
    - "**Tip 1** explanation"
    - "**Tip 2** explanation"
  example: "Real-world example" # Case study or example
  companions:                   # Related experiences (array)
    - Planning
    - Fundraising
    - Ideation
```

**Example:**
```yaml
- experience: Ideation
  goal: "I want to come up with new ideas."
  icon: 💡
  adjectives: "Creative, Participatory, Generative"
  tagline: "Develop ideas for new projects and programs"
  size: "Up to 75 people"
  process: "Develop an idea > Invite interested parties > Create an agenda > Facilitate ideation session > Document ideas > Follow-up > Launch new ideas"
  protips:
    - "**Start with the problem, not the solution.** The best ideas come from deeply understanding the challenge you're trying to solve."
    - "**Create psychological safety.** Make it clear that all ideas are welcome, even wild ones."
    - "**Build on each other.** Encourage participants to riff on each other's ideas rather than critiquing them."
  example: "Sprout hosted quarterly Think & Drink sessions where community members gathered to brainstorm solutions to local challenges."
  companions:
    - Planning
    - Recruitment
    - Showcase
    - Knowledge-Sharing
```

**Key Points:**
- Experience name must match page frontmatter `experience:` field
- All content is defined here, not in the markdown file
- Protips support Markdown formatting (`**bold**`, `_italic_`)
- Companions list related experiences (must be valid experience names)

**How it's used:**
- Referenced by pages with `layout: experiences`
- Template looks up experience by name
- All content rendered from this data file
- Markdown files only contain frontmatter

**Adding new experiences:**
1. Add entry to this file with all fields
2. Create markdown file in `community-building/experiences/`
3. Set `experience:` frontmatter to match name here
4. Content auto-populates from data file

---

## Community Building Techniques

**File:** `_data/community-building-techniques.yml`

**Purpose:** Define all content for community building technique pages

**Structure:**
Similar to experiences, but for facilitation techniques:

```yaml
- technique: Technique Name     # Must match frontmatter `technique` field
  goal: "I want to..."          # User goal
  icon: 🎯                       # Emoji icon
  tagline: "Description"        # Summary
  description: "Full description of the technique"
  process: "Step-by-step process"
  protips:
    - "Tip 1"
    - "Tip 2"
  example: "Real-world application"
  companions:
    - Generate
    - Prioritize
```

**Example:**
```yaml
- technique: Generate
  goal: "I want to generate lots of ideas."
  icon: 🌟
  tagline: "Brainstorm and ideate freely"
  description: "Generation techniques help groups produce many ideas quickly without judgment or critique."
  process: "Set clear parameters > Create safe space > Encourage wild ideas > Build on others > Defer judgment > Go for quantity"
  protips:
    - "**Quantity over quality.** At this stage, more is better."
    - "**Yes, and...** Build on ideas rather than shooting them down."
  example: "Used brainstorming to generate 100+ ideas for community events in 30 minutes."
  companions:
    - Prioritize
    - Reflect
```

**How it's used:**
- Same pattern as experiences
- Referenced by pages with `layout: techniques`
- Content pulled from this file

---

## Best Practices

### General YAML Guidelines

1. **Quote strings with colons:**
   ```yaml
   title: "Program Design: A Guide"  # Good
   title: Program Design: A Guide    # Bad - breaks YAML
   ```

2. **Use consistent indentation:**
   ```yaml
   item: Name
     description: Description        # Bad - inconsistent

   item: Name
   description: Description          # Good
   ```

3. **Quote URLs:**
   ```yaml
   url: "https://example.com"        # Good
   url: https://example.com          # Works but risky
   ```

4. **Comments:**
   ```yaml
   # This is a comment
   - title: Page Name                # Inline comment
   ```

### Data File Workflow

1. **Edit data file** in `_data/`
2. **Validate YAML** syntax (use online validator if unsure)
3. **Rebuild Jekyll:**
   ```bash
   bundle exec jekyll build --config "_config.yml,_config_dev.yml"
   ```
4. **Verify changes** in development site
5. **Commit changes** to version control

### Common Issues

**YAML parsing errors:**
- Check for unquoted colons
- Verify indentation (use spaces, not tabs)
- Ensure list items start with `-`
- Validate with YAML linter

**Data not appearing:**
- Verify page slug matches data key exactly
- Check that frontmatter `experience`/`technique` matches data
- Rebuild Jekyll after data changes
- Clear browser cache

**Navigation not updating:**
- Ensure titles exactly match page frontmatter
- Check nesting levels (max 3)
- Verify YAML structure
- Rebuild Jekyll

---

## Testing Data Changes

### Validate YAML Syntax

```bash
ruby -ryaml -e "puts YAML.load_file('_data/nav.yml')"
```

### Check Data Loading

In development, add to a page temporarily:
```liquid
{{ site.data.nav | inspect }}
{{ site.data.templates-downloads.catalytic-funding | inspect }}
```

### Verify Include Output

```liquid
{% include docs/templates-downloads.html %}
<!-- Check browser inspector for generated HTML -->
```

---

## Additional Resources

- **YAML Specification:** https://yaml.org/spec/1.2/spec.html
- **YAML Validator:** http://www.yamllint.com/
- **Font Awesome Icons:** https://fontawesome.com/icons
- **Jekyll Data Files:** https://jekyllrb.com/docs/datafiles/

---

## Summary

Data files in `_data/` provide:

- **Centralized content management** for navigation, downloads, and structured data
- **Separation of content and presentation** for easier maintenance
- **Dynamic page components** that auto-populate based on page context
- **Reusable content** across multiple pages
- **Structured data** for consistent formatting

By understanding data file structures, you can manage site-wide content without editing templates or individual pages.
