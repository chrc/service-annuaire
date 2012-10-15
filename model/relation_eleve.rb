#coding: utf-8
#
# model for 'relation_eleve' table
# generated 2012-04-19 17:45:32 +0200 by model_generator.rb
#
# ------------------------------+---------------------+----------+----------+------------+--------------------
# COLUMN_NAME                   | DATA_TYPE           | NULL?    | KEY      | DEFAULT    | EXTRA
# ------------------------------+---------------------+----------+----------+------------+--------------------
# user_id                       | char(8)             | false    | PRI      |            | 
# eleve_id                      | char(8)             | false    | PRI      |            | 
# type_relation_eleve_id        | int(11)             | false    | MUL      |            | 
# ------------------------------+---------------------+----------+----------+------------+--------------------
#
class RelationEleve < Sequel::Model(:relation_eleve)

  # Plugins
  plugin :validation_helpers
  plugin :json_serializer

  # Referential integrity

  # Not nullable cols
  def validate
    super
    validates_presence [:type_relation_eleve_id]
  end
end