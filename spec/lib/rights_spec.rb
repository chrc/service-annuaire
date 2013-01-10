#coding: utf-8
require_relative '../helper'

describe Rights do
  it "return create_user rights for user in ressource etablissement if user has role on etab" do
    r = create_test_role()
    ressource_etab = create_test_ressources_tree()
    # On créer un deuxième etab
    e2 = Etablissement.create(:nom => "test", :type_etablissement => TypeEtablissement.first)
    admin = create_user_with_role(r.id, ressource_etab)
    Rights.get_rights(admin.id, SRV_ETAB, ressource_etab.id, SRV_USER).should == [ACT_CREATE]
    Rights.get_rights(admin.id, SRV_ETAB, e2.id, SRV_USER).should == []
  end

  it "return create_user rights for user in ressource etablissement if user has role on laclasse" do
    r = create_test_role()
    ressource_etab = create_test_ressources_tree()
    # On créer un deuxième etab
    e2 = Etablissement.create(:nom => "test", :type_etablissement => TypeEtablissement.first)
    admin = create_user_with_role(r.id)
    Rights.get_rights(admin.id, SRV_ETAB, ressource_etab.id, SRV_USER).should == [ACT_CREATE]
    Rights.get_rights(admin.id, SRV_ETAB, e2.id, SRV_USER).should == [ACT_CREATE]
  end

  it "should return create rights for user on resource class if user has role on etab " do
    r = create_test_role()
    e = create_test_etablissement()
    admin = create_user_with_role(r.id, e.ressource)
    classe = e.add_regroupement({:type_regroupement_id => TYP_REG_CLS})
    Rights.get_rights(admin.id, SRV_CLASSE, classe.id).should == [ACT_DELETE]
  end

  it "should handle merge similar rights" do
    # On donne des droits sur un établissement et sur laclasse
    r = create_test_role()
    e = create_test_etablissement()
    admin = create_user_with_role(r.id)
    RoleUser.create(:user_id => admin.id, 
      :ressource_id => e.ressource.id, :ressource_service_id => e.ressource.service_id,
      :role_id => r.id)
    Rights.get_rights(admin.id, SRV_ETAB, e.ressource.id, SRV_USER).should == [ACT_CREATE]
  end

  it "should return create rights on service user for laclasse admin" do
    r = create_test_role()
    admin = create_user_with_role(r.id)
    laclasse_id = Ressource[:service_id => SRV_LACLASSE].id
    Rights.get_rights(admin.id, SRV_LACLASSE, laclasse_id, SRV_USER).should == [ACT_CREATE]
  end

  it "cumulate rights from different role" do
    r = create_test_role()
    e = create_test_etablissement()
    # On donne un role sur l'établissement
    admin = create_user_with_role(r.id, e.ressource)
    r = Role.find_or_create(:id => "TEST2", :service_id => SRV_CLASSE)
    ActiviteRole.find_or_create(:service_id => SRV_CLASSE, :role_id => r.id, :activite_id => ACT_UPDATE)
    classe = e.add_regroupement({:type_regroupement_id => TYP_REG_CLS})
    # Puis un role sur la classe
    admin.add_role(classe.id, SRV_CLASSE, r.id)

    # On doit cumuler les role de l'établissement et du groupe
    Rights.get_rights(admin.id, SRV_CLASSE, classe.id).sort.should == [ACT_DELETE, ACT_UPDATE]
    
    # Maintenant si j'enlève le role sur la classe et que je le rajoute sur l'établissement
    RoleUser.filter(:ressource_id => classe.id, :ressource_service_id => SRV_CLASSE).destroy()
    admin.add_role(e.id, SRV_ETAB, r.id)
    
    # Ca doit faire pareil
    Rights.get_rights(admin.id, SRV_CLASSE, classe.id).sort.should == [ACT_DELETE, ACT_UPDATE]

    r.destroy()
  end

  # todo : Tester que l'on puisse accéder aux fichiers d'un établissement mais pas à celui des classes
  # notion de service_parent_id
  
end