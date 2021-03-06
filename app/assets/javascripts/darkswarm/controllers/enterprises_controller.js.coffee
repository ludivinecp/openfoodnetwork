Darkswarm.controller "EnterprisesCtrl", ($scope, $rootScope, $timeout, Enterprises, Search, $document, HashNavigation, FilterSelectorsService, EnterpriseModal, enterpriseMatchesNameQueryFilter, distanceWithinKmFilter) ->
  $scope.Enterprises = Enterprises
  $scope.totalActive = FilterSelectorsService.totalActive
  $scope.clearAll = FilterSelectorsService.clearAll
  $scope.filterText = FilterSelectorsService.filterText
  $scope.FilterSelectorsService = FilterSelectorsService
  $scope.query = Search.search()
  $scope.openModal = EnterpriseModal.open
  $scope.activeTaxons = []
  $scope.show_profiles = false
  $scope.filtersActive = false
  $scope.distanceMatchesShown = false


  $scope.$watch "query", (query)->
    Enterprises.flagMatching query
    Search.search query
    $rootScope.$broadcast 'enterprisesChanged'
    $scope.distanceMatchesShown = false

    $timeout ->
      Enterprises.calculateDistance query, $scope.firstNameMatch()
      $rootScope.$broadcast 'enterprisesChanged'


  $rootScope.$on "enterprisesChanged", ->
    $scope.filterEnterprises()
    $scope.updateVisibleMatches()


  # When filter settings change, this could change which name match is at the top, or even
  # result in no matches. This affects the reference point that the distance matches are
  # calculated from, so we need to recalculate distances.
  $scope.$watch '[activeTaxons, shippingTypes, show_profiles]', ->
    $timeout ->
      Enterprises.calculateDistance $scope.query, $scope.firstNameMatch()
      $rootScope.$broadcast 'enterprisesChanged'
  , true


  $rootScope.$on "$locationChangeSuccess", (newRoute, oldRoute) ->
    if HashNavigation.active "hubs"
      $document.scrollTo $("#hubs"), 100, 200


  $scope.filterEnterprises = ->
    es = Enterprises.hubs
    $scope.nameMatches = enterpriseMatchesNameQueryFilter(es, true)
    $scope.distanceMatches = enterpriseMatchesNameQueryFilter(es, false)
    $scope.distanceMatches = distanceWithinKmFilter($scope.distanceMatches, 50)


  $scope.updateVisibleMatches = ->
    $scope.visibleMatches = if $scope.nameMatches.length == 0 || $scope.distanceMatchesShown
      $scope.nameMatches.concat $scope.distanceMatches
    else
      $scope.nameMatches


  $scope.showDistanceMatches = ->
    $scope.distanceMatchesShown = true
    $scope.updateVisibleMatches()


  $scope.firstNameMatch = ->
    if $scope.nameMatchesFiltered?
      $scope.nameMatchesFiltered[0]
    else
      undefined
