#coding: utf-8
#
# model for 'regroupement' table
# generated 2012-04-19 17:45:32 +0200 by model_generator.rb
#
# ------------------------------+---------------------+----------+----------+------------+--------------------
# COLUMN_NAME                   | DATA_TYPE           | NULL?    | KEY      | DEFAULT    | EXTRA
# ------------------------------+---------------------+----------+----------+------------+--------------------
# id                            | int(11)             | false    | PRI      |            | auto_increment
# libelle                       | varchar(45)         | true     |          |            | 
# description                   | text                | true     |          |            | 
# code_mef_aaf                  | int(11)             | true     |          |            | 
# date_last_maj_aaf             | date                | true     |          |            | 
# libelle_aaf                   | char(8)             | true     |          |            | 
# etablissement_id              | int(11)             | true     | MUL      |            | 
# type_regroupement_id          | char(8)             | false    | MUL      |            | 
# ------------------------------+---------------------+----------+----------+------------+--------------------
#
class Regroupement < Sequel::Model(:regroupement)

  # Plugins
  plugin :validation_helpers
  plugin :json_serializer

  [SRV_CLASSE, SRV_GROUPE, SRV_LIBRE].each do |service|
    Service.declare_service_class(service, self)  
  end

  # Referential integrity
  many_to_one :etablissement
  one_to_many :enseigne_dans_regroupement
  one_to_one :ressource, :key => :id do |ds|
    ds.where(:service_id => [SRV_GROUPE, SRV_CLASSE, SRV_LIBRE])
  end
  many_to_one :niveau
  one_to_many :eleve_dans_regroupement

  # Not nullable cols
  def validate
    super
    validates_presence [:type_regroupement_id]
    # validates presence :etablissemnet_id if type_regroupement is CLS, GRP
    validates_presence [:code_mef_aaf] if :type_regroupement_id == 'CLS'
  end


  def after_create
    # On définit le type de service en fonction du type de regroupement
    case self.type_regroupement_id
      when 'CLS'
        service_id = "CLASSE"
      when 'GRP'
        service_id = "GROUPE"
      when 'LBR'
        service_id = "LIBRE"
    end

    Ressource.create(:id => self.id, :service_id => service_id)
    super
  end

  def before_destroy
    # Supprimera toutes les ressources liées à ce regroupement
    self.ressource.destroy() if self.ressource
    # Supprime tous les enseignements effectués dans ce regroupement
    enseigne_dans_regroupement_dataset.destroy()
    super
  end

  #Les regroupement de type classe ont forcément un niveau
  def niveau
    Niveau[niveau_id]
  end

  def nb_membres
    RoleUser.filter(:ressource => self.ressource).unique(:user_id)
  end

  def is_classe
    type_regroupement_id == TYP_REG_CLS 

  end

  def is_groupe
    type_regroupement_id == TYP_REG_GRP 
  end

=begin
  # returns the number of groups in the class 
  def nb_groups
    if type_regroupement_id == TYP_REG_CLS
      #MembreRegroupement.filter(:user_id => MembreRegroupement.select(:user_id).filter(:regroupement => self)).select(:regroupement_id).distinct.count
    else
      raise 'Erreur, le groupe n\' est pas une classe'
    end
  end

  # Liste des membres du regroupement dont le profil est élève
  def eleves
    User.filter(:membre_regroupement => MembreRegroupement.filter(:regroupement => self),
      :profil_user => ProfilUser.filter(:etablissement_id => etablissement_id, :profil_id => 'ELV')).all
  end

  # Liste des membres du regroupement dont le profil est Prof
  def profs
    User.filter(:enseigne_regroupement => EnseigneRegroupement.filter(:regroupement => self),
      :profil_user => ProfilUser.filter(:etablissement_id => etablissement_id, :profil_id => 'ENS')).all  
  end

  def membres
    User.filter(:membre_regroupement => MembreRegroupement.filter(:regroupement => self),
      :profil_user => ProfilUser.filter(:etablissement_id => etablissement_id)).all 
  end
 
  def add_membre(user_id)
    membre = MembreRegroupement.new
    membre.regroupement = self
    membre.user_id = user_id
    membre.save
    #MembreRegroupement.create(:regroupement => self, :user_id => user_id)
  end
  def delete_membre(user_id)
    MembreRegroupement.where(:user_id => user_id, :regroupement => self).delete
  end

=end

  # matieres = [ ]
  def add_prof(user, matiere, principal = "N" )
    # for the moment i dont treat roles
    #user.add_role(self.ressource.id, self.ressource.service_id, "PROF_CLS")
    EnseigneDansRegroupement.find_or_create(:regroupement_id => self.id, :user_id => user.id,
      :matiere_enseignee_id => matiere.id, :prof_principal => principal)
  end

  def delete_prof(user_id)
    # supprimer le role prof de l'utilisateur
    # supprimer les matieres ensignee par cet utilisateur
    RoleUser[:user_id => user_id, :role_id => PROF_CLS]
    EnseigneDansRegroupement.where(:user_id => user_id, :regroupement => self).delete
  end
end
