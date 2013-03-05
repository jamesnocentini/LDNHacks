app = angular.module('LDNHacks.directives', [])

#This directive is in each hackathon div and gets the list of participants
app.directive 'participants', ($http) ->
  controller = ($scope) ->
    $scope.participants = ''
    $http.get('participants/'+$scope.hackathon.index).success((data) ->
      $scope.participants = data
      $scope.test = "HEY"
    )



  #Add user to list of participants
  linker = (scope) ->
    scope.participateAndUpdateView = () ->
      if scope.user.screen_name == 'Guest'
        alert "Please log in!"
        return
      else
        scope.participants.push({hackathon: scope.hackathon.what, screen_name: scope.user.screen_name, profile_pic: scope.user.profile_pic})
        console.log(scope.participants)
        #Tell the controller to execute the POST
        scope.participate(scope.hackathon.index)

  return {
    restrict: "E",
    controller: controller,
    link: linker
  }