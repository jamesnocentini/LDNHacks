app = angular.module('LDNHacks', ['LDNHacks.directives'])


@HackathonListCtrl = ($scope, $http) ->
  $scope.hackathons = [
    {
      "what": "#WOWhack - Celebrate Women of the World"
      "when": "Saturday, March 9, 2013 9:00 AM"
      "where": "Southbank Centre"
      "about": "The aim is to work together over the course of a weekend to build usable software solutions that make healthcare safer, more efficient and maybe even more fun!"
      "img": "http://rewiredstate.org/uploads/default/hacks/wow_series_2013.jpg"
      "rsvp": "http://rewiredstate.org/hacks/wowhack"
      "index": "hack1"
    },
    {
      "what": "NHS Hack Scotland"
      "when": "Saturday, March 23, 2013 9:00 AM"
      "where": "Tech Cube"
      "about": "The aim is to work together over the course of a weekend to build usable software solutions that make healthcare safer, more efficient and maybe even more fun!"
      "img": "https://si0.twimg.com/profile_images/3158343987/471959e73a96c2ac9604b829ed1ad03f.jpeg"
      "rsvp": "http://nhshackscotland.org.uk/"
      "index": "hack2"
    },
    {
      "what": "National Hack the Government #NHTG13"
      "when": "Saturday, April 6, 2013"
      "where": "Needs a location (coming soon)"
      "about": "The National Hack The Government Day Hack invites you to join us to build software, visualizations and other creations that puts the government’s meticulously-compiled facts and figures to good use. You will have free reign over the data, able to build and showcase what is important to you and what you think is important to others. It's an exiting opportunity for developers, designers and tech heads to visualize data in new and interesting ways, or build frameworks that make it easier for future software to tap into it."
      "img": "http://www.smarta.com/umbraco/ImageGen.ashx?image=/media/3375911/youngrewiredstatelogo.jpg&width=500"
      "rsvp": "http://rewiredstate.org/hacks/national-hack-the-government-2013"
      "index": "hack3"
    },
    {
    "what": "Urban Prototyping London"
    "when": "Friday, April 19, 2013 6:00 PM"
    "where": "Imperial College London"
    "about": "You will be challenged to create technology solutions that result in real-world change in terms of environment, local economy or local community. You will have the weekend to work on a mobile hack, game, mobile site or API mash-up that engages citizens to overcome the serious challenges that our society faces. It doesn't have to be the finished product, as long as its something that shows potential; there will be plenty of support to turn it into a polished, end-user-ready app or solution."
    "img": "http://ukdisabilityhistorymonth.com/storage/imperial_college_london%20LOGO.jpg?__SQUARESPACE_CACHEVERSION=1352847194189"
    "rsvp": "http://uplondonhackathon.eventbrite.co.uk/"
    "index": "hack4"
    }
  ]


  $scope.user = ''
  #Get the user state (guest or logged in)
  $http.get('auth/twitter/user').success((data) ->
    $scope.user = data
  )
  #POST participant infos
  $scope.participate = (hack) ->
    #If user is not logged in, tell him

      $scope.participant = {hackathon: hack, screen_name: $scope.user.screen_name, profile_pic: $scope.user.profile_pic}


      $http.post('/participate', $scope.participant).success((data) ->

      console.log($scope.participant)

      )

    $scope.fetch2 = () ->
      alert("Hey 2")


