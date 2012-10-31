#coding: utf-8
class UserApi < Grape::API
  format :json

    helpers do
    # return an array of columns 
    def model
      params['model'].capitalize
    end
    # input user_name 
    # output UserName
    def classify(string)
      string.split('_').collect!{ |w| w.capitalize }.join
    end
    #change hash keys to symbols
    def symblize_hash(h)
      h.keys.each do |key|
        h[(key.to_sym rescue key) || key] = h.delete(key)
      end 
    end
    def symbolize_array(arr)
      arr.map{|v| v.is_a?(String) ? v.to_sym : v}
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

  # TODO : merger ce code avec /:id => nécessite modif SSO
  desc "Renvois le profil utilisateur si on donne le bon login. Nécessite une authentification."
  params do
    requires :login, type: String
  end
  get "profil/:login" do
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

  # Renvois la ressource user
  desc "Service de création d'un utilisateur"
  params do
    # todo : optional mais si password, login obligé et vice/versa
    requires :login, type: String, desc: "Doit commencer par une lettre et ne pas comporter d'espace"
    optional :password, type: String
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

  # Même chose que post mais peut ne pas prendre des champs require
  # Renvois la ressource user complète
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

  desc "a service to search users according to certiain informations"
  # look at tests to see some examples about parameters
  get "/query/users"  do
    params["columns"].nil? ? columns = User.columns : columns = symbolize_array(params["columns"].split(","))
    #filter_params
    filter = params["where"].nil? ? {} : params["where"].to_hash
    symblize_hash(filter)

    filter.keys.each do |k|
      # key is of a pattern ex. user_profil.etablissement_id  where user_profil is an association and etablissment_id is a column in the association table
      if(k =~ /\w*[.][a-z]+/) 
          association_array= k.to_s.split(".")
          association = symbolize_array(association_array) 
          model_name  = classify(association[0].to_s)
          begin 
            raise "error"  if !User.associations.include?(association[0])
            model = Kernel.const_get(model_name)
            column = association[1]
            raise "error"  if !model.columns.include?(column)
             # add if filter[assocition] exists add filter to the request
            if filter[association[0]].nil?
                filter[association[0]] =  model.filter(column => filter[k])
            else 
              filter[association[0]] = filter[association[0]].filter(column => filter[k])
            end 
          rescue
             error!("Bad Request : invalid parameters", 400)  
          end   
          #puts model_column.inspect
          filter.delete(k)
      elsif( !User.columns.include?(k))
        error!("Bad Request", 400)  unless User.columns.include?(k)
      end
    end
    start = params["start"].nil? || params["start"].empty? ? 0 : params["start"]
    length = params["length"].nil? || params["length"].empty? ? 10 : params["length"]
    sortdir = params["sortdir"].nil? ? "" : params["sortdir"]
    sortcol = params["sortcol"].nil? || params["sortcol"].empty? ? 1 : columns.include?(params["sortcol"].to_sym) ? columns.index(params["sortcol"].to_sym) : 1 
    search = params["search"].nil? ?  '' : params["search"]

    response = PagedQuery.new('User', columns, filter, start, length, sortcol, sortdir, search)
    response.as_json
  end

  desc "Search parents of a student who has a specific sconet_id"
  params do
    requires :id_sconet, type: Integer 
    optional :nom, type: String
    optional :prenom, type: String
  end
  # returns empty array if parent(s) is(are) not found
  get "/parent/eleve"  do
    nom = params["nom"].nil? ?  "" : params["nom"]
    prenom = params["prenom"].nil? ?  "" : params["prenom"]
    eleve = User[:id_sconet => params["id_sconet"]]
    parents = eleve.parents

    parents.keep_if do |p|
      keep_parent = true
      if !nom.empty?
        keep_parent = p.nom == nom
      end
      if !prenom.empty? and keep_parent
        keep_parent = p.prenom == prenom
      end
      keep_parent
    end

    parents
  end

  # Récupération des relations 
  # returns the relations of a user 
  # actually not complet 
  get "/:id/relations" do 
    id = params[:id]
    if !id.nil? and !id.empty?
      user = User[:id => id]
    else
      error!("Utilisateur non trouvé", 404)
    end 
    relation = !user.relation_adulte.empty? ? user.relation_adulte : user.relation_eleve
  end

  
  # @state[not finished]
  #Il ne peut y en avoir qu'une part adulte
  #Cas d'un user qui devient parent d'élève {eleve_id: VAA60001, type_relation_id: "PAR"}
  desc "Ajout d'une relation entre un adulte et un élève"  
  post "/:user_id/relation" do
    user_id = params["user_id"]
    if User[:id => user_id].nil? 
      error!("ressource non trouvé", 404)
    end 
    eleve_id = params["eleve_id"]
    type_relation_id = params["type_relation_id"]

    if !eleve_id.nil? and !eleve_id.empty?
      if !type_relation_id.nil? and !type_relation_id.empty?
        #User[:id => user_id].add_relation(eleve_id, type_relation_id) 
        # returns {id: user_id ,relations: [{eleve_id, type_relation id}]}

        {:user_id => user_id , :eleve_id => eleve_id , :type_relation_id => type_relation_id}
      else
        error!("mauvaise requete", 400)
      end 
    else
      error!("mauvaise requete", 400) 
    end 

  end


  # @state[not finished]
  desc "Modification de la relation"
  params do
    requires :type_relation_id, type: String
    requires :eleve_id, type:String 
  end
  put "/:user_id/relation/:eleve_id" do
    user_id = params["user_id"]
    if User[:id => user_id].nil?
      error!("ressource non trouvé", 403)
    end
    eleve_id = params["eleve_id"]
    type_relation_id = !params["type_relation_id"].empty? ? params["type_relation_id"] : error!("mauvaise requete", 400)
    {:user_id => user_id, :eleve_id => eleve_id}
  end
  

  #//Suppression de la relation (1 par adulte)
  #DEL /user/:user_id/relation/:eleve_id  



end