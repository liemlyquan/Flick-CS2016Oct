# FLICK

A quick program to show now playing and top rated movie based on the database from [The Movie Database API](http://docs.themoviedb.apiary.io/)

### Time spent:
approximately 11 hours in total

### Feature
##### Required
* [x] User can view a list of movies currently playing in theaters from The Movie Database. Poster images must be loaded asynchronously.
* [x] User can view movie details by tapping on a cell.
* [x] User sees an error message when there's a networking error. You may not use UIAlertController or a 3rd party library to display the error.
* [x] User can pull to refresh the movie list.

##### Optional
* [x] Add a tab bar for Now Playing or Top Rated movies. (high)
* [x] Implement a UISegmentedControl to switch between a list view and a grid view. (high)
* [x] Add a search bar. (med)
* [x] All images fade in as they are loading. (low)
* [x] For the large poster, load the low-res image first and switch to high-res when complete. (low)
* [x] Customize the highlight and selection effect of the cell. (low)
* [x] Customize the navigation bar. (low)

### Known issues
* High quality image may not be used in many cases, especially when after filtered by search bar
* DZNEmptyDataSet incompatibility with Refresh Control. Cannot use pull to refresh when data set is empty
* Refresh control cannot be added to BOTH table view and collection view at the same time (even tried added two different instance)

### Reflection
* Should have spend more time trying to perfect the features rather than rushing through all the features. :(

### Walkthrough of the app
![App Walkthrough](https://raw.githubusercontent.com/liemlyquan/Flick-CS2016Oct/master/Flick.gif)

GIF created with LiceCap.
## License

Copyright [2016] [Ly Quan Liem]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.