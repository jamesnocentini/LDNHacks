app = angular.module('LDNHacks.directives', [])

#This directive is in each hackathon div and gets the list of participants
app.directive 'participants', ($http, $timeout) ->
  #Controller for each 'participants' directive
  controller = ($scope) ->
    $scope.participants = ''
    $http.get('participants/'+$scope.hackathon.index).success((data) ->
      $scope.participants = data
      $scope.test = "HEY"
    )

  #Add user to list of participants
  linker = (scope, element) ->
    reply = ''
    #Checks if the user is in scope.participants (array)
    checkParticipants = (callback) ->
      scope.participants.forEach((participant) ->
        #He is
        if scope.user.screen_name == participant.screen_name
          reply = "Already attending"
          console.log(reply)
          return reply
        #He's not
        else
      )
      callback()

    console.log(scope.participants)


    scope.participateAndUpdateView = () ->
      if scope.user.screen_name == 'Guest'
        #The user is not logged in
        alert "Please log in!"
        return
      else
        #The user is logged in
        #Check if he is in the list of participants
        checkParticipants(() ->
          if reply == "Already attending"
            #He is in the list
            alert("Already attending")
            return
          else
            #He is not
            scope.participants.push({hackathon: scope.hackathon.what, screen_name: scope.user.screen_name, profile_pic: scope.user.profile_pic})
            console.log(scope.participants)
            #Tell the controller to execute the POST
            scope.participate(scope.hackathon.index)
            element.children().addClass("green")
            element.children().removeClass("grey")
            element.children("button").html("I'm Going!")
        )

    #When user is connected load state of buttons
    #Settimeout necessary because the code in the linking function executes before the controller code ($http.get)
    setTimeout ( ->
      checkParticipants(() ->
        if reply == "Already attending"
          element.children().addClass("green")
          element.children().removeClass("grey")
          element.children("button").html("I'm Going!")
          return
        else
      )
    ), 1000

  return {
    restrict: "E",
    controller: controller,
    link: linker
  }



app.directive 'signin', () ->
  linker = (scope, element) ->
    setTimeout ( ->
      if scope.user.screen_name == 'Guest'
        return
      else
        element.html("Signed in as "+scope.user.screen_name)
    ), 400

  return {
    restrict: "E",
    link: linker
  }