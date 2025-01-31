#coding: utf-8
#
# model for 'service' table
# generated 2012-10-19 17:11:43 +0200 by model_generator.rb
#
# ------------------------------+---------------------+----------+----------+------------+--------------------
# COLUMN_NAME                   | DATA_TYPE           | NULL? | KEY | DEFAULT | EXTRA
# ------------------------------+---------------------+----------+----------+------------+--------------------
# id                            | char(8)             | false    | PRI      |            | 
# libelle                       | varchar(255)        | true     |          |            | 
# description                   | varchar(1024)       | true     |          |            | 
# url                           | varchar(1024)       | true     |          |            | 
# ------------------------------+---------------------+----------+----------+------------+--------------------
#
class TypeResource < Sequel::Model(:service)

  class NoServiceError < StandardError
  end

  # Plugins
  plugin :validation_helpers
  plugin :json_serializer

  unrestrict_primary_key()

  # Referential integrity
  one_to_many :ressource
  one_to_many :role

  # A un service correspond une classe représentant la ressource (etablissement, user etc.)
  # Cette classe doit avoir l'operateur [] pour récupérer la ressource avec son identifiant
  # et une fonction destroy() pour pouvoir la supprimer
  @@class_map = {}
  def self.class_map
    @@class_map
  end

  # Chaque classe liée à un service se déclare ici
  def self.declare_service_class(service_id, class_const)
    #raise NoServiceError.new("Service #{service_id} non existant") if Service[service_id].nil?
    @@class_map[service_id] = class_const
  end

  # Not nullable cols and unicity validation
  def validate
    super
  end

  def before_destroy
    # On supprime aussi tous les roles liés à ce service
    role_dataset.destroy()
    super
  end
end
