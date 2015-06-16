require 'mini_magick'
module Hydra
  module Derivatives
    class Image < Processor
      class_attribute :timeout

      def process
        timeout ? process_with_timeout : process_without_timeout
      end

      def process_with_timeout
        status = Timeout::timeout(timeout) do
          process_without_timeout
        end
      rescue Timeout::Error => ex
        raise Hydra::Derivatives::TimeoutError, "Unable to process image derivative\nThe command took longer than #{timeout} seconds to execute"
      end

      def process_without_timeout
        directives.each do |name, args|
          opts = args.kind_of?(Hash) ? args : {size: args}
          format = opts.fetch(:format, 'png')
          create_resized_image(output_file(output_file_name), opts[:size], format)
        end
      end

      protected

      def new_mime_type(format)
        MIME::Types.type_for(format).first.to_s
      end

      def create_resized_image(output_file, size, format, quality=nil)
        create_image(output_file, format, quality) do |xfrm|
          xfrm.resize(size) if size.present?
        end
        output_file.mime_type = new_mime_type(format)
      end

      def create_image(output_file, format, quality=nil)
        xfrm = load_image_transformer
        yield(xfrm) if block_given?
        xfrm.format(format)
        xfrm.quality(quality.to_s) if quality
        write_image(output_file, xfrm)
      end

      def write_image(output_file, xfrm)
        stream = StringIO.new
        xfrm.write(stream)
        stream.rewind
        # output_file.content = stream
        output_file_service.call(object, stream, destination_name, mime_type: mime_type)

      end

      # Override this method if you want a different transformer, or need to load the
      # raw image from a different source (e.g.  external file)
      def load_image_transformer
        MiniMagick::Image.read(source_file.content)
      end
    end
  end
end
