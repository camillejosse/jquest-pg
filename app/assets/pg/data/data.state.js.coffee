angular.module 'jquest'
  .config ($stateProvider)->
    'ngInject'
    $stateProvider
      .state 'main.season.pg.data',
        url: 'data'
        controller: 'MainSeasonPgDataCtrl'
        controllerAs: 'data'
        templateUrl: 'data/data.html'
        params:
          person_fullname_or_legislature_name_cont:
            value:null
          legislature_country_eq:
            value:null
          legislature_territory_cont:
            value:null
          legislature_id_eq:
            value:null
        resolve:
          $title: ->
            'Collected Data'
          mandatures: (seasons, seasonRestangular, $stateParams)->
            'ngInject'
            seasonRestangular.all('mandatures').getList($stateParams)
