import requests
from geopy.geocoders import GoogleV3

# Get the user's IP address
ip_address = requests.get('https://api.ipify.org').text

# Create a geocoder
geolocator = GoogleV3()

# Get the user's location
location = geolocator.geocode(ip_address)

# Print the user's location
print(location.address)

# # Get the user's location
# if navigator.geolocation:
#     position = navigator.geolocation.getCurrentPosition()
#     latitude = position.coords.latitude
#     longitude = position.coords.longitude
#     print("The user's location is {latitude}, {longitude}")
# else:
#     print('The user has not granted permission to access their location.')
