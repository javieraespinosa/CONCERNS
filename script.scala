


val file   = sc.textFile("Geolife/Data/sample/labels.txt")
val labels = file.filter( line => !(line contains "Start") )
val tags   = labels.map(
  l =>
    var tokens = l.split("\t")
    (tokens._1)
)


labels.take(10).foreach(println)



object geolife {

  def strToTag(s: Array[String]): String = {
    return s
  }

}
