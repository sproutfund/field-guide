#!/usr/bin/env ruby
# Export Field Guide to hierarchical Markdown
# Usage: ruby export_fieldguide.rb

require 'yaml'

# Configuration
NAV_FILE = '_data/nav.yml'
OUTPUT_FILE = 'exports/FIELDGUIDE_all.md'
CONTENT_DIRS = ['catalytic-funding', 'community-building', 'introduction', 'lessons-learned', 'resources', 'about']
BASE_URL = 'https://fieldguide.sproutfund.org'

# Known groups for path inference
CATALYTIC_FUNDING_GROUPS = ['planning-preparing', 'cultivating-applicants', 'making-decisions', 'managing-funded-projects', 'sustaining-sunsetting']
COMMUNITY_BUILDING_GROUPS = ['experiences', 'techniques', 'voices-from-the-field', 'campaigns']

# Known page patterns for path inference
CATALYTIC_FUNDING_PAGES = {
  'fundraising' => 'catalytic-funding/planning-preparing/fundraising/',
  'program-design' => 'catalytic-funding/planning-preparing/program-design/',
  'application-design' => 'catalytic-funding/cultivating-applicants/application-design/'
}

# Helper: Convert relative markdown links to absolute URLs
def convert_relative_links_to_absolute(content, current_page_slug = nil)
  content.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do
    link_text = $1
    link_path = $2

    # Skip external links (http/https)
    if link_path.start_with?('http://') || link_path.start_with?('https://')
      "[#{link_text}](#{link_path})"
    # Handle anchor-only links (#something)
    elsif link_path.start_with?('#')
      # Special case: template-download and external-link anchors point to resources pages with page slug
      if link_path.start_with?('#template-download--') || link_path.start_with?('#download--')
        if current_page_slug
          "[#{link_text}](#{BASE_URL}/resources/templates-downloads/##{current_page_slug})"
        else
          "[#{link_text}](#{BASE_URL}/resources/templates-downloads/#{link_path})"
        end
      elsif link_path.start_with?('#external-link--')
        if current_page_slug
          "[#{link_text}](#{BASE_URL}/resources/related-external-links/##{current_page_slug})"
        else
          "[#{link_text}](#{BASE_URL}/resources/related-external-links/#{link_path})"
        end
      else
        # Regular anchor link - keep as-is or make absolute if we have context
        "[#{link_text}](#{link_path})"
      end
    else
      # Remove relative path navigation (../)
      clean_path = link_path.gsub(/^(\.\.\/)+/, '').gsub(/^\//, '')

      # Remove any anchor fragments for analysis
      path_without_anchor = clean_path.split('#').first || clean_path

      # Check if path already starts with a known section
      if CONTENT_DIRS.any? { |dir| path_without_anchor.start_with?(dir) }
        # Already has section, just prepend base URL
        "[#{link_text}](#{BASE_URL}/#{clean_path})"
      else
        # Check if this is a known page slug that we can map directly
        page_slug = path_without_anchor.gsub(/\/$/, '')
        if CATALYTIC_FUNDING_PAGES.key?(page_slug)
          full_path = CATALYTIC_FUNDING_PAGES[page_slug]
          # Preserve any anchor if present
          anchor = clean_path.include?('#') ? '#' + clean_path.split('#').last : ''
          "[#{link_text}](#{BASE_URL}/#{full_path}#{anchor})"
        else
          # Infer section based on group names in path
          section = nil

          CATALYTIC_FUNDING_GROUPS.each do |group|
            if path_without_anchor.include?(group)
              section = 'catalytic-funding'
              break
            end
          end

          unless section
            COMMUNITY_BUILDING_GROUPS.each do |group|
              if path_without_anchor.include?(group)
                section = 'community-building'
                break
              end
            end
          end

          if section
            "[#{link_text}](#{BASE_URL}/#{section}/#{clean_path})"
          else
            # Fallback: prepend base URL to cleaned path
            "[#{link_text}](#{BASE_URL}/#{clean_path})"
          end
        end
      end
    end
  end
end

# Helper: Increment all headings by N levels
def increment_headings(content, levels)
  return content if levels == 0

  # Work from highest to lowest to avoid double-processing
  content = content.gsub(/^###### /, '#' * (6 + levels) + ' ')
  content = content.gsub(/^##### /, '#' * (5 + levels) + ' ')
  content = content.gsub(/^#### /, '#' * (4 + levels) + ' ')
  content = content.gsub(/^### /, '#' * (3 + levels) + ' ')
  content = content.gsub(/^## /, '#' * (2 + levels) + ' ')

  content
end

# Helper: Find markdown file for a page title with optional section/group context
def find_page_file(title, section_title = nil, group_title = nil)
  # Convert title to likely filename
  slug = title.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')

  # If we have section and group context, search there first
  if section_title && group_title
    section_slug = section_title.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
    group_slug = group_title.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')

    # Try section/group/slug.md
    file = File.join(section_slug, group_slug, "#{slug}.md")
    return file if File.exist?(file)

    # Try section/group/slug/index.md
    index_file = File.join(section_slug, group_slug, slug, 'index.md')
    return index_file if File.exist?(index_file)
  end

  # If we have just section context, search there first
  if section_title
    section_slug = section_title.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')

    # Try section/slug.md
    file = File.join(section_slug, "#{slug}.md")
    return file if File.exist?(file)

    # Try section/slug/index.md
    index_file = File.join(section_slug, slug, 'index.md')
    return index_file if File.exist?(index_file)

    # Try in section subdirectories
    Dir.glob(File.join(section_slug, '**', "#{slug}.md")).each do |f|
      return f
    end

    # Try index.md in section nested subdirectories
    Dir.glob(File.join(section_slug, '**', slug, 'index.md')).each do |f|
      return f
    end
  end

  # Fall back to global search in content directories
  CONTENT_DIRS.each do |dir|
    # Try direct match
    file = File.join(dir, "#{slug}.md")
    return file if File.exist?(file)

    # Try as index.md in subdirectory
    index_file = File.join(dir, slug, 'index.md')
    return index_file if File.exist?(index_file)

    # Try in subdirectories
    Dir.glob(File.join(dir, '**', "#{slug}.md")).each do |f|
      return f
    end

    # Try index.md in nested subdirectories
    Dir.glob(File.join(dir, '**', slug, 'index.md')).each do |f|
      return f
    end
  end

  # Try in root
  file = "#{slug}.md"
  return file if File.exist?(file)

  # Try as index.md in root subdirectory
  index_file = File.join(slug, 'index.md')
  return index_file if File.exist?(index_file)

  nil
end

# Helper: Parse frontmatter from file
def parse_frontmatter(file)
  return nil unless file && File.exist?(file)

  content = File.read(file)
  return nil unless content.start_with?('---')

  parts = content.split(/^---\s*$/, 3)
  return nil unless parts.length >= 2

  YAML.load(parts[1]) rescue nil
end

# Helper: Read page content (skip frontmatter)
def read_page_content(file)
  return "" unless file && File.exist?(file)

  content = File.read(file)

  # Skip YAML frontmatter
  if content.start_with?('---')
    parts = content.split(/^---\s*$/, 3)
    content = parts[2] || ""
  end

  content.strip
end

# Helper: Render experience data from YAML
def render_experience_data(experience_name)
  experiences_file = '_data/community-building-experiences.yml'
  return "" unless File.exist?(experiences_file)

  experiences = YAML.load_file(experiences_file)
  experience = experiences.find { |e| e['experience'] == experience_name }
  return "" unless experience

  lines = []

  # Target Size, Attributes, Shorthand
  lines << "**Target Size**: #{experience['size']} | **Attributes**: #{experience['adjectives']} | **Shorthand**: \"#{experience['goal']}\""
  lines << ""

  # Protips
  if experience['protips']
    lines << "#### Protips"
    lines << ""
    experience['protips'].each do |protip|
      lines << "* #{protip}"
    end
    lines << ""
  end

  # Process Checklist
  if experience['process']
    lines << "#### Process Checklist"
    lines << ""
    process_steps = experience['process'].split(' > ')
    process_steps.each do |step|
      lines << "* [x] #{step}"
    end
    lines << ""
  end

  # Related Experiences
  if experience['companions'] && !experience['companions'].empty?
    companions_text = experience['companions'].join(', ')
    lines << "**Related Experiences**: #{companions_text}"
    lines << ""
  end

  # Related Techniques (would need to scan techniques file)
  techniques_file = '_data/community-building-techniques.yml'
  if File.exist?(techniques_file)
    techniques = YAML.load_file(techniques_file)
    related_techniques = techniques.select { |t| t['experiences'] && t['experiences'].include?(experience_name) }
    if !related_techniques.empty?
      technique_names = related_techniques.map { |t| t['technique'] }.sort.join(', ')
      lines << "**Related Techniques**: #{technique_names}"
      lines << ""
    end
  end

  # Example & Artifacts
  if experience['example']
    lines << "#### Example & Artifacts"
    lines << ""
    lines << experience['example']
    lines << ""
  end

  lines.join("\n")
end

# Helper: Render templates-downloads data from YAML files
def render_templates_downloads_data
  lines = []

  ['catalytic-funding', 'community-building'].each do |section|
    yaml_file = File.join('_data', 'templates-downloads', "#{section}.yml")
    next unless File.exist?(yaml_file)

    data = YAML.load_file(yaml_file)
    next unless data

    lines << "## #{section.split('-').map(&:capitalize).join(' ')}"
    lines << ""

    data.each do |page_slug, items|
      next if items == false || items.nil? || items.empty?

      # Convert slug to title
      page_title = page_slug.split('-').map(&:capitalize).join(' ')
      lines << "### #{page_title}"
      lines << ""

      items.each do |item|
        if item['icon']
          lines << "* **#{item['title']}** ([#{item['icon']}](#{item['url']}))"
        else
          lines << "* **[#{item['title']}](#{item['url']})**"
        end
        if item['description']
          lines << "  * #{item['description']}"
        end
      end
      lines << ""
    end
  end

  lines.join("\n")
end

# Helper: Render related-external-links data from YAML files
def render_external_links_data
  lines = []

  ['catalytic-funding', 'community-building'].each do |section|
    yaml_file = File.join('_data', 'related-external-links', "#{section}.yml")
    next unless File.exist?(yaml_file)

    data = YAML.load_file(yaml_file)
    next unless data

    lines << "## #{section.split('-').map(&:capitalize).join(' ')}"
    lines << ""

    data.each do |page_slug, items|
      next if items == false || items.nil? || items.empty?

      # Convert slug to title
      page_title = page_slug.split('-').map(&:capitalize).join(' ')
      lines << "### #{page_title}"
      lines << ""

      items.each do |item|
        lines << "* **[#{item['title']}](#{item['url']})**"
        if item['via']
          lines << "  * via #{item['via']}"
        end
        if item['description']
          lines << "  * #{item['description']}"
        end
      end
      lines << ""
    end
  end

  lines.join("\n")
end

# Helper: Render techniques for a category (generate, prioritize, reflect)
def render_techniques_data(purpose)
  techniques_file = '_data/community-building-techniques.yml'
  return "" unless File.exist?(techniques_file)

  techniques = YAML.load_file(techniques_file)
  category_techniques = techniques.select { |t| t['purpose'] == purpose }
  return "" if category_techniques.empty?

  lines = []

  category_techniques.each do |technique|
    # Technique name as heading
    lines << "#### #{technique['technique']}"
    lines << ""

    # Tagline
    if technique['tagline']
      lines << "*#{technique['tagline']}*"
      lines << ""
    end

    # Description
    if technique['description']
      lines << technique['description']
      lines << ""
    end

    # Related Techniques
    if technique['companions'] && !technique['companions'].empty?
      companions_text = technique['companions'].join(', ')
      lines << "**Related Techniques**: #{companions_text}"
      lines << ""
    end

    # Related Experiences
    if technique['experiences'] && !technique['experiences'].empty?
      experiences_text = technique['experiences'].join(', ')
      lines << "**Related Experiences**: #{experiences_text}"
      lines << ""
    end

    lines << ""  # Extra spacing between techniques
  end

  lines.join("\n")
end

# Helper: Load and render checklist from YAML
def render_checklist(checklist_id)
  checklist_file = File.join('_data', 'checklists', "#{checklist_id}.yml")

  unless File.exist?(checklist_file)
    return "<!-- WARNING: Checklist file not found: #{checklist_file} -->"
  end

  checklist_data = YAML.load_file(checklist_file)

  lines = []
  checklist_data.each do |item|
    if item['description']
      lines << "* [x] **#{item['item']}**: #{item['description']}"
    else
      lines << "* [x] **#{item['item']}**"
    end
  end

  lines.join("\n")
end

# Helper: Clean up Liquid tags from content
def cleanup_liquid_tags(content, page_slug = nil)
  # Convert {% include image.html src="..." alt="..." ... %} to markdown image syntax
  content = content.gsub(/\{% include image\.html src="([^"]+)" alt="([^"]+)"[^\}]+ %\}/) do
    src = $1
    alt = $2
    "![#{alt}](#{src})"
  end

  # Remove Bootstrap grid divs (common wrapper for images and text)
  # This captures the entire row structure and extracts just the content
  content = content.gsub(/<div class="row[^"]*">\s*<div class="col[^"]*">\s*(!\[[^\]]*\]\([^\)]+\))\s*<\/div>\s*<div class="col[^"]*">\s*(<p>.*?<\/p>)\s*<\/div>\s*<\/div>/m) do
    image = $1
    paragraph = $2
    # Remove <p> tags from paragraph and keep just the content
    para_content = paragraph.gsub(/<\/?p>/, '')
    "#{image}\n\n#{para_content}"
  end

  # Remove {% capture thinking-questions %} ... {% endcapture %} {% include ... %} blocks
  # Keep only the content between capture tags
  content = content.gsub(/\{% capture thinking-questions %\}\n?(.*?)\n?\{% endcapture %\}\n?\{% include docs\/thinking-questions\.html [^\}]+ %\}/m) do
    # $1 is the content between capture tags
    $1
  end

  # Handle {% capture example %} blocks - convert to blockquote with title
  content = content.gsub(/\{% capture example %\}\n?(.*?)\n?\{% endcapture %\}\n?\{% include docs\/example\.html content=example title="([^"]+)" %\}/m) do
    example_content = $1
    example_title = $2

    # Format as blockquote with title
    lines = []
    lines << "> **_#{example_title}_**"
    lines << ">"

    # Add content with > prefix on each line
    example_content.split("\n").each do |line|
      if line.strip.empty?
        lines << ">"
      else
        lines << "> #{line}"
      end
    end

    lines.join("\n")
  end

  # Handle {% include docs/checklist.html id="..." %} blocks
  content = content.gsub(/\{% include docs\/checklist\.html id="([^"]+)" %\}/) do
    checklist_id = $1
    render_checklist(checklist_id)
  end

  # Remove {{ site.baseurl }} references (replace with nothing or keep URL path)
  content = content.gsub(/\{\{ site\.baseurl \}\}/, '')

  # Convert relative markdown links to absolute URLs
  content = convert_relative_links_to_absolute(content, page_slug)

  # Remove {:target="_blank"} from links (Kramdown syntax)
  content = content.gsub(/\{:target="_blank"\}/, '')

  # Replace emoji shortcuts with actual emojis
  content = content.gsub(/:heart:/, '❤️')
  content = content.gsub(/:bulb:/, '💡')
  content = content.gsub(/:warning:/, '⚠️')

  # Remove other common Liquid tags that might be in content
  # (Add more patterns here as needed)

  content
end

# Main export
def export_fieldguide
  # Load navigation
  nav = YAML.load_file(NAV_FILE)

  # Create output directory
  Dir.mkdir('exports') unless Dir.exist?('exports')

  # Start output
  output = []
  output << "# Field Guide for Philanthropy & Civic Action - Complete Export"
  output << ""
  output << "Auto-generated export of all content following the navigation hierarchy."
  output << ""
  output << "**Generated:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  output << ""
  output << "---"
  output << ""

  # Process each section
  nav.each do |section|
    section_title = section['title']
    puts "Processing section: #{section_title}"

    output << ""
    output << "# #{section_title}"
    output << ""

    # Check if this section has an index.md file with content (e.g., Lessons Learned)
    if !section['pages'] || section['pages'].empty?
      # Try to find section index file
      section_slug = section_title.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
      index_file = File.join(section_slug, 'index.md')

      if File.exist?(index_file)
        puts "  Processing section index file"
        frontmatter = parse_frontmatter(index_file)
        content = read_page_content(index_file)
        content = cleanup_liquid_tags(content, section_slug)

        # Add subtitle if present
        if frontmatter && frontmatter['subtitle'] && !frontmatter['subtitle'].empty?
          output << "**#{frontmatter['subtitle']}**"
          output << ""
        end

        output << content
        output << ""
      end

      next
    end

    # Process pages in section

    section['pages'].each do |page_or_group|
      # Check if this is a group (has nested pages)
      if page_or_group['pages']
        # This is a group
        group_title = page_or_group['title']
        puts "  Processing group: #{group_title}"

        output << ""
        output << "## #{group_title}"
        output << ""

        # Process pages in group
        page_or_group['pages'].each do |page|
          page_title = page['title']
          puts "    Processing page: #{page_title}"

          file = find_page_file(page_title, section_title, group_title)
          if file
            # Parse frontmatter to check for special layouts
            frontmatter = parse_frontmatter(file)

            # Create page slug for link conversion
            page_slug = page_title.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')

            content = read_page_content(file)
            # Clean up Liquid tags
            content = cleanup_liquid_tags(content, page_slug)

            # Check for special layouts and append data
            if frontmatter && frontmatter['layout'] == 'experiences' && frontmatter['experience']
              experience_data = render_experience_data(frontmatter['experience'])
              content = content + "\n\n" + experience_data if !experience_data.empty?
            elsif frontmatter && frontmatter['layout'] == 'techniques'
              # Extract purpose from page title slug
              purpose = page_title.downcase.gsub(/^techniques to /, '')
              techniques_data = render_techniques_data(purpose)
              content = content + "\n\n" + techniques_data if !techniques_data.empty?
            elsif frontmatter && frontmatter['layout'] == 'templates-downloads'
              templates_data = render_templates_downloads_data
              content = content + "\n\n" + templates_data if !templates_data.empty?
            elsif page_title == 'Related External Links'
              links_data = render_external_links_data
              content = content + "\n\n" + links_data if !links_data.empty?
            end

            # Increment headings by 2 (page is ###, so ## becomes ####)
            adjusted_content = increment_headings(content, 2)

            output << ""
            output << "### #{page_title}"
            output << ""
            # Add subtitle if present in frontmatter
            if frontmatter && frontmatter['subtitle'] && !frontmatter['subtitle'].empty?
              output << "**#{frontmatter['subtitle']}**"
              output << ""
            end
            output << adjusted_content
            output << ""
          else
            puts "    WARNING: Could not find file for '#{page_title}'"
          end
        end

      else
        # This is a direct page under section
        page_title = page_or_group['title']
        puts "  Processing page: #{page_title}"

        file = find_page_file(page_title, section_title)
        if file
          # Parse frontmatter to check for special layouts
          frontmatter = parse_frontmatter(file)

          # Create page slug for link conversion
          page_slug = page_title.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')

          content = read_page_content(file)
          # Clean up Liquid tags
          content = cleanup_liquid_tags(content, page_slug)

          # Check for special layouts and append data
          if frontmatter && frontmatter['layout'] == 'experiences' && frontmatter['experience']
            experience_data = render_experience_data(frontmatter['experience'])
            content = content + "\n\n" + experience_data if !experience_data.empty?
          elsif frontmatter && frontmatter['layout'] == 'techniques'
            # Extract purpose from page title slug
            purpose = page_title.downcase.gsub(/^techniques to /, '')
            techniques_data = render_techniques_data(purpose)
            content = content + "\n\n" + techniques_data if !techniques_data.empty?
          elsif frontmatter && frontmatter['layout'] == 'templates-downloads'
            templates_data = render_templates_downloads_data
            content = content + "\n\n" + templates_data if !templates_data.empty?
          elsif page_title == 'Related External Links'
            links_data = render_external_links_data
            content = content + "\n\n" + links_data if !links_data.empty?
          end

          # Increment headings by 1 (page is ##, so ## becomes ###)
          adjusted_content = increment_headings(content, 1)

          output << ""
          output << "## #{page_title}"
          output << ""
          # Add subtitle if present in frontmatter
          if frontmatter && frontmatter['subtitle'] && !frontmatter['subtitle'].empty?
            output << "**#{frontmatter['subtitle']}**"
            output << ""
          end
          output << adjusted_content
          output << ""
        else
          puts "  WARNING: Could not find file for '#{page_title}'"
        end
      end
    end
  end

  # Write output
  final_output = output.join("\n")

  # Collapse multiple blank lines to single blank line (final cleanup)
  final_output = final_output.gsub(/\n{3,}/, "\n\n")

  File.write(OUTPUT_FILE, final_output)
  puts "\nExport complete: #{OUTPUT_FILE}"
  puts "Total lines: #{output.length}"
end

# Run export
export_fieldguide
