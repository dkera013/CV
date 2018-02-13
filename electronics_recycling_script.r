library(kernlab)
library(caret)
library(RMySQL)
library(googleVis)
library(plyr)
library(dplyr)


##con<-dbConnect(MySQL(),user="ikera",password="p49p0DbW",dbname="electronics_recycling_2",host="158.125.161.156")
con<-dbConnect(MySQL(),user="root",password="password",dbname="electronics_recycling_2",host="localhost")



process_history_tbl<-dbReadTable(con,"process_history")
product_tbl<-dbReadTable(con,"product")
product_type_tbl<-dbReadTable(con,"product_type")


####two tables join
joined<-dbGetQuery(con,"SELECT * ,timestampdiff(SECOND,start_time,end_time) as duration
                        FROM product, process_history
                        WHERE product.idproduct = process_history.product_idproduct")

#####the same. 3 tables joined
process_history1<-dbGetQuery(con,"SELECT product.idproduct, product_type_idproduct_type, start_time, end_time, process_history.process_types_idprocess_types, type 
                        FROM product, process_types, process_history
                        WHERE product.idproduct = process_history.product_idproduct
                        AND process_types.idprocess_types = process_history.process_types_idprocess_types")
# #####the same
process_history2<-dbGetQuery(con,"SELECT P.idproduct, product_type_idproduct_type, PH.process_types_idprocess_types, 
type
FROM product P, process_types PT, process_history PH
WHERE PH.product_idproduct = P.idproduct
AND PH.process_types_idprocess_types = PT.idprocess_types")
# 

times<-dbGetQuery(con,"SELECT TIMESTAMPDIFF(SECOND, assetTrack.start_time,assetTrack.end_time), TIMESTAMPDIFF(SECOND, visualInspect.start_time,visualInspect.end_time), TIMESTAMPDIFF(SECOND, dataErasure.start_time,dataErasure.end_time), TIMESTAMPDIFF(SECOND, functionalTest.start_time,functionalTest.end_time), TIMESTAMPDIFF(SECOND, assetTrack.start_time,functionalTest.end_time) 
                 FROM process_history assetTrack 
                  JOIN product b ON b.idproduct = assetTrack.product_idproduct 
                  JOIN process_history visualInspect ON visualInspect.product_idproduct = assetTrack.product_idproduct 
                  JOIN process_history dataErasure ON dataErasure.product_idproduct = assetTrack.product_idproduct 
                  JOIN process_history functionalTest ON functionalTest.product_idproduct = assetTrack.product_idproduct 
                  WHERE assetTrack.process_types_idprocess_types = '1' 
                  AND visualInspect.process_types_idprocess_types = '2' 
                  AND dataErasure.process_types_idprocess_types = '4' 
                  AND functionalTest.process_types_idprocess_types = '5' 
                  AND b.product_type_idproduct_type = '1'")
# #####count and group by process or product
# 
count<-dbGetQuery(con,"SELECT a.process_types_idprocess_types,COUNT(*) as frequency,b.type
                  FROM process_history a JOIN process_types b ON a.process_types_idprocess_types = b.idprocess_types
                  GROUP BY process_types_idprocess_types")
# 
# 
history<-dbGetQuery(con, "SELECT a.product_type_idproduct_type, COUNT(*), b.type 
                    FROM product a 
                    JOIN product_type b ON a.product_type_idproduct_type = b.idproduct_type 
                    GROUP BY product_type_idproduct_type")
# ####or using where
history2<-dbGetQuery(con,"SELECT a.product_type_idproduct_type, b.type, COUNT( * ) 
                    FROM product a, product_type b
                    WHERE b.idproduct_type = a.product_type_idproduct_type
                    GROUP BY product_type_idproduct_type")
# 
# ####or
number_of_processes_in_history<-dbGetQuery(con,"SELECT process_types_idprocess_types, COUNT( * ) 
FROM process_history
GROUP BY process_types_idprocess_types
")
# 
# #####sold products until now. comments in sql
last<-dbGetQuery(con,"SELECT COUNT(*), c.type FROM process_history a 
                 JOIN product b ON b.idproduct = a.product_idproduct 
                 JOIN product_type c ON c.idproduct_type = b.product_type_idproduct_type 
                 JOIN process_history assetTrack ON assetTrack.product_idproduct = b.idproduct 
                 WHERE a.process_types_idprocess_types = '10' 
                 AND assetTrack.process_types_idprocess_types = '1' /*AND a.pass_fail = '0'*/ AND assetTrack.start_time BETWEEN DATE('2015-01-01 00:00:00') AND CURDATE() 
                 GROUP BY b.product_type_idproduct_type")
# 
# 
# 
# #####durations by product type
# 
# 
phones_grouped<-dbGetQuery(con,"SELECT *, timestampdiff(SECOND,start_time,end_time) as duration
                           FROM product, process_history
                           WHERE product.idproduct = process_history.product_idproduct
                           AND product_type_idproduct_type =1
                           GROUP BY idproduct")
servers_grouped<-dbGetQuery(con,"SELECT *,timestampdiff(SECOND,start_time,end_time) as duration 
                             FROM product, process_history
                             WHERE product.idproduct = process_history.product_idproduct
                             AND product_type_idproduct_type =2
                             GROUP BY idproduct")
bs_grouped<-dbGetQuery(con,"SELECT *,timestampdiff(SECOND,start_time,end_time) as duration 
                             FROM product, process_history
                             WHERE product.idproduct = process_history.product_idproduct
                             AND product_type_idproduct_type =3
                             GROUP BY idproduct")
monitors_grouped<-dbGetQuery(con,"SELECT *,timestampdiff(SECOND,start_time,end_time) as duration 
                             FROM product, process_history
                             WHERE product.idproduct = process_history.product_idproduct
                             AND product_type_idproduct_type =4
                             GROUP BY idproduct")
printers_grouped<-dbGetQuery(con,"SELECT *,timestampdiff(SECOND,start_time,end_time) as duration 
                             FROM product, process_history
                             WHERE product.idproduct = process_history.product_idproduct
                             AND product_type_idproduct_type =5
                             GROUP BY idproduct")
laptops_grouped<-dbGetQuery(con,"SELECT *,timestampdiff(SECOND,start_time,end_time) as duration 
                             FROM product, process_history
                             WHERE product.idproduct = process_history.product_idproduct
                             AND product_type_idproduct_type =6
                             GROUP BY idproduct")

hdds_grouped<-dbGetQuery(con,"SELECT *,timestampdiff(SECOND,start_time,end_time) as duration 
                             FROM product, process_history
                             WHERE product.idproduct = process_history.product_idproduct
                             AND product_type_idproduct_type =8
                             GROUP BY idproduct")
# #######history by product type
# 
phones_history<-dbGetQuery(con,"SELECT * 
                           FROM product, process_history
                           WHERE product.idproduct = process_history.product_idproduct
                           AND product_type_idproduct_type = 1")

servers_history<-dbGetQuery(con,"SELECT * 
                           FROM product, process_history
                           WHERE product.idproduct = process_history.product_idproduct
                           AND product_type_idproduct_type = 2")
bs_history<-dbGetQuery(con,"SELECT * 
                           FROM product, process_history
                           WHERE product.idproduct = process_history.product_idproduct
                           AND product_type_idproduct_type = 3")
monitors_history<-dbGetQuery(con,"SELECT * 
                           FROM product, process_history
                           WHERE product.idproduct = process_history.product_idproduct
                           AND product_type_idproduct_type = 4")
printers_history<-dbGetQuery(con,"SELECT * 
                             FROM product, process_history
                             WHERE product.idproduct = process_history.product_idproduct
                             AND product_type_idproduct_type =5
                             ")
laptops_history<-dbGetQuery(con,"SELECT * 
                           FROM product, process_history
                           WHERE product.idproduct = process_history.product_idproduct
                           AND product_type_idproduct_type = 6")
hard_drives_history<-dbGetQuery(con,"SELECT * 
                                FROM product, process_history
                                WHERE product.idproduct = process_history.product_idproduct
                                AND product_type_idproduct_type = 8")
# 
# #######pass per process
# 
pass_history_grouped<-dbGetQuery(con,"SELECT process_history.process_types_idprocess_types, count(process_history.pass_fail) as frequency, process_types.type
                                 FROM process_types, process_history
                                 WHERE process_history.process_types_idprocess_types = process_types.idprocess_types
                                 AND process_history.pass_fail=1
                                 Group by process_history.process_types_idprocess_types" )
# 
# 
# #########this will need an updated database
product_type_last_100_days<-dbGetQuery(con,"SELECT a.product_type_idproduct_type, COUNT(*) , b.type
                                      FROM product a, product_type b, process_history c
                                      WHERE a.product_type_idproduct_type = b.idproduct_type
                                      AND c.product_idproduct = a.idproduct
                                      AND c.start_time >= DATE_SUB( CURDATE( ) , INTERVAL 500 DAY ) 
                                      AND c.process_types_idprocess_types =  '1'
                                      GROUP BY product_type_idproduct_type")
# 
whole_number_of_items_failed_ft<-dbGetQuery(con,"SELECT COUNT(*), c.type 
                                             FROM process_history a 
                                             JOIN product b ON b.idproduct = a.product_idproduct 
                                             JOIN product_type c ON c.idproduct_type = b.product_type_idproduct_type 
                                             WHERE a.process_types_idprocess_types = '5' AND a.pass_fail = '0' 
                                             GROUP BY b.product_type_idproduct_type")
# 
whole_number_of_items_failed_de<-dbGetQuery(con,"SELECT COUNT(*), c.type 
                                             FROM process_history a 
                                             JOIN product b ON b.idproduct = a.product_idproduct 
                                             JOIN product_type c ON c.idproduct_type = b.product_type_idproduct_type 
                                             WHERE a.process_types_idprocess_types = '4' AND a.pass_fail = '0' 
                                             GROUP BY b.product_type_idproduct_type")

whole_number_of_items_failed_repair<-dbGetQuery(con,"SELECT COUNT(*), c.type 
                                             FROM process_history a 
                                             JOIN product b ON b.idproduct = a.product_idproduct 
                                             JOIN product_type c ON c.idproduct_type = b.product_type_idproduct_type 
                                             WHERE a.process_types_idprocess_types = '7' AND a.pass_fail = '0' 
                                             GROUP BY b.product_type_idproduct_type")

whole_number_of_phones_passing_repair<-dbGetQuery(con,"SELECT COUNT(*), c.type, a.pass_fail 
                                                  FROM process_history a 
                                                  JOIN product b ON b.idproduct = a.product_idproduct 
                                                  JOIN product_type c ON c.idproduct_type = b.product_type_idproduct_type 
                                                  WHERE a.process_types_idprocess_types = '7' AND c.type = 'mobile phone' 
                                                  GROUP BY a.pass_fail")
#

# ##################times
# 
phone_duration_in_process_asset_to_cleaning<-dbGetQuery(con,"SELECT a.start_time, c.end_time,TIMESTAMPDIFF(MINUTE,a.start_time,c.end_time) 
                                                        FROM process_history a 
                                                        JOIN product b ON b.idproduct = a.product_idproduct 
                                                        JOIN process_history c ON c.product_idproduct = a.product_idproduct 
                                                        WHERE a.process_types_idprocess_types = '1' AND b.product_type_idproduct_type = '1' AND c.process_types_idprocess_types = '6'")


asset_duration<-dbGetQuery(con,"SELECT start_time, end_time, TIMESTAMPDIFF(SECOND,start_time,end_time) 
                           FROM process_history 
                           WHERE process_types_idprocess_types='1'")

vi_duration<-dbGetQuery(con,"SELECT start_time, end_time, TIMESTAMPDIFF(SECOND,start_time,end_time) 
                        FROM process_history 
                        WHERE process_types_idprocess_types='2'")

de_duration<-dbGetQuery(con,"SELECT start_time, end_time, TIMESTAMPDIFF(SECOND,start_time,end_time) 
                        FROM process_history 
                        WHERE process_types_idprocess_types='4'")

ft_duration<-dbGetQuery(con,"SELECT start_time, end_time, TIMESTAMPDIFF(SECOND,start_time,end_time) 
                        FROM process_history 
                        WHERE process_types_idprocess_types='5'")

cd_duration<-dbGetQuery(con,"SELECT start_time, end_time, TIMESTAMPDIFF(SECOND,start_time,end_time) 
                        FROM process_history 
                        WHERE process_types_idprocess_types='7'")

repair_duration<-dbGetQuery(con,"SELECT start_time, end_time, TIMESTAMPDIFF(SECOND,start_time,end_time) 
                            FROM process_history 
                            WHERE process_types_idprocess_types='6'")




counteventsperday1<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
WHERE end_time
                  BETWEEN DATE(  '2017-01-01 00:00:00' ) 
                  AND DATE(  '2017-02-01 00:00:00' ) 
                  AND process_types_idprocess_types =  '1'
GROUP   BY  DATE(end_time)")

counteventsperday2<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
WHERE end_time
                  BETWEEN DATE(  '2017-01-01 00:00:00' ) 
                  AND DATE(  '2017-02-01 00:00:00' ) 
                  AND process_types_idprocess_types =  '2'
GROUP   BY  DATE(end_time)")

counteventsperday3<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
WHERE end_time
                  BETWEEN DATE(  '2017-01-01 00:00:00' ) 
                  AND DATE(  '2017-02-01 00:00:00' ) 
                  AND process_types_idprocess_types =  '3'
GROUP   BY  DATE(end_time)")

counteventsperday4<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
WHERE end_time
                  BETWEEN DATE(  '2017-01-01 00:00:00' ) 
                  AND DATE(  '2017-02-01 00:00:00' ) 
                  AND process_types_idprocess_types =  '4'
GROUP   BY  DATE(end_time)")

counteventsperday5<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
WHERE end_time
                  BETWEEN DATE(  '2017-01-01 00:00:00' ) 
                  AND DATE(  '2017-02-01 00:00:00' ) 
                  AND process_types_idprocess_types =  '5'
GROUP   BY  DATE(end_time)")

counteventsperday6<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
WHERE end_time
                  BETWEEN DATE(  '2017-01-01 00:00:00' ) 
                  AND DATE(  '2017-02-01 00:00:00' ) 
                  AND process_types_idprocess_types =  '6'
GROUP   BY  DATE(end_time)")

counteventsperday8<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
WHERE end_time
                  BETWEEN DATE(  '2017-01-01 00:00:00' ) 
                  AND DATE(  '2017-02-01 00:00:00' ) 
                  AND process_types_idprocess_types =  '8'
GROUP   BY  DATE(end_time)")

countallevents<-dbGetQuery(con,"SELECT  DATE(end_time) Date, COUNT(DISTINCT idprocess) totalCount
FROM process_history ph
JOIN product prd ON prd.idproduct = ph.product_idproduct
GROUP   BY  DATE(end_time)")


# 
 dbDisconnect(con)
# #######################################################################algorithms section
# 
########algorithm to group process sequences
# find where one appears and 
from <- which(joined$process_types_idprocess_types == 1)
to <- c((from-1)[-1], nrow(joined)) # up to which point the sequence runs

# generate a sequence (len) and based on its length, repeat a consecutive number len times
get.seq <- mapply(from, to, 1:length(from), FUN = function(x, y, z) {
    len <- length(seq(from = x[1], to = y[1]))
    return(rep(z, times = len))
})
# 
# when we unlist, we get a vector
joined$group <- unlist(get.seq)
# and append it to your original data.frame. since this is
# designating a group, it makes sense to make it a factor
joined$group <- as.factor(joined$group)
# 
# #########end of algorithm. type joined to watch the results
# 
# #########
# 
df<-data.frame(joined$idproduct,joined$process_types_idprocess_types,joined$duration,joined$group)
#omit nas otherwise createDataPartition doesn't work
clear<-na.omit(df)
# 
aresult<-group_by(clear, joined.group)
aresult<-summarise(aresult,sum=sum(joined.duration))
# 
#####automatic pattern recognition
data<-joined$process_types_idprocess_types
x <- split(data, cumsum(data == 1))#splits the dataset
unique(x)#finds all the different patterns
res <- vapply(unique(x), function(x, y) sum(vapply(y, FUN = identical, y = x, FUN.VALUE = TRUE)), y = x, FUN.VALUE = 1L)#counts the occurences
Res <- data.frame(n = res,seq = vapply(unique(x), paste, collapse = ",",  FUN.VALUE = "a"))#creates the dataframe of frequencies and patterns
# 
# ##########################################################################graphs section
# 
# 
# 
# ####transforamtions for the right format
history<-history[c("type","COUNT(*)","product_type_idproduct_type")]
product_type_last_100_days<-product_type_last_100_days[c("type","COUNT(*)")]
last<-last[c("type","COUNT(*)")]
count<-count[c("type","frequency","process_types_idprocess_types")]
whole_number_of_items_failed_ft<-whole_number_of_items_failed_ft[c("type","COUNT(*)")]
whole_number_of_items_failed_de<-whole_number_of_items_failed_de[c("type","COUNT(*)")]
whole_number_of_items_failed_repair<-whole_number_of_items_failed_repair[c("type","COUNT(*)")]
whole_number_of_phones_passing_repair<-whole_number_of_phones_passing_repair[c("type","COUNT(*)")]
Res<-Res[c("seq","n")]
phonesdu<-phones_grouped[c("idproduct","duration")]
serversdu<-servers_grouped[c("idproduct","duration")]
bsdu<-bs_grouped[c("idproduct","duration")]
monitorsdu<-monitors_grouped[c("idproduct","duration")]
printersdu<-printers_grouped[c("idproduct","duration")]
laptopsdu<-laptops_grouped[c("idproduct","duration")]
hddsdu<-hdds_grouped[c("idproduct","duration")]
pass_history_grouped<-pass_history_grouped[c("type","frequency","process_types_idprocess_types")]
# 
# ###gvis charts
historyPie<-gvisPieChart(history,options=list(title="products totals"))
countPie<-gvisPieChart(count,options=list(title="process totals"))
lastPie<-gvisPieChart(last,options=list(title="sold products until now"))
totalpassPie<-gvisPieChart(pass_history_grouped,options=list(title="pass totals"))
failsPie<-gvisPieChart(whole_number_of_items_failed_ft,options=list(title="items failed FT"))
passPie<-gvisPieChart(whole_number_of_phones_passing_repair,options=list(title="phones passed repair"))
assettocleaninghist<-gvisHistogram(data.frame(phone_duration_in_process_asset_to_cleaning[,3]),options=list(title="time from asset to cleaning for phones in seconds"))
assethist<-gvisHistogram(data.frame(asset_duration[,3]),options=list(title="time distribution of asset tracking in seconds"))
vihist<-gvisHistogram(data.frame(vi_duration[,3]),options=list(title="time distribution of visual inspection in seconds"))
dehist<-gvisHistogram(data.frame(de_duration[,3]),options=list(title="time distribution of data erasure in seconds"))
fthist<-gvisHistogram(data.frame(ft_duration[,3]),options=list(title="time distribution of functional test in seconds"))
repairhist<-gvisHistogram(data.frame(repair_duration[,3]),options=list(title="time distribution of repair in seconds"))
Bar<-gvisColumnChart(aresult,options=list(title="durations groupped by transactions"))
RoutesDistr<-gvisColumnChart(Res,options=list(title="Routes Occurences Distribution"))
phones<-gvisColumnChart(phonesdu,options=list(title="Phones Time Distribution"))
servers<-gvisColumnChart(serversdu,options=list(title="Servers Time Distribution"))
bs<-gvisColumnChart(bsdu,options=list(title="Base Stations Time Distribution"))
monitors<-gvisColumnChart(monitorsdu,options=list(title="Monitors Time Distribution"))
printers<-gvisColumnChart(printersdu,options=list(title="Printers Time Distribution"))
laptops<-gvisColumnChart(laptopsdu,options=list(title="Laptops Time Distribution"))
hdds<-gvisColumnChart(hddsdu,options=list(title="HDDs Time Distribution"))
column<-gvisColumnChart(product_type_last_100_days,options=list(title="product types last 100 days"))
fails_dePie<-gvisPieChart(whole_number_of_items_failed_de,options=list(title="items failed DE"))
fails_repairPie<-gvisPieChart(whole_number_of_items_failed_repair,options=list(title="items failed Repair"))
events<-gvisColumnChart(countallevents,options=list(title="events"))
eventsperprocess<-gvisColumnChart(counteventsperday1,options=list(title="asset tracking events of one week"))
# 
# #####graphs merging
Graphs12<-gvisMerge(historyPie,countPie,horizontal=TRUE)
Graphs34<-gvisMerge(lastPie,totalpassPie, horizontal=TRUE)
Graphs56<-gvisMerge(failsPie,passPie, horizontal=TRUE)
Graphs78<-gvisMerge(fails_dePie,fails_repairPie, horizontal=TRUE)
Graphs910<-gvisMerge(assettocleaninghist,assethist, horizontal=TRUE)
Graphs1112<-gvisMerge(vihist,dehist, horizontal=TRUE)
Graphs1314<-gvisMerge(fthist,repairhist,horizontal=TRUE)
Graphs1516<-gvisMerge(Bar,RoutesDistr,horizontal=TRUE)
Graphs1718<-gvisMerge(phones,servers,horizontal=TRUE)
Graphs1920<-gvisMerge(bs,monitors,horizontal=TRUE)
Graphs2122<-gvisMerge(printers,laptops,horizontal=TRUE)
Graphs2324<-gvisMerge(events,eventsperprocess,horizontal=TRUE)
Graphs1234<-gvisMerge(Graphs12,Graphs34,horizontal=FALSE)
Graphs5678<-gvisMerge(Graphs56,Graphs78,horizontal=FALSE)
Graphs12345678<-gvisMerge(Graphs1234,Graphs5678,horizontal=FALSE)
Graphs12345678910<-gvisMerge(Graphs12345678,Graphs910, horizontal = FALSE)
Graphs123456789101112<-gvisMerge(Graphs12345678910,Graphs1112, horizontal = FALSE)
Graphs1234567891011121314<-gvisMerge(Graphs123456789101112,Graphs1314, horizontal = FALSE)
Graphs12345678910111213141516<-gvisMerge(Graphs1234567891011121314,Graphs1516, horizontal = FALSE)
Graphs123456789101112131415161718<-gvisMerge(Graphs12345678910111213141516,Graphs1718, horizontal = FALSE)
Graphs1234567891011121314151617181920<-gvisMerge(Graphs123456789101112131415161718,Graphs1920, horizontal = FALSE)
Graphs12345678910111213141516171819202122<-gvisMerge(Graphs1234567891011121314151617181920,Graphs2122, horizontal = FALSE)
Graphs123456789101112131415161718192021222324<-gvisMerge(Graphs12345678910111213141516171819202122,Graphs2324, horizontal = FALSE)
# ####plot everything
plot(Graphs123456789101112131415161718192021222324)
# # 
# # 

