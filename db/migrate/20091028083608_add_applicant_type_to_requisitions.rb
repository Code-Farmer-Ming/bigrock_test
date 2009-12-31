class AddApplicantTypeToRequisitions < ActiveRecord::Migration
  def self.up
    add_column :requisitions, :applicant_type, :string,:null=>false
  end

  def self.down
    remove_column :requisitions, :applicant_type
  end
end
