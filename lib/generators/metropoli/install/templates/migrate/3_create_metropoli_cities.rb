class CreateMetropoliCities < ActiveRecord::Migration
  def self.up 
    create_table :cities do |t|
      t.integer :geonamesid
      t.integer :state_id
      t.string  :ascii_name
      t.integer :population
      t.string  :alternate_names
      t.string  :name

      t.float   :latitude
      t.float   :longitude
      t.string  :timezone
    end
    
    add_index :cities, :name
    add_index :cities, :state_id
  end
  
  def self.down
    drop_table :cities
  end
end
