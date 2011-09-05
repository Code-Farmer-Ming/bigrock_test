require 'active_record'
 
module Acts #:nodoc:
  module LoggerPlugin #:nodoc:

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    module ClassMethods
      #记录日志
      def acts_as_logger(options = {})
        options[:owner_attribute] ||= "self"
 
        options[:except_field] ||= "created_at,updated_at"
        options[:log_action] ||= ["create" ,"update" ]
        options[:logable] ||= "self"
        options[:log_type] ||= "self"
        options[:can_log] ||= true
        
        class_eval <<-END
            @@log_class = LogItem
            if  ('#{options[:logable]}'== 'self')
              has_many :log_items,:as=>:logable,:dependent=>:destroy
            else
              has_many :log_items,:as=>:logable
            end
            has_one :log_item,:as=>:logable

            if #{options[:log_action].include?("update")} 
              before_save :get_changes_#{options[:log_type]}
            end
            after_save :log_changes_#{options[:log_type]}

            if #{options[:log_action].include?("destroy")} && '#{options[:logable]}'!= 'self' 
               after_destroy :log_destroy_#{options[:log_type]}
            end

            def get_changes_#{options[:log_type]}
              if #{options[:log_action].include?("update")}
                except_field = '#{options[:except_field]}'.split(',')
                @logger_changes = self.changes.reject { |k, v| except_field.include?(k) }
              end
            end
            
            def log_changes_#{options[:log_type]}
         
              if ((@new_record_before_save &&  #{options[:log_action].include?("create")}) ||
                 (!@new_record_before_save && #{options[:log_action].include?("update")})) && #{options[:can_log]}

                @@log_class.create(
                  :logable =>#{options[:logable]},
                  :log_type => ('#{options[:log_type]}'=='self' ?  #{options[:log_type]}.class.to_s : '#{options[:log_type]}') ,
                  :operation => @new_record_before_save ? "create" : "update",
                  :changes => @logger_changes,
                  :owner => #{options[:owner_attribute]}
                )
              end
            end
            
            def log_destroy_#{options[:log_type]}
   
              if @@log_class.table_exists? \
                and @@log_class.column_names.include?('logable_id') and #{options[:can_log]}
                @@log_class.create(
                  :logable =>#{options[:logable]},
                  :log_type => '#{options[:log_type]}'=='self' ?  #{options[:log_type]}.class.to_s : '#{options[:log_type]}' ,
                  :operation => "destroy",
                  :changes => @logger_changes,
                  :owner => #{options[:owner_attribute]}
                )
              end
            end
        END
      end
    end

  end
end



# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it

ActiveRecord::Base.class_eval do
  include Acts::LoggerPlugin
end
