require 'digest/sha2'
require 'open4'

module WikiExternalFilter
  class Filter
    class << self
      def config
        @config ||= load_config
      end

      def have_macro?(macro)
        config.key?(macro)
      end

      def construct_cache_key(macro, name)
        ["wiki_external_filter", macro, name].join("_")
      end

      private
      def load_config
        config_file = "#{Rails.root}/config/wiki_external_filter.yml"
        unless File.exists?(config_file)
          config_file = File.expand_path("../../config/wiki_external_filter.yml",
                                         __dir__)
        end
        YAML.load_file(config_file)[Rails.env]
      end
    end

    def build(args, text, attachments, macro, info)

      name = Digest::SHA256.hexdigest(text.to_s)
      result = {}
      content = nil
      cache_key = nil
      expires = 0

      if info.key?('cache_seconds')
        expires = info['cache_seconds']
      else
        expires = Setting.plugin_wiki_external_filter['cache_seconds'].to_i
      end

      if expires > 0
        cache_key = self.class.construct_cache_key(macro, name)
        begin
          content = Rails.cache.read cache_key, :expires_in => expires.seconds
        rescue
          Rails.logger.error "Failed to load cache: #{cache_key}, error: $! #{error} #{$@}"
        end
      end

      if content
        result[:source] = text.to_s
        result[:content] = content
        Rails.logger.debug "from cache: #{cache_key}"
      else
        result = build_forced(args, text, attachments, info)
        if result[:status]
          if expires > 0
            begin
              Rails.cache.write cache_key, result[:content], :expires_in => expires.seconds
              Rails.logger.debug "cache saved: #{cache_key} expires #{expires.seconds}"
            rescue
              Rails.logger.error "Failed to save cache: #{cache_key}, result content #{result[:content]}, error: $!"
            end
          end
        else
          raise "Error applying external filter: stdout is #{result[:content]}, stderr is #{result[:errors]}"
        end
      end

      result[:name] = name
      result[:macro] = macro
      result[:content_types] = info['outputs'].map { |out| out['content_type'] }
      result[:template] = info['template']

      return result
    end

    def build_forced(args, text, attachments, info)
      if info['replace_attachments'] and attachments
        attachments.each do |att|
          text.gsub!(/#{att.filename.downcase}/i, att.diskfile)
        end
      end

      result = {}
      content = []
      errors = ""

      text          = text.gsub("<br />", "\n") if text
      Rails.logger.debug "\n Text #{text} \n"

      info['outputs'].each do |out|
        Rails.logger.info "executing command: #{out['command']}"

        c = nil
        e = nil

        Open4::popen4(out['command']) { |pid, fin, fout, ferr|
          fin.puts out['prolog'] if out.key?('prolog')
          fin.write text
          fin.write "\n"+out['epilog'] if out.key?('epilog')
          fin.close
          c, e = [fout.read, ferr.read]
        }

        Rails.logger.debug("child status: sig=#{$?.termsig}, exit=#{$?.exitstatus}")

        content << c
        errors += e if e
      end

      Rails.logger.debug "\n Content #{content} \n Errors #{errors} \n"

      result[:content] = content
      result[:errors] = errors
      result[:source] = text
      result[:status] = $?.exitstatus == 0

      return result
    end
  end
end
