
``` Map.addLayer(gfc);
var treeCover = gfc.select(['treecover2000']);


// Perform Canny edge detection and display the result.
var canny = ee.Algorithms.CannyEdgeDetector({
  image: treeCover, threshold: 10, sigma: 1
});
Map.setCenter(-122.054, 37.7295, 10);
Map.addLayer(canny, {}, 'canny');

var edge = canny.multiply(ee.Image.pixelArea())
```


![alt text](/images/edge_test)
