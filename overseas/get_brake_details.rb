﻿#encoding: UTF-8
require 'rubygems'
require 'mongoid'
require 'nokogiri'
require 'open-uri'
require 'pp'



Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end

ENV['MONGOID_ENV'] = 'aap'

Mongoid.load!("config/mongoid.yml")
class String
    def br_to_new_line
        self.gsub('<br>', "\n")
    end
    def n_to_nil
        self.gsub('\n', "")
    end	
    def strip_tag
        self.gsub(%r[<[^>]*>], '').gsub(/\t|\n|\r/, ' ')
    end
end #String
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


  def safe_open(url, retries = 5, sleep_time = 0.42,  headers = {})
    begin  
      html = open(url).read  
		rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
      puts $!  
      retries -= 1  
      if retries > 0  
        sleep sleep_time and retry  
      else  
				#logger.error($!)
				#错误日志
        #TODO Logging..  
      end  
    end
  end
  

def create_file_to_write
	file_path = File.join('.', "aap-#{Time.now.to_formatted_s(:number) }.txt")
	@file_to_write = IoFactory.init(file_path)
end #create_file_to_write

create_file_to_write

def get_urls
	@baseurl = "http://shop.advanceautoparts.com/webapp/wcs/stores/servlet/PartListCmd?storeId=10151&langId=-1&catalogId=10051&vehicleIdSearch=-1&isAllVehicle=true&navigationPath=L1*14921|L2*16462&sortBy=5&categoryId=16462&fromCategory=yes&pageId=ajaxPartList&category=&keywords=brake-drums-rotors&l1_categoryId=16462&l2_categoryId=&partType=&beginIndex="
	@end = "&pageSize=50"
	1.times do |i|
		beginIndex = i * 50
		url = "#{@baseurl}beginIndex#{@end}"
		url = URI.parse(URI.encode(url))
		@listdoc = Nokogiri::HTML(open(url).read.strip) 
		@listdoc.xpath("//h1").each do |row|
			
			href = row.at_xpath('a[1]/@href')
			aap = Aap.find_or_create_by(:title => title, :part_no => part_no)
			puts row.at_xpath('a[1]/@href')
			
		end
	end
end
#get_urls
#return
#http://shop.advanceautoparts.com/webapp/wcs/stores/servlet/PartListCmd?storeId=10151&langId=-1&catalogId=10051&vehicleIdSearch=-1&isAllVehicle=true&navigationPath=L1*14921|L2*16462&sortBy=5&categoryId=16462&fromCategory=yes&pageId=ajaxPartList&category=&keywords=brake-drums-rotors&l1_categoryId=16462&l2_categoryId=&partType=&beginIndex=140&pageSize=100

#http://shop.advanceautoparts.com/webapp/wcs/stores/servlet/category_brake-drums-rotors_16462

#@url ="http://shop.advanceautoparts.com/webapp/wcs/stores/servlet/product_brake-rotor--front-wearever_5670068-p"


production_ids = %w(
YH145250
YH141530
YH145158
YH145259
YH145265
YH145150
YH145155
YH141453
YH145350
YH145582
YH145146
YH145050
YH145308
YH141903
YH145147
YH145381
YH141602
YH145180
YH145260
YH145152
YH141471
YH145441
YH145075
YH145254
YH141868
YH145314
YH141604
YH145153
YH145258
YH145521
YH145274
YH145182
YH145294
YH145311
YH145527
YH145316
YH145313
YH145043
YH145076
YH145301
YH145304
YH145282
YH145234
YH145344
YH141869
YH145358
YH145287
YH145519
YH145365
YH145052
YH145273
YH141635
YH145419
YH145329
YH145266
YH145528
YH145064
YH145299
YH141263
YH145563
YH145244
YH145398
YH141829
YH145241
YH145057
YH145253
YH141581
YH145383
YH145229
YH141893
YH141723
YH141724
YH141849
YH145276
YH145310
YH145518
YH145207
YH145471
YH145041
YH145362
YH145198
YH145063
YH145238
YH145235
YH145251
YH141586
YH145654
YH145078
YH145406
YH145261
YH145405
YH145249
YH140385
YH140451
YH140731
YH141261
YH141940
YH141477
YH145291
YH145341
YH145667
YH141908
YH145456
YH145576
YH145326
YH145686
YH141911
YH145040
YH141474
YH141818
YH141892
YH141792
YH145239
YH141770
YH145455
YH145342
YH141576
YH145452
YH145359
YH145051
YH145564
YH141400
YH141464
YH145285
YH141901
YH145367
YH145283
YH145044
YH141379
YH145137
YH145442
YH145583
YH145315
YH141513
YH145339
YH145140
YH145628
YH141906
YH145142
YH145112
YH145191
YH141845
YH145298
YH145220
YH145233
YH141726
YH145652
YH141902
YH145071
YH141907
YH145353
YH145567
YH145414
YH145189
YH141067
YH145109
YH145534
YH145305
YH145411
YH145000
YH141441
YH145231
YH145650
YH145499
YH145478
YH141811
YH141233
YH145468
YH145497
YH145532
YH141745
YH145559
YH141921
YH141264
YH145625
YH145393
YH145617
YH145023
YH145297
YH145535
YH141711
YH145376
YH145684
YH145473
YH145566
YH145509
YH145317
YH145048
YH145280
YH145537
YH145275
YH145397
YH145247
YH141698
YH145002
YH145399
YH145270
YH145330
YH145343
YH145433
YH141214
YH145454
YH145227
YH141785
YH145067
YH145498
YH145221
YH145469
YH145325
YH145651
YH145049
YH145324
YH145403
YH145549
YH145656
YH145055
YH141692
YH145666
YH145237
YH145340
YH141942
YH145047
YH145026
YH145300
YH141401
YH141786
YH141547
YH141846
YH141621
YH145134
YH145364
YH145584
YH145423
YH145296
YH145357
YH145303
YH145729
YH141905
YH145010
YH141523
YH145263
YH145245
YH145328
YH141447
YH145400
YH145236
YH145429
YH141900
YH145494
YH145458
YH145614
YH145012
YH141408
YH141634
YH145409
YH145472
YH145507
YH145496
YH145597
YH145536
YH145133
YH141454
YH145581
YH145077
YH145504
YH145306
YH145202
YH145290
YH141941
YH145181
YH141043
YH145377
YH145668
YH145278
YH145420
YH145284
YH145292
YH145338
YH145079
YH145060
YH145619
YH141381
YH145524
YH141195
YH141815
YH145138
YH145268
YH145417
YH141578
YH141800
YH145309
YH145066
YH145585
YH145620
YH145571
YH145141
YH145734
YH145269
YH145550
YH145070
YH145382
YH145196
YH145604
YH145107
YH145145
YH145673
YH141577
YH145602
YH141744
YH145255
YH145457
YH145401
YH141505
YH141514
YH145422
YH141741
YH141376
YH145678
YH141574
YH141923
YH145425
YH141176
YH141918
YH145603
YH145395
YH141482
YH141088
YH141292
YH145460
YH145445
YH141545
YH145606
YH145069
YH145197
YH145267
YH145605
YH140697
YH140532
YH140570
YH140502
YH140659
YH140670
YH140690
YH140610
YH140800
YH140623
YH140762
YH140673
YH140540
YH140660
YH140597
YH140508
YH140484
YH140517
YH140454
YH140461
YH140767
YH140798
YH140452
YH140799
YH140745
YH140681
YH140766
YH140622
YH140738
YH145080
YH145538
YH145402
YH141947
YH141442
YH145323
YH145607
YH145201
YH141431
YH141605
YH141216
YH145480
YH145449
YH145612
YH145593
YH141487
YH145523
YH145187
YH141199
YH141777
YH145832
YH145413
YH145562
YH145293
YH145476
YH145653
YH141880
YH141572
YH145613
YH145440
YH145577
YH141194
YH141201
YH145264
YH145446
YH145200
YH145657
YH145139
YH141445
YH141554
YH145256
YH141710
YH145453
YH145059
YH141405
YH141265
YH141301
YH145412
YH145428
YH145444
YH141504
YH145121
YH145475
YH145568
YH141840
YH145674
YH145596
YH141382
YH145726
YH145371
YH141169
YH145886
YH145370
YH145372
YH141888
YH145378
YH145385
YH145765
YH141863
YH145379
YH145608
YH145021
YH145522
YH145846
YH145474
YH145624
YH141816
YH145163
YH145600
YH141857
YH145548
YH145547
YH141424
YH140761
YH140753
YH140658
YH140557
YH140385
YH140743
YH140664
YH140581
YH140699
YH140708
YH140717
YH140669
YH140490
YH140732
YH140675
YH140324
YH140602
YH140254
YH140583
YH141715
YH145525
YH145009
YH141186
YH141848
YH141398
YH145594
YH145230
YH145616
YH141220
YH145216
YH145312
YH145043
YH141673
YH145569
YH145520
YH141667
YH141847
YH141425
YH141642
YH141817
YH145081
YH145693
YH145240
YH141895
YH141502
YH145319
YH141633
YH145120
YH145032
YH145271
YH141389
YH141380
YH141443
YH141916
YH141283
YH145526
YH141528
YH141632
YH145410
YH141752
YH141797
YH145610
YH145421
YH141420
YH141917
YH145539
YH145380
YH141738
YH145366
YH141898
YH145335
YH145408
YH141631
YH145246
YH141934
YH141776
YH140630
YH140671
YH140371
YH140484
YH140449
YH140543
YH140545
)

def  get_details(doc, url)
	@doc = doc
	puts @doc.at_xpath('//title/text()')
	puts part_no = @doc.at_xpath('//div[@id= "prod-info-block-left"]/table/tr/td[@class = "table-prod-info-block"]/text()').to_s.strip
	puts title = @doc.at_xpath('//h1/text()').to_s.strip
	puts product_id = @doc.at_xpath('//a[@id = "checkFit"]/@name').to_s.strip
	
	aap = Aap.find_or_create_by(:title => title, :part_no => part_no)
	aap.product_id = product_id
	aap.url = url
	
	paras =  []
	@doc.xpath('//div[@id= "fragment-2"]/table/tr').each_with_index do |row, i|
		para = Parameter.new()
		para.name = row.at_xpath('td[1]/text()').to_s.strip
		para.value = row.at_xpath('td[2]/text()').to_s.strip
		
		paras << para
	end
	
	aap.parameters = paras
	aap.save()
	
end
length = production_ids.length

production_ids.each_with_index do |item , i|
	url = "http://shop.advanceautoparts.com/webapp/wcs/stores/servlet/PartSearchCmd?storeId=10151&catalogId=10051&pageId=partTypeList&suggestion=&actionSrc=Form&langId=-1&searchTerm=#{item.downcase()}&vehicleIdSearch=-1&searchedFrom=header"
#production_ids.each_with_index do |item , i|
#	url = item
	url =URI.parse(URI.encode(url))
	html_stream = safe_open(url , retries = 3, sleep_time = 0.42, headers = {})
	doc = Nokogiri::HTML(html_stream) 
	get_details(doc, url)
	puts "#{i}/#{length}"

end