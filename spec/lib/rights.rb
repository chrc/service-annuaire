#coding: utf-8
require_relative '../helper'

describe Rights do
  #in case something went wrong
  delete_test_ressources_tree()
  delete_test_role()
  delete_test_users()
  
  it "return create_user rights for user in ressource etablissement if user has role on etab" do
    r = create_test_role()
    ressource_etab = create_test_ressources_tree()
    # On créer un deuxième etab
    e2 = Etablissement.create(:nom => "test", :type_etablissement => TypeEtablissement.first)
    admin = create_user_with_role(r.id, ressource_etab)
    Rights.get_rights(admin.id, SRV_ETAB, ressource_etab.id, SRV_USER).should == [ACT_CREATE]
    Rights.get_rights(admin.id, SRV_ETAB, e2.id, SRV_USER).should == []
    delete_test_ressources_tree()
    delete_test_role()
  end

  it "return create_user rights for user in ressource etablissement if user has role on laclasse" do
    r = create_test_role()
    ressource_etab = create_test_ressources_tree()
    # On créer un deuxième etab
    e2 = Etablissement.create(:nom => "test", :type_etablissement => TypeEtablissement.first)
    admin = create_user_with_role(r.id)
    Rights.get_rights(admin.id, SRV_ETAB, ressource_etab.id, SRV_USER).should == [ACT_CREATE]
    Rights.get_rights(admin.id, SRV_ETAB, e2.id, SRV_USER).should == [ACT_CREATE]
    delete_test_ressources_tree()
    delete_test_role()
  end

  # it "should return create rights for user on resource class if user has role on etab " do
  #   Rights.get_rights(admin.id, SRV_CLASSE, cls_id).shoud == [ACT_CREATE_USER]
  # end

  # it "should handle merge similar rights" do
  #   # On donne des droits sur un établissement et sur laclasse
    
  #   Rights.get_rights(admin.id, SRV_ETAB, ressource_etab.id).should == [ACT_CREATE_USER]
  # end

  # it "should return create rights on service user for laclasse admin" do
  #   Rights.get_rights(admin.id, SRV_SERVICE, SRV_USER).should == [ACT_CREATE]
  # end

  # it "cumulate rights from different role" do
  #   # On donne un role d'admin d'établissement
  #   # Puis un role d'admin de groupe
  #   # On doit cumuler les role d'admin d'établissement et de groupe sur le groupe

  # end

  # todo : Tester que l'on puisse accéder aux fichiers d'un établissement mais pas à celui des classes
  # notion de service_parent_id
  
end