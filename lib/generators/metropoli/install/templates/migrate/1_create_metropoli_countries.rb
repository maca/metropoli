class CreateMetropoliCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.integer :geonamesid
      t.string  :name
      t.string  :alternate_names
      t.string  :iso
      t.string  :abbr

      t.float   :latitude
      t.float   :longitude
      t.string  :timezone
    end
    
    add_index :countries, :name
    add_index :countries, :abbr
  end
  
  def self.down
    drop_table :countries
  end
end
