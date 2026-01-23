---
layout: null
---
{%- comment -%}
This layout exports field guide content with hierarchical headings:
- # Section (e.g., Catalytic Funding)
- ## Group (e.g., Making Decisions)
- ### Page (e.g., Application Intake)
- #### Content headings (from page's ##)
- ##### Content subheadings (from page's ###)

Parameters (set in page frontmatter):
- filter_section: String to filter by section (e.g., "catalytic-funding", "community-building"), or null for all
{%- endcomment -%}

{%- comment -%}{{ content }}{%- endcomment -%}

{%- comment -%} Load navigation structure {%- endcomment -%}
{%- assign nav_sections = site.data.nav -%}

{%- comment -%} Filter sections if requested {%- endcomment -%}
{%- if page.filter_section -%}
  {%- assign filtered_sections = "" | split: "" -%}
  {%- for section in nav_sections -%}
    {%- assign section_slug = section.title | slugify -%}
    {%- if section_slug == page.filter_section -%}
      {%- assign filtered_sections = filtered_sections | push: section -%}
    {%- endif -%}
  {%- endfor -%}
  {%- assign nav_sections = filtered_sections -%}
{%- endif -%}

{%- comment -%} Iterate through navigation hierarchy {%- endcomment -%}
{%- for section in nav_sections -%}
{{ "" }}
{{ "" }}
# {{ section.title | smartify }}
{{ "" }}
{{ "" }}
  {%- if section.pages -%}
    {%- for page_or_group in section.pages -%}
{{ "" }}
      {%- comment -%} Check if this is a group (has nested pages) or a page {%- endcomment -%}
      {%- if page_or_group.pages -%}
{{ "" }}
## {{ page_or_group.title | smartify }}
{{ "" }}
{{ "" }}
        {%- for subpage in page_or_group.pages -%}
          {%- comment -%} Find the actual Jekyll page matching this title {%- endcomment -%}
          {%- assign matching_page = null -%}
          {%- for jekyll_page in site.pages -%}
            {%- if jekyll_page.title == subpage.title and jekyll_page.layout != null -%}
              {%- assign matching_page = jekyll_page -%}
              {%- break -%}
            {%- endif -%}
          {%- endfor -%}
{{ "" }}
          {%- if matching_page -%}
{{ "" }}
### {{ matching_page.title | smartify }}
{{ "" }}
{{ "" }}
            {%- comment -%} Increment content headings by 2 levels (## becomes ####, ### becomes #####, etc.) {%- endcomment -%}
            {%- assign adjusted_content = matching_page.content | replace: "###### ", "######## " | replace: "##### ", "####### " | replace: "#### ", "###### " | replace: "### ", "##### " | replace: "## ", "#### " -%}
{{ adjusted_content | strip }}
{{ "" }}
{{ "" }}
          {%- endif -%}
        {%- endfor -%}
{{ "" }}
      {%- else -%}
        {%- comment -%} This is a direct page under the section (no group) (e.g., Foreward under Introduction) {%- endcomment -%}
        {%- assign matching_page = null -%}
        {%- for jekyll_page in site.pages -%}
          {%- if jekyll_page.title == page_or_group.title and jekyll_page.layout != null -%}
            {%- assign matching_page = jekyll_page -%}
            {%- break -%}
          {%- endif -%}
        {%- endfor -%}
        {{ "" }}
        {%- if matching_page -%}
{{ "" }}
## {{ matching_page.title | smartify }}
{{ "" }}
{{ "" }}
          {%- comment -%} Increment content headings by 1 level (## becomes ###, ### becomes ####, etc.) {%- endcomment -%}
          {%- assign adjusted_content = matching_page.content | replace: "###### ", "####### " | replace: "##### ", "###### " | replace: "#### ", "##### " | replace: "### ", "#### " | replace: "## ", "### " -%}
{{ adjusted_content | strip }}
{{ "" }}
{{ "" }}
        {%- endif -%}
      {%- endif -%}
{{ "" }}
      {%- endfor -%}
    {%- endif -%}
{{ "" }}
{%- endfor -%}
