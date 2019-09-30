import ee
import datetime
ee.Initialize()

corridor = ee.Geometry.Polygon([[23.59794820675529,-17.92443787510395],[23.598291529509197,-17.90810417359222],[23.60996450314201,-17.88980864142204],[23.61442769894279,-17.86366889569713],[23.612367762419353,-17.846349196906182],[23.558466090056072,-17.858113704340248],[23.563615931364666,-17.87543225726971],[23.565675867888103,-17.90875755055333],[23.56430257687248,-17.923784555951116],[23.59794820675529,-17.92443787510395]])
bb = ee.Geometry.Polygon([[23.503795091104962,-17.945111296227406], [23.763347093058083,-17.945111296227406], [23.763347093058083,-17.790879261804], [23.503795091104962,-17.790879261804], [23.503795091104962,-17.945111296227406]])
region = ee.Geometry.Polygon([[23.539520449050315,-17.851829360100737],[23.870826906569846,-17.82895240705628],[23.86773700178469,-17.79920797603527],[23.537803835280783,-17.828298736637873],[23.539520449050315,-17.851829360100737]])

month = datetime.datetime.now().month

collection = ee.ImageCollection('COPERNICUS/S1_GRD').filterBounds(bb).filterDate('2019-06-01', '2019-11-01').filter(ee.Filter.calendarRange(month,month,'month')).select('VV','VH').median()

input = collection
training = input.sample(region, 10)
clusterer = ee.Clusterer.wekaKMeans(2).train(training)
result_raw = input.clip(bb).cluster(clusterer)
result = result_raw.reproject("EPSG:4326", None, 50)

sum_1 = ee.Number(ee.Image(1).clip(corridor).updateMask(result.eq(0)).reduceRegion(ee.Reducer.sum(), corridor, 50, "EPSG:4326").get('constant'))
sum_2 = ee.Number(ee.Image(1).clip(corridor).updateMask(result.eq(1)).reduceRegion(ee.Reducer.sum(), corridor, 50, "EPSG:4326").get('constant'))
cleared = sum_1.multiply(sum_1.lt(sum_2)).add(sum_2.multiply(sum_2.lt(sum_1)))
area = ee.Number(ee.Image(1).reduceRegion(ee.Reducer.sum(), corridor, 50, "EPSG:4326").get('constant'))
final = cleared.divide(area.divide(100)).round()

print(final.getInfo())


