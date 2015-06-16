module Hydra
  module Derivatives
    class Config
      attr_writer :ffmpeg_path, :libreoffice_path, :temp_file_base, :fits_path,
        :enable_ffmpeg, :kdu_compress_path, :kdu_compress_recipes
      def ffmpeg_path
        @ffmpeg_path ||= 'ffmpeg'
      end

      def libreoffice_path
        @libreoffice_path ||= 'soffice'
      end

      def temp_file_base
        @temp_file_base ||= '/tmp'
      end

      def source_file_service
        @source_file_service ||= Hydra::Derivatives::RetrieveSourceFileService
      end

      def output_file_service
        @output_file_service ||= Hydra::Derivatives::PersistIndirectlyContainedOutputFile
      end

      def fits_path
        @fits_path ||= 'fits.sh'
      end

      def enable_ffmpeg
        @enable_ffmpeg ||= true
      end

      def kdu_compress_path
        @kdu_compress_path ||= 'kdu_compress'
      end

      def kdu_compress_recipes
        @kdu_compress_recipes ||= {
          default_color: %Q{-rate 2.4,1.48331273,.91673033,.56657224,.35016049,.21641118,.13374944,.08266171
            -jp2_space sRGB
            -double_buffering 10
            -num_threads 4
            -no_weights
            Clevels=6
            Clayers=8
            "Cblk={64,64}"
            Cuse_sop=yes
            Cuse_eph=yes
            Corder=RPCL
            ORGgen_plt=yes
            ORGtparts=R
            "Stiles={1024,1024}" }.gsub(/\s+/, " ").strip,
          default_grey: %Q{-rate 2.4,1.48331273,.91673033,.56657224,.35016049,.21641118,.13374944,.08266171
            -jp2_space sLUM
            -double_buffering 10
            -num_threads 4
            -no_weights
            Clevels=6
            Clayers=8
            "Cblk={64,64}"
            Cuse_sop=yes
            Cuse_eph=yes
            Corder=RPCL
            ORGgen_plt=yes
            ORGtparts=R
            "Stiles={1024,1024}" }.gsub(/\s+/, " ").strip
        }
      end

    end
  end
end
