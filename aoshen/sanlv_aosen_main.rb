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
			# 80 空滤 101 机滤 127汽滤
			@domain = %q[http://www.jarparts.com/Products_indexlist.asp?lang=CN&page=]
			@article = 'article'
            @end_type = '&SortID=127&keys='
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
			from_encode ="GBK"
			to_encode = "utf-8"

            begin
			html_stream = open(@url).read.strip
			html_stream.encode!(to_encode, from_encode)
                @doc = Nokogiri::HTML(html_stream)
				#@doc = 
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
            @page_css = %q[div.pages span]
        end
        def define_content_css
            @content_css = %q[li.at.c.h2]
        end #define_content_cssea
		
        def total_page
			puts @url
            page = ''
            p = doc.at_css(@page_css) 
            m = p.content.match(/\/\d+/)[0].match(/\d+/)              
                page = m[0] if m                                
            page.to_i
        end #total_page
		
		def build_lists &blk
			lists = []
			#regEx = /getTypes\((.*)\);getTypePic/
			regEx = /\d+,'\w+'/

			@doc.css("table > tr").each do |item|
				temp = []
				temp << item.css("td")[1].text
				temp << item.css("td")[3].text
				urlstr = item.attr("onclick")
				if regEx =~ urlstr
				  lists << temp + regEx.match(urlstr).to_s.gsub('\'','').split(/,/)
				end		
				#puts lists
				#lists << [item., "http://www.jarparts.com/" + item.at_css("a").attr("href")]
			end

			
			if block_given?	
				blk.call(lists)			
			else
				puts lists.length
			end
			
			
		end
		
        def build_content &blk
		
			rows = @doc.xpath('//table[@class = "proInfoTable"]/tbody')
			puts rows.length
			if rows.length == 0
				blk.call(@url)
			end
			items = @doc.at_css("div.mainTitle").text
			rows.collect do |row|
				#puts row
				['tr[1]/td[2]',
				 'tr[1]/td[4]',
				 'tr[2]/td[2]',
				 'tr[2]/td[4]',
				 'tr[3]/td[2]',
				 'tr[3]/td[4]',				 
				 'tr[4]/td[2]',
				 'tr[4]/td[4]',
				 'tr[6]/td[1]',
				].each do |xpath|
					#puts "#{row.at_xpath(xpath).to_s.strip_tag.strip}"
					items += "\t" + row.at_xpath(xpath).to_s.strip_tag.strip 
				end
				items += "\t" + @url
			  #puts detail
				if block_given?	
					blk.call(items)
				else
					puts detail
				end
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
				@url_lists = %w(http://www.globalaosen.com/showProducts.asp?classID=986
http://www.globalaosen.com/showProducts.asp?classID=985
http://www.globalaosen.com/showProducts.asp?classID=3
http://www.globalaosen.com/showProducts.asp?classID=4
http://www.globalaosen.com/showProducts.asp?classID=5
http://www.globalaosen.com/showProducts.asp?classID=6
http://www.globalaosen.com/showProducts.asp?classID=8
http://www.globalaosen.com/showProducts.asp?classID=9
http://www.globalaosen.com/showProducts.asp?classID=10
http://www.globalaosen.com/showProducts.asp?classID=11
http://www.globalaosen.com/showProducts.asp?classID=12
http://www.globalaosen.com/showProducts.asp?classID=13
http://www.globalaosen.com/showProducts.asp?classID=14
http://www.globalaosen.com/showProducts.asp?classID=15
http://www.globalaosen.com/showProducts.asp?classID=16
http://www.globalaosen.com/showProducts.asp?classID=17
http://www.globalaosen.com/showProducts.asp?classID=18
http://www.globalaosen.com/showProducts.asp?classID=19
http://www.globalaosen.com/showProducts.asp?classID=20
http://www.globalaosen.com/showProducts.asp?classID=990
http://www.globalaosen.com/showProducts.asp?classID=21
http://www.globalaosen.com/showProducts.asp?classID=22
http://www.globalaosen.com/showProducts.asp?classID=23
http://www.globalaosen.com/showProducts.asp?classID=24
http://www.globalaosen.com/showProducts.asp?classID=25
http://www.globalaosen.com/showProducts.asp?classID=26
http://www.globalaosen.com/showProducts.asp?classID=27
http://www.globalaosen.com/showProducts.asp?classID=28
http://www.globalaosen.com/showProducts.asp?classID=29
http://www.globalaosen.com/showProducts.asp?classID=30
http://www.globalaosen.com/showProducts.asp?classID=31
http://www.globalaosen.com/showProducts.asp?classID=32
http://www.globalaosen.com/showProducts.asp?classID=33
http://www.globalaosen.com/showProducts.asp?classID=34
http://www.globalaosen.com/showProducts.asp?classID=35
http://www.globalaosen.com/showProducts.asp?classID=36
http://www.globalaosen.com/showProducts.asp?classID=37
http://www.globalaosen.com/showProducts.asp?classID=38
http://www.globalaosen.com/showProducts.asp?classID=39
http://www.globalaosen.com/showProducts.asp?classID=40
http://www.globalaosen.com/showProducts.asp?classID=41
http://www.globalaosen.com/showProducts.asp?classID=42
http://www.globalaosen.com/showProducts.asp?classID=43
http://www.globalaosen.com/showProducts.asp?classID=44
http://www.globalaosen.com/showProducts.asp?classID=996
http://www.globalaosen.com/showProducts.asp?classID=45
http://www.globalaosen.com/showProducts.asp?classID=46
http://www.globalaosen.com/showProducts.asp?classID=47
http://www.globalaosen.com/showProducts.asp?classID=48
http://www.globalaosen.com/showProducts.asp?classID=49
http://www.globalaosen.com/showProducts.asp?classID=50
http://www.globalaosen.com/showProducts.asp?classID=51
http://www.globalaosen.com/showProducts.asp?classID=52
http://www.globalaosen.com/showProducts.asp?classID=53
http://www.globalaosen.com/showProducts.asp?classID=54
http://www.globalaosen.com/showProducts.asp?classID=55
http://www.globalaosen.com/showProducts.asp?classID=56
http://www.globalaosen.com/showProducts.asp?classID=57
http://www.globalaosen.com/showProducts.asp?classID=58
http://www.globalaosen.com/showProducts.asp?classID=59
http://www.globalaosen.com/showProducts.asp?classID=60
http://www.globalaosen.com/showProducts.asp?classID=61
http://www.globalaosen.com/showProducts.asp?classID=62
http://www.globalaosen.com/showProducts.asp?classID=63
http://www.globalaosen.com/showProducts.asp?classID=64
http://www.globalaosen.com/showProducts.asp?classID=65
http://www.globalaosen.com/showProducts.asp?classID=66
http://www.globalaosen.com/showProducts.asp?classID=67
http://www.globalaosen.com/showProducts.asp?classID=68
http://www.globalaosen.com/showProducts.asp?classID=69
http://www.globalaosen.com/showProducts.asp?classID=70
http://www.globalaosen.com/showProducts.asp?classID=71
http://www.globalaosen.com/showProducts.asp?classID=72
http://www.globalaosen.com/showProducts.asp?classID=73
http://www.globalaosen.com/showProducts.asp?classID=74
http://www.globalaosen.com/showProducts.asp?classID=75
http://www.globalaosen.com/showProducts.asp?classID=76
http://www.globalaosen.com/showProducts.asp?classID=77
http://www.globalaosen.com/showProducts.asp?classID=78
http://www.globalaosen.com/showProducts.asp?classID=79
http://www.globalaosen.com/showProducts.asp?classID=80
http://www.globalaosen.com/showProducts.asp?classID=81
http://www.globalaosen.com/showProducts.asp?classID=82
http://www.globalaosen.com/showProducts.asp?classID=83
http://www.globalaosen.com/showProducts.asp?classID=84
http://www.globalaosen.com/showProducts.asp?classID=85
http://www.globalaosen.com/showProducts.asp?classID=86
http://www.globalaosen.com/showProducts.asp?classID=87
http://www.globalaosen.com/showProducts.asp?classID=88
http://www.globalaosen.com/showProducts.asp?classID=89
http://www.globalaosen.com/showProducts.asp?classID=90
http://www.globalaosen.com/showProducts.asp?classID=91
http://www.globalaosen.com/showProducts.asp?classID=92
http://www.globalaosen.com/showProducts.asp?classID=93
http://www.globalaosen.com/showProducts.asp?classID=94
http://www.globalaosen.com/showProducts.asp?classID=95
http://www.globalaosen.com/showProducts.asp?classID=96
http://www.globalaosen.com/showProducts.asp?classID=97
http://www.globalaosen.com/showProducts.asp?classID=98
http://www.globalaosen.com/showProducts.asp?classID=99
http://www.globalaosen.com/showProducts.asp?classID=100
http://www.globalaosen.com/showProducts.asp?classID=101
http://www.globalaosen.com/showProducts.asp?classID=102
http://www.globalaosen.com/showProducts.asp?classID=103
http://www.globalaosen.com/showProducts.asp?classID=104
http://www.globalaosen.com/showProducts.asp?classID=997
http://www.globalaosen.com/showProducts.asp?classID=105
http://www.globalaosen.com/showProducts.asp?classID=106
http://www.globalaosen.com/showProducts.asp?classID=107
http://www.globalaosen.com/showProducts.asp?classID=108
http://www.globalaosen.com/showProducts.asp?classID=109
http://www.globalaosen.com/showProducts.asp?classID=110
http://www.globalaosen.com/showProducts.asp?classID=111
http://www.globalaosen.com/showProducts.asp?classID=112
http://www.globalaosen.com/showProducts.asp?classID=113
http://www.globalaosen.com/showProducts.asp?classID=114
http://www.globalaosen.com/showProducts.asp?classID=115
http://www.globalaosen.com/showProducts.asp?classID=116
http://www.globalaosen.com/showProducts.asp?classID=117
http://www.globalaosen.com/showProducts.asp?classID=118
http://www.globalaosen.com/showProducts.asp?classID=119
http://www.globalaosen.com/showProducts.asp?classID=120
http://www.globalaosen.com/showProducts.asp?classID=121
http://www.globalaosen.com/showProducts.asp?classID=122
http://www.globalaosen.com/showProducts.asp?classID=123
http://www.globalaosen.com/showProducts.asp?classID=124
http://www.globalaosen.com/showProducts.asp?classID=125
http://www.globalaosen.com/showProducts.asp?classID=126
http://www.globalaosen.com/showProducts.asp?classID=127
http://www.globalaosen.com/showProducts.asp?classID=128
http://www.globalaosen.com/showProducts.asp?classID=129
http://www.globalaosen.com/showProducts.asp?classID=130
http://www.globalaosen.com/showProducts.asp?classID=131
http://www.globalaosen.com/showProducts.asp?classID=132
http://www.globalaosen.com/showProducts.asp?classID=133
http://www.globalaosen.com/showProducts.asp?classID=134
http://www.globalaosen.com/showProducts.asp?classID=135
http://www.globalaosen.com/showProducts.asp?classID=136
http://www.globalaosen.com/showProducts.asp?classID=137
http://www.globalaosen.com/showProducts.asp?classID=138
http://www.globalaosen.com/showProducts.asp?classID=998
http://www.globalaosen.com/showProducts.asp?classID=139
http://www.globalaosen.com/showProducts.asp?classID=140
http://www.globalaosen.com/showProducts.asp?classID=141
http://www.globalaosen.com/showProducts.asp?classID=142
http://www.globalaosen.com/showProducts.asp?classID=143
http://www.globalaosen.com/showProducts.asp?classID=144
http://www.globalaosen.com/showProducts.asp?classID=145
http://www.globalaosen.com/showProducts.asp?classID=146
http://www.globalaosen.com/showProducts.asp?classID=147
http://www.globalaosen.com/showProducts.asp?classID=148
http://www.globalaosen.com/showProducts.asp?classID=149
http://www.globalaosen.com/showProducts.asp?classID=150
http://www.globalaosen.com/showProducts.asp?classID=151
http://www.globalaosen.com/showProducts.asp?classID=152
http://www.globalaosen.com/showProducts.asp?classID=153
http://www.globalaosen.com/showProducts.asp?classID=154
http://www.globalaosen.com/showProducts.asp?classID=155
http://www.globalaosen.com/showProducts.asp?classID=156
http://www.globalaosen.com/showProducts.asp?classID=157
http://www.globalaosen.com/showProducts.asp?classID=158
http://www.globalaosen.com/showProducts.asp?classID=159
http://www.globalaosen.com/showProducts.asp?classID=160
http://www.globalaosen.com/showProducts.asp?classID=161
http://www.globalaosen.com/showProducts.asp?classID=162
http://www.globalaosen.com/showProducts.asp?classID=163
http://www.globalaosen.com/showProducts.asp?classID=164
http://www.globalaosen.com/showProducts.asp?classID=165
http://www.globalaosen.com/showProducts.asp?classID=166
http://www.globalaosen.com/showProducts.asp?classID=167
http://www.globalaosen.com/showProducts.asp?classID=168
http://www.globalaosen.com/showProducts.asp?classID=169
http://www.globalaosen.com/showProducts.asp?classID=170
http://www.globalaosen.com/showProducts.asp?classID=171
http://www.globalaosen.com/showProducts.asp?classID=172
http://www.globalaosen.com/showProducts.asp?classID=173
http://www.globalaosen.com/showProducts.asp?classID=174
http://www.globalaosen.com/showProducts.asp?classID=175
http://www.globalaosen.com/showProducts.asp?classID=176
http://www.globalaosen.com/showProducts.asp?classID=177
http://www.globalaosen.com/showProducts.asp?classID=178
http://www.globalaosen.com/showProducts.asp?classID=179
http://www.globalaosen.com/showProducts.asp?classID=180
http://www.globalaosen.com/showProducts.asp?classID=181
http://www.globalaosen.com/showProducts.asp?classID=182
http://www.globalaosen.com/showProducts.asp?classID=183
http://www.globalaosen.com/showProducts.asp?classID=184
http://www.globalaosen.com/showProducts.asp?classID=185
http://www.globalaosen.com/showProducts.asp?classID=186
http://www.globalaosen.com/showProducts.asp?classID=187
http://www.globalaosen.com/showProducts.asp?classID=188
http://www.globalaosen.com/showProducts.asp?classID=189
http://www.globalaosen.com/showProducts.asp?classID=190
http://www.globalaosen.com/showProducts.asp?classID=191
http://www.globalaosen.com/showProducts.asp?classID=192
http://www.globalaosen.com/showProducts.asp?classID=193
http://www.globalaosen.com/showProducts.asp?classID=194
http://www.globalaosen.com/showProducts.asp?classID=195
http://www.globalaosen.com/showProducts.asp?classID=196
http://www.globalaosen.com/showProducts.asp?classID=197
http://www.globalaosen.com/showProducts.asp?classID=198
http://www.globalaosen.com/showProducts.asp?classID=199
http://www.globalaosen.com/showProducts.asp?classID=200
http://www.globalaosen.com/showProducts.asp?classID=201
http://www.globalaosen.com/showProducts.asp?classID=202
http://www.globalaosen.com/showProducts.asp?classID=203
http://www.globalaosen.com/showProducts.asp?classID=204
http://www.globalaosen.com/showProducts.asp?classID=205
http://www.globalaosen.com/showProducts.asp?classID=206
http://www.globalaosen.com/showProducts.asp?classID=207
http://www.globalaosen.com/showProducts.asp?classID=208
http://www.globalaosen.com/showProducts.asp?classID=209
http://www.globalaosen.com/showProducts.asp?classID=210
http://www.globalaosen.com/showProducts.asp?classID=211
http://www.globalaosen.com/showProducts.asp?classID=212
http://www.globalaosen.com/showProducts.asp?classID=213
http://www.globalaosen.com/showProducts.asp?classID=214
http://www.globalaosen.com/showProducts.asp?classID=215
http://www.globalaosen.com/showProducts.asp?classID=216
http://www.globalaosen.com/showProducts.asp?classID=217
http://www.globalaosen.com/showProducts.asp?classID=218
http://www.globalaosen.com/showProducts.asp?classID=219
http://www.globalaosen.com/showProducts.asp?classID=220
http://www.globalaosen.com/showProducts.asp?classID=221
http://www.globalaosen.com/showProducts.asp?classID=222
http://www.globalaosen.com/showProducts.asp?classID=223
http://www.globalaosen.com/showProducts.asp?classID=224
http://www.globalaosen.com/showProducts.asp?classID=225
http://www.globalaosen.com/showProducts.asp?classID=226
http://www.globalaosen.com/showProducts.asp?classID=227
http://www.globalaosen.com/showProducts.asp?classID=228
http://www.globalaosen.com/showProducts.asp?classID=229
http://www.globalaosen.com/showProducts.asp?classID=230
http://www.globalaosen.com/showProducts.asp?classID=231
http://www.globalaosen.com/showProducts.asp?classID=232
http://www.globalaosen.com/showProducts.asp?classID=233
http://www.globalaosen.com/showProducts.asp?classID=234
http://www.globalaosen.com/showProducts.asp?classID=235
http://www.globalaosen.com/showProducts.asp?classID=236
http://www.globalaosen.com/showProducts.asp?classID=237
http://www.globalaosen.com/showProducts.asp?classID=238
http://www.globalaosen.com/showProducts.asp?classID=239
http://www.globalaosen.com/showProducts.asp?classID=240
http://www.globalaosen.com/showProducts.asp?classID=241
http://www.globalaosen.com/showProducts.asp?classID=242
http://www.globalaosen.com/showProducts.asp?classID=243
http://www.globalaosen.com/showProducts.asp?classID=244
http://www.globalaosen.com/showProducts.asp?classID=245
http://www.globalaosen.com/showProducts.asp?classID=246
http://www.globalaosen.com/showProducts.asp?classID=247
http://www.globalaosen.com/showProducts.asp?classID=248
http://www.globalaosen.com/showProducts.asp?classID=249
http://www.globalaosen.com/showProducts.asp?classID=250
http://www.globalaosen.com/showProducts.asp?classID=251
http://www.globalaosen.com/showProducts.asp?classID=252
http://www.globalaosen.com/showProducts.asp?classID=253
http://www.globalaosen.com/showProducts.asp?classID=254
http://www.globalaosen.com/showProducts.asp?classID=255
http://www.globalaosen.com/showProducts.asp?classID=256
http://www.globalaosen.com/showProducts.asp?classID=257
http://www.globalaosen.com/showProducts.asp?classID=258
http://www.globalaosen.com/showProducts.asp?classID=259
http://www.globalaosen.com/showProducts.asp?classID=260
http://www.globalaosen.com/showProducts.asp?classID=261
http://www.globalaosen.com/showProducts.asp?classID=262
http://www.globalaosen.com/showProducts.asp?classID=263
http://www.globalaosen.com/showProducts.asp?classID=264
http://www.globalaosen.com/showProducts.asp?classID=265
http://www.globalaosen.com/showProducts.asp?classID=266
http://www.globalaosen.com/showProducts.asp?classID=267
http://www.globalaosen.com/showProducts.asp?classID=268
http://www.globalaosen.com/showProducts.asp?classID=269
http://www.globalaosen.com/showProducts.asp?classID=270
http://www.globalaosen.com/showProducts.asp?classID=271
http://www.globalaosen.com/showProducts.asp?classID=272
http://www.globalaosen.com/showProducts.asp?classID=273
http://www.globalaosen.com/showProducts.asp?classID=274
http://www.globalaosen.com/showProducts.asp?classID=275
http://www.globalaosen.com/showProducts.asp?classID=276
http://www.globalaosen.com/showProducts.asp?classID=277
http://www.globalaosen.com/showProducts.asp?classID=278
http://www.globalaosen.com/showProducts.asp?classID=279
http://www.globalaosen.com/showProducts.asp?classID=280
http://www.globalaosen.com/showProducts.asp?classID=281
http://www.globalaosen.com/showProducts.asp?classID=282
http://www.globalaosen.com/showProducts.asp?classID=283
http://www.globalaosen.com/showProducts.asp?classID=284
http://www.globalaosen.com/showProducts.asp?classID=285
http://www.globalaosen.com/showProducts.asp?classID=286
http://www.globalaosen.com/showProducts.asp?classID=287
http://www.globalaosen.com/showProducts.asp?classID=288
http://www.globalaosen.com/showProducts.asp?classID=289
http://www.globalaosen.com/showProducts.asp?classID=290
http://www.globalaosen.com/showProducts.asp?classID=291
http://www.globalaosen.com/showProducts.asp?classID=292
http://www.globalaosen.com/showProducts.asp?classID=293
http://www.globalaosen.com/showProducts.asp?classID=294
http://www.globalaosen.com/showProducts.asp?classID=295
http://www.globalaosen.com/showProducts.asp?classID=296
http://www.globalaosen.com/showProducts.asp?classID=297
http://www.globalaosen.com/showProducts.asp?classID=298
http://www.globalaosen.com/showProducts.asp?classID=299
http://www.globalaosen.com/showProducts.asp?classID=300
http://www.globalaosen.com/showProducts.asp?classID=301
http://www.globalaosen.com/showProducts.asp?classID=302
http://www.globalaosen.com/showProducts.asp?classID=303
http://www.globalaosen.com/showProducts.asp?classID=304
http://www.globalaosen.com/showProducts.asp?classID=305
http://www.globalaosen.com/showProducts.asp?classID=306
http://www.globalaosen.com/showProducts.asp?classID=307
http://www.globalaosen.com/showProducts.asp?classID=308
http://www.globalaosen.com/showProducts.asp?classID=309
http://www.globalaosen.com/showProducts.asp?classID=310
http://www.globalaosen.com/showProducts.asp?classID=311
http://www.globalaosen.com/showProducts.asp?classID=312
http://www.globalaosen.com/showProducts.asp?classID=313
http://www.globalaosen.com/showProducts.asp?classID=314
http://www.globalaosen.com/showProducts.asp?classID=315
http://www.globalaosen.com/showProducts.asp?classID=316
http://www.globalaosen.com/showProducts.asp?classID=317
http://www.globalaosen.com/showProducts.asp?classID=318
http://www.globalaosen.com/showProducts.asp?classID=319
http://www.globalaosen.com/showProducts.asp?classID=320
http://www.globalaosen.com/showProducts.asp?classID=321
http://www.globalaosen.com/showProducts.asp?classID=322
http://www.globalaosen.com/showProducts.asp?classID=323
http://www.globalaosen.com/showProducts.asp?classID=324
http://www.globalaosen.com/showProducts.asp?classID=325
http://www.globalaosen.com/showProducts.asp?classID=326
http://www.globalaosen.com/showProducts.asp?classID=327
http://www.globalaosen.com/showProducts.asp?classID=328
http://www.globalaosen.com/showProducts.asp?classID=329
http://www.globalaosen.com/showProducts.asp?classID=330
http://www.globalaosen.com/showProducts.asp?classID=331
http://www.globalaosen.com/showProducts.asp?classID=332
http://www.globalaosen.com/showProducts.asp?classID=333
http://www.globalaosen.com/showProducts.asp?classID=334
http://www.globalaosen.com/showProducts.asp?classID=335
http://www.globalaosen.com/showProducts.asp?classID=336
http://www.globalaosen.com/showProducts.asp?classID=337
http://www.globalaosen.com/showProducts.asp?classID=338
http://www.globalaosen.com/showProducts.asp?classID=339
http://www.globalaosen.com/showProducts.asp?classID=340
http://www.globalaosen.com/showProducts.asp?classID=341
http://www.globalaosen.com/showProducts.asp?classID=342
http://www.globalaosen.com/showProducts.asp?classID=343
http://www.globalaosen.com/showProducts.asp?classID=344
http://www.globalaosen.com/showProducts.asp?classID=345
http://www.globalaosen.com/showProducts.asp?classID=346
http://www.globalaosen.com/showProducts.asp?classID=347
http://www.globalaosen.com/showProducts.asp?classID=348
http://www.globalaosen.com/showProducts.asp?classID=349
http://www.globalaosen.com/showProducts.asp?classID=350
http://www.globalaosen.com/showProducts.asp?classID=351
http://www.globalaosen.com/showProducts.asp?classID=352
http://www.globalaosen.com/showProducts.asp?classID=353
http://www.globalaosen.com/showProducts.asp?classID=354
http://www.globalaosen.com/showProducts.asp?classID=355
http://www.globalaosen.com/showProducts.asp?classID=356
http://www.globalaosen.com/showProducts.asp?classID=357
http://www.globalaosen.com/showProducts.asp?classID=358
http://www.globalaosen.com/showProducts.asp?classID=359
http://www.globalaosen.com/showProducts.asp?classID=360
http://www.globalaosen.com/showProducts.asp?classID=361
http://www.globalaosen.com/showProducts.asp?classID=362
http://www.globalaosen.com/showProducts.asp?classID=363
http://www.globalaosen.com/showProducts.asp?classID=364
http://www.globalaosen.com/showProducts.asp?classID=365
http://www.globalaosen.com/showProducts.asp?classID=366
http://www.globalaosen.com/showProducts.asp?classID=367
http://www.globalaosen.com/showProducts.asp?classID=368
http://www.globalaosen.com/showProducts.asp?classID=369
http://www.globalaosen.com/showProducts.asp?classID=370
http://www.globalaosen.com/showProducts.asp?classID=371
http://www.globalaosen.com/showProducts.asp?classID=372
http://www.globalaosen.com/showProducts.asp?classID=373
http://www.globalaosen.com/showProducts.asp?classID=374
http://www.globalaosen.com/showProducts.asp?classID=375
http://www.globalaosen.com/showProducts.asp?classID=376
http://www.globalaosen.com/showProducts.asp?classID=377
http://www.globalaosen.com/showProducts.asp?classID=378
http://www.globalaosen.com/showProducts.asp?classID=379
http://www.globalaosen.com/showProducts.asp?classID=380
http://www.globalaosen.com/showProducts.asp?classID=381
http://www.globalaosen.com/showProducts.asp?classID=382
http://www.globalaosen.com/showProducts.asp?classID=383
http://www.globalaosen.com/showProducts.asp?classID=384
http://www.globalaosen.com/showProducts.asp?classID=385
http://www.globalaosen.com/showProducts.asp?classID=386
http://www.globalaosen.com/showProducts.asp?classID=387
http://www.globalaosen.com/showProducts.asp?classID=388
http://www.globalaosen.com/showProducts.asp?classID=389
http://www.globalaosen.com/showProducts.asp?classID=390
http://www.globalaosen.com/showProducts.asp?classID=391
http://www.globalaosen.com/showProducts.asp?classID=392
http://www.globalaosen.com/showProducts.asp?classID=393
http://www.globalaosen.com/showProducts.asp?classID=394
http://www.globalaosen.com/showProducts.asp?classID=395
http://www.globalaosen.com/showProducts.asp?classID=396
http://www.globalaosen.com/showProducts.asp?classID=397
http://www.globalaosen.com/showProducts.asp?classID=398
http://www.globalaosen.com/showProducts.asp?classID=399
http://www.globalaosen.com/showProducts.asp?classID=400
http://www.globalaosen.com/showProducts.asp?classID=401
http://www.globalaosen.com/showProducts.asp?classID=402
http://www.globalaosen.com/showProducts.asp?classID=403
http://www.globalaosen.com/showProducts.asp?classID=404
http://www.globalaosen.com/showProducts.asp?classID=405
http://www.globalaosen.com/showProducts.asp?classID=406
http://www.globalaosen.com/showProducts.asp?classID=407
http://www.globalaosen.com/showProducts.asp?classID=408
http://www.globalaosen.com/showProducts.asp?classID=409
http://www.globalaosen.com/showProducts.asp?classID=410
http://www.globalaosen.com/showProducts.asp?classID=411
http://www.globalaosen.com/showProducts.asp?classID=412
http://www.globalaosen.com/showProducts.asp?classID=413
http://www.globalaosen.com/showProducts.asp?classID=414
http://www.globalaosen.com/showProducts.asp?classID=415
http://www.globalaosen.com/showProducts.asp?classID=416
http://www.globalaosen.com/showProducts.asp?classID=417
http://www.globalaosen.com/showProducts.asp?classID=418
http://www.globalaosen.com/showProducts.asp?classID=419
http://www.globalaosen.com/showProducts.asp?classID=420
http://www.globalaosen.com/showProducts.asp?classID=421
http://www.globalaosen.com/showProducts.asp?classID=422
http://www.globalaosen.com/showProducts.asp?classID=423
http://www.globalaosen.com/showProducts.asp?classID=424
http://www.globalaosen.com/showProducts.asp?classID=425
http://www.globalaosen.com/showProducts.asp?classID=426
http://www.globalaosen.com/showProducts.asp?classID=427
http://www.globalaosen.com/showProducts.asp?classID=428
http://www.globalaosen.com/showProducts.asp?classID=429
http://www.globalaosen.com/showProducts.asp?classID=430
http://www.globalaosen.com/showProducts.asp?classID=431
http://www.globalaosen.com/showProducts.asp?classID=432
http://www.globalaosen.com/showProducts.asp?classID=433
http://www.globalaosen.com/showProducts.asp?classID=434
http://www.globalaosen.com/showProducts.asp?classID=435
http://www.globalaosen.com/showProducts.asp?classID=436
http://www.globalaosen.com/showProducts.asp?classID=437
http://www.globalaosen.com/showProducts.asp?classID=438
http://www.globalaosen.com/showProducts.asp?classID=439
http://www.globalaosen.com/showProducts.asp?classID=440
http://www.globalaosen.com/showProducts.asp?classID=441
http://www.globalaosen.com/showProducts.asp?classID=442
http://www.globalaosen.com/showProducts.asp?classID=443
http://www.globalaosen.com/showProducts.asp?classID=444
http://www.globalaosen.com/showProducts.asp?classID=445
http://www.globalaosen.com/showProducts.asp?classID=446
http://www.globalaosen.com/showProducts.asp?classID=447
http://www.globalaosen.com/showProducts.asp?classID=448
http://www.globalaosen.com/showProducts.asp?classID=449
http://www.globalaosen.com/showProducts.asp?classID=450
http://www.globalaosen.com/showProducts.asp?classID=451
http://www.globalaosen.com/showProducts.asp?classID=452
http://www.globalaosen.com/showProducts.asp?classID=453
http://www.globalaosen.com/showProducts.asp?classID=454
http://www.globalaosen.com/showProducts.asp?classID=455
http://www.globalaosen.com/showProducts.asp?classID=456
http://www.globalaosen.com/showProducts.asp?classID=457
http://www.globalaosen.com/showProducts.asp?classID=458
http://www.globalaosen.com/showProducts.asp?classID=459
http://www.globalaosen.com/showProducts.asp?classID=460
http://www.globalaosen.com/showProducts.asp?classID=461
http://www.globalaosen.com/showProducts.asp?classID=462
http://www.globalaosen.com/showProducts.asp?classID=463
http://www.globalaosen.com/showProducts.asp?classID=464
http://www.globalaosen.com/showProducts.asp?classID=465
http://www.globalaosen.com/showProducts.asp?classID=466
http://www.globalaosen.com/showProducts.asp?classID=467
http://www.globalaosen.com/showProducts.asp?classID=468
http://www.globalaosen.com/showProducts.asp?classID=469
http://www.globalaosen.com/showProducts.asp?classID=470
http://www.globalaosen.com/showProducts.asp?classID=471
http://www.globalaosen.com/showProducts.asp?classID=472
http://www.globalaosen.com/showProducts.asp?classID=473
http://www.globalaosen.com/showProducts.asp?classID=474
http://www.globalaosen.com/showProducts.asp?classID=475
http://www.globalaosen.com/showProducts.asp?classID=476
http://www.globalaosen.com/showProducts.asp?classID=477
http://www.globalaosen.com/showProducts.asp?classID=478
http://www.globalaosen.com/showProducts.asp?classID=479
http://www.globalaosen.com/showProducts.asp?classID=480
http://www.globalaosen.com/showProducts.asp?classID=481
http://www.globalaosen.com/showProducts.asp?classID=482
http://www.globalaosen.com/showProducts.asp?classID=483
http://www.globalaosen.com/showProducts.asp?classID=484
http://www.globalaosen.com/showProducts.asp?classID=485
http://www.globalaosen.com/showProducts.asp?classID=486
http://www.globalaosen.com/showProducts.asp?classID=487
http://www.globalaosen.com/showProducts.asp?classID=488
http://www.globalaosen.com/showProducts.asp?classID=489
http://www.globalaosen.com/showProducts.asp?classID=490
http://www.globalaosen.com/showProducts.asp?classID=491
http://www.globalaosen.com/showProducts.asp?classID=492
http://www.globalaosen.com/showProducts.asp?classID=493
http://www.globalaosen.com/showProducts.asp?classID=494
http://www.globalaosen.com/showProducts.asp?classID=495
http://www.globalaosen.com/showProducts.asp?classID=496
http://www.globalaosen.com/showProducts.asp?classID=497
http://www.globalaosen.com/showProducts.asp?classID=498
http://www.globalaosen.com/showProducts.asp?classID=499
http://www.globalaosen.com/showProducts.asp?classID=500
http://www.globalaosen.com/showProducts.asp?classID=501
http://www.globalaosen.com/showProducts.asp?classID=502
http://www.globalaosen.com/showProducts.asp?classID=999
http://www.globalaosen.com/showProducts.asp?classID=1000
http://www.globalaosen.com/showProducts.asp?classID=1001
http://www.globalaosen.com/showProducts.asp?classID=1002
http://www.globalaosen.com/showProducts.asp?classID=1003
http://www.globalaosen.com/showProducts.asp?classID=1004
http://www.globalaosen.com/showProducts.asp?classID=1005
http://www.globalaosen.com/showProducts.asp?classID=1006
http://www.globalaosen.com/showProducts.asp?classID=1007
http://www.globalaosen.com/showProducts.asp?classID=1008
http://www.globalaosen.com/showProducts.asp?classID=1009
http://www.globalaosen.com/showProducts.asp?classID=1010
http://www.globalaosen.com/showProducts.asp?classID=1011
http://www.globalaosen.com/showProducts.asp?classID=1012
http://www.globalaosen.com/showProducts.asp?classID=1013
http://www.globalaosen.com/showProducts.asp?classID=1014
http://www.globalaosen.com/showProducts.asp?classID=1015
http://www.globalaosen.com/showProducts.asp?classID=1016
http://www.globalaosen.com/showProducts.asp?classID=1017
http://www.globalaosen.com/showProducts.asp?classID=1018
http://www.globalaosen.com/showProducts.asp?classID=1019
http://www.globalaosen.com/showProducts.asp?classID=1020
http://www.globalaosen.com/showProducts.asp?classID=1021
http://www.globalaosen.com/showProducts.asp?classID=1022
http://www.globalaosen.com/showProducts.asp?classID=1023
http://www.globalaosen.com/showProducts.asp?classID=1024
http://www.globalaosen.com/showProducts.asp?classID=1025
http://www.globalaosen.com/showProducts.asp?classID=1026
http://www.globalaosen.com/showProducts.asp?classID=1027
http://www.globalaosen.com/showProducts.asp?classID=1028
http://www.globalaosen.com/showProducts.asp?classID=1029
http://www.globalaosen.com/showProducts.asp?classID=1030
http://www.globalaosen.com/showProducts.asp?classID=1031
http://www.globalaosen.com/showProducts.asp?classID=1032
http://www.globalaosen.com/showProducts.asp?classID=1033
http://www.globalaosen.com/showProducts.asp?classID=1034
http://www.globalaosen.com/showProducts.asp?classID=1035
http://www.globalaosen.com/showProducts.asp?classID=1036
http://www.globalaosen.com/showProducts.asp?classID=1037
http://www.globalaosen.com/showProducts.asp?classID=1038
http://www.globalaosen.com/showProducts.asp?classID=1039
http://www.globalaosen.com/showProducts.asp?classID=1040
http://www.globalaosen.com/showProducts.asp?classID=1041
http://www.globalaosen.com/showProducts.asp?classID=1042
http://www.globalaosen.com/showProducts.asp?classID=1043
http://www.globalaosen.com/showProducts.asp?classID=1044
http://www.globalaosen.com/showProducts.asp?classID=1045
http://www.globalaosen.com/showProducts.asp?classID=1046
http://www.globalaosen.com/showProducts.asp?classID=1047
http://www.globalaosen.com/showProducts.asp?classID=1048
http://www.globalaosen.com/showProducts.asp?classID=1049
http://www.globalaosen.com/showProducts.asp?classID=1050
http://www.globalaosen.com/showProducts.asp?classID=1051
http://www.globalaosen.com/showProducts.asp?classID=1052
http://www.globalaosen.com/showProducts.asp?classID=1053
http://www.globalaosen.com/showProducts.asp?classID=1054
http://www.globalaosen.com/showProducts.asp?classID=1055
http://www.globalaosen.com/showProducts.asp?classID=1056
http://www.globalaosen.com/showProducts.asp?classID=1057
http://www.globalaosen.com/showProducts.asp?classID=1058
http://www.globalaosen.com/showProducts.asp?classID=1059
http://www.globalaosen.com/showProducts.asp?classID=1060
http://www.globalaosen.com/showProducts.asp?classID=1061
http://www.globalaosen.com/showProducts.asp?classID=1062
http://www.globalaosen.com/showProducts.asp?classID=1063
http://www.globalaosen.com/showProducts.asp?classID=1064
http://www.globalaosen.com/showProducts.asp?classID=1065
http://www.globalaosen.com/showProducts.asp?classID=1066
http://www.globalaosen.com/showProducts.asp?classID=1067
http://www.globalaosen.com/showProducts.asp?classID=1068
http://www.globalaosen.com/showProducts.asp?classID=1069
http://www.globalaosen.com/showProducts.asp?classID=1070
http://www.globalaosen.com/showProducts.asp?classID=1071
http://www.globalaosen.com/showProducts.asp?classID=1072
http://www.globalaosen.com/showProducts.asp?classID=1073
http://www.globalaosen.com/showProducts.asp?classID=1074
http://www.globalaosen.com/showProducts.asp?classID=1075
http://www.globalaosen.com/showProducts.asp?classID=1076
http://www.globalaosen.com/showProducts.asp?classID=1077
http://www.globalaosen.com/showProducts.asp?classID=1078
http://www.globalaosen.com/showProducts.asp?classID=1079
http://www.globalaosen.com/showProducts.asp?classID=1080
http://www.globalaosen.com/showProducts.asp?classID=1081
http://www.globalaosen.com/showProducts.asp?classID=1082
http://www.globalaosen.com/showProducts.asp?classID=1083
http://www.globalaosen.com/showProducts.asp?classID=1084
http://www.globalaosen.com/showProducts.asp?classID=1085
http://www.globalaosen.com/showProducts.asp?classID=1086
http://www.globalaosen.com/showProducts.asp?classID=1087
http://www.globalaosen.com/showProducts.asp?classID=1088
http://www.globalaosen.com/showProducts.asp?classID=1089
http://www.globalaosen.com/showProducts.asp?classID=1090
http://www.globalaosen.com/showProducts.asp?classID=1091
http://www.globalaosen.com/showProducts.asp?classID=1092
http://www.globalaosen.com/showProducts.asp?classID=1093
http://www.globalaosen.com/showProducts.asp?classID=1094
http://www.globalaosen.com/showProducts.asp?classID=1095
http://www.globalaosen.com/showProducts.asp?classID=1096
http://www.globalaosen.com/showProducts.asp?classID=1097
http://www.globalaosen.com/showProducts.asp?classID=1098
http://www.globalaosen.com/showProducts.asp?classID=1099
http://www.globalaosen.com/showProducts.asp?classID=1100
http://www.globalaosen.com/showProducts.asp?classID=1101
http://www.globalaosen.com/showProducts.asp?classID=1102
http://www.globalaosen.com/showProducts.asp?classID=1103
http://www.globalaosen.com/showProducts.asp?classID=1104
http://www.globalaosen.com/showProducts.asp?classID=1105
http://www.globalaosen.com/showProducts.asp?classID=1106
http://www.globalaosen.com/showProducts.asp?classID=1107
http://www.globalaosen.com/showProducts.asp?classID=1108
http://www.globalaosen.com/showProducts.asp?classID=1109
http://www.globalaosen.com/showProducts.asp?classID=1110
http://www.globalaosen.com/showProducts.asp?classID=1111
http://www.globalaosen.com/showProducts.asp?classID=1112
http://www.globalaosen.com/showProducts.asp?classID=1113
http://www.globalaosen.com/showProducts.asp?classID=1114
http://www.globalaosen.com/showProducts.asp?classID=1115
http://www.globalaosen.com/showProducts.asp?classID=1116
http://www.globalaosen.com/showProducts.asp?classID=1117
http://www.globalaosen.com/showProducts.asp?classID=1118
http://www.globalaosen.com/showProducts.asp?classID=1119
http://www.globalaosen.com/showProducts.asp?classID=1120
http://www.globalaosen.com/showProducts.asp?classID=1121
http://www.globalaosen.com/showProducts.asp?classID=1122
http://www.globalaosen.com/showProducts.asp?classID=1123
http://www.globalaosen.com/showProducts.asp?classID=1124
http://www.globalaosen.com/showProducts.asp?classID=1125
http://www.globalaosen.com/showProducts.asp?classID=1126
http://www.globalaosen.com/showProducts.asp?classID=1127
http://www.globalaosen.com/showProducts.asp?classID=1128
http://www.globalaosen.com/showProducts.asp?classID=1129
http://www.globalaosen.com/showProducts.asp?classID=1130
http://www.globalaosen.com/showProducts.asp?classID=1131
http://www.globalaosen.com/showProducts.asp?classID=1132
http://www.globalaosen.com/showProducts.asp?classID=1133
http://www.globalaosen.com/showProducts.asp?classID=1134
http://www.globalaosen.com/showProducts.asp?classID=991
http://www.globalaosen.com/showProducts.asp?classID=503
http://www.globalaosen.com/showProducts.asp?classID=504
http://www.globalaosen.com/showProducts.asp?classID=505
http://www.globalaosen.com/showProducts.asp?classID=1135
http://www.globalaosen.com/showProducts.asp?classID=506
http://www.globalaosen.com/showProducts.asp?classID=1136
http://www.globalaosen.com/showProducts.asp?classID=507
http://www.globalaosen.com/showProducts.asp?classID=508
http://www.globalaosen.com/showProducts.asp?classID=509
http://www.globalaosen.com/showProducts.asp?classID=1137
http://www.globalaosen.com/showProducts.asp?classID=510
http://www.globalaosen.com/showProducts.asp?classID=511
http://www.globalaosen.com/showProducts.asp?classID=512
http://www.globalaosen.com/showProducts.asp?classID=513
http://www.globalaosen.com/showProducts.asp?classID=514
http://www.globalaosen.com/showProducts.asp?classID=515
http://www.globalaosen.com/showProducts.asp?classID=516
http://www.globalaosen.com/showProducts.asp?classID=517
http://www.globalaosen.com/showProducts.asp?classID=518
http://www.globalaosen.com/showProducts.asp?classID=519
http://www.globalaosen.com/showProducts.asp?classID=520
http://www.globalaosen.com/showProducts.asp?classID=521
http://www.globalaosen.com/showProducts.asp?classID=522
http://www.globalaosen.com/showProducts.asp?classID=523
http://www.globalaosen.com/showProducts.asp?classID=524
http://www.globalaosen.com/showProducts.asp?classID=525
http://www.globalaosen.com/showProducts.asp?classID=526
http://www.globalaosen.com/showProducts.asp?classID=527
http://www.globalaosen.com/showProducts.asp?classID=528
http://www.globalaosen.com/showProducts.asp?classID=529
http://www.globalaosen.com/showProducts.asp?classID=530
http://www.globalaosen.com/showProducts.asp?classID=531
http://www.globalaosen.com/showProducts.asp?classID=532
http://www.globalaosen.com/showProducts.asp?classID=533
http://www.globalaosen.com/showProducts.asp?classID=534
http://www.globalaosen.com/showProducts.asp?classID=535
http://www.globalaosen.com/showProducts.asp?classID=536
http://www.globalaosen.com/showProducts.asp?classID=537
http://www.globalaosen.com/showProducts.asp?classID=538
http://www.globalaosen.com/showProducts.asp?classID=539
http://www.globalaosen.com/showProducts.asp?classID=540
http://www.globalaosen.com/showProducts.asp?classID=541
http://www.globalaosen.com/showProducts.asp?classID=542
http://www.globalaosen.com/showProducts.asp?classID=543
http://www.globalaosen.com/showProducts.asp?classID=544
http://www.globalaosen.com/showProducts.asp?classID=545
http://www.globalaosen.com/showProducts.asp?classID=546
http://www.globalaosen.com/showProducts.asp?classID=547
http://www.globalaosen.com/showProducts.asp?classID=548
http://www.globalaosen.com/showProducts.asp?classID=549
http://www.globalaosen.com/showProducts.asp?classID=550
http://www.globalaosen.com/showProducts.asp?classID=551
http://www.globalaosen.com/showProducts.asp?classID=552
http://www.globalaosen.com/showProducts.asp?classID=553
http://www.globalaosen.com/showProducts.asp?classID=554
http://www.globalaosen.com/showProducts.asp?classID=555
http://www.globalaosen.com/showProducts.asp?classID=1138
http://www.globalaosen.com/showProducts.asp?classID=1139
http://www.globalaosen.com/showProducts.asp?classID=556
http://www.globalaosen.com/showProducts.asp?classID=557
http://www.globalaosen.com/showProducts.asp?classID=558
http://www.globalaosen.com/showProducts.asp?classID=559
http://www.globalaosen.com/showProducts.asp?classID=560
http://www.globalaosen.com/showProducts.asp?classID=561
http://www.globalaosen.com/showProducts.asp?classID=562
http://www.globalaosen.com/showProducts.asp?classID=563
http://www.globalaosen.com/showProducts.asp?classID=564
http://www.globalaosen.com/showProducts.asp?classID=565
http://www.globalaosen.com/showProducts.asp?classID=566
http://www.globalaosen.com/showProducts.asp?classID=567
http://www.globalaosen.com/showProducts.asp?classID=568
http://www.globalaosen.com/showProducts.asp?classID=569
http://www.globalaosen.com/showProducts.asp?classID=570
http://www.globalaosen.com/showProducts.asp?classID=571
http://www.globalaosen.com/showProducts.asp?classID=572
http://www.globalaosen.com/showProducts.asp?classID=573
http://www.globalaosen.com/showProducts.asp?classID=574
http://www.globalaosen.com/showProducts.asp?classID=575
http://www.globalaosen.com/showProducts.asp?classID=576
http://www.globalaosen.com/showProducts.asp?classID=577
http://www.globalaosen.com/showProducts.asp?classID=578
http://www.globalaosen.com/showProducts.asp?classID=579
http://www.globalaosen.com/showProducts.asp?classID=580
http://www.globalaosen.com/showProducts.asp?classID=581
http://www.globalaosen.com/showProducts.asp?classID=582
http://www.globalaosen.com/showProducts.asp?classID=583
http://www.globalaosen.com/showProducts.asp?classID=584
http://www.globalaosen.com/showProducts.asp?classID=585
http://www.globalaosen.com/showProducts.asp?classID=586
http://www.globalaosen.com/showProducts.asp?classID=587
http://www.globalaosen.com/showProducts.asp?classID=588
http://www.globalaosen.com/showProducts.asp?classID=589
http://www.globalaosen.com/showProducts.asp?classID=590
http://www.globalaosen.com/showProducts.asp?classID=591
http://www.globalaosen.com/showProducts.asp?classID=592
http://www.globalaosen.com/showProducts.asp?classID=593
http://www.globalaosen.com/showProducts.asp?classID=1140
http://www.globalaosen.com/showProducts.asp?classID=594
http://www.globalaosen.com/showProducts.asp?classID=595
http://www.globalaosen.com/showProducts.asp?classID=596
http://www.globalaosen.com/showProducts.asp?classID=597
http://www.globalaosen.com/showProducts.asp?classID=598
http://www.globalaosen.com/showProducts.asp?classID=599
http://www.globalaosen.com/showProducts.asp?classID=600
http://www.globalaosen.com/showProducts.asp?classID=601
http://www.globalaosen.com/showProducts.asp?classID=602
http://www.globalaosen.com/showProducts.asp?classID=603
http://www.globalaosen.com/showProducts.asp?classID=604
http://www.globalaosen.com/showProducts.asp?classID=605
http://www.globalaosen.com/showProducts.asp?classID=606
http://www.globalaosen.com/showProducts.asp?classID=607
http://www.globalaosen.com/showProducts.asp?classID=608
http://www.globalaosen.com/showProducts.asp?classID=609
http://www.globalaosen.com/showProducts.asp?classID=610
http://www.globalaosen.com/showProducts.asp?classID=611
http://www.globalaosen.com/showProducts.asp?classID=612
http://www.globalaosen.com/showProducts.asp?classID=613
http://www.globalaosen.com/showProducts.asp?classID=614
http://www.globalaosen.com/showProducts.asp?classID=615
http://www.globalaosen.com/showProducts.asp?classID=616
http://www.globalaosen.com/showProducts.asp?classID=617
http://www.globalaosen.com/showProducts.asp?classID=618
http://www.globalaosen.com/showProducts.asp?classID=619
http://www.globalaosen.com/showProducts.asp?classID=1141
http://www.globalaosen.com/showProducts.asp?classID=620
http://www.globalaosen.com/showProducts.asp?classID=621
http://www.globalaosen.com/showProducts.asp?classID=622
http://www.globalaosen.com/showProducts.asp?classID=623
http://www.globalaosen.com/showProducts.asp?classID=624
http://www.globalaosen.com/showProducts.asp?classID=625
http://www.globalaosen.com/showProducts.asp?classID=626
http://www.globalaosen.com/showProducts.asp?classID=627
http://www.globalaosen.com/showProducts.asp?classID=628
http://www.globalaosen.com/showProducts.asp?classID=629
http://www.globalaosen.com/showProducts.asp?classID=630
http://www.globalaosen.com/showProducts.asp?classID=631
http://www.globalaosen.com/showProducts.asp?classID=632
http://www.globalaosen.com/showProducts.asp?classID=633
http://www.globalaosen.com/showProducts.asp?classID=634
http://www.globalaosen.com/showProducts.asp?classID=635
http://www.globalaosen.com/showProducts.asp?classID=636
http://www.globalaosen.com/showProducts.asp?classID=637
http://www.globalaosen.com/showProducts.asp?classID=638
http://www.globalaosen.com/showProducts.asp?classID=639
http://www.globalaosen.com/showProducts.asp?classID=640
http://www.globalaosen.com/showProducts.asp?classID=641
http://www.globalaosen.com/showProducts.asp?classID=642
http://www.globalaosen.com/showProducts.asp?classID=643
http://www.globalaosen.com/showProducts.asp?classID=644
http://www.globalaosen.com/showProducts.asp?classID=1142
http://www.globalaosen.com/showProducts.asp?classID=645
http://www.globalaosen.com/showProducts.asp?classID=646
http://www.globalaosen.com/showProducts.asp?classID=647
http://www.globalaosen.com/showProducts.asp?classID=648
http://www.globalaosen.com/showProducts.asp?classID=649
http://www.globalaosen.com/showProducts.asp?classID=650
http://www.globalaosen.com/showProducts.asp?classID=651
http://www.globalaosen.com/showProducts.asp?classID=652
http://www.globalaosen.com/showProducts.asp?classID=653
http://www.globalaosen.com/showProducts.asp?classID=654
http://www.globalaosen.com/showProducts.asp?classID=655
http://www.globalaosen.com/showProducts.asp?classID=656
http://www.globalaosen.com/showProducts.asp?classID=657
http://www.globalaosen.com/showProducts.asp?classID=658
http://www.globalaosen.com/showProducts.asp?classID=659
http://www.globalaosen.com/showProducts.asp?classID=660
http://www.globalaosen.com/showProducts.asp?classID=661
http://www.globalaosen.com/showProducts.asp?classID=662
http://www.globalaosen.com/showProducts.asp?classID=663
http://www.globalaosen.com/showProducts.asp?classID=664
http://www.globalaosen.com/showProducts.asp?classID=665
http://www.globalaosen.com/showProducts.asp?classID=666
http://www.globalaosen.com/showProducts.asp?classID=667
http://www.globalaosen.com/showProducts.asp?classID=668
http://www.globalaosen.com/showProducts.asp?classID=669
http://www.globalaosen.com/showProducts.asp?classID=670
http://www.globalaosen.com/showProducts.asp?classID=671
http://www.globalaosen.com/showProducts.asp?classID=672
http://www.globalaosen.com/showProducts.asp?classID=673
http://www.globalaosen.com/showProducts.asp?classID=674
http://www.globalaosen.com/showProducts.asp?classID=675
http://www.globalaosen.com/showProducts.asp?classID=676
http://www.globalaosen.com/showProducts.asp?classID=677
http://www.globalaosen.com/showProducts.asp?classID=678
http://www.globalaosen.com/showProducts.asp?classID=679
http://www.globalaosen.com/showProducts.asp?classID=680
http://www.globalaosen.com/showProducts.asp?classID=681
http://www.globalaosen.com/showProducts.asp?classID=682
http://www.globalaosen.com/showProducts.asp?classID=683
http://www.globalaosen.com/showProducts.asp?classID=684
http://www.globalaosen.com/showProducts.asp?classID=685
http://www.globalaosen.com/showProducts.asp?classID=686
http://www.globalaosen.com/showProducts.asp?classID=1143
http://www.globalaosen.com/showProducts.asp?classID=687
http://www.globalaosen.com/showProducts.asp?classID=688
http://www.globalaosen.com/showProducts.asp?classID=689
http://www.globalaosen.com/showProducts.asp?classID=690
http://www.globalaosen.com/showProducts.asp?classID=691
http://www.globalaosen.com/showProducts.asp?classID=692
http://www.globalaosen.com/showProducts.asp?classID=693
http://www.globalaosen.com/showProducts.asp?classID=694
http://www.globalaosen.com/showProducts.asp?classID=1144
http://www.globalaosen.com/showProducts.asp?classID=1145
http://www.globalaosen.com/showProducts.asp?classID=695
http://www.globalaosen.com/showProducts.asp?classID=696
http://www.globalaosen.com/showProducts.asp?classID=697
http://www.globalaosen.com/showProducts.asp?classID=698
http://www.globalaosen.com/showProducts.asp?classID=699
http://www.globalaosen.com/showProducts.asp?classID=700
http://www.globalaosen.com/showProducts.asp?classID=701
http://www.globalaosen.com/showProducts.asp?classID=702
http://www.globalaosen.com/showProducts.asp?classID=703
http://www.globalaosen.com/showProducts.asp?classID=704
http://www.globalaosen.com/showProducts.asp?classID=705
http://www.globalaosen.com/showProducts.asp?classID=706
http://www.globalaosen.com/showProducts.asp?classID=707
http://www.globalaosen.com/showProducts.asp?classID=708
http://www.globalaosen.com/showProducts.asp?classID=709
http://www.globalaosen.com/showProducts.asp?classID=710
http://www.globalaosen.com/showProducts.asp?classID=711
http://www.globalaosen.com/showProducts.asp?classID=712
http://www.globalaosen.com/showProducts.asp?classID=713
http://www.globalaosen.com/showProducts.asp?classID=714
http://www.globalaosen.com/showProducts.asp?classID=715
http://www.globalaosen.com/showProducts.asp?classID=716
http://www.globalaosen.com/showProducts.asp?classID=717
http://www.globalaosen.com/showProducts.asp?classID=718
http://www.globalaosen.com/showProducts.asp?classID=719
http://www.globalaosen.com/showProducts.asp?classID=720
http://www.globalaosen.com/showProducts.asp?classID=721
http://www.globalaosen.com/showProducts.asp?classID=722
http://www.globalaosen.com/showProducts.asp?classID=723
http://www.globalaosen.com/showProducts.asp?classID=724
http://www.globalaosen.com/showProducts.asp?classID=725
http://www.globalaosen.com/showProducts.asp?classID=726
http://www.globalaosen.com/showProducts.asp?classID=727
http://www.globalaosen.com/showProducts.asp?classID=728
http://www.globalaosen.com/showProducts.asp?classID=729
http://www.globalaosen.com/showProducts.asp?classID=1146
http://www.globalaosen.com/showProducts.asp?classID=1147
http://www.globalaosen.com/showProducts.asp?classID=1148
http://www.globalaosen.com/showProducts.asp?classID=1149
http://www.globalaosen.com/showProducts.asp?classID=1150
http://www.globalaosen.com/showProducts.asp?classID=730
http://www.globalaosen.com/showProducts.asp?classID=731
http://www.globalaosen.com/showProducts.asp?classID=732
http://www.globalaosen.com/showProducts.asp?classID=733
http://www.globalaosen.com/showProducts.asp?classID=1151
http://www.globalaosen.com/showProducts.asp?classID=1152
http://www.globalaosen.com/showProducts.asp?classID=1153
http://www.globalaosen.com/showProducts.asp?classID=1154
http://www.globalaosen.com/showProducts.asp?classID=1155
http://www.globalaosen.com/showProducts.asp?classID=1156
http://www.globalaosen.com/showProducts.asp?classID=1157
http://www.globalaosen.com/showProducts.asp?classID=1158
http://www.globalaosen.com/showProducts.asp?classID=1159
http://www.globalaosen.com/showProducts.asp?classID=1160
http://www.globalaosen.com/showProducts.asp?classID=1162
http://www.globalaosen.com/showProducts.asp?classID=1161
http://www.globalaosen.com/showProducts.asp?classID=1163
http://www.globalaosen.com/showProducts.asp?classID=1164
http://www.globalaosen.com/showProducts.asp?classID=1165
http://www.globalaosen.com/showProducts.asp?classID=1166
http://www.globalaosen.com/showProducts.asp?classID=1167
http://www.globalaosen.com/showProducts.asp?classID=1168
http://www.globalaosen.com/showProducts.asp?classID=1169
http://www.globalaosen.com/showProducts.asp?classID=1170
http://www.globalaosen.com/showProducts.asp?classID=1171
http://www.globalaosen.com/showProducts.asp?classID=1172
http://www.globalaosen.com/showProducts.asp?classID=1173
http://www.globalaosen.com/showProducts.asp?classID=1174
http://www.globalaosen.com/showProducts.asp?classID=1175
http://www.globalaosen.com/showProducts.asp?classID=1176
http://www.globalaosen.com/showProducts.asp?classID=1177
http://www.globalaosen.com/showProducts.asp?classID=1178
http://www.globalaosen.com/showProducts.asp?classID=1179
http://www.globalaosen.com/showProducts.asp?classID=1180
http://www.globalaosen.com/showProducts.asp?classID=1181
http://www.globalaosen.com/showProducts.asp?classID=1182
http://www.globalaosen.com/showProducts.asp?classID=1183
http://www.globalaosen.com/showProducts.asp?classID=1184
http://www.globalaosen.com/showProducts.asp?classID=1185
http://www.globalaosen.com/showProducts.asp?classID=1186
http://www.globalaosen.com/showProducts.asp?classID=1187
http://www.globalaosen.com/showProducts.asp?classID=1188
http://www.globalaosen.com/showProducts.asp?classID=1189
http://www.globalaosen.com/showProducts.asp?classID=1190
http://www.globalaosen.com/showProducts.asp?classID=1191
http://www.globalaosen.com/showProducts.asp?classID=1192
http://www.globalaosen.com/showProducts.asp?classID=1193
http://www.globalaosen.com/showProducts.asp?classID=1194
http://www.globalaosen.com/showProducts.asp?classID=1195
http://www.globalaosen.com/showProducts.asp?classID=1196
http://www.globalaosen.com/showProducts.asp?classID=1197
http://www.globalaosen.com/showProducts.asp?classID=1198
http://www.globalaosen.com/showProducts.asp?classID=1199
http://www.globalaosen.com/showProducts.asp?classID=1200
http://www.globalaosen.com/showProducts.asp?classID=1201
http://www.globalaosen.com/showProducts.asp?classID=1202
http://www.globalaosen.com/showProducts.asp?classID=1203
http://www.globalaosen.com/showProducts.asp?classID=1204
http://www.globalaosen.com/showProducts.asp?classID=1205
http://www.globalaosen.com/showProducts.asp?classID=1206
http://www.globalaosen.com/showProducts.asp?classID=1207
http://www.globalaosen.com/showProducts.asp?classID=1208
http://www.globalaosen.com/showProducts.asp?classID=1209
http://www.globalaosen.com/showProducts.asp?classID=1210
http://www.globalaosen.com/showProducts.asp?classID=1211
http://www.globalaosen.com/showProducts.asp?classID=1212
http://www.globalaosen.com/showProducts.asp?classID=1213
http://www.globalaosen.com/showProducts.asp?classID=1214
http://www.globalaosen.com/showProducts.asp?classID=734
http://www.globalaosen.com/showProducts.asp?classID=735
http://www.globalaosen.com/showProducts.asp?classID=736
http://www.globalaosen.com/showProducts.asp?classID=1216
http://www.globalaosen.com/showProducts.asp?classID=737
http://www.globalaosen.com/showProducts.asp?classID=738
http://www.globalaosen.com/showProducts.asp?classID=1217
http://www.globalaosen.com/showProducts.asp?classID=1218
http://www.globalaosen.com/showProducts.asp?classID=739
http://www.globalaosen.com/showProducts.asp?classID=740
http://www.globalaosen.com/showProducts.asp?classID=741
http://www.globalaosen.com/showProducts.asp?classID=742
http://www.globalaosen.com/showProducts.asp?classID=743
http://www.globalaosen.com/showProducts.asp?classID=744
http://www.globalaosen.com/showProducts.asp?classID=745
http://www.globalaosen.com/showProducts.asp?classID=746
http://www.globalaosen.com/showProducts.asp?classID=747
http://www.globalaosen.com/showProducts.asp?classID=748
http://www.globalaosen.com/showProducts.asp?classID=749
http://www.globalaosen.com/showProducts.asp?classID=750
http://www.globalaosen.com/showProducts.asp?classID=751
http://www.globalaosen.com/showProducts.asp?classID=752
http://www.globalaosen.com/showProducts.asp?classID=753
http://www.globalaosen.com/showProducts.asp?classID=754
http://www.globalaosen.com/showProducts.asp?classID=755
http://www.globalaosen.com/showProducts.asp?classID=756
http://www.globalaosen.com/showProducts.asp?classID=757
http://www.globalaosen.com/showProducts.asp?classID=758
http://www.globalaosen.com/showProducts.asp?classID=759
http://www.globalaosen.com/showProducts.asp?classID=760
http://www.globalaosen.com/showProducts.asp?classID=761
http://www.globalaosen.com/showProducts.asp?classID=762
http://www.globalaosen.com/showProducts.asp?classID=763
http://www.globalaosen.com/showProducts.asp?classID=764
http://www.globalaosen.com/showProducts.asp?classID=765
http://www.globalaosen.com/showProducts.asp?classID=766
http://www.globalaosen.com/showProducts.asp?classID=767
http://www.globalaosen.com/showProducts.asp?classID=768
http://www.globalaosen.com/showProducts.asp?classID=769
http://www.globalaosen.com/showProducts.asp?classID=770
http://www.globalaosen.com/showProducts.asp?classID=771
http://www.globalaosen.com/showProducts.asp?classID=772
http://www.globalaosen.com/showProducts.asp?classID=773
http://www.globalaosen.com/showProducts.asp?classID=774
http://www.globalaosen.com/showProducts.asp?classID=775
http://www.globalaosen.com/showProducts.asp?classID=776
http://www.globalaosen.com/showProducts.asp?classID=777
http://www.globalaosen.com/showProducts.asp?classID=778
http://www.globalaosen.com/showProducts.asp?classID=779
http://www.globalaosen.com/showProducts.asp?classID=780
http://www.globalaosen.com/showProducts.asp?classID=781
http://www.globalaosen.com/showProducts.asp?classID=782
http://www.globalaosen.com/showProducts.asp?classID=783
http://www.globalaosen.com/showProducts.asp?classID=784
http://www.globalaosen.com/showProducts.asp?classID=785
http://www.globalaosen.com/showProducts.asp?classID=786
http://www.globalaosen.com/showProducts.asp?classID=787
http://www.globalaosen.com/showProducts.asp?classID=788
http://www.globalaosen.com/showProducts.asp?classID=789
http://www.globalaosen.com/showProducts.asp?classID=790
http://www.globalaosen.com/showProducts.asp?classID=791
http://www.globalaosen.com/showProducts.asp?classID=792
http://www.globalaosen.com/showProducts.asp?classID=793
http://www.globalaosen.com/showProducts.asp?classID=794
http://www.globalaosen.com/showProducts.asp?classID=795
http://www.globalaosen.com/showProducts.asp?classID=796
http://www.globalaosen.com/showProducts.asp?classID=797
http://www.globalaosen.com/showProducts.asp?classID=798
http://www.globalaosen.com/showProducts.asp?classID=799
http://www.globalaosen.com/showProducts.asp?classID=800
http://www.globalaosen.com/showProducts.asp?classID=801
http://www.globalaosen.com/showProducts.asp?classID=802
http://www.globalaosen.com/showProducts.asp?classID=803
http://www.globalaosen.com/showProducts.asp?classID=804
http://www.globalaosen.com/showProducts.asp?classID=805
http://www.globalaosen.com/showProducts.asp?classID=806
http://www.globalaosen.com/showProducts.asp?classID=807
http://www.globalaosen.com/showProducts.asp?classID=808
http://www.globalaosen.com/showProducts.asp?classID=809
http://www.globalaosen.com/showProducts.asp?classID=810
http://www.globalaosen.com/showProducts.asp?classID=811
http://www.globalaosen.com/showProducts.asp?classID=812
http://www.globalaosen.com/showProducts.asp?classID=813
http://www.globalaosen.com/showProducts.asp?classID=814
http://www.globalaosen.com/showProducts.asp?classID=815
http://www.globalaosen.com/showProducts.asp?classID=816
http://www.globalaosen.com/showProducts.asp?classID=817
http://www.globalaosen.com/showProducts.asp?classID=1215
http://www.globalaosen.com/showProducts.asp?classID=818
http://www.globalaosen.com/showProducts.asp?classID=819
http://www.globalaosen.com/showProducts.asp?classID=820
http://www.globalaosen.com/showProducts.asp?classID=821
http://www.globalaosen.com/showProducts.asp?classID=822
http://www.globalaosen.com/showProducts.asp?classID=823
http://www.globalaosen.com/showProducts.asp?classID=824
http://www.globalaosen.com/showProducts.asp?classID=825
http://www.globalaosen.com/showProducts.asp?classID=826
http://www.globalaosen.com/showProducts.asp?classID=827
http://www.globalaosen.com/showProducts.asp?classID=828
http://www.globalaosen.com/showProducts.asp?classID=829
http://www.globalaosen.com/showProducts.asp?classID=830
http://www.globalaosen.com/showProducts.asp?classID=831
http://www.globalaosen.com/showProducts.asp?classID=832
http://www.globalaosen.com/showProducts.asp?classID=833
http://www.globalaosen.com/showProducts.asp?classID=834
http://www.globalaosen.com/showProducts.asp?classID=835
http://www.globalaosen.com/showProducts.asp?classID=836
http://www.globalaosen.com/showProducts.asp?classID=837
http://www.globalaosen.com/showProducts.asp?classID=838
http://www.globalaosen.com/showProducts.asp?classID=839
http://www.globalaosen.com/showProducts.asp?classID=840
http://www.globalaosen.com/showProducts.asp?classID=841
http://www.globalaosen.com/showProducts.asp?classID=842
http://www.globalaosen.com/showProducts.asp?classID=843
http://www.globalaosen.com/showProducts.asp?classID=844
http://www.globalaosen.com/showProducts.asp?classID=845
http://www.globalaosen.com/showProducts.asp?classID=846
http://www.globalaosen.com/showProducts.asp?classID=847
http://www.globalaosen.com/showProducts.asp?classID=848
http://www.globalaosen.com/showProducts.asp?classID=849
http://www.globalaosen.com/showProducts.asp?classID=850
http://www.globalaosen.com/showProducts.asp?classID=851
http://www.globalaosen.com/showProducts.asp?classID=852
http://www.globalaosen.com/showProducts.asp?classID=853
http://www.globalaosen.com/showProducts.asp?classID=854
http://www.globalaosen.com/showProducts.asp?classID=855
http://www.globalaosen.com/showProducts.asp?classID=856
http://www.globalaosen.com/showProducts.asp?classID=857
http://www.globalaosen.com/showProducts.asp?classID=858
http://www.globalaosen.com/showProducts.asp?classID=859
http://www.globalaosen.com/showProducts.asp?classID=860
http://www.globalaosen.com/showProducts.asp?classID=861
http://www.globalaosen.com/showProducts.asp?classID=862
http://www.globalaosen.com/showProducts.asp?classID=863
http://www.globalaosen.com/showProducts.asp?classID=864
http://www.globalaosen.com/showProducts.asp?classID=865
http://www.globalaosen.com/showProducts.asp?classID=866
http://www.globalaosen.com/showProducts.asp?classID=867
http://www.globalaosen.com/showProducts.asp?classID=1219
http://www.globalaosen.com/showProducts.asp?classID=868
http://www.globalaosen.com/showProducts.asp?classID=869
http://www.globalaosen.com/showProducts.asp?classID=870
http://www.globalaosen.com/showProducts.asp?classID=871
http://www.globalaosen.com/showProducts.asp?classID=872
http://www.globalaosen.com/showProducts.asp?classID=873
http://www.globalaosen.com/showProducts.asp?classID=874
http://www.globalaosen.com/showProducts.asp?classID=875
http://www.globalaosen.com/showProducts.asp?classID=876
http://www.globalaosen.com/showProducts.asp?classID=877
http://www.globalaosen.com/showProducts.asp?classID=878
http://www.globalaosen.com/showProducts.asp?classID=879
http://www.globalaosen.com/showProducts.asp?classID=880
http://www.globalaosen.com/showProducts.asp?classID=881
http://www.globalaosen.com/showProducts.asp?classID=882
http://www.globalaosen.com/showProducts.asp?classID=883
http://www.globalaosen.com/showProducts.asp?classID=884
http://www.globalaosen.com/showProducts.asp?classID=885
http://www.globalaosen.com/showProducts.asp?classID=886
http://www.globalaosen.com/showProducts.asp?classID=887
http://www.globalaosen.com/showProducts.asp?classID=888
http://www.globalaosen.com/showProducts.asp?classID=889
http://www.globalaosen.com/showProducts.asp?classID=890
http://www.globalaosen.com/showProducts.asp?classID=891
http://www.globalaosen.com/showProducts.asp?classID=892
http://www.globalaosen.com/showProducts.asp?classID=893
http://www.globalaosen.com/showProducts.asp?classID=894
http://www.globalaosen.com/showProducts.asp?classID=895
http://www.globalaosen.com/showProducts.asp?classID=896
http://www.globalaosen.com/showProducts.asp?classID=897
http://www.globalaosen.com/showProducts.asp?classID=898
http://www.globalaosen.com/showProducts.asp?classID=899
http://www.globalaosen.com/showProducts.asp?classID=900
http://www.globalaosen.com/showProducts.asp?classID=901
http://www.globalaosen.com/showProducts.asp?classID=902
http://www.globalaosen.com/showProducts.asp?classID=903
http://www.globalaosen.com/showProducts.asp?classID=904
http://www.globalaosen.com/showProducts.asp?classID=905
http://www.globalaosen.com/showProducts.asp?classID=906
http://www.globalaosen.com/showProducts.asp?classID=907
http://www.globalaosen.com/showProducts.asp?classID=908
http://www.globalaosen.com/showProducts.asp?classID=909
http://www.globalaosen.com/showProducts.asp?classID=910
http://www.globalaosen.com/showProducts.asp?classID=911
http://www.globalaosen.com/showProducts.asp?classID=912
http://www.globalaosen.com/showProducts.asp?classID=913
http://www.globalaosen.com/showProducts.asp?classID=914
http://www.globalaosen.com/showProducts.asp?classID=915
http://www.globalaosen.com/showProducts.asp?classID=916
http://www.globalaosen.com/showProducts.asp?classID=917
http://www.globalaosen.com/showProducts.asp?classID=918
http://www.globalaosen.com/showProducts.asp?classID=919
http://www.globalaosen.com/showProducts.asp?classID=920
http://www.globalaosen.com/showProducts.asp?classID=921
http://www.globalaosen.com/showProducts.asp?classID=922
http://www.globalaosen.com/showProducts.asp?classID=923
http://www.globalaosen.com/showProducts.asp?classID=924
http://www.globalaosen.com/showProducts.asp?classID=925
http://www.globalaosen.com/showProducts.asp?classID=926
http://www.globalaosen.com/showProducts.asp?classID=927
http://www.globalaosen.com/showProducts.asp?classID=928
http://www.globalaosen.com/showProducts.asp?classID=929
http://www.globalaosen.com/showProducts.asp?classID=930
http://www.globalaosen.com/showProducts.asp?classID=931
http://www.globalaosen.com/showProducts.asp?classID=932
http://www.globalaosen.com/showProducts.asp?classID=933
http://www.globalaosen.com/showProducts.asp?classID=934
http://www.globalaosen.com/showProducts.asp?classID=935
http://www.globalaosen.com/showProducts.asp?classID=936
http://www.globalaosen.com/showProducts.asp?classID=937
http://www.globalaosen.com/showProducts.asp?classID=938
http://www.globalaosen.com/showProducts.asp?classID=939
http://www.globalaosen.com/showProducts.asp?classID=940
http://www.globalaosen.com/showProducts.asp?classID=941
http://www.globalaosen.com/showProducts.asp?classID=1220
http://www.globalaosen.com/showProducts.asp?classID=942
http://www.globalaosen.com/showProducts.asp?classID=943
http://www.globalaosen.com/showProducts.asp?classID=944
http://www.globalaosen.com/showProducts.asp?classID=945
http://www.globalaosen.com/showProducts.asp?classID=946
http://www.globalaosen.com/showProducts.asp?classID=947
http://www.globalaosen.com/showProducts.asp?classID=948
http://www.globalaosen.com/showProducts.asp?classID=949
http://www.globalaosen.com/showProducts.asp?classID=950
http://www.globalaosen.com/showProducts.asp?classID=951
http://www.globalaosen.com/showProducts.asp?classID=952
http://www.globalaosen.com/showProducts.asp?classID=953
http://www.globalaosen.com/showProducts.asp?classID=954
http://www.globalaosen.com/showProducts.asp?classID=955
http://www.globalaosen.com/showProducts.asp?classID=956

)
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
				@total_page = 1 if @total_page == 0
				puts @total_page.to_s + "pages"
                if @total_page.nil?
                    puts 'Can not get total page'
                    exit
                end #if

            end # get_total_page

            def output_content              
				@url_lists.each_with_index do |url, i|
					puts "#{i} -- #{url}"
					ContentWorker.new(url).build_content do |cc|
						@file_to_write.puts "#{cc}"
						#@file_to_write.puts '*' * 40
					end # build_content
					
						

                end #times
            end #output_content

    end #Runner

end #SanLv

include SanLv

id = 1111

Runner.go id
 