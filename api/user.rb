#coding: utf-8
class UserApi < Grape::API
  format :json

    helpers do
    # return an array of columns 
    def columns(params)
      query_cols = params.select{|key,value| key =~ /col_(.*)/}
      query_cols.keys.each { |k| query_cols[k.sub(/col_/, '').to_sym] = query_cols[k]; query_cols.delete(k) }
      query_cols
    end

    def cols 
        where.keys.each{|k| User.columns.include?(k) ? h[k] = where[k] : true }
    end
    def assoc 
        #where.keys.each do |k| 
        #User.association_reflections[:enseigne_regroupement][:class_name]
    end 

    def model
      params['model'].capitalize
    end

    def authenticate!
      error!('401 Unauthorized', 401) unless current_user
    end

    # input user_name 
    # output UserName
    def classify(string)
      string.split('_').collect!{ |w| w.capitalize }.join
    end
  end

  desc "Renvois le profil utilisateur si on passe le bon login/password"
  params do
    requires :login, type: String, regexp: /^[a-z]/i, desc: "Doit commencer par une lettre"
    requires :password, type: String
  end
  get do
    u = User[:login => params[:login]]
    if u and u.password == params[:password]
      u
    else
      error!("Forbidden", 403)
    end
  end

  desc "Renvois le profil utilisateur si on donne le bon id. Nécessite une authentification."
  params do
    requires :id, type: String
  end
  get "/:id" do
    User[params[:id]]
  end

  
  desc "Renvois le profil utilisateur si on donne le bon login. Nécessite une authentification."
  params do
    requires :login, type: String
  end
  get "info/:login" do
    result = {}
    u = User[:login => params[:login]]
    if u
      #result[:user] = u
      p = u.profil_actif
      if p
        #result[:profil] = {:code_uai => p.etablissement.code_uai, :code_ent => p.profil.code_ent}
        result = u.to_hash.merge({:code_uai => p.etablissement.code_uai, :categories => p.profil.code_ent}) 
      end
    else
      error!("Utilisateur non trouvé", 404)
    end
    result
  end

  desc "Service de création d'un utilisateur"
  params do
    requires :login, type: String, desc: "Doit commencer par une lettre et ne pas comporter d'espace"
    requires :password, type: String
    requires :nom, type: String
    requires :prenom, type: String
    optional :sexe, type: String, desc: "Valeurs possibles : F ou M"
    optional :date_naissance, type: Date
    optional :adresse, type: String
    optional :code_postal, type: Integer, desc: "Ne doit comporter que 6 chiffres" 
    optional :ville, type: String
    optional :id_sconet, type: Integer
    optional :id_jointure_aaf, type: Integer
  end
  
  post do
    p = params
    begin
      u = User.new()
      params.each do |k,v|
        if k != "route_info"
          begin
            u.set(k.to_sym => v)
          rescue
            error!("Validation failed", 400)
          end
        end
      end
      u.save()
    rescue Sequel::ValidationFailed
      error!("Validation failed", 400)
    end
  end

  desc "Modification d'un compte utilisateur"
  put "/:id" do
    u = User[params[:id]]
    if u
      params.each do |k,v|
        # Un peu hacky mais je ne vois pas comment faire autrement...
        if k != "id" and k != "route_info"
          begin
            u.set(k.to_sym => v)
          rescue
            error!("Validation failed", 400)
          end
        end
      end
      begin
        u.save()
      rescue Sequel::ValidationFailed
        error!("Validation failed", 400)
      end
    else
      error!("Utilisateur non trouvé", 404)
    end
  end

  desc "Service spécifique au SSO"
  get "/sso_attributes_men/:login" do
    u = User[:login => params[:login]]
    if !u.nil? and !u.profil_actif.nil?
      attributes = {
        "user" => u.id,
        "UAI" => u.etablissement.code_uai,
        "ENTPersonProfils" => u.profil_actif.profil.code_national,
        "CodeNivFormation" => nil,
        "NivFormation" => nil,
        "NivFormationDiplome" => nil,
        "Filiere" => nil,
        "Specialite" => nil,
        "Enseignement" => nil,
        "Classe" => nil,
        "Groupe" => nil,
        "MatiereEnseignEtab" => nil
      }

      if u.profil_actif.profil_id == "ENS"
        attributes["Classe"] = u.enseigne_classes.map{|c| c.libelle}.join(",")
        attributes["Groupe"] = u.enseigne_groupes.map{|g| g.libelle}.join(",")
        attributes["MatiereEnseignEtab"] = u.matiere_enseigne.map{|m| m.libelle_court}.join(",")
      else
        cls = u.classe
        attributes["Classe"] = cls.nil? ? nil : cls.libelle
        attributes["NivFormation"] = cls.nil? ? nil : cls.niveau.libelle
        attributes["Groupe"] = u.groupes.map{|g| g.libelle}.join(",")
      end

      attributes
    else
      error!("Utilisateur non trouvé", 404)
    end
  end

  desc "Service spécifique au SSO"
  get "/sso_attributes/:login" do
    u = User[:login => params[:login]]
    if !u.nil? and !u.profil_actif.nil?
      attributes = {
        "login" => u.login,
        "pass" => u.password,
        "ENT_id" => u.id,
        "uid" => u.id,
        "LaclasseNom" => u.nom,
        "LaclassePrenom" => u.prenom,
        "LaclasseDateNais" => u.date_naissance,
        "LaclasseSexe" => u.sexe,
        "LaclasseAdresse" => u.adresse,
        "LaclasseCivilite" => u.civilite,
        "ENTPersonStructRattach" => u.etablissement.code_uai,
        "ENTPersonStructRattachRNE" => u.etablissement.code_uai,
        "ENTPersonProfils" => u.profil_actif.profil.code_national,
        "LaclasseEmail" => u.email_principal,
        "LaclasseEmailAca" => u.email_academique
      }

      cls = u.classe
      attributes["ENTEleveClasses"] = cls.nil? ? nil : cls.libelle
      attributes["LaclasseNomClasse"] = cls.nil? ? nil : cls.libelle
      attributes["ENTEleveNivFormation"] = cls.nil? ? nil : cls.niveau.libelle

      attributes
    else
      error!("Utilisateur non trouvé", 404)
    end
  end

  get "/query/users"  do
    # query =, columns = "nom,prenom,id, id_sconet", 
    #where = col_sexe = F & col_etablissement_id = 2  displaystart = 0, displaylength = 10, sortcol, sortdir, searchcol, searchphrase
    #if param[:etablissement]
      #where[:profil_user => ProfilUser.filter(:etablissement_id => 2)]
    #end
    #where = {:sexe=>'F', :profil_user => )}
    #response = PagedQuery.new('User',["nom", "prenom", "id", "id_sconet"], ,0, 10, 1, 'desc', 'sexe','')
    #response.as_json
    # query_columns =
    where = {}
    puts params.inspect 
    params["columns"].nil? ? columns = User.columns : columns = params["columns"].split(",")
    response = PagedQuery.new('User',columns, where,0, 10, 1, 'desc', 'sexe','')
    response.as_json
    
  end 



end