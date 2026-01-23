# Complete Export Documentation

This document describes the Ruby script that exports the entire Field Guide to a single hierarchical Markdown file optimized for LLM ingestion.

## Overview

The export process uses a Ruby script (`export_fieldguide.rb`) instead of Jekyll's Liquid templating to generate a clean, hierarchical Markdown export. This approach provides:

- **Proper regex support** with `^` anchor for start-of-line matching
- **Accurate heading level shifts** without double-replacement issues
- **Fast execution** (no full Jekyll build required)
- **Clean Liquid tag removal** with precise control over formatting

## File Location

**Script:** `export_fieldguide.rb` (in repository root)

**Output:** `exports/FIELDGUIDE_all.md`

## Running the Export

### VS Code

1. Press `Cmd+Shift+P` / `Ctrl+Shift+P`
2. Select "Tasks: Run Task"
3. Choose "Export Field Guide to Markdown (Ruby Script)"

### Command Line

```bash
ruby export_fieldguide.rb
```

## Export Structure

The script generates a hierarchical Markdown document following the navigation structure defined in `_data/nav.yml`:

```markdown
# Section (e.g., Catalytic Funding)

## Group (e.g., Making Decisions)

### Page (e.g., Application Intake)

#### Content Section (from page's ## heading)

##### Content Subsection (from page's ### heading)
```

### Hierarchy Levels

- **Sections** - Top-level navigation items (`# Introduction`, `# Catalytic Funding`, etc.)
- **Groups** - Nested navigation groupings (`## Planning & Preparing`, `## Making Decisions`, etc.)
- **Pages** - Individual content pages
  - `###` if within a group (e.g., `### Program Design`)
  - `##` if directly under section (e.g., `## Foreword`)
- **Content headings** - Shifted automatically:
  - For grouped pages: Increment by 2 levels (`##` → `####`)
  - For ungrouped pages: Increment by 1 level (`##` → `###`)

## How It Works

### 1. Load Navigation Structure

Reads `_data/nav.yml` to determine the order and hierarchy of content:

```ruby
nav = YAML.load_file('_data/nav.yml')
```

### 2. Find Markdown Files

For each page title in the navigation, the script searches for matching files using context-aware lookup:

- Converts title to slug (e.g., "Application Design" → `application-design`)
- Uses section and group context from navigation hierarchy for priority matching
- Search order:
  1. **Context-aware search** (if section/group provided):
     - `section-slug/group-slug/page-slug.md`
     - `section-slug/group-slug/page-slug/index.md`
     - `section-slug/**/page-slug.md`
  2. **Global search** in `CONTENT_DIRS` (fallback):
     - `dir/slug.md`
     - `dir/slug/index.md`
     - `dir/**/slug.md`
     - `dir/**/slug/index.md`

This context-aware approach prevents filename collisions (e.g., `catalytic-funding/planning-preparing/fundraising.md` vs `community-building/experiences/fundraising.md`)

### 3. Parse Frontmatter and Read Page Content

Parses YAML frontmatter to extract metadata (layout type, subtitle, etc.):

```ruby
frontmatter = parse_frontmatter(file)
# Returns hash with frontmatter fields: layout, subtitle, experience, etc.
```

Reads the markdown file and strips YAML frontmatter:

```ruby
content = File.read(file)
if content.start_with?('---')
  parts = content.split(/^---\s*$/, 3)
  content = parts[2] || ""
end
```

If a subtitle is present in frontmatter, it's rendered in bold immediately after the page heading:

```markdown
### Page Title

**This is the subtitle from frontmatter**

Page content begins here...
```

### 4. Clean Up Liquid Tags

Removes or transforms Liquid template tags for clean markdown output:

#### Thinking Questions

**Input:**
```liquid
{% capture thinking-questions %}
##### Thinking Questions

* Question 1
* Question 2
{% endcapture %}
{% include docs/thinking-questions.html content=thinking-questions %}
```

**Output:**
```markdown
##### Thinking Questions

* Question 1
* Question 2
```

#### Examples

**Input:**
```liquid
{% capture example %}
Content here...
{% endcapture %}
{% include docs/example.html content=example title="Example Title" %}
```

**Output:**
```markdown
> **_Example Title_**
>
> Content here...
```

#### Checklists

**Input:**
```liquid
{% include docs/checklist.html id="catalytic-funding_application-components" %}
```

**Output:**
```markdown
* [x] **Applicant Contact Information**: Name, daytime phone, email address, social media for person completing the application who should receive follow-up
* [x] **Organizational Information**: Affiliation of the applicant or the applying organization (if applicable)
* [x] **Budget**: Form or upload
```

The script:
1. Parses the `id` parameter from the include tag
2. Loads the corresponding YAML file from `_data/checklists/{id}.yml`
3. Renders each item as a markdown checkbox list item (`* [x]`) with bold item name
4. Includes optional description after colon if present in YAML

#### Images

**Input:**
```liquid
<div class="row justify-content-between align-items-center">
  <div class="col-12 col-xl-6 order-xl-last col-xxl-4">
    {% include image.html src="/downloads/community-building/what-is-community-building.gif" alt="What is community building?" class="img-fluid mt-3 mt-xl-0 mb-3 mb-xl-0" %}
  </div>
  <div class="col-12 col-xl-6 order-xl-first col-xxl-8">
    <p>We think about our work as a campaign...</p>
  </div>
</div>
```

**Output:**
```markdown
![What is community building?](/downloads/community-building/what-is-community-building.gif)

We think about our work as a campaign...
```

The script:
1. Converts `{% include image.html src="..." alt="..." %}` to markdown image syntax `![alt](src)`
2. Strips Bootstrap grid wrapper divs
3. Preserves paragraph content alongside the image

#### Relative Link Conversion

**Input:**
```markdown
* [Application Design](../../cultivating-applicants/application-design/)
* [Fundraising](../fundraising/)
* [External Link](https://example.com)
```

**Output:**
```markdown
* [Application Design](https://fieldguide.sproutfund.org/catalytic-funding/cultivating-applicants/application-design/)
* [Fundraising](https://fieldguide.sproutfund.org/catalytic-funding/planning-preparing/fundraising/)
* [External Link](https://example.com)
```

The script converts all relative internal links to absolute URLs:
1. Detects markdown links `[text](path)`
2. Skips external links (starting with `http://` or `https://`)
3. Handles special anchor-only links using current page context:
   - `#template-download--...` → `https://fieldguide.sproutfund.org/resources/templates-downloads/#[page-slug]`
   - `#external-link--...` → `https://fieldguide.sproutfund.org/resources/related-external-links/#[page-slug]`
   - Where `[page-slug]` is the slug of the page being processed (e.g., "applicant-outreach-info-sessions")
   - Other `#anchors` → kept as-is for in-page navigation
4. Removes relative navigation (`../`) from paths
5. Infers section based on:
   - Known directory structure (if path starts with a section name)
   - Known group names in the path (catalytic-funding or community-building groups)
   - Direct page slug mapping for common pages
6. Constructs absolute URL with `https://fieldguide.sproutfund.org`

This ensures all links in the exported document point to the live Field Guide site, with anchor links directing to the appropriate section of the resources pages.

#### Other Cleanup

- Removes `{{ site.baseurl }}` references
- Removes `{:target="_blank"}` Kramdown syntax
- Replaces emoji shortcuts (`:heart:` → ❤️, `:bulb:` → 💡, `:warning:` → ⚠️)

### 5. Increment Heading Levels

Uses regex with start-of-line anchor to shift heading levels:

```ruby
def increment_headings(content, levels)
  content = content.gsub(/^###### /, '#' * (6 + levels) + ' ')
  content = content.gsub(/^##### /, '#' * (5 + levels) + ' ')
  content = content.gsub(/^#### /, '#' * (4 + levels) + ' ')
  content = content.gsub(/^### /, '#' * (3 + levels) + ' ')
  content = content.gsub(/^## /, '#' * (2 + levels) + ' ')
  content
end
```

**Key feature:** The `^` regex anchor ensures only headings at the start of lines are matched, preventing double-replacement issues that occur with simple string replacement.

### 6. Concatenate Output

Builds the final markdown file by concatenating:
- Header with metadata (title, generation timestamp)
- Sections, groups, and pages in navigation order
- Content with adjusted heading levels
- Blank lines for proper markdown spacing

### 7. Final Cleanup

Before writing the output file:
- Joins all output array elements with newlines
- Collapses multiple consecutive blank lines (3+) to single blank lines
- Ensures clean, consistent spacing throughout the entire document

## Configuration

### Content Directories

The script searches these directories for markdown files:

```ruby
CONTENT_DIRS = [
  'catalytic-funding',
  'community-building',
  'introduction',
  'lessons-learned',
  'resources',
  'about'
]
```

Add additional directories here if new top-level sections are added to the site.

### Output File

```ruby
OUTPUT_FILE = 'exports/FIELDGUIDE_all.md'
```

The `exports/` directory is created automatically if it doesn't exist. This directory is in `.gitignore` to avoid committing generated files.

## Advantages Over Jekyll Template Approach

### 1. Proper Regex Support

Jekyll's Liquid `replace` filter doesn't support regex anchors, leading to issues like:

```liquid
{%- assign content = content | replace: "## ", "#### " -%}
```

This replaces ALL occurrences of `## `, including:
- Actual headings: `## Overview` → `#### Overview` ✓
- Within URLs: `example.com/page## text` → `example.com/page#### text` ✗
- Mid-sentence: `text ## more` → `text #### more` ✗

Ruby's regex with `^` anchor solves this:

```ruby
content.gsub(/^## /, '#### ')  # Only matches at start of line
```

### 2. No Double-Replacement

Liquid's sequential replacements can double-process:

```liquid
{%- assign content = content | replace: "###### ", "######## " -%}
{%- assign content = content | replace: "## ", "#### " -%}
```

If `######## ` contains `## `, it gets replaced again! Ruby processes each line once.

### 3. Speed

- **Jekyll build**: ~5-10 seconds (full site generation)
- **Ruby script**: <1 second (direct file processing)

### 4. Debugging

Ruby script provides console output showing progress:

```
Processing section: Catalytic Funding
  Processing group: Making Decisions
    Processing page: Application Intake
    Processing page: Committee Review
```

Warnings for missing files:

```
WARNING: Could not find file for 'Page Title'
```

### Special Content Rendering

The script automatically detects special page types and renders their associated data inline.

#### Section-Level Content

For sections without sub-pages (like "Lessons Learned"), the script looks for an `index.md` file in the section directory and renders its content with subtitle support.

**Example:** `lessons-learned/index.md` → Renders full content under `# Lessons Learned`

### Experience/Technique Data Rendering

The script automatically detects experience and technique pages and renders their YAML data inline.

#### Experience Pages

**Detection:**
- Frontmatter has `layout: experiences`
- Frontmatter includes `experience: "Experience Name"`

**Rendering:**
```markdown
### Planning

**Target Size**: 5–10 people | **Attributes**: Small, Intentional, Focused | **Shorthand**: "I want to plan something."

#### Protips

* _As the saying goes..._ **Proper planning prevents poor performance.**
* **Don't start with a blank sheet of paper.**...

#### Process Checklist

* [x] Gather a planning team
* [x] Arrange a meeting (in-person, if possible)
...

**Related Experiences**: Fundraising, Kick-Off, Feedback...

**Related Techniques**: Affinity Clustering, Bullseye...

#### Example & Artifacts

Sprout designed and led a series of planning meetings...
```

The script:
1. Parses frontmatter and detects `layout: experiences`
2. Extracts the experience name from `experience:` field
3. Loads matching experience from `_data/community-building-experiences.yml`
4. Renders all fields: target size, attributes, shorthand, protips, process checklist, companions, related techniques, and examples

#### Technique Pages

**Detection:**
- Frontmatter has `layout: techniques`
- Page title used to determine technique category (generate/prioritize/reflect)

**Rendering:**
```markdown
### Generate

#### Co-Creation Session

*Lead a hands-on working session and build something new together.*

A broad way to describe a hands-on, in-person session...

**Related Experiences**: Planning, Recruitment, Ideation...

#### Concept Posters

*Sketch out the details of a new idea.*

A great solo or group activity...

**Related Techniques**: Statement Starters, Concept Posters...

**Related Experiences**: Planning, Ideation...
```

The script:
1. Parses frontmatter and detects `layout: techniques`
2. Extracts category from page title (e.g., "Generate" from "Techniques to Generate")
3. Loads all techniques with that `purpose` from `_data/community-building-techniques.yml`
4. Renders each technique with: name, tagline, description, related techniques, related experiences

#### Resources Pages

**Templates & Downloads:**
- Detects `layout: templates-downloads`
- Loads all YAML files from `_data/templates-downloads/` (catalytic-funding.yml, community-building.yml)
- Renders hierarchically organized by section → page → items
- Format: `* **[Title](url)** [icon]` with optional descriptions

**Related External Links:**
- Detects page title "Related External Links"
- Loads all YAML files from `_data/related-external-links/`
- Renders hierarchically organized by section → page → items
- Format: `* **[Title](url)**` with optional "via" attribution and descriptions

Both resources pages provide complete aggregated lists of all templates and external links referenced throughout the Field Guide.

## Future Enhancements

### Filtered Exports

Add support for section-specific exports:

```bash
ruby export_fieldguide.rb --section catalytic-funding
# Output: exports/FIELDGUIDE_catalytic-funding.md

ruby export_fieldguide.rb --section community-building
# Output: exports/FIELDGUIDE_community-building.md
```

### Custom Formatting

Add command-line options for output customization:

```bash
ruby export_fieldguide.rb --format=obsidian   # Obsidian-style links
ruby export_fieldguide.rb --format=notion     # Notion-specific formatting
ruby export_fieldguide.rb --format=llm        # Current default
```

## Troubleshooting

### Page Not Found

**Issue:** `WARNING: Could not find file for 'Page Title'`

**Solutions:**
1. Check that the file exists in one of `CONTENT_DIRS`
2. Verify filename matches slug convention: lowercase, hyphens, `.md` extension
3. Check for `index.md` if page is in a subdirectory
4. Add the parent directory to `CONTENT_DIRS` if needed

### Incorrect Heading Levels

**Issue:** Content headings not at expected level

**Debug:**
1. Check source markdown file - what heading levels are used?
2. Verify page placement in nav.yml (grouped vs ungrouped)
3. Confirm heading increment logic matches page hierarchy

### Liquid Tags Not Removed

**Issue:** Liquid syntax appearing in export output

**Solutions:**
1. Check if tag pattern is covered in `cleanup_liquid_tags` function
2. Add new regex pattern for uncovered tag types
3. Run with verbose output to see which files contain unhandled tags

### Empty Content

**Issue:** Page title appears but no content

**Debug:**
1. Check if frontmatter parsing is working (script skips content before 2nd `---`)
2. Verify file encoding (should be UTF-8)
3. Check if page uses special layout that needs data file integration

## Related Documentation

- **[CONTENT_GUIDE.md](CONTENT_GUIDE.md)**: Guide to frontmatter and layouts
- **[DATA.md](DATA.md)**: Data file structures and usage
- **[CLAUDE.md](../CLAUDE.md)**: AI assistant guide for this repository
- **[README.md](../README.md)**: Project overview and development setup

## Script Maintenance

When making changes to the export script:

1. **Test thoroughly** - Run export and verify output in `exports/FIELDGUIDE_all.md`
2. **Check all page types** - Ensure docs, experiences, techniques, voices all export correctly
3. **Validate hierarchy** - Confirm heading levels create proper document structure
4. **Update this documentation** - Document any new features or changes
5. **Consider edge cases** - Test with special characters, long content, nested structures

## Version History

- **v1.0** (2025-01-13): Initial Ruby script implementation with hierarchy support
  - Basic navigation traversal
  - Heading level incrementation
  - Frontmatter stripping

- **v1.1** (2025-01-13): Enhanced file finding
  - Added `index.md` support
  - Added `about/` directory
  - Improved search patterns

- **v1.2** (2025-01-13): Liquid tag cleanup
  - Thinking questions extraction
  - Example blocks to blockquotes
  - Baseurl removal

- **v1.3** (2025-01-13): Checklist support
  - YAML checklist loading from `_data/checklists/`
  - Inline rendering as markdown checkboxes (`* [x]`) with item names and descriptions
  - Support for both description and non-description formats

- **v1.4** (2025-01-13): Image conversion
  - Liquid image includes converted to markdown syntax
  - Bootstrap grid wrapper cleanup
  - Clean image/text layout in export

- **v1.5** (2025-01-13): Experience and technique data rendering
  - Frontmatter parsing to detect special layouts
  - Experience page data loaded from `_data/community-building-experiences.yml`
  - Technique category data loaded from `_data/community-building-techniques.yml`
  - Full rendering of protips, process checklists, related items, and examples
  - Automatic cross-referencing between experiences and techniques
  - Subtitle rendering from frontmatter for all pages

- **v1.6** (2025-01-13): Relative link conversion to absolute URLs
  - All internal relative links converted to absolute URLs pointing to live site
  - Section inference based on group names and directory structure
  - Direct page slug mapping for common pages
  - External links preserved unchanged
  - Anchor links (#) preserved unchanged

- **v1.7** (2025-01-13): Context-aware file finding
  - File lookup now uses section/group context from navigation hierarchy
  - Prevents filename collisions (e.g., two `fundraising.md` files in different sections)
  - Priority search in context directory before falling back to global search
  - Fixes issue where duplicate filenames would render the same content

- **v1.8** (2025-01-13): Content cleanup and polish
  - Removes `{:target="_blank"}` Kramdown syntax from links
  - Replaces emoji shortcuts with actual emojis (`:heart:` → ❤️, `:bulb:` → 💡, `:warning:` → ⚠️)
  - Collapses multiple consecutive blank lines to single blank lines
  - Special anchor link handling for resources pages with page-slug context
  - Section-level content rendering for sections without sub-pages (e.g., Lessons Learned)
  - Resources pages YAML data rendering (Templates & Downloads, Related External Links)

- **v1.9** (2025-01-13): Context-aware anchor link conversion
  - Anchor links now use current page slug instead of original anchor
  - `#template-download--...` → `resources/templates-downloads/#[page-slug]`
  - `#external-link--...` → `resources/related-external-links/#[page-slug]`
  - Enables proper navigation to relevant section on resources aggregation pages
  - Moved blank line collapse to final cleanup step (before file write) for cleaner output
