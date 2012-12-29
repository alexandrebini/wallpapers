require 'open-uri'
require 'net/http'
require 'csv'

module Crawler
  module UrlOpener
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def open_url(url, options={})
        uri = URI.parse(url)
        options = { max_attempts: 10, proxy: false }.merge(options)

        if options[:proxy] == false
          begin # try without proxy first
            open_url_without_proxy(uri, options)
          rescue # if does not work, try with proxy
            open_url_with_proxy(uri, options)
          end
        else
          open_url_with_proxy(uri, options)
        end
      end

      def open_url_with_proxy(uri, options={})
        @denied_proxies ||= []
        attempts = 0

        proxy = Crawler::Base.proxy
        proxy_uri = URI.parse(proxy)

        http = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port).start(uri.host)
        body = response_is_valid?(http, uri, options)
        throw "Body is nil for #{ uri }" if body.blank?

        return body
      rescue Exception => e
        error_logger "\n#{ proxy } #{ e.to_s }. Trying a new proxy..."
        @denied_proxies << proxy unless @denied_proxies.include?(proxy)
        attempts += 1
        retry unless attempts >= options[:max_attempts]
      ensure
        http.finish
      end

      def open_url_without_proxy(uri, options)
        attempts = 0
        http = Net::HTTP.start(uri.host)
        body = response_is_valid?(http, uri, options)
        throw "Body is nil for #{ uri }" if body.blank?
        return body
      rescue Exception => e
        attempts += 1
        retry unless attempts >= options[:max_attempts]
      ensure
        http.finish
      end

      def response_is_valid?(http, uri, options={})
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        unless response.kind_of?(Net::HTTPRedirection)
          if body_is_valid?(response.body, options[:verification_matcher])
            body = response.body
          end
        end
      end

      def body_is_valid?(body, verification_matcher=nil)
        return false if body.blank?
        return true if verification_matcher.nil?
        return body.index(verification_matcher).present?
      end

      def proxy
        available_proxies = (@proxy_list.to_a - @denied_proxies.to_a)

        if @proxy_list.nil? || available_proxies.size == 0
          error_logger "\nGetting a new proxy list..."
          @denied_proxies = []
          @proxy_list = []

          # get from http://www.checkedproxylists.com/
          CSV.open("#{ Rails.root }/config/proxylist.csv", col_sep: ';').each do |row|
            next if row[3] == 'true'
            ip = row[0].strip
            port = row[1].to_i
            url = "http://#{ ip }:#{ port }"
            begin
              URI.parse(url)
              @proxy_list << url
            rescue
            end
          end
        end

        return (@proxy_list - @denied_proxies.to_a).sample
      end

      def error_logger(msg)
        @error_logger ||= Logger.new("#{ Rails.root }/log/crawler_error.log")
        @error_logger << msg
      end
    end
  end
end