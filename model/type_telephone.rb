#coding: utf-8
#
# model for 'type_telephone' table
# generated 2012-04-19 17:45:32 +0200 by model_generator.rb
#
# ------------------------------+---------------------+----------+----------+------------+--------------------
# COLUMN_NAME                   | DATA_TYPE           | NULL?    | KEY      | DEFAULT    | EXTRA
# ------------------------------+---------------------+----------+----------+------------+--------------------
# id                            | int(11)             | false    | PRI      |            | auto_increment
# libelle                       | varchar(45)         | true     |          |            | 
# description                   | varchar(255)        | true     |          |            | 
# ------------------------------+---------------------+----------+----------+------------+--------------------
#
class TypeTelephone < Sequel::Model(:type_telephone)

  # Plugins
  plugin :validation_helpers
  plugin :json_serializer

  # Referential integrity
  one_to_many :telephone

  # Not nullable cols
  def validate
    super
  end
end