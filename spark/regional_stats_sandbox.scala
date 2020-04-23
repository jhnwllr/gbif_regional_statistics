
// country	gbifRegion	num_species	num_of_occ	num_datasets	snapshot
// country_counts_time_series.tsv
// gbif countries over time 

// spark2-shell --executor-memory 10g
// spark2-shell --master yarn --num-executors 50 --executor-cores 5
// spark2-shell --num-executors 40 --executor-cores 5 --driver-memory 8g --driver-cores 4 --executor-memory 32g

import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc)
import sqlContext.implicits._;

// sc.setCheckpointDir("hdfs://ha-nn/jwaller/")

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
filter($"tableName" =!= "occurrence_20190101").
select("tableName").collect.map(row=>row.getString(0))

val df_about = snapshots.
map(snapshot => {
val df_output = sqlContext.sql("SELECT * FROM snapshot." + snapshot).
groupBy("country").
agg(count(lit(1)).alias("num_occ"),countDistinct("species_id").as("num_species")).
withColumn("snapshot",lit(snapshot)).
withColumn("type",lit("about")).
coalesce(1)
df_output
}).reduce(_ union _).
cache()

val df_published = snapshots.
map(snapshot => {
val df_output = sqlContext.sql("SELECT * FROM snapshot." + snapshot).
groupBy("publisher_country").
agg(count(lit(1)).alias("num_occ"),countDistinct("species_id").as("num_species")).
withColumn("snapshot",lit(snapshot)).
withColumn("type",lit("published")).
withColumnRenamed("publisher_country","country").
coalesce(1)
df_output
}).reduce(_ union _).
cache()

val export_df = df_about.union(df_published).cache()

import org.apache.spark.sql.SaveMode
import sys.process._

val save_table_name = "country_counts_time_series.tsv"

// coalesce(1).
// option("header", "true").

export_df. // need this otherwise you get multi headers
write.format("csv").
option("sep", "\t").
mode(SaveMode.Overwrite).
save(save_table_name) 

// export and copy file to right location 
(s"hdfs dfs -ls")!
(s"rm " + save_table_name)!
(s"hdfs dfs -getmerge /user/jwaller/"+ save_table_name + " " + save_table_name)!
(s"cat " + save_table_name)!
(s"rm /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!
(s"ls -lh /mnt/auto/misc/download.gbif.org/custom_download/jwaller/")!
(s"cp /home/jwaller/" + save_table_name + " /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!

// cp /home/jwaller/country_counts_time_series.tsv  /mnt/auto/misc/download.gbif.org/custom_download/jwaller/country_counts_time_series.tsv
// sed -i '1i country\tocc_count\tspecies_count\tsnapshot\ttype' country_counts_time_series.tsv



import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import sqlContext.implicits._;

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val export_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot)
var output_df = snapshot_df.groupBy("publisher_country").
agg(countDistinct("species_id").as("num_species_published"),count(lit(1)).alias("num_of_occ_published"),countDistinct("dataset_id").as("num_datasets")).
withColumn("snapshot",lit(snapshot))
print(output_df.show(1000))
output_df
}).reduce(_ union _).
collect()




// gbif regions over time 
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc)
import sqlContext.implicits._;

// sc.setCheckpointDir("hdfs://ha-nn/jwaller/")

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumn("publisher_country",$"iso2"). // add columns for joining later 
withColumn("country",$"iso2").
withColumn("gbif_region",$"gbifRegion")

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val df_about = snapshots.
map(snapshot => {
val output_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot).
join(df_gbif_regions,"country").
groupBy("gbif_region").
agg(count(lit(1)).alias("num_occ"),countDistinct("species_id").as("num_species")).
withColumn("snapshot",lit(snapshot)).
withColumn("type",lit("about"))
// print(output_df.show())
output_df
}).reduce(_ union _).
persist()

val df_published = snapshots.
map(snapshot => {
val output_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot).
join(df_gbif_regions,"publisher_country").
groupBy("gbif_region").
agg(count(lit(1)).alias("num_occ"),countDistinct("species_id").as("num_species")).
withColumn("snapshot",lit(snapshot)).
withColumn("type",lit("published"))
// print(output_df.show())
output_df
}).reduce(_ union _).
persist()

val df_export = List(df_about,df_published).reduce(_ union _)

import org.apache.spark.sql.SaveMode
import sys.process._

val save_table_name = "gbif_regions_time_series.tsv"

df_export.coalesce(1). // need this otherwise you get multi headers
write.format("csv").
option("sep", "\t").
option("header", "true").
mode(SaveMode.Overwrite).
save(save_table_name) 

// export and copy file to right location 
(s"hdfs dfs -ls")!
(s"rm " + save_table_name)!
(s"hdfs dfs -getmerge /user/jwaller/"+ save_table_name + " " + save_table_name)!
(s"cat " + save_table_name)!
(s"rm /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!
(s"ls -lh /mnt/auto/misc/download.gbif.org/custom_download/jwaller/")!
(s"cp /home/jwaller/" + save_table_name + " /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!



// country_breakdown_taxon.tsv

import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import sqlContext.implicits._;

var df = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs")
// var df = sqlContext.sql("SELECT * FROM uat.occurrence_pipeline_hdfs")


val kingdom_keys = List(1,6,5)
val phylum_keys = List(52,35,95,34)
val class_keys =  List(359,212,131,216,358,367)

val kingdom_about_df = df.groupBy("countrycode","kingdomkey").
agg(countDistinct("specieskey").as("num_species"),count(lit(1)).alias("num_of_occ")).
filter($"kingdomkey".isin(kingdom_keys:_*))

val phylum_about_df = df.groupBy("countrycode","phylumkey").
agg(countDistinct("specieskey").as("num_species"),count(lit(1)).alias("num_of_occ")).
filter($"phylumkey".isin(phylum_keys:_*))

val class_about_df = df.groupBy("countrycode","classkey").
agg(countDistinct("specieskey").as("num_species"),count(lit(1)).alias("num_of_occ")).
filter($"classkey".isin(class_keys:_*))

val df_about = List(kingdom_about_df,phylum_about_df,class_about_df).
reduce(_ union _).
withColumnRenamed("kingdomkey","taxonkey").
withColumn("merge_id", concat($"countrycode", lit("_"),$"taxonkey"))

val kingdom_published_df = df.groupBy("publishingcountry","kingdomkey").
agg(countDistinct("specieskey").as("num_species_published"),count(lit(1)).alias("num_of_occ_published")).
filter($"kingdomkey".isin(kingdom_keys:_*))

val phylum_published_df = df.groupBy("publishingcountry","phylumkey").
agg(countDistinct("specieskey").as("num_species_published"),count(lit(1)).alias("num_of_occ_published")).
filter($"phylumkey".isin(phylum_keys:_*))

val class_published_df = df.groupBy("publishingcountry","classkey").
agg(countDistinct("specieskey").as("num_species_published"),count(lit(1)).alias("num_of_occ_published")).
filter($"classkey".isin(class_keys:_*))

val df_published = List(kingdom_published_df,phylum_published_df,class_published_df).
reduce(_ union _).
withColumnRenamed("kingdomkey","taxonkey").
withColumn("merge_id", concat($"publishingcountry", lit("_"),$"taxonkey")).
drop("countrycode","taxonkey")

val df_published_about = df_about.join(df_published,df_about("merge_id") ===  df_published("merge_id"),joinType = "full").
drop("merge_id")

val df_published_totals = df.groupBy("publishingcountry").
agg(count(lit(1)).alias("occ_published_total"),countDistinct("specieskey").as("species_published_total")).
withColumnRenamed("publishingcountry", "publishingcountry_merge")

val df_about_totals = df.groupBy("countrycode").
agg(count(lit(1)).alias("occ_total"),countDistinct("specieskey").as("species_total")).
withColumnRenamed("countrycode", "countrycode_merge")

val df_1 = df_published_about.join(df_published_totals,df_published_about("publishingcountry") ===  df_published_totals("publishingcountry_merge"),joinType = "full").
drop("publishingcountry_merge")

val df_2 = df_1.join(df_about_totals,df_1("countrycode") ===  df_about_totals("countrycode_merge"),joinType = "full").
drop("countrycode_merge")

val df_export = df_2 // 

import org.apache.spark.sql.SaveMode
import sys.process._

val save_table_name = "country_breakdown_taxon.tsv"

df_export.coalesce(1). // need this otherwise you get multi headers
write.format("csv").
option("sep", "\t").
option("header", "true").
mode(SaveMode.Overwrite).
save(save_table_name) 

// export and copy file to right location 
(s"hdfs dfs -ls")!
(s"rm " + save_table_name)!
(s"hdfs dfs -getmerge /user/jwaller/"+ save_table_name + " " + save_table_name)!
(s"cat " + save_table_name)!
(s"rm /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!
(s"ls -lh /mnt/auto/misc/download.gbif.org/custom_download/jwaller/")!
(s"cp /home/jwaller/" + save_table_name + " /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!




// country_breakdown_data_published.tsv





// regional comparison barplot table 
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

// val database = "uat"
val database = "prod_h"

val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumn("publishingcountry",$"iso2"). // add columns for joining later 
withColumn("countrycode",$"iso2"). 
withColumn("gbif_region",$"gbifRegion")


// val df_published = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs").
val df_published = sqlContext.sql("SELECT * FROM " + database + ".occurrence_pipeline_hdfs").
filter($"publishingorgkey" =!= "7ce8aef0-9e92-11dc-8738-b8a03c50a862"). // filter out plazi
select("publishingcountry","kingdom","phylum","class","datasetkey","publishingorgkey","specieskey").
join(df_gbif_regions,"publishingcountry").
groupBy("gbif_region").
agg(count(lit(1)).as("num_occ"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species")).
withColumn("type",lit("published"))

val df_about = sqlContext.sql("SELECT * FROM " + database + ".occurrence_pipeline_hdfs").
filter($"publishingorgkey" =!= "7ce8aef0-9e92-11dc-8738-b8a03c50a862"). // filter out plazi
select("countrycode","kingdom","phylum","class","datasetkey","publishingorgkey","specieskey").
join(df_gbif_regions,"countrycode").
groupBy("gbif_region").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species")).
withColumn("type",lit("about"))

val df_export = List(df_about,df_published).reduce(_ union _)

import org.apache.spark.sql.SaveMode
import sys.process._

val save_table_name = "gbif_regions_counts.tsv"

df_export.coalesce(1). // need this otherwise you get multi headers
write.format("csv").
option("sep", "\t").
option("header", "true").
mode(SaveMode.Overwrite).
save(save_table_name) 

// export and copy file to right location 
(s"hdfs dfs -ls")!
(s"rm " + save_table_name)!
(s"hdfs dfs -getmerge /user/jwaller/"+ save_table_name + " " + save_table_name)!
(s"cat " + save_table_name)!
(s"rm /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!
(s"ls -lh /mnt/auto/misc/download.gbif.org/custom_download/jwaller/")!
(s"cp /home/jwaller/" + save_table_name + " /mnt/auto/misc/download.gbif.org/custom_download/jwaller/" + save_table_name)!



// simple save and table csv processsing 
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;
import org.apache.spark.sql.SaveMode
import sys.process._

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import sqlContext.implicits._;

// var df = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs").
var df = sqlContext.sql("SELECT * FROM uat.occurrence_pipeline_hdfs").
groupBy("kingdomkey").
agg(countDistinct("specieskey").as("num_species"),count(lit(1)).alias("num_of_occ"))

df.coalesce(1). // need this otherwise you get multi headers
write.format("csv").
option("sep", "\t").
option("header", "true").
mode(SaveMode.Overwrite).
save("kingdom_counts.tsv") 

(s"hdfs dfs -ls")!
(s"hdfs dfs -getmerge /user/jwaller/kingdom_counts.tsv kingdom_counts.tsv")!
(s"ls -lh")!
(s"cat kingdom_counts.tsv")!


// val df_collected = df.collect()

// save a table test 
// "/mnt/auto/misc/download.gbif.org/custom_download/jwaller"



// taxonomic breakdown by country 

import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import sqlContext.implicits._;

var df = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs")
// var df = sqlContext.sql("SELECT * FROM uat.occurrence_pipeline_hdfs")

val kingdom_keys = List(1,6,5)
val phylum_keys = List(52,35,95,34)
val class_keys =  List(359,212,131,216,358,367)

val kingdom_about_df = df.groupBy("countrycode","kingdomkey").
agg(countDistinct("specieskey").as("num_species"),count(lit(1)).alias("num_of_occ")).
filter($"kingdomkey".isin(kingdom_keys:_*))

val phylum_about_df = df.groupBy("countrycode","phylumkey").
agg(countDistinct("specieskey").as("num_species"),count(lit(1)).alias("num_of_occ")).
filter($"phylumkey".isin(phylum_keys:_*))

val class_about_df = df.groupBy("countrycode","classkey").
agg(countDistinct("specieskey").as("num_species"),count(lit(1)).alias("num_of_occ")).
filter($"classkey".isin(class_keys:_*))

val df_about = List(kingdom_about_df,phylum_about_df,class_about_df).
reduce(_ union _).
withColumnRenamed("kingdomkey","taxonkey").
withColumn("merge_id", concat($"countrycode", lit("_"),$"taxonkey"))

val kingdom_published_df = df.groupBy("publishingcountry","kingdomkey").
agg(countDistinct("specieskey").as("num_species_published"),count(lit(1)).alias("num_of_occ_published")).
filter($"kingdomkey".isin(kingdom_keys:_*))

val phylum_published_df = df.groupBy("publishingcountry","phylumkey").
agg(countDistinct("specieskey").as("num_species_published"),count(lit(1)).alias("num_of_occ_published")).
filter($"phylumkey".isin(phylum_keys:_*))

val class_published_df = df.groupBy("publishingcountry","classkey").
agg(countDistinct("specieskey").as("num_species_published"),count(lit(1)).alias("num_of_occ_published")).
filter($"classkey".isin(class_keys:_*))

val df_published = List(kingdom_published_df,phylum_published_df,class_published_df).
reduce(_ union _).
withColumnRenamed("kingdomkey","taxonkey").
withColumn("merge_id", concat($"publishingcountry", lit("_"),$"taxonkey")).
drop("countrycode","taxonkey")

val df_published_about = df_about.join(df_published,df_about("merge_id") ===  df_published("merge_id"),joinType = "full").
drop("merge_id")

val df_published_totals = df.groupBy("publishingcountry").
agg(count(lit(1)).alias("occ_published_total"),countDistinct("specieskey").as("species_published_total")).
withColumnRenamed("publishingcountry", "publishingcountry_merge")

val df_about_totals = df.groupBy("countrycode").
agg(count(lit(1)).alias("occ_total"),countDistinct("specieskey").as("species_total")).
withColumnRenamed("countrycode", "countrycode_merge")

val df_1 = df_published_about.join(df_published_totals,df_published_about("publishingcountry") ===  df_published_totals("publishingcountry_merge"),joinType = "full").
drop("publishingcountry_merge")

val df_2 = df_1.join(df_about_totals,df_1("countrycode") ===  df_about_totals("countrycode_merge"),joinType = "full").
drop("countrycode_merge")


// val export_df = df_about.join(df_published,"merge_id",joinType = "full")

// .
// drop("merge_id")

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import org.apache.spark.sql.DataFrame
val make_external_table = (df: DataFrame, tableName: String, schema: String) => {
  df.createOrReplaceTempView(tableName + "_temp");
  val create_sql = "CREATE EXTERNAL TABLE jwaller." + tableName + " (" + schema + ") ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE LOCATION '/user/jwaller/" + tableName + ".csv'";
  val overwrite_sql = "INSERT OVERWRITE TABLE jwaller." + tableName + " SELECT * FROM " + tableName + "_temp";
  val delete_sql = "DROP TABLE IF EXISTS jwaller." + tableName;
  println(create_sql);
  println(overwrite_sql);

  sqlContext.sql(delete_sql);  
  sqlContext.sql(create_sql);
  sqlContext.sql(overwrite_sql);
  sqlContext.sql("show tables from jwaller").show(100);
}

// countrycode|taxonkey|num_species|num_of_occ|num_species_published|num_of_occ_published
val schema = "countrycode string, taxonkey int, num_species bigint, snapshot string"
make_external_table(export_df,"country_taxon_breakdown",schema)


// Regional Country publisher country 

import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import sqlContext.implicits._;

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val export_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot)
var output_df = snapshot_df.groupBy("publisher_country").
agg(countDistinct("species_id").as("num_species_published"),count(lit(1)).alias("num_of_occ_published"),countDistinct("dataset_id").as("num_datasets")).
withColumn("snapshot",lit(snapshot))
print(output_df.show(1000))
output_df
}).reduce(_ union _).
collect()



// make regional taxanomic breakdowns 

import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import sqlContext.implicits._;

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","country").
cache()

val kingdom_keys = List(1,6,5)
val phylum_keys = List(52,35,95,34)
val class_keys =  List(359,212,131,216,358,367)

val output_kingdom_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot)
var df = snapshot_df.join(df_gbif_regions,"country")
var kingdom_df = df.groupBy("gbifRegion","kingdom_id").
agg(countDistinct("species_id").as("num_species"),count(lit(1)).alias("num_of_occ")).
withColumn("snapshot",lit(snapshot)).
filter($"kingdom_id".isin(kingdom_keys:_*))
print(kingdom_df.show(1000))
kingdom_df
}).reduce(_ union _)

val output_phylum_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot)
var df = snapshot_df.join(df_gbif_regions,"country")
var phylum_df = df.groupBy("gbifRegion","phylum_id").
agg(countDistinct("species_id").as("num_species"),count(lit(1)).alias("num_of_occ")).
withColumn("snapshot",lit(snapshot)).
filter($"phylum_id".isin(phylum_keys:_*))
print(phylum_df.show(1000))
phylum_df
}).reduce(_ union _)

val output_class_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot)
var df = snapshot_df.join(df_gbif_regions,"country")
var class_df = df.groupBy("gbifRegion","class_id").
agg(countDistinct("species_id").as("num_species"),count(lit(1)).alias("num_of_occ")).
withColumn("snapshot",lit(snapshot)).
filter($"class_id".isin(class_keys:_*))
print(class_df.show(1000))
class_df
}).reduce(_ union _)




// number of records published by region over time  

import org.apache.spark.sql.DataFrame;
import sqlContext.implicits._;
import org.apache.spark.sql.functions._;

val sqlContext = new org.apache.spark.sql.SQLContext(sc);

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","publisher_country").
cache()

val output_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot);
var df = snapshot_df.join(df_gbif_regions,"publisher_country")
var export_df = df.groupBy("gbifRegion").
agg(count(lit(1)).alias("num_published_of_occ")).
withColumn("snapshot",lit(snapshot));
print(export_df.show(10))
export_df
}).reduce(_ union _)



// number of species published 

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import org.apache.spark.sql.DataFrame
val make_external_table = (df: DataFrame, tableName: String, schema: String) => {
  df.createOrReplaceTempView(tableName + "_temp");
  val create_sql = "CREATE EXTERNAL TABLE jwaller." + tableName + " (" + schema + ") ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE LOCATION '/user/jwaller/" + tableName + ".csv'";
  val overwrite_sql = "INSERT OVERWRITE TABLE jwaller." + tableName + " SELECT * FROM " + tableName + "_temp";
  val delete_sql = "DROP TABLE IF EXISTS jwaller." + tableName;
  println(create_sql);
  println(overwrite_sql);

  sqlContext.sql(delete_sql);  
  sqlContext.sql(create_sql);
  sqlContext.sql(overwrite_sql);
  sqlContext.sql("show tables from jwaller").show(100);
}


import org.apache.spark.sql.DataFrame;
import sqlContext.implicits._;
import org.apache.spark.sql.functions._;

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","publisher_country").
cache()

val output_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot);
var df = snapshot_df.join(df_gbif_regions,"publisher_country")
var export_df = df.groupBy("gbifRegion").
agg(countDistinct("species_id").as("num_species")).
withColumn("snapshot",lit(snapshot));
print(export_df.show(10))
export_df
}).reduce(_ union _)



// number of species 
// yarn application -kill application_1582294906387_77073
// spark2-shell --driver-memory 4g

val sqlContext = new org.apache.spark.sql.SQLContext(sc);
import org.apache.spark.sql.DataFrame
val make_external_table = (df: DataFrame, tableName: String, schema: String) => {
  df.createOrReplaceTempView(tableName + "_temp");
  val create_sql = "CREATE EXTERNAL TABLE jwaller." + tableName + " (" + schema + ") ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE LOCATION '/user/jwaller/" + tableName + ".csv'";
  val overwrite_sql = "INSERT OVERWRITE TABLE jwaller." + tableName + " SELECT * FROM " + tableName + "_temp";
  val delete_sql = "DROP TABLE IF EXISTS jwaller." + tableName;
  println(create_sql);
  println(overwrite_sql);

  sqlContext.sql(delete_sql);  
  sqlContext.sql(create_sql);
  sqlContext.sql(overwrite_sql);
  sqlContext.sql("show tables from jwaller").show(100);
}


import org.apache.spark.sql.DataFrame;
import sqlContext.implicits._;
import org.apache.spark.sql.functions._;

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","country").
cache()

val output_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot);
var df = snapshot_df.join(df_gbif_regions,"country")
var export_df = df.groupBy("gbifRegion").
agg(countDistinct("species_id").as("num_species")).
withColumn("snapshot",lit(snapshot));
print(export_df.show(10))
export_df
}).reduce(_ union _)

// println(export_df.count())
// .
// collect()

// output_df.count()

val schema = "gbifRegion string, num_species bigint, snapshot string"
make_external_table(output_df, "gbif_regions_species_over_time", schema)

// hdfs dfs -getmerge /user/jwaller/gbif_regions_over_time.csv gbif_regions_over_time.tsv
// sed -i 's#\\N##g' gbif_regions_over_time.tsv
// sed -i '1i gbifRegion\twith_birds\tnum_of_occ\tsnapshot' gbif_regions_over_time.tsv
// scp -r jwaller@c5gateway-vh.gbif.org:/home/jwaller/ /cygdrive/c/Users/ftw712/Desktop/jwaller/




// start making spagetti graph 
// yarn application -kill application_1582294906387_43651
// spark2-shell --executor-memory 4G
spark2-shell --driver-memory 4g

import org.apache.spark.sql.DataFrame
val make_external_table = (df: DataFrame, tableName: String, schema: String) => {
  df.createOrReplaceTempView(tableName + "_temp");
// val x = df.columns.toSeq.mkString(" STRING, ");
// val x = "TAXONKEY INT, Q1 DOUBLE, Q3 DOUBLE, FOCAL_LAT DOUBLE, FOCAL_LON DOUBLE, AVG_DIST DOUBLE, IQR DOUBLE, IQR_6 DOUBLE"
  val create_sql = "CREATE EXTERNAL TABLE jwaller." + tableName + " (" + schema + ") ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE LOCATION '/user/jwaller/" + tableName + ".csv'";
  val overwrite_sql = "INSERT OVERWRITE TABLE jwaller." + tableName + " SELECT * FROM " + tableName + "_temp";
val delete_sql = "DROP TABLE IF EXISTS jwaller." + tableName;
  println(create_sql);
  println(overwrite_sql);

sqlContext.sql(delete_sql);
  sqlContext.sql(create_sql);
  sqlContext.sql(overwrite_sql);
  sqlContext.sql("show tables from jwaller").show(100);
}

val sqlContext = new org.apache.spark.sql.SQLContext(sc);

import org.apache.spark.sql.DataFrame;
import sqlContext.implicits._;
import org.apache.spark.sql.functions._;

val snapshots = sqlContext.sql("show tables from snapshot").
filter($"tableName".contains("occurrence")).
filter($"tableName" =!= "export_occurrence_20170724").
select("tableName").collect.map(row=>row.getString(0));

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","country").
cache()

val output_df = snapshots.
map(snapshot => {
var snapshot_df = sqlContext.sql("SELECT * FROM snapshot." + snapshot);
var df_with_birds = snapshot_df.join(df_gbif_regions,"country").withColumn("with_birds",lit("no"));
var snapshot_not_birds = sqlContext.sql("SELECT * FROM snapshot." + snapshot).filter($"class_id" =!= 212);
var df_not_birds = snapshot_not_birds.join(df_gbif_regions,"country").withColumn("with_birds",lit("yes"));
var df = df_with_birds.unionAll(df_not_birds);
var export_df = df.groupBy("gbifRegion","with_birds").agg(count(lit(1)).alias("num_of_occ")).withColumn("snapshot",lit(snapshot));
export_df
}).reduce(_ union _)

val schema = "gbifRegion string, with_birds string, num_of_occ bigint, snapshot string"
make_external_table(output_df, "gbif_regions_over_time", schema)

// hdfs dfs -getmerge /user/jwaller/gbif_regions_over_time.csv gbif_regions_over_time.tsv
// sed -i 's#\\N##g' gbif_regions_over_time.tsv
// sed -i '1i gbifRegion\twith_birds\tnum_of_occ\tsnapshot' gbif_regions_over_time.tsv
// scp -r jwaller@c5gateway-vh.gbif.org:/home/jwaller/ /cygdrive/c/Users/ftw712/Desktop/jwaller/



// look for big publisher outliers 

val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs").
groupBy("publisher").
agg(countDistinct("datasetkey").as("num_datasets")).
orderBy($"num_datasets".desc)

// filter($"publishingorgkey" =!= "7ce8aef0-9e92-11dc-8738-b8a03c50a862"). // filter out plazi
// select("publishingcountry","countrycode","kingdom","phylum","class","datasetkey","publishingorgkey","specieskey")


// filter plazi for regional stats 

val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","publishingcountry")

val df_gbif = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs").
filter($"publishingorgkey" =!= "7ce8aef0-9e92-11dc-8738-b8a03c50a862"). // filter out plazi
select("publishingcountry","countrycode","kingdom","phylum","class","datasetkey","publishingorgkey","specieskey")

val df = df_gbif.join(df_gbif_regions,"publishingcountry")

val df_counts = df.
groupBy("gbifRegion").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species"))


// get counts by country for regional stats 
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","countrycode")

val df_gbif = sqlContext.sql("SELECT * FROM uat.occurrence_pipeline_hdfs").
select("countrycode","kingdom","datasetkey","publishingorgkey","specieskey")

val df = df_gbif.join(df_gbif_regions,"countrycode")

val df_counts = df.
groupBy("gbifRegion").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species"))
// .
// orderBy($"kingdom".desc)


// data by publishingcountry
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df_gbif_regions = spark.read.
option("sep", "\t").
option("header", "true").
csv("gbif_regions.tsv"). 
withColumnRenamed("iso2","publishingcountry")

val df_gbif = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs").
select("publishingcountry","countrycode","kingdom","phylum","class","datasetkey","publishingorgkey","specieskey")

val df = df_gbif.join(df_gbif_regions,"publishingcountry")

val df_counts = df.
groupBy("gbifRegion").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species"))



// orderBy($"class".desc)





// get regional stats from isea3h_res5_table polygons
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

val df_1 = sqlContext.sql("SELECT * FROM jwaller.isea3h_res6_table")

// val df_2 = sqlContext.sql("SELECT * FROM uat.occurrence_pipeline_hdfs").
val df_2 = sqlContext.sql("SELECT * FROM prod_h.occurrence_pipeline_hdfs").
select("gbifid","taxonkey","publishingorgkey","datasetkey","taxonrank","kingdomkey","phylumkey","classkey","orderkey","specieskey")

val df = df_1.join(df_2,"gbifid")

// groupBy("polygon_id","polygon_geometry","kingdomkey","phylumkey","classkey","orderkey").
val df_counts = df.
groupBy("polygon_id","polygon_geometry").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species")).
orderBy($"num_publishers".desc)


import org.apache.spark.sql.DataFrame
val make_external_table = (df: DataFrame, tableName: String, schema: String) => {
  df.createOrReplaceTempView(tableName + "_temp");
  // val x = df.columns.toSeq.mkString(" STRING, ");
// val x = "TAXONKEY INT, Q1 DOUBLE, Q3 DOUBLE, FOCAL_LAT DOUBLE, FOCAL_LON DOUBLE, AVG_DIST DOUBLE, IQR DOUBLE, IQR_6 DOUBLE"
  val create_sql = "CREATE EXTERNAL TABLE jwaller." + tableName + " (" + schema + ") ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE LOCATION '/user/jwaller/" + tableName + ".csv'";
  val overwrite_sql = "INSERT OVERWRITE TABLE jwaller." + tableName + " SELECT * FROM " + tableName + "_temp";
val delete_sql = "DROP TABLE IF EXISTS jwaller." + tableName;
  println(create_sql);
  println(overwrite_sql);

sqlContext.sql(delete_sql);
  sqlContext.sql(create_sql);
  sqlContext.sql(overwrite_sql);
  sqlContext.sql("show tables from jwaller").show(100);
}

// val schema = "polygon_id int, polygon_geometry string, kingdomkey int, phylumkey int, classkey int, orderkey int, occ_count bigint, num_datasets bigint, num_publishers bigint, num_species bigint"
val schema = "polygon_id int, polygon_geometry string, occ_count bigint, num_datasets bigint, num_publishers bigint, num_species bigint"
make_external_table(df_counts, "polygon_counts_isea3h_res6", schema)


// hdfs dfs -getmerge /user/jwaller/polygon_counts_isea3h_res6.csv polygon_counts_isea3h_res6.tsv
// sed -i 's#\\N##g' polygon_counts_isea3h_res6.tsv
// sed -i '1i polygon_id\tpolygon_geometry\tocc_count\tnum_datasets\tnum_publishers\tnum_species' polygon_counts_isea3h_res6.tsv
// scp -r jwaller@c5gateway-vh.gbif.org:/home/jwaller/ /cygdrive/c/Users/ftw712/Desktop/jwaller/

df_classkey_counts.select("polygon_geometry","classkey","num_publishers").show(100,false)

val df_counts = df.
groupBy("polygon_id","polygon_geometry").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species")).
orderBy($"num_publishers".desc)

val df_phylumkey_counts = df.
groupBy("polygon_id","polygon_geometry","kingdomkey","phylumkey").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species")).
orderBy($"num_publishers".desc)

val df_kingdomkey_counts = df.
groupBy("polygon_id","polygon_geometry","kingdomkey").
agg(count(lit(1)).as("occ_count"),countDistinct("datasetkey").as("num_datasets"),countDistinct("publishingorgkey").as("num_publishers"),countDistinct("specieskey").as("num_species")).
orderBy($"num_publishers".desc)





// val df_birds = df.
// groupBy("polygon_id","polygon_geometry").
// filter($"classkey" === 212). 
// agg(count(lit(1)).as("occ_count_birds"),countDistinct("specieskey").as("num_species_birds"),countDistinct("datasetkey").as("num_datasets_birds"),countDistinct("publishingorgkey").as("num_publishers_birds")).
// orderBy($"num_species_birds".desc)











