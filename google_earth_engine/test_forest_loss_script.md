https://code.earthengine.google.com/f7a08d792ac6e3cb4eb2dd499c8f3c01

// Calculating forest cover change in test red panda habitat
// Cameron Cosgrove
// 26th Jan 2019

Map.addLayer(hansen);
Map.addLayer(test_habitat);
Map.addLayer(borders);

var panda_countries = borders.filter(
    ee.Filter.eq("country_na", "Bhutan"));
    
Map.addLayer(panda_countries)
// Set the scale for our calculations to the scale of the Hansen dataset
// which is 30m
var scale = hansen.projection().nominalScale();

// Create a variable for the original tree cover in 2000
var treeCover = hansen.select(['treecover2000']);

// Convert the tree cover layer because the treeCover by default is in
// hundreds of hectares, but the loss and gain layers are just in hectares!
treeCover = treeCover.divide(1);

// Create a variable for forest loss
var loss = hansen.select(['loss']);

// Create a variable for forest gain
var gain = hansen.select(['gain']);

// Add the tree cover layer in light grey
Map.addLayer(treeCover.updateMask(treeCover),
    {palette: ['D0D0D0', '00FF00'], max: 100}, 'Forest Cover');

// Add the loss layer in pink
Map.addLayer(loss.updateMask(loss),
            {palette: ['#BF619D']}, 'Loss');

// Add the gain layer in yellow
Map.addLayer(gain.updateMask(gain),
            {palette: ['#CE9E5D']}, 'Gain');
            
// The units of the variables are numbers of pixels
// Here we are converting the pixels into actual area
// Dividing by 10 000 so that the final result is in km2
var areaCover = treeCover.multiply(ee.Image.pixelArea())
                .divide(1).select([0],["areacover"]);

var areaLoss = loss.gt(0).multiply(ee.Image.pixelArea()).multiply(treeCover)
              .divide(1).select([0],["arealoss"]);

var areaGain = gain.gt(0).multiply(ee.Image.pixelArea()).multiply(treeCover)
              .divide(1).select([0],["areagain"]);
              
// Sum the values of loss pixels.
var statsLoss = areaLoss.reduceRegions({
  reducer: ee.Reducer.sum(),
  collection: panda_countries,
  scale: scale
});

// Sum the values of gain pixels.
var statsGain = areaGain.reduceRegions({
  reducer: ee.Reducer.sum(),
  collection: panda_countries,
  scale: scale
});

// Sum the values of Cover pixels.
var statsCover = areaCover.reduceRegions({
  reducer: ee.Reducer.sum(),
  collection: panda_countries,
  scale: scale
});

Export.table.toDrive({
  collection: statsLoss,
  description: 'bhutan_panda_forest_loss'});
  
Export.table.toDrive({
  collection: statsGain,
  description: 'bhutan_panda_forest_gain'});
  
Export.table.toDrive({
  collection: statsCover,
  description: 'bhutan_panda_forest_cover'});
