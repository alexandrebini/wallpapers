module Crawler
  class UrlOpener
    def open_url(url, options={})
      uri = URI.parse(url)
      options = { max_attempts: 20, proxy: false }.merge(options)

      if options[:proxy] == true
        open_url_with_proxy(uri, options)
      else
        # when we are not using a proxy, in 5% of cases I want to reset the
        # denied_host to give it a new chance because some servers may block
        # our ip just for some minutes
        @denied_host = false if rand(20) == 0

        # try without proxy first
        if @denied_host
          body = nil
        else
          body = open_url_without_proxy(uri, options)
        end

        return body unless body.blank?

        # if does not work, try with proxy
        error_logger "\nlocalhost marked as denied. Trying with proxy..."
        @denied_host = true
        return open_url_with_proxy(uri, options)
      end
    end

    def open_url_with_proxy(uri, options={})
      @denied_proxies ||= []
      attempts = 0
      begin
        proxy_uri = URI.parse(proxy)

        http = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port).start(uri.host)
        body = response_is_valid?(http, uri, options)
        raise "Body is nil" if body.blank?
        return body
      rescue Exception => e
        error_logger "\n#{ uri } (#{ attempts += 1 }/#{ options[:max_attempts] }) \n\t#{ e.to_s }. Proxy #{ proxy } marked as denied, trying again with a new one..."
        @denied_proxies << proxy unless @denied_proxies.include?(proxy)
        sleep(5)
        retry unless attempts >= options[:max_attempts]
      end
    ensure
      http.finish if http
    end

    def open_url_without_proxy(uri, options)
      attempts = 1
      begin
        http = Net::HTTP.start(uri.host)
        body = response_is_valid?(http, uri, options)
        raise "Body is invalid" if body.blank?
        GC.start
        return body
      rescue Exception => e
        error_logger "\n#{ uri } (#{ attempts += 1 }/#{ options[:max_attempts] }) \n\t#{ e.to_s }. Trying again..."
        sleep(5)
        retry unless attempts >= options[:max_attempts]
      end
    ensure
      http.finish if http
    end

    def response_is_valid?(http, uri, options={})
      attempts = 0
      request = Net::HTTP::Get.new(uri.request_uri)
      request.initialize_http_header({ "User-Agent" => user_agent })
      response = http.request(request)
      http.finish

      if response.kind_of?(Net::HTTPSuccess) && body_is_valid?(response, uri, options)
        return response.body
      else
        return nil
      end
    end

    def body_is_valid?(response, uri, options={})
      return false if response.body.blank?

      # validates the verification matcher
      return false if options[:verification_matcher].present? &&
        response.body.index(options[:verification_matcher]).blank?

      # validates the min size
      return false if options[:min_size].present? &&
        response.body.bytesize < options[:min_size]

      # validate the content-length
      return false if response['content-length'] &&
        response['content-length'].to_i < response.body.bytesize

      # use jpeginfo to check corrupted files
      filename = File.basename(uri.to_s)
      if options[:image] && File.extname(filename) == '.jpg'
        tempfile = Tempfile.new(filename)
        tempfile.binmode
        tempfile.write response.body
        tempfile.rewind
        return false if system "jpeginfo -c \"#{ tempfile.path }\" | grep -E \"WARNING|ERROR\""
      end

      return true
    ensure
      if tempfile
        tempfile.close
        tempfile.unlink   # deletes the temp file
      end
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

        file = open('http://www.vpngeeks.com/proxylist.php?country=0&port=&speed%5B%5D=2&speed%5B%5D=3&anon%5B%5D=1&anon%5B%5D=2&anon%5B%5D=3&type%5B%5D=1&conn%5B%5D=1&conn%5B%5D=2&conn%5B%5D=3&sort=1&order=1&rows=800&search=Find+Proxy')
        doc = Nokogiri::HTML(file)
        file.close

        doc.css('table tr.tr_style2, table tr.tr_style1').map do |tr|
          ip = tr.css('td')[0].content.gsub('\n', '').strip
          port = tr.css('td')[1].content.to_i
          url = "http://#{ ip }:#{ port }"
          begin
            URI.parse(url)
            @proxy_list << url
          rescue
          end
        end

        @proxy_list.uniq!
      end

      return (@proxy_list - @denied_proxies.to_a).sample
    end

    def error_logger(msg)
      @error_logger ||= Logger.new("#{ Rails.root }/log/crawler_error.log")
      @error_logger << msg
    end

    def user_agent
      @user_agents ||= File.readlines("#{ Rails.root }/config/user_agents.txt")
      @user_agents.sample
    end
  end
end