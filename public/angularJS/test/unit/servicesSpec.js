'use strict';

/* jasmine specs for services go here */

describe('service', function() {
  beforeEach(module('myApp.services'));


  describe('version', function() {
    it('should return current version', inject(function(version) {
      expect(version).toEqual('0.1');
    }));
  });

  describe('Etablissement', function(){
  	it('should return an Etablissement factory', inject(function(Etablissement){
  		var etab = Etablissement.get({id: '1'}); 
  		expect(etab.nom).toEqual('ERASME'); 
  	}));
  }); 
});
