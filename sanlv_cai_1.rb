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
    def n_to_nil
        self.gsub('\n', "")
    end	
    def strip_tag
        self.gsub(%r[<[^>]*>], '').gsub(/\t|\n|\r/, '')
    end
end #String
module SanLv
    class UrlBuilder
        attr_reader :domain, :id, :article
        attr_reader :end_type
        def initialize id

			@domain = %q[http://www.stronger-filter.com/products.asp?page=]
			@article = 'article'
            @end_type = '&lb=b&bid=&bid2=&sid=&act=&go=&title=&cx1=&type2=&type1=&fang='
            @id = id.to_s
        end     
        def article_url
            @domain + id + @end_type
        end #article_url        
        def build_article_url page
            page = page.to_s
            "#{@domain}#{page}#{@end_type}"
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
            define_page_css
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
			from_encode ="gb18030"
			to_encode = "utf-8"

            begin
				html_stream = open(@url).read.strip
				html_stream.encode!(to_encode, from_encode)
                @doc = Nokogiri::HTML(html_stream)
            rescue
                @@log.error "Can Not Open [#{@url}]" if @@log
                times += 1
                retry if(times < @retry_time)
            end #begin
        end #get_nokogiri_doc
        def define_max_retry_time
            @retry_time = 3
        end #define_max_retry_time
		
        def define_page_css
            @page_css = %q[div.page]
        end
        def define_content_css
            @content_css = %q[li.at.c.h2]
        end #define_content_css
		
        def total_page
            #page = ''
            #doc.css(page_css).each do |p|
            #    m = p.content.match(/，\d+/)[0].match(/\d+/)  
            #    page = m[0] if m                                
            #end #each
            #page.to_i
			130
        end #total_page
		
		def build_lists &blk
			puts "采集列表页"
			lists = []

			@doc.css("div.index_pic_title").each do |item|
				lists << [item.at_css("a").text, "http://www.stronger-filter.com/" + item.at_css("a").attr("href")]
			end

			
			if block_given?	
				blk.call(lists)			
			else
				puts lists.length
			end
			
			
		end
		
        def build_content &blk
			puts "采集明细页"

			row = @doc.at_xpath('//table[@class = "product_bk1"]')
			puts row
			puts "="*40
			details = []
			[
			[:s1, 'tr[1]/td[2]//tr[1]'],
			[:s2, 'tr[1]/td[2]//tr[2]'],
			[:s3, 'tr[1]/td[2]//tr[3]'],
			[:s4, 'tr[1]/td[2]//tr[4]'],
			[:s4, 'tr[1]/td[2]//tr[5]'],			
			[:s5, 'tr[2]'],
			].each do |name, xpath|
				item = row.at_xpath(xpath).to_s.strip_tag.strip 
				puts "#{name}:- #{item}"
				details << item
			end


			if block_given?	
				temp = "#{@url}\t"
				details.collect  do |p| 
					#if(["品牌" , "型号" , "适用车型" , "配件编号", "外型尺寸"].include? p.split(/：/)[0])
						temp << "#{p}\t"
					#end
				end
				blk.call(temp)
			else
				puts details
			end
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

				get_total_page
                
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
				puts @start_url
            end #get_start_url

            def get_total_page
                @total_page = ContentWorker.new(@start_url).total_page
				@total_page = 1 if @total_page == 0
				puts @total_page.to_s + "pages"
                if @total_page.nil?
                    puts 'Can not get total page'
                    exit
                end #if

            end # get_total_page

            def output_content              
				@total_page.times do |part|
                    list_url = @url_builder.build_article_url(part+1)
					puts "list_page: #{list_url}" 
                    ContentWorker.new(list_url).build_lists do |c|
                        pp c
						c.each do |item|
							page_url =  item[1] #"http://www.litongly.cn/athena/offerdetail/sale/litongly-1032152-558158414.html"
							puts "-----page_url: #{page_url}"
							ContentWorker.new(page_url).build_content do |cc|
								@file_to_write.puts cc
								#@file_to_write.puts '*' * 40
							end # build_content
						end						
						
						
                    end # build_lists
                end #times


  

            end #output_content

    end #Runner

end #SanLv

include SanLv

id = 1

Runner.go id
 