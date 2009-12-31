class UpdateIndustryData < ActiveRecord::Migration
  def self.up
    create_table :industries,:force => true  do |t|
      t.string :name
    end
 
    industries =%[电脑硬件开发/生产,软件开发,系统集成商,通信产品设备研发与生产,
IT/通信产品经销商,电信/通信运营,IT综合服务/网络服务,体育/娱乐,休闲/旅游,
国防/航天/军队,政府,研究机构,教育/培训,金融/银行/保险,交通/运输/航空,能源/化工,
制造业-电子,制造业-汽车,制造业-其他,会计/咨询/顾问/广告,
商业贸易/零售,医疗机构,医药/医疗设备,建筑/装饰/房地产,法律,
媒体/网站,文化艺术,IT代理/经销商,非IT代理/经销商,
投资机构,酒店/旅馆/餐饮,其他事业单位（图书馆、气象局等）,其他(卫生/农业/自然等)]

    industries.split(',').each do |industry|
 
      Industry.create(:name=>industry.strip.chomp)
    end
  end

  def self.down
    drop_table :industries
  end
end
