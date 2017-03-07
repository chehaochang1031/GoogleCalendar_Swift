# GoogleCalendar_Swift
It's a way to use Google Calendar API by using Swift 3.0 in iOS 10.0+.

Google is changing its Oauth policies, with this it is intended that no native web views initiate Oauth flows. There are some situations showed up when I try to get the authorizer. 

Based on Google Calendar Quickstart: https://developers.google.com/google-apps/calendar/quickstart/ios?ver=swift#further_reading

I received 403 error: disallowed_useragent on my phone. It means that this app was disable to use native web views to initiate Oauth flows.  

In my project, I use Google SignIn framework instead of GTMOAuth2ViewControllerTouch to get user's authorizer. 

Requirements: 
swift 3.0
