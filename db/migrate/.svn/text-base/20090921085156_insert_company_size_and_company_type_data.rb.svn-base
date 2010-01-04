class InsertCompanySizeAndCompanyTypeData < ActiveRecord::Migration
  def self.up

    #公司类型
    types=["私有","国有","上市","合资(欧美)","合资(港台)","外资(欧美)","外资(港台)","其他"]
    sizes=["10人以下","10-50人","50-100人","100-500人","500-1000人","1000-5000人","5000人以上"]
    types.each do |type|
      CompanyType.create(:name=>type)
    end
    sizes.each do |size|
      CompanySize.create(:name=>size)
    end
  end

  def self.down
    CompanySize.destroy_all
    CompanyType.destroy_all
  end
end
