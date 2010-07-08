module Metropoli
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module Messages
    def self.error(class_name, kind)
      I18n.t( kind, :resource_name => class_name,
             :scope => [:metropoli, class_name.downcase])
    end
  end 
  
  module ClassMethods
    
    def belongs_to_metropoli(args = {})
      metropoli_relation = args[:with] || 'city'
      relation_class_name = ConfigurationHelper.relation_class_for(metropoli_relation)
      relation_name = args[:as] || ConfigurationHelper.relation_name_for(args[:with])
      relation_class = eval(relation_class_name)
      relation_collector = "metropoli_#{relation_name.pluralize}".to_sym

      self.belongs_to relation_name.to_sym, :class_name => relation_class_name

      define_method "#{relation_name}_name=" do |attr_value|
        write_attribute "#{relation_name}_name", attr_value
        write_attribute relation_collector, (relation_class.autocomplete(attr_value) || [])
        if read_attribute(relation_collector).size == 1
          send "#{relation_name}=", read_attribute(relation_collector).first
        else
          send "#{relation_name}=", nil
        end
      end

      define_method "#{relation_name}_name" do
        metropoli_attribute = send(relation_name)
        return read_attribute("#{relation_name}_name") if read_attribute("#{relation_name}_name")
        return metropoli_attribute.to_s if metropoli_attribute
      end
      
      #Validation Methods
      if args[:required]
        validates_presence_of   relation_name
        validate do |record|
          collection = record.read_attribute(relation_collector)
          relation = record.read_attribute(relation_name)
          if collection
            if (collection.size > 1 rescue nil)
              record.errors.add(relation_name, Metropoli::Messages.error(metropoli_relation, :found_too_many))
            end
            if (collection.size == 0)
              record.errors.add(relation_name, Metropoli::Messages.error(metropoli_relation, :couldnt_find))
            end
          end
        end
      end
      
      send :include, InstanceMethods
    end
    
    
    def has_and_belongs_to_many_metropoli(args = {})
      relation_class_name = ConfigurationHelper.relation_class_for(args[:with] || 'cities')
      relation_name = args[:as] || ConfigurationHelper.relation_name_for(args[:with], 'has_many')
      relation_class = eval(relation_class_name)
      
      self.has_and_belongs_to_many relation_name.to_sym, :class_name => relation_class_name, 
                                   :join_table => [self.table_name, relation_name].sort.join('_'),
                                   :association_foreign_key => "#{relation_name.singularize}_id"
      
      define_method "add_#{relation_name.singularize}" do |attr_value|
        results = relation_class.like(attr_value)
        if results.count == 1
          send("#{relation_name}") << results.first
          results.first
        else
          nil
        end
      end
        
      define_method "remove_#{relation_name.singularize}" do |attr_value|
        results = relation_class.like(attr_value)
        if results.count == 1
          send("#{relation_name}").delete(results.first)
          results.first
        else
          nil
        end
      end
      
      if args[:required]
        validate do |record|
          min = args[:min] || 1
          collection = record.send(relation_name)
          if collection.size < min
            record.errors.add(relation_name, Metropoli::Messages.error(relation_name, :not_enough))
            if args[:max] and collection.size > args[:max]
              record.errors.add(relation_name, Metropoli::Messages.error(relation_name, :too_many))
            end
          else
        end
      end
      
    end
    
  end
  
  module InstanceMethods
    
  end
  
end

ActiveRecord::Base.send :include, Metropoli