# FLICK

A quick program to show now playing and top rated movie based on the database from [The Movie Database API](http://docs.themoviedb.apiary.io/)

### Time spent:
approximately 2+2+2 hours in total

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

### Walkthrough of the app
![App Walkthrough](https://raw.githubusercontent.com/liemlyquan/Flick-CS2016Oct/master/gif/Flick.gif)

GIF created with LiceCap.


<div>Icons made by <a href="http://www.flaticon.com/authors/alfredo-hernandez" title="Alfredo Hernandez">Alfredo Hernandez</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>