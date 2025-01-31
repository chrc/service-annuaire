#coding: utf-8
require_relative '../../../helper'

# Classe qui initialise les données qui vont bien pour les tests
class ParserTest < Alimentation::ParserXmlMongo
  attr_reader :cur_etb_data
  def initialize
    config = {:server => "localhost", :db => "mydb"}
    init_memory_db(config)
    @cur_etb_uai = '0690000X'
    @cur_etb_xml_id = "1234"
    @cur_etb = @db.collection("etablissement").find_one({"code_uai" => @cur_etb_uai})
  end
end

################### SampleXML DATA ###########
################### Eleve ####################
# Renvois la description XML d'un élève
def get_eleve_xml(options = {})
  node = '<addRequest>
<operationalAttributes><attr name="categoriePersonne"><value>Eleve</value></attr></operationalAttributes>'
  if options[:wrong_identifier]
    node += '<identifier><id>123457</id></identifier>'
  elsif options[:no_identifier]
    node += '<identifier><id></id></identifier>'
  else
    node += '<identifier><id>123456</id></identifier>'
  end
  node += '<attributes>'
  if options[:no_id_jointure]
    node += '<attr name="ENTPersonJointure"><value></value></attr>'
  else
    node += '<attr name="ENTPersonJointure"><value>123456</value></attr>'
  end

  if options[:no_date_naiss]
    node += '<attr name="ENTPersonDateNaissance"><value></value></attr>'
  else
    node += '<attr name="ENTPersonDateNaissance"><value>06/06/1996</value></attr>'
  end
  node += '<attr name="ENTPersonNomPatro"><value>RODRIGUEZ</value></attr>
<attr name="sn"><value>RODRIGUEZ</value></attr>'
  if options[:mismatch_first_name]
    node += '<attr name="givenName"><value>Michele</value></attr>'
  else
    node += '<attr name="givenName"><value>Michèle</value></attr>'
  end
  node += '<attr name="ENTPersonAutresPrenoms"><value>Michèle</value><value>Robert</value></attr>
<attr name="personalTitle"><value>Mlle</value></attr>
<attr name="ENTEleveParents"><value>123457</value><value>123458</value></attr>
<attr name="ENTElevePere"><value>123457</value></attr>
<attr name="ENTEleveMere"><value>123458</value></attr> 
<attr name="ENTEleveStructRattachId"><value>547554</value></attr>'
  if options[:different_autorite]
    node += '<attr name="ENTEleveAutoriteParentale"><value>234567</value><value>234568</value></attr>'
  else
    node += '<attr name="ENTEleveAutoriteParentale"><value>123457</value><value>123458</value></attr>'
  end
  if options[:corr_is_parent]
    node += '<attr name="ENTElevePersRelEleve1"><value>123457</value></attr>'
  elsif options[:different_autorite]
    node += '<attr name="ENTElevePersRelEleve1"><value>234567</value></attr>'
  else
    node += '<attr name="ENTElevePersRelEleve1"><value>123459</value></attr>'
  end
  if options[:one_resp_financier]
    node += '<attr name="ENTEleveQualitePersRelEleve1"><value>Responsable financier</value></attr>'
  else
    node += '<attr name="ENTEleveQualitePersRelEleve1"><value>CONTACT</value></attr>'
  end
node += '<attr name="ENTElevePersRelEleve2"><value>123460</value></attr>
<attr name="ENTEleveQualitePersRelEleve2"><value>CONTACT</value></attr>
<attr name="ENTElevePersRelEleve"><value>123457$1$1$1$1$0</value><value>123458$2$0$2$1$0</value></attr>
<attr name="ENTEleveBoursier"><value>N</value></attr>
<attr name="ENTEleveRegime"><value>EXTERNE LIBRE</value></attr>
<attr name="ENTEleveTransport"><value>N</value></attr>
<attr name="ENTEleveStatutEleve"><value>SCOLAIRE</value></attr>
<attr name="ENTEleveMEF"><value>10210001110</value></attr>
<attr name="ENTEleveLibelleMEF"><value>4EME</value></attr>
<attr name="ENTEleveNivFormation"><value>4EME GENERALE (N.C 4E AES)</value></attr>
<attr name="ENTEleveFiliere"><value>4EME GENERALE (N.C 4E AES)</value></attr>
<attr name="ENTEleveEnseignements"><value>ANGLAIS LV1</value><value>ARTS PLASTIQUES</value><value>EDUCATION CIVIQUE</value><value>EDUCATION MUSICALE</value><value>EDUCATION PHYSIQUE ET SPORTIVE</value><value>ESPAGNOL LV2</value><value>FRANCAIS</value><value>HISTOIRE ET GEOGRAPHIE</value><value>ITINERAIRE DECOUVERTE (ARTS HUMANITE)</value><value>ITINERAIRE DECOUVERTE (AUTRES)</value><value>ITINERAIRE DECOUVERTE (CREATION TECHNIQ)</value><value>ITINERAIRE DECOUVERTE (LANGUES CIVILIS.)</value><value>ITINERAIRE DECOUVERTE (NATURE CORPS HUM)</value><value>MATHEMATIQUES</value><value>PHYSIQUE-CHIMIE</value><value>SCIENCES DE LA VIE ET DE LA TERRE</value><value>TECHNOLOGIE</value><value>VIE SCOLAIRE</value></attr>'
  if options[:no_struct_rattach]
    node += '<attr name="ENTPersonStructRattach"><value></value></attr>'
  else
    node += '<attr name="ENTPersonStructRattach"><value>1234</value></attr>'
  end
  if options[:two_classes]
    node += '<attr name="ENTEleveClasses"><value>1234$4E3</value><value>1234$4E5</value></attr>'
  else  
    # Un elève peut être dans plusieurs établissements
    node += '<attr name="ENTEleveClasses"><value>1234$4E3</value><value>4567$4E5</value></attr>'
  end
node += '<attr name="ENTEleveGroupes"><value>1234$4DP3</value></attr>
</attributes>
</addRequest>'
  Nokogiri::XML(node).css("addRequest, modifyRequest").first
end

################### Sample XML DATA ###########
################### Relation Eleve ############
def get_rel_eleve_xml(options = {})
  node = '<addRequest>
<operationalAttributes><attr name="categoriePersonne"><value>PersRelEleve</value></attr></operationalAttributes>
<identifier><id>2345678</id></identifier>
<attributes>
<attr name="ENTPersonJointure"><value>2345678</value></attr>
<attr name="ENTPersonDateNaissance"><value/></attr>
<attr name="ENTPersonNomPatro"><value>VAN DAMME</value></attr>
<attr name="sn"><value>VAN DAMME</value></attr>
<attr name="givenName"><value>Jean-Claude</value></attr>
<attr name="personalTitle"><value>M.</value></attr>'

  if options[:home_phone_is_port]
    node += '<attr name="homePhone"><value>+33 6 12 34 56 78</value></attr>'
  else
    node += '<attr name="homePhone"><value>+33 4 13 34 56 78</value></attr>'
  end
node += '<attr name="telephoneNumber"><value>+33 4 12 34 58 78</value></attr>
<attr name="ENTPersonAdresse"><value>3 RUE KARATE</value></attr>
<attr name="ENTPersonCodePostal"><value>69110</value></attr>
<attr name="ENTPersonVille"><value>STE FOY LES LYON</value></attr>
<attr name="ENTPersonPays"><value>FRANCE</value></attr>
</attributes>
</addRequest>'
  Nokogiri::XML(node).css("addRequest, modifyRequest").first
end

################### Sample XML DATA ###########
################### Person Education National #
def get_pen(options = {})
  node = '<addRequest>
<operationalAttributes><attr name="categoriePersonne"><value>PersEducNat</value></attr></operationalAttributes>
<identifier><id>1122</id></identifier>
<attributes>
<attr name="ENTPersonJointure"><value>1122</value></attr>
<attr name="ENTPersonDateNaissance"><value>06/05/1952</value></attr>
<attr name="ENTPersonNomPatro"><value>CLAVIER</value></attr>
<attr name="sn"><value>CLAVIER</value></attr>
<attr name="givenName"><value>CHRISTIAN</value></attr>
<attr name="personalTitle"><value>M.</value></attr>
<attr name="mail"><value>christian.clavier@ac-lyon.fr</value></attr>
<attr name="ENTPersonStructRattach"><value>1234</value></attr>'
  if options[:devant_eleve]
    node += '<attr name="ENTAuxEnsCategoDiscipline"><value>16$BIOLOGIE - GEOLOGIE</value></attr>
    <attr name="ENTAuxEnsDisciplinesPoste"><value>SCIENCES DE LA VIE ET DE LA TERRE$16</value></attr>
    <attr name="ENTAuxEnsMEF"><value>1234$1001000C11A$6EME BILANGUE</value><value>1234$10010012110$6EME</value><value>1234$10110001110$5EME</value><value>1234$1011000C11A$5EME BILANGUE</value><value>1234$1031000D11A$3EME A DEUX LANGUES VIVANTES 1</value><value>1234$10310019110$3EME</value><value>1234$10310019112$3E-EU  3EME A 2 OPT. SECT EUROPEENNE</value></attr>
    <attr name="ENTAuxEnsMatiereEnseignEtab"><value>1234$SCIENCES DE LA VIE ET DE LA TERRE</value></attr>
    <attr name="ENTAuxEnsClasses"><value>1234$3E2</value><value>1234$3E3</value><value>1234$3E4</value><value>1234$5E2</value><value>1234$5E3</value></attr>
    <attr name="ENTAuxEnsGroupes"><value/></attr>
    <attr name="ENTAuxEnsClassesPrincipal"><value/></attr>
    <attr name="ENTPersonFonctions"><value>1234$ENS$ENSEIGNEMENT$L1600$SCIENCES DE LA VIE ET DE LA TERRE</value></attr>
    <attr name="PersEducNatPresenceDevantEleves"><value>O</value></attr>'
  elsif options[:devant_eleve] == false
    node += '<attr name="ENTAuxEnsCategoDiscipline"><value>13$MATHEMATIQUES</value></attr>
<attr name="ENTAuxEnsDisciplinesPoste"><value>MATHEMATIQUES$13</value></attr>
<attr name="ENTAuxEnsMEF"><value/></attr>
<attr name="ENTAuxEnsMatiereEnseignEtab"><value/></attr>
<attr name="ENTAuxEnsClasses"><value/></attr>
<attr name="ENTAuxEnsGroupes"><value/></attr>
<attr name="ENTAuxEnsClassesPrincipal"><value/></attr>
<attr name="ENTPersonFonctions"><value>1234$ENS$ENSEIGNEMENT$L1300$MATHEMATIQUES</value></attr>
<attr name="PersEducNatPresenceDevantEleves"><value>N</value></attr>'
  else
    node += '<attr name="ENTAuxEnsCategoDiscipline"><value>00$NON SPECIALISE</value></attr>
<attr name="ENTAuxEnsDisciplinesPoste"><value>ORIENTATION$00</value></attr>
<attr name="ENTAuxEnsMEF"><value/></attr>
<attr name="ENTAuxEnsMatiereEnseignEtab"><value/></attr>
<attr name="ENTAuxEnsClasses"><value/></attr>
<attr name="ENTAuxEnsGroupes"><value/></attr>
<attr name="ENTAuxEnsClassesPrincipal"><value/></attr>
<attr name="ENTPersonFonctions"><value>1234$ORI$ORIENTATION$O0040$ORIENTATION</value></attr>
<attr name="PersEducNatPresenceDevantEleves"><value>N</value></attr>'
  end
  node += '</attributes>
</addRequest>'
  Nokogiri::XML(node).css("addRequest, modifyRequest").first
end

################### Sample XML DATA ###########
################### Etablissement   ###########
def get_etab()
  node = '<addRequest>
<operationalAttributes><attr name="categorieStructure"><value>EtabEducNat</value></attr></operationalAttributes> 
<identifier><id>4144</id></identifier> 
<attributes> 
<attr name="ENTStructureJointure"><value>4144</value></attr>
<attr name="ENTStructureUAI"><value>0011241U</value></attr>
<attr name="ENTEtablissementUAI"><value>0011241U</value></attr>
<attr name="ENTStructureSIREN"><value>17010431900323</value></attr>
<attr name="ENTStructureNomCourant"><value>SCE IA-INSPECTION ACADEMIQUE AIN-ac-LYON</value></attr>
<attr name="ENTStructureTypeStruct"><value>SERVICE DE L INSPECTION ACADEMIQUE</value></attr>
<attr name="ENTEtablissementMinistereTutelle"><value>MINISTERE DE L&apos;EDUCATION NATIONALE</value></attr>
<attr name="ENTEtablissementContrat"><value>PU</value></attr>
<attr name="postOfficeBox"><value/></attr>
<attr name="street"><value>7 AVENUE JEAN-MARIE VERNE</value></attr>
<attr name="postalCode"><value>01000</value></attr>
<attr name="l"><value>BOURG EN BRESSE</value></attr>
<attr name="telephoneNumber"><value>+33 4 74 21 29 28</value></attr>
<attr name="facsimileTelephoneNumber"><value/></attr>
<attr name="ENTEtablissementStructRattachFctl"><value/></attr>
<attr name="ENTEtablissementBassin"><value/></attr>
<attr name="ENTServAcAcademie"><value>LYON</value></attr>
<attr name="ENTStructureClasses"><value/></attr>
<attr name="ENTStructureGroupes"><value/></attr>
</attributes>
</addRequest>'
 Nokogiri::XML(node).css("addRequest, modifyRequest").first
end

describe Alimentation::ParserXmlMongo do

  CATEGORIE_ELEVE = "Eleve"
  CATEGORIE_REL_ELEVE = "PersRelEleve"
  CATEGORIE_PEN = "PersEducNat"
  CATEGORIE_MEF = "MefEducNat"
  CATEGORIE_ETAB = "EtabEducNat"

## important notes : date format 

  it "parse well an eleve user" do
    p = ParserTest.new
    eleve = p.parse_user(get_eleve_xml(), CATEGORIE_ELEVE)
    eleve.should_not == nil
    eleve["prenom"].should == "Michèle"
    eleve["sexe"].should == 'F'
    eleve["nom"].should == 'RODRIGUEZ'
    eleve["id_jointure_aaf"].should == 123456
  end
  
  
  it "Generate a WrongDataError if no identifier" do
    p = ParserTest.new
    expect{
      eleve = p.parse_user(get_eleve_xml({:no_identifier => true}), CATEGORIE_ELEVE)
    }.to raise_error(Alimentation::WrongDataError)
  end


  it "Generate a WrongDataError if wrong identifier" do
    p = ParserTest.new
    expect{
      eleve = p.parse_user(get_eleve_xml({:wrong_identifier => true}), CATEGORIE_ELEVE)
    }.to raise_error(Alimentation::WrongDataError)
  end
  
  it "Generate a MissingDataError if no id_jointure_aaf" do
    p = ParserTest.new
    expect{
      eleve = p.parse_user(get_eleve_xml({:no_id_jointure => true}), CATEGORIE_ELEVE)
    }.to raise_error(Alimentation::MissingDataError)
  end

  it "Generate WrongDataError with wrong categorie" do
    p = ParserTest.new
    expect{
      eleve = p.parse_user(get_eleve_xml(), CATEGORIE_PEN)
    }.to raise_error(Alimentation::WrongDataError)
  end


  it "Generate a MissingDataError if no date naissance given for an eleve" do
    p = ParserTest.new
    expect{
      eleve = p.parse_user(get_eleve_xml({:no_date_naiss => true}), CATEGORIE_ELEVE)
    }.to raise_error(Alimentation::MissingDataError)
    # Pas de problème pour les parents
    p = p.parse_user(get_rel_eleve_xml(), CATEGORIE_REL_ELEVE) 
  end

  it "Generate a MissingDataError if no ENTPersonStructRattach on parse_eleve" do
    p = ParserTest.new
    expect{
      node = get_eleve_xml({:no_struct_rattach => true})
      eleve = p.parse_user(node, CATEGORIE_ELEVE)
      p.parse_eleve(node, eleve)
    }.to raise_error(Alimentation::MissingDataError)
  end

  it "Handle all the relation_eleve for an eleve" do
    p = ParserTest.new
    node = get_eleve_xml
    eleve = p.parse_user(node, CATEGORIE_ELEVE)
    p.parse_eleve(node, eleve)
    p.db.collection("relation_eleve").count.should == 2
    p.db.collection("relation_eleve").find({"type_relation_eleve_id" => 1}).count.should == 1
    p.db.collection("relation_eleve").find({"type_relation_eleve_id" => 2}).count.should == 1
    p.db.collection("relation_eleve").find({"type_relation_eleve_id" => 3}).count.should == 0
    p.db.collection("profil_user").find({"profil_id" => "PAR"}).count.should == 2
  end


  it "Parse well eleve regroupement" do
    p = ParserTest.new
    node = get_eleve_xml()
    eleve = p.parse_user(node, CATEGORIE_ELEVE)
    p.parse_regroupement(node, "ENTEleveClasses", "CLS", eleve)
    p.db.collection("membre_regroupement").count.should == 1
    p.parse_regroupement(node, "ENTEleveGroupes", "GRP", eleve)
    p.db.collection("membre_regroupement").count.should == 2
    p.db.collection("regroupement").count.should == 2
  end


  it "Parse well eleve regroupement in parse_eleve" do
    p = ParserTest.new
    node = get_eleve_xml()
    eleve = p.parse_user(node, CATEGORIE_ELEVE)
    p.parse_eleve(node, eleve)
    p.db.collection("membre_regroupement").count.should == 2
    p.db.collection("membre_regroupement").find({"user" => eleve}).count.should == 2
  end


  it "Generate WrongDataError when more than one classe given for an eleve" do
    p = ParserTest.new
    node = get_eleve_xml({:two_classes => true})
    eleve = p.parse_user(node, CATEGORIE_ELEVE)
    expect{
      p.parse_regroupement(node, "ENTEleveClasses", "CLS", eleve)
    }.to raise_error(Alimentation::WrongDataError)
  end


  it "Parse well multiple_attr_etb" do
    p = ParserTest.new
    node = Nokogiri::XML('<attr name="ENTEleveClasses"><value>1234$4E3</value><value>1234$4E5</value></attr>')
    p.get_multiple_attr_etb(node, "ENTEleveClasses").should == ["4E3", "4E5"]
    node = Nokogiri::XML('<attr name="ENTEleveClasses"><value>1234$4E3</value><value>4567$4E5</value></attr>')
    p.get_multiple_attr_etb(node, "ENTEleveClasses").should == ["4E3"]
  end


  it "Parse well a PersRelEleve" do
    p = ParserTest.new
    node = get_rel_eleve_xml
    rel_eleve = p.parse_user(node, CATEGORIE_REL_ELEVE)
    p.parse_pers_rel_eleve(node, rel_eleve)
    p.db.collection("telephone").count.should == 2
    p.db.collection("telephone").find({"type_telephone_id" => 'MAIS'}).count.should == 1
    p.db.collection("telephone").find({"type_telephone_id" => 'AUTR'}).count.should == 1
    
    ##pp p.db.collection("telephone").find.to_a
  end
  
  it "Detect mobil numbers" do
    p = ParserTest.new
    node = get_rel_eleve_xml({:home_phone_is_port => true})
    rel_eleve = p.parse_user(node, CATEGORIE_REL_ELEVE)
    p.parse_pers_rel_eleve(node, rel_eleve)
    p.db.collection("telephone").count.should == 2
    p.db.collection("telephone").find({"type_telephone_id" => 'PORT'}).count.should == 1
  end


  it "Parse well a PEN enseignant" do
    p = ParserTest.new
    node = get_pen({:devant_eleve => true})
    #puts "------XML------- \n"
    pen = p.parse_user(node, CATEGORIE_PEN)
    p.parse_pen(node, pen)
    p.db.collection("regroupement").count.should == 5
    p.db.collection("enseigne_regroupement").count.should == 5
    p.db.collection("email").count.should == 1
    mail = p.db.collection("email").find_one
    mail["academique"].should == true
    p.db.collection("profil_user").find({"profil_id" => 'ENS'}).count.should == 1
  end
  

  it "Parse well a PEN enseignant pas devant eleve" do
    p = ParserTest.new
    node = get_pen({:devant_eleve => false})
    pen = p.parse_user(node, CATEGORIE_PEN)
    p.parse_pen(node, pen)
    p.db.collection("enseigne_regroupement").count.should == 0
    p.db.collection("profil_user").find({"profil_id" => 'ENS'}).count.should == 1
  end


  it "Parse well a PEN Orientation" do
    p = ParserTest.new
    node = get_pen()
    pen = p.parse_user(node, CATEGORIE_PEN)
    p.parse_pen(node, pen)
    p.db.collection("enseigne_regroupement").count.should == 0
    p.db.collection("profil_user").find({"profil_id" => 'ORI'}).count.should == 1
  end
  
  # add tests for parsing etablissements

  it "parse well an etablissemenet" do 
    p = ParserTest.new 
    node = get_etab()
    #puts "-------------\n"
    #pp node
    p.parse_etab_educ_nat(node)
    puts "-------"
    pp p.db.collection("etablissement").find.to_a  
  end
  
  ## matiere and mef in onother file


  it "parses an Eleve file and fill memory_db with correct number of records" do 
    p = ParserTest.new
    # write data to file maybe
    # befor parsing
    p.db.collection("users").count.should == 0
    p.parse_file('file_Eleve_test.xml')
    # after parsing  => add 2 users(eleve)
    # add all users ids to the memory db 
    p.db.collection("users").count.should == 6
    #puts "-----\n"
    #pp p.db.collection("users").find.to_a
    
  end

  it "parses an EtabEducNat(etablissement) and fill memory_db with correct data and number of records"  do
    p = ParserTest.new
    #befor parsing
    p.db.collection("etablissement").count.should  == 0
    p.parse_file('file_EtabEducNat_test.xml')
    #after parsing  => add 2 etablissements
    p.db.collection("etablissement").count.should == 3
    #puts "---------------\n"
    #pp p.db.collection("etablissement").find.to_a
   end
   
end
