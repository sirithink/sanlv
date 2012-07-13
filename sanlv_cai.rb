﻿#encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'pp'

class String
    def br_to_new_line
        self.gsub('<br>', "\n")
    end
    def strip_tag
        self.gsub(%r[<[^>]*>], '')
    end
end #String

module SanLv
    class UrlBuilder
        attr_reader :domain, :id, :article
        attr_reader :end_type
        def initialize id
		#http://www.litongly.cn/athena/offerdetail/sale/litongly-1032152-558158414.html
		#http://www.litongly.cn/page/offerdetail.htm?offerId=508084921
            @domain = %q[http://tianyayidu.com/]
            @article = 'article'
            @end_type = '.html'
            @id = id.to_s
        end     
        def article_url
            @domain + @article + '-a-'+ id + @end_type
        end #article_url        
        def build_article_url page
            page = page.to_s
            "#{@domain}#{@article}-a-#{@id}-#{page+@end_type}"
        end #build_article_url      
    end #UrlBuilder
    class ContentWorker
        attr_reader :url, :doc, :retry_time
        attr_accessor :page_css, :content_css
        class << self
            def log=(log_file)
                @@log = log_file
            end #log=
            def log
                @@log
            end
        end #class
        def initialize url
            @url = url
            define_max_retry_time
            
            define_content_css
            get_nokogiri_doc
            exit if @doc.nil?
            log_or_output_info
        end #initialize     
        def log_or_output_info
            msg = "processing #{@url}"
            if @@log
                @@log.debug msg
            else
                puts msg
            end #if
        end #log_or_output_info
        def get_nokogiri_doc
            times = 0
			from_encode ="gbk"
			to_encode = "utf-8"

            begin
                @doc = Nokogiri::HTML(open(@url).read.strip)
				@doc = @doc.encode!(to_encode, from_encode)
            rescue
                @@log.error "Can Not Open [#{@url}]" if @@log
                times += 1
                retry if(times < @retry_time)
            end #begin
        end #get_nokogiri_doc
        def define_max_retry_time
            @retry_time = 3
        end #define_max_retry_time

        def define_content_css
            @content_css = %q[li.at.c.h2]
        end #define_content_css


        def build_content &blk
		
	rows = @doc.xpath('//div[@id="mod-detail-attributes"]/table/tbody')
			details = rows.collect do |row|
				puts row
				puts "=="
			  detail = {}
			  [
				[:type, 'tr[1]/td[1]/text()'],
[:style, 'tr[1]/td[2]/text()'],
[:cars, 'tr[1]/td[3]/text()'],
[:size, 'tr[2]/td[1]/text()'],
			  ].each do |name, xpath|
				
				detail[name] = row.at_xpath(xpath).to_s.strip #split(/[：]/)[1].strip
				puts "***details[name]" + detail[name]
			  end
			  detail
			end
			pp details
	if block_given?	
			details.each do |d|
				blk.call(d[:type] + "\t" + d[:style] + "\t" + d[:cars] + "\t" + d[:size])
			end
			
		else
			puts details
		end
	
	
		
            #@doc.css(@content_css).each do |li|
            #    if block_given?
            #        blk.call(li.to_html.br_to_new_line.strip_tag)
            #    else
            #        puts li.to_html.br_to_new_line.strip_tag
            #    end #if
            #end #each 
        end #build_content
    end #ContentWorker

    class IoFactory

        attr_reader :file

        def self.init file

            @file = file

            if @file.nil?

                puts 'Can Not Init File To Write'

                exit

            end #if

            File.open @file, 'a'

        end     

    end #IoFactory

    class Runner        

            attr_reader :url_builder, :start_url

            attr_reader :total_page, :file_to_write

            def initialize id

                init_logger

                @url_builder = UrlBuilder.new(id)               

                get_start_url


                create_file_to_write id             

                output_content

            end #initialize

            def self.go(id)
                self.new(id)
            end

            def create_file_to_write id
                file_path = File.join('.', id.to_s.concat('.txt'))
                @file_to_write = IoFactory.init(file_path)
            end #create_file_to_write

            def init_logger
                logger_file = IoFactory.init('./log.txt')
                logger = Logger.new logger_file
                ContentWorker.log = logger
            end #init_logger

            def get_start_url               
                @start_url = @url_builder.article_url
            end #get_start_url

            def get_total_page
                @total_page = ContentWorker.new(@start_url).total_page
                if @total_page.nil?
                    puts 'Can not get total page'
                    exit
                end #if

            end # get_total_page

            def output_content              
                
                    a_url = "http://www.litongly.cn/athena/offerdetail/sale/litongly-1032152-558158414.html"
                    ContentWorker.new(a_url).build_content do |c|
                        @file_to_write.puts c
                        @file_to_write.puts '*' * 40
                    end # build_content
  

            end #output_content

    end #Runner

end #SanLv

include SanLv

id = 1

Runner.go id
 