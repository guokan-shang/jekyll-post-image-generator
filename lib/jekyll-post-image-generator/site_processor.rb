# frozen_string_literal: true

require 'fileutils'

module Jekyll
  module JekyllPostImageGenerator
    # Processes the Jekyll site and generates new images for posts
    class SiteProcessor
      attr_reader :config

      def initialize(
        config = {},
        generator = ImageGenerator.new(
          config.fetch('background_image', '_background_image.png'),
          ImageGeneratorProperties.from_dict(config)
        )
      )
        @config = config
        @generator = generator
        @output_dir = config.fetch('output_directory', File.join('assets', 'images'))
      end

      def process(site)
        site.posts.docs.each do |doc|
          next unless can_generate?(doc)

          source_basename = doc.basename_without_ext

          Jekyll.logger.info('Jekyll Post Image Generator:', "Generating image for #{source_basename}")
          generate(doc.data, source_basename)

          site.static_files << Jekyll::StaticFile.new(site, site.source, @output_dir, fullname(source_basename))
        end
      end

      private

      def generate(data, source_basename)
        text = set?('cover_image_text', data) ? data['cover_image_text'] : data['title']
        @generator.generate("\"#{text}\"".undump, output_path(source_basename))
      end

      def fullname(basename)
        "#{basename.sub(/^\d\d\d\d-\d\d-\d\d-/, '')}.jpg"
      end

      def output_path(basename)
        File.join(@output_dir, fullname(basename))
      end

      def can_generate?(doc)
        data = doc.data
        !set?('cover_image', data) \
        && (set?('title', data) || set?('cover_image_text', data)) \
        && !File.exist?(output_path(doc.basename_without_ext))
      end

      def set?(key, data)
        data.key?(key) && !data[key].nil? && !data[key].strip.empty?
      end
    end
  end
end
