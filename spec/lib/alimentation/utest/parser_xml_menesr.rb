#coding: utf-8
require_relative '../../../helper'

# Classe qui initialise les données qui vont bien pour les tests
class ParserTest < Alimentation::ParserXmlMenesr
  def initialize
    init_memory_db()
    @cur_etb_uai = '0690000X'
    @cur_etb_xml_id = 1234
    @cur_etb = @cur_etb_data[:etablissement].find_or_add({:code_uai => @cur_etb_uai})
  end
end

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
<attr name="ENTEleveAutoriteParentale"><value>123457</value><value>123458</value></attr>
<attr name="ENTElevePersRelEleve1"><value>123459</value></attr>
<attr name="ENTEleveQualitePersRelEleve1"><value>CONTACT</value></attr>
<attr name="ENTElevePersRelEleve2"><value>123460</value></attr>
<attr name="ENTEleveQualitePersRelEleve2"><value>CONTACT</value></attr>
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
  node += '<attr name="ENTEleveClasses"><value>1234$4E3</value></attr>
<attr name="ENTEleveGroupes"><value/></attr>
</attributes>
</addRequest>'
  Nokogiri::XML(node).css("addRequest, modifyRequest").first
end

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
<attr name="personalTitle"><value>M.</value></attr>
<attr name="homePhone"><value>+33 6 12 34 56 78</value></attr>
<attr name="telephoneNumber"><value>+33 4 12 34 58 78</value></attr>
<attr name="ENTPersonAdresse"><value>3 RUE KARATE</value></attr>
<attr name="ENTPersonCodePostal"><value>69110</value></attr>
<attr name="ENTPersonVille"><value>STE FOY LES LYON</value></attr>
<attr name="ENTPersonPays"><value>FRANCE</value></attr>
</attributes>
</addRequest>'
  Nokogiri::XML(node).css("addRequest, modifyRequest").first
end

describe Alimentation::ParserXmlMenesr do

  CATEGORIE_ELEVE = "Eleve"
  CATEGORIE_REL_ELEVE = "PersRelEleve"
  CATEGORIE_PEN = "PersEducNat"

  it "parse well an eleve user" do
    p = ParserTest.new
    eleve = p.parse_user(get_eleve_xml(), CATEGORIE_ELEVE)
    eleve.should.not == nil
    eleve[:prenom].should == "Michèle"
    eleve[:sexe].should == 'F'
    eleve[:nom].should == 'RODRIGUEZ'
    eleve[:id_jointure_aaf].should == 123456
  end

  it "Generate a WrongDataError if no identifier" do
    p = ParserTest.new
    should.raise Alimentation::WrongDataError do
      eleve = p.parse_user(get_eleve_xml({:no_identifier => true}), CATEGORIE_ELEVE)
    end
  end

  it "Generate a WrongDataError if wrong identifier" do
    p = ParserTest.new
    should.raise Alimentation::WrongDataError do
      eleve = p.parse_user(get_eleve_xml({:wrong_identifier => true}), CATEGORIE_ELEVE)
    end
  end

  it "Generate a MissingDataError if no id_jointure_aaf" do
    p = ParserTest.new
    should.raise Alimentation::MissingDataError do
      eleve = p.parse_user(get_eleve_xml({:no_id_jointure => true}), CATEGORIE_ELEVE)
    end
  end

  it "Generate WrongDataError with wrong categorie" do
    p = ParserTest.new
    should.raise Alimentation::WrongDataError do
      eleve = p.parse_user(get_eleve_xml(), CATEGORIE_PEN)
    end
  end

  it "Generate a MissingDataError if no date naissance given for an eleve" do
    p = ParserTest.new
    should.raise Alimentation::MissingDataError do
      eleve = p.parse_user(get_eleve_xml({:no_date_naiss => true}), CATEGORIE_ELEVE)
    end
    # Pas de problème pour les parents
    p = p.parse_user(get_rel_eleve_xml(), CATEGORIE_REL_ELEVE) 
  end

  it "Generate a MissingDataError if no ENTPersonStructRattach on parse_eleve" do
    p = ParserTest.new
    should.raise Alimentation::MissingDataError do
      eleve = p.parse_user(get_eleve_xml({:no_struct_rattach => true}), CATEGORIE_ELEVE)
      p.parse_eleve(get_eleve_xml({:no_struct_rattach => true}), eleve)
    end
  end
end