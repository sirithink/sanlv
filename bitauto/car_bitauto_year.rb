﻿#encoding: utf-8
require 'rubygems'
require 'open-uri'
require 'nokogiri'

class String
    def br_to_new_line
        self.gsub('<br>', "\n")
    end
    def n_to_nil
        self.gsub('\n', "")
    end	
    def strip_tag
        self.gsub(%r[<[^>]*>], '')
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

def create_file_to_write
	file_path = File.join('.', '1all_brand_year_list.txt')
	@file_to_write = IoFactory.init(file_path)
end #create_file_to_write

create_file_to_write

@url_items = %w(http://car.bitauto.com/yiqiaodi/
http://car.bitauto.com/aodi/
http://car.bitauto.com/asidunmading/
http://car.bitauto.com/aerfaluomiou/
http://car.bitauto.com/acschnitzer-20194/
http://car.bitauto.com/shanghaitongyongbieke/
http://car.bitauto.com/bieke/
http://car.bitauto.com/biyadi/
http://car.bitauto.com/huachenbaoma/
http://car.bitauto.com/baoma/
http://car.bitauto.com/dongfengbentian/
http://car.bitauto.com/guangqibentian/
http://car.bitauto.com/bentian/
http://car.bitauto.com/beijingbenchi/
http://car.bitauto.com/fujianbenchi/
http://car.bitauto.com/benchi/
http://car.bitauto.com/dongfengbiaozhi/
http://car.bitauto.com/biaozhi/
http://car.bitauto.com/baoshijie/
http://car.bitauto.com/beijingqiche/
http://car.bitauto.com/yiqibenteng/
http://car.bitauto.com/baojun/
http://car.bitauto.com/beiqi/
http://car.bitauto.com/bujiadi/
http://car.bitauto.com/binli/
http://car.bitauto.com/weiwang/
http://car.bitauto.com/babosi/
http://car.bitauto.com/baofeili/
http://car.bitauto.com/baolong/
http://car.bitauto.com/changcheng/
http://car.bitauto.com/changanjiaoche/
http://car.bitauto.com/changanshangyongche/
http://car.bitauto.com/changfengyangzi/
http://car.bitauto.com/changfengliebao/
http://car.bitauto.com/changhe/
http://car.bitauto.com/shanghaidazhong/
http://car.bitauto.com/yiqidazhong/
http://car.bitauto.com/dazhong/
http://car.bitauto.com/dongnan/
http://car.bitauto.com/fengxing/
http://car.bitauto.com/dongfeng/
http://car.bitauto.com/dongfengyuan/
http://car.bitauto.com/fengshen/
http://car.bitauto.com/dongnandaoqi/
http://car.bitauto.com/daoqi/
http://car.bitauto.com/ds-20193/
http://car.bitauto.com/datong-20175/
http://car.bitauto.com/dadi/
http://car.bitauto.com/changanfute/
http://car.bitauto.com/fute/
http://car.bitauto.com/guangqifengtian/
http://car.bitauto.com/tianjinyiqifengtian/
http://car.bitauto.com/fengtian/
http://car.bitauto.com/guangqifeiyate/
http://car.bitauto.com/feiyate/
http://car.bitauto.com/falali/
http://car.bitauto.com/futianqiche/
http://car.bitauto.com/ouhui/
http://car.bitauto.com/fudi/
http://car.bitauto.com/huaxiangfuqi/
http://car.bitauto.com/guangqi/
http://car.bitauto.com/jiao/
http://car.bitauto.com/gmc/
http://car.bitauto.com/guanggang/
http://car.bitauto.com/guangqiriye/
http://car.bitauto.com/haima/
http://car.bitauto.com/huatai/
http://car.bitauto.com/hanma/
http://car.bitauto.com/hafei/
http://car.bitauto.com/fushida/
http://car.bitauto.com/huanghaiqiche/
http://car.bitauto.com/hongqi/
http://car.bitauto.com/huapu/
http://car.bitauto.com/haige/
http://car.bitauto.com/shanghaihuizhong/
http://car.bitauto.com/hengtianqiche/
http://car.bitauto.com/hangtianyuantong/
http://car.bitauto.com/jianghuai/
http://car.bitauto.com/anchi/
http://car.bitauto.com/jianghuaikeche/
http://car.bitauto.com/quanqiuying/
http://car.bitauto.com/jipu/
http://car.bitauto.com/dihao/
http://car.bitauto.com/shanghaiyinglun/
http://car.bitauto.com/huachenjinbei/
http://car.bitauto.com/jiebao/
http://car.bitauto.com/jiangling/
http://car.bitauto.com/jiangnan/
http://car.bitauto.com/dajinlong/
http://car.bitauto.com/junfeng/
http://car.bitauto.com/jiulongshangwuche/
http://car.bitauto.com/jinlvkeche/
http://car.bitauto.com/shanghaitongyongkaidilake/
http://car.bitauto.com/kaidilake/
http://car.bitauto.com/dongnankelaisile/
http://car.bitauto.com/kelaisile/
http://car.bitauto.com/kairui/
http://car.bitauto.com/kenisaige/
http://car.bitauto.com/changanlingmu/
http://car.bitauto.com/changhelingmu/
http://car.bitauto.com/lingmu/
http://car.bitauto.com/luhu/
http://car.bitauto.com/leikesasi/
http://car.bitauto.com/lifan/
http://car.bitauto.com/lanbojini/
http://car.bitauto.com/leinuo/
http://car.bitauto.com/qingnianlianhua/
http://car.bitauto.com/lianhuaqingnian/
http://car.bitauto.com/lufeng/
http://car.bitauto.com/laosilaisi/
http://car.bitauto.com/linken/
http://car.bitauto.com/linian-20177/
http://car.bitauto.com/lianhua/
http://car.bitauto.com/lanqiya/
http://car.bitauto.com/changanmazida/
http://car.bitauto.com/yiqimazida/
http://car.bitauto.com/mazida/
http://car.bitauto.com/shangqimingjue/
http://car.bitauto.com/minimini/
http://car.bitauto.com/maibahe/
http://car.bitauto.com/mashaladi/
http://car.bitauto.com/maikailun/
http://car.bitauto.com/meiya/
http://car.bitauto.com/nazhijie/
http://car.bitauto.com/ouge/
http://car.bitauto.com/oubao/
http://car.bitauto.com/oulang/
http://car.bitauto.com/dongfengyuedaqiya/
http://car.bitauto.com/qiya/
http://car.bitauto.com/qirui/
http://car.bitauto.com/qichen/
http://car.bitauto.com/qingling/
http://car.bitauto.com/dongfengrichan/
http://car.bitauto.com/zhengzhourichan/
http://car.bitauto.com/richan/
http://car.bitauto.com/shangqirongwei/
http://car.bitauto.com/ruiqi/
http://car.bitauto.com/shanghaidazhongsikeda/
http://car.bitauto.com/sikeda/
http://car.bitauto.com/dongnansanling/
http://car.bitauto.com/changfengsanling/
http://car.bitauto.com/sanling/
http://car.bitauto.com/sibalu/
http://car.bitauto.com/simatesmart/
http://car.bitauto.com/shuanglong/
http://car.bitauto.com/shuanghuan/
http://car.bitauto.com/sabo/
http://car.bitauto.com/shijue/
http://car.bitauto.com/tianma/
http://car.bitauto.com/wuling/
http://car.bitauto.com/changanwoerwo/
http://car.bitauto.com/woerwo/
http://car.bitauto.com/weilin/
http://car.bitauto.com/beijingxiandai/
http://car.bitauto.com/xiandai/
http://car.bitauto.com/shanghaitongyongxuefolan/
http://car.bitauto.com/xuefolan/
http://car.bitauto.com/dongfengxuetielong/
http://car.bitauto.com/xuetielong/
http://car.bitauto.com/xiyate/
http://car.bitauto.com/xingkete/
http://car.bitauto.com/xinkai/
http://car.bitauto.com/dadi-10014/
http://car.bitauto.com/tianjinyiqi/
http://car.bitauto.com/yiqijiqi/
http://car.bitauto.com/yiqiqingxingqiche/
http://car.bitauto.com/yiqitongyong/
http://car.bitauto.com/yingfeinidi/
http://car.bitauto.com/yema/
http://car.bitauto.com/yongyuanqicheufo/
http://car.bitauto.com/nanjingyiweike/
http://car.bitauto.com/yutong-20190/
http://car.bitauto.com/youyi-20188/
http://car.bitauto.com/huachenzhonghua/
http://car.bitauto.com/zhongtai/
http://car.bitauto.com/zhongxing/
http://car.bitauto.com/zhongouqiche/
http://car.bitauto.com/zhongkehuabei/
http://car.bitauto.com/zhongshun/
)

@url_items.each_with_index do |url, u|
	html_stream = open(url).read.strip
	@doc = Nokogiri::HTML(html_stream)
	rows = @doc.xpath('//div[@id = "seriallist"]//dd/p/b/a/@href')
	@totle = rows.length

	rows.each_with_index do |row, i|
		puts "process:#{u}/179-#{i}/#{@totle}"
		@doc = Nokogiri::HTML(open("http://car.bitauto.com#{row}").read.strip) 
		lists = @doc.xpath('//em[@class = "h3_spcar"]//a/@href')
		lists.each do |a|
			@file_to_write.puts "http://car.bitauto.com#{a}"
		end
  
	  #@file_to_write.puts  "http://car.bitauto.com#{row.at_xpath("div/a[1]/@href")}"
	  

	  #puts row.to_s.strip_tag.strip
	end
end
#@file_to_write.puts  html_stream.gsub(/^\<ID\>(.*)\<\/ID$/) {$1}

#scan(/\d{9}/).collect { |p| p.to_s[0, 6] }.join(' ')



 