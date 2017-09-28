require 'redcarpet'
require 'nokogiri'
require 'sanitize'

# This utility class is used to
# work on html text
#
# You can initialize it with html or markdown text
class HtmlProcessor
  attr_reader :html, :original

  #======================================
  # Constants
  #======================================
  DESCRIPTION_PROCESSING_ORDER = %w( p h1 h2 h3 h4 h5 h6 )


  # Define Youtube transformer for Sanitize
  YOUTUBE_TRANSFORMER = lambda do |env|
    node      = env[:node]
    node_name = env[:node_name]

    # Don't continue if this node is already whitelisted or is not an element.
    return if env[:is_whitelisted] || !node.element?

    # Don't continue unless the node is an iframe.
    return unless node_name == 'iframe'

    # Verify that the video URL is actually a valid YouTube video URL.
    return unless node['src'] =~ %r|\A(?:https?:)?//(?:www\.)?youtube(?:-nocookie)?\.com/|

    # We're now certain that this is a YouTube embed, but we still need to run
    # it through a special Sanitize step to ensure that no unwanted elements or
    # attributes that don't belong in a YouTube embed can sneak in.
    Sanitize.node!(node, {
      :elements => %w[iframe],

      :attributes => {
        'iframe'  => %w[allowfullscreen frameborder height src width]
      }
    })

    # Now that we're sure that this is a valid YouTube embed and that there are
    # no unwanted elements or attributes hidden inside it, we can tell Sanitize
    # to whitelist the current node.
    {:node_whitelist => [node]}
  end

  # Default options for Sanitize
  SANITIZER_OPTS = Sanitize::Config::RELAXED.merge(
    attributes: Sanitize::Config::RELAXED[:attributes].merge(
      'a' => %w[href hreflang name rel target],
      'img' => %w[src ta-insert-video allowfullscreen frameborder style contenteditable]
    ),
    transformers: YOUTUBE_TRANSFORMER
  )

  #======================================
  # Methods
  #======================================
  def initialize(text, options = { })
    @original = text

    # Process markdown or leave original
    if options[:format].to_s == 'markdown' && text
      html_options = { safe_links_only: true, hard_wrap: true, filter_html: false }
      renderer_options = { autolink: true, no_intraemphasis: true, fenced_code_blocks: true, superscript: true }

      renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(html_options), renderer_options)
      raw_html = renderer.render(text)
      @html = Sanitize.fragment(raw_html, SANITIZER_OPTS)
    else
      @html = text
    end
  end

  # Return a Nokogiri document based
  # on processor html
  def document
    @document ||= Nokogiri::HTML(@html)
  end

  # Return a description of the document
  # by returning the first sentence of the
  # first DESCRIPTION_PROCESSING_ORDER found
  def description
    # Return cached value if one
    return @description if @description

    # Parse the html document to try to find
    # a description
    @description = ''
    DESCRIPTION_PROCESSING_ORDER.each do |selector|
      elem = self.document.css(selector).detect { |e| e && !e.content.blank? }
      next if elem.blank? #skip if nil or empty

      # Try to get the first two sentences
      match = elem.content.match(/([^.!?]+[.!?]?)([^.!?]+[.!?]?)?/)
      if match && match.captures.any?
        @description = match.captures.compact.join('')
      end
      break if !@description.empty?
    end

    return @description
  end
end
