﻿#encoding: UTF-8
require 'rubygems'
require 'mongoid'
require 'nokogiri'
require 'open-uri'
require 'logger'



Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end


#ENV['MONGOID_ENV'] = 'localcar'
ENV['MONGOID_ENV'] = 'development'

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

def create_file_to_write
	file_path = File.join('.', "bitauto-#{Time.now.to_formatted_s(:number) }.txt")
	@file_to_write = IoFactory.init(file_path)
end #create_file_to_write

create_file_to_write


@bitautocar = Qqcar.bitautocar2
@total = @bitautocar.count
	@title = %w(上市日期(年)
年款
进气型式
变速器型式
车身颜色
保修政策
综合工况油耗
市区工况油耗
市郊工况油耗
百公里等速油耗
最小转弯半径
驱动方式
乘员人数（含司机）
整备质量
允许总质量
加速时间
最高车速
百公里等速油耗速度
车门数
车身型式
车顶型式
天窗型式
车篷型式
长
宽
高
轴距
燃料类型
供油方式
型号
排量
最大功率-功率值
最大功率-转速
最大扭矩-扭矩值
最大扭矩—转速
气缸排列型式
发动机位置
凸轮轴
汽缸数
每缸气门数
环保标准
转向助力
前进档数
变速箱变速杆位置
前制动类型
后制动类型
前悬挂类型
后悬挂类型
前轮胎规格
后轮胎规格
备胎类型
备胎位置
车窗
电动窗锁止功能
电动窗防夹功能
后风窗加热功能
雨刷传感器
内后视镜防眩目功能
外后视镜电动调节
外后视镜加热功能
前照灯类型
前大灯延时关闭
前雾灯
前照灯照射高度调节
前照灯自动清洗功能
侧转向灯
行李箱灯
高位(第三)制动灯
方向盘表面材料
方向盘幅数
方向盘换档
仪表板显示型式
仪表板背光颜色
行车电脑
时钟
车外温度显示
燃油不足警告方式
转速表
座椅面料
运动座椅
座椅按摩功能
驾驶座座椅加热
驾驶座座椅调节方式
驾驶座座椅调节方向
后座中央扶手
主动式安全头枕
后座椅头枕
前座椅头枕调节
后座椅头枕调节
儿童安全座椅固定装置
收音机
VCD
CD
CD碟数
DVD
中控台液晶屏
扬声器数量
空调
空调控制方式
温区个数
定速巡航系统
GPS电子导航
倒车雷达
中控门锁
蓝牙系统
多功能方向盘
遥控钥匙
遥控行李箱盖
遮阳板化妆镜
ABS(刹车防抱死制动系统)
DSC(动态稳定控制系统)
EBD/EBV(电子制动力分配)
TCS(牵引力控制系统)
电子防盗系统
发动机防盗系统
驾驶位安全气囊
副驾驶位安全气囊
前排头部气囊(气帘)
后排头部气囊(气帘)
前排侧安全气囊
前安全带调节
安全带预收紧功能
安全带限力功能
后排安全带
后排中间三点式安全带
儿童锁
溃缩式制动踏板
车门防撞杆(防撞侧梁)
可溃缩转向柱
最大承载质量
天窗开合方式
燃油箱容积
随速助力转向调节(EPS)
会车前灯防眩目功能
仪表板亮度可调
座椅颜色
驾驶座椅调节记忆位置组数
副驾驶座椅调节方式
副驾驶座椅调节方向
卡带
车载电视
电子限速
倒车影像
胎压检测装置
行李箱盖车内开启
行李箱盖开合方式
遥控油箱盖
ABD(自动制动差速器)
EDS(电子差速锁)
外后视镜电动折叠功能
油箱盖车内开启
副气囊锁止功能
车篷开合方式
车顶行李箱架
前大灯自动开闭
音频格式支持
EBA/EVA(紧急制动辅助系统)
出风口个数
气囊气帘数量
外后视镜记忆功能
前大灯随动转向
驾驶座腰部支撑调节
后排出风口
后排侧安全气囊
前轮距
后轮距
行李箱容积
压缩比
轮毂材料
后导流尾翼
运动包围
方向盘调节方式
前座中央扶手
后排座位放倒比例
车内电源电压
车厢前阅读灯
车厢后阅读灯
前排杯架
后排杯架
衣物挂钩
前排腿部最大空间
后排腿部最大空间
车内电源插口数量
无钥匙点火系统
ASR(驱动防滑装置)
ESP(电子稳定程序)
车体结构
缸径
行程
最大马力
驻车制动器
减震器类型
上坡辅助
LED尾灯
防紫外线/隔热玻璃
外接音源接口
车载电话
泊车雷达(车前)
安全带未系提示
车内灯光延时关闭
中央置物盒
最小离地间隙
前轮毂规格
后轮毂规格
后雨刷器
车内中控锁
接近角
离去角
缸体材料
方向盘上下调节
方向盘前后调节
内饰颜色
最大涉水深度
后窗遮阳帘
罗盘/指南针
DVD碟数
行李箱打开方式
人机交互系统
第三排座椅
后排液晶显示器
温度分区控制
空气调节/花粉过滤
特有技术
多功能方向盘功能
加速时间(0—100km/h)
制动距离(100—0km/h)
车内怠速噪音
车内等速(40km/h)噪音
车内等速(60km/h)噪音
车内等速(80km/h)噪音
车内等速(100km/h)噪音
车内等速(120km/h)噪音
18米绕桩速度
悬挂高度调节
电动吸合门
HUD抬头数字显示
座椅通风
电动座椅记忆
自动泊车入位
并线辅助
主动刹车/主动安全系统
夜视系统
全景摄像头
自动驻车
陡坡缓降
油耗
行李箱最大拓展容积
后排独立空调
制动距离(100—0 km/h)
零压续行(零胎压继续行驶)
日间行车灯
车内氛围灯
后排侧遮阳帘
方向盘记忆设置
无线上网功能
车载冰箱
整体主动转向系统
膝部气囊
主动转向系统
车内等速噪音
最大爬坡度
C-NCAP星级
行李箱内部最大宽度
CNCAP市区工况油耗
CNCAP市郊工况油耗
音响品牌
车篷开合时间
前风窗玻璃类型
分动箱操纵
最大爬坡度(值)
NCAP碰撞测试
副油箱容积
方向盘回转总圈数
行李箱内部深度
后风窗玻璃类型
主动安全-其他
分动箱档数
行李箱内部高度
)
@bitautocar.each_with_index do |car, i|

	puts "#{i}/#{@total}:#{car.brand}"
	item = []
	item = "#{car.brand}\t#{car.maker}\t#{car.series}\t#{car.year}\t#{car.name}\t"
	@title.each do |t|
		car.parameters.each do |p|
			item << p.value if (t.eql?(p.name))
		end	
		item << "\t"
	end
	@file_to_write.puts item
	
	#break
end
	
