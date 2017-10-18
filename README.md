# news.sh
## A news-api based shell script to read the latest happenings from around the globe.

An Operating Systems mini-project by - 
* Aditya Kulkarni - 115a1061 - @adikul30
* Siddharth Poduval - 115a1076 - @sudocoder98
* Omkar Prabhu - 115a10767 - @nerdyninja

### Background
In today’s dynamic and ever changing world, it is imperative for professionals across all fields of work to keep up with the social and political happenings. However, very often technical professionals from fields such as computer science, engineering, medicine, architecture, science, and more, are relatively uninformed about the political landscape both locally and globally. This leads to an uninformed electorate who go on to elect demagogues and dictatorial politicians, as we have seen in recent years. A society that doesn’t allow the free percolation of information between all it’s various communities and components such as politics, entertainment, sports, and technology, is a recipe for disaster, and we must strive to correct this.  Technical professional spend most of their time in front of their computers. \*nix users, such as server-side engineers, data scientists, analysts, across a plethora of fields, begin and end their day behind their terminal shells. Therefore, *we must bring all the **relevant news** of the day in a readable, easy to access and intelligent format **right into the users terminal.***

With this problem statement in mind, we set out to develop **news.sh - *Your one stop shop for the latest news, right from your terminal!*** 
* A simple shell script that uses the news-api to deliver the top news articles of the day right to your terminal window. 
* It is easy to read, and sorted along user defined parameters such as - top, popular, latest. 
* Moreover, the user can customise the application with their preferred news sources, and view articles and sources categorised by language, country and news categories such as - business, entertainment, gaming, general, music, politics, science-and-nature, sport, technology.

### Flow Diagram
![Base Structure](/images/base-structure.png)
![View Articles](/images/viewArticles.png)
![Modify Preferences](/images/modifyPreferences.png)

### Methodology
**News-API**
News API is a simple and easy-to-use API that returns JSON metadata for the headlines currently published on a range of news sources and blogs (70 and counting so far). It consists of only two endpoints with clearly defined and documented functionality.

The [sources endpoint](https://newsapi.org/#apiSources) provides a list of the news sources and blogs available on the News API service. The response can be filtered by categories (such as, business, gaming, sport, etc.), language (en, fr, etc.) and country.

The [articles endpoint](https://newsapi.org/#apiArticles) provides a list of live article metadata from a news source or blog. This endpoint compulsorily requires a news source, and can further be customised by sorting the articles according to predefined parameters: top, latest, popular (if supported by selected source).

An API key is needed to access the API. This key can be shared by multiple users. 

**Jq**
[jq](https://stedolan.github.io/jq/) is often described as the ‘sed’ command for JSON data - you can use it to slice and filter and map and transform structured data with the same ease that sed, awk, grep and other standard shell commands let you play with normal text.
The jq library comes equipped with powerful tools and features that can process raw input, JSON objects, array and files. 
Jq can process JSON formatted HTTP responses. It does the work of parsing through the json response and formats the data as specified. The jq command relies on the concept of filters which are the parameters along which the modifications, selections and formatting is done. It can also be used to merge, search through and modify JSON files directly through the shell script file.


### Results
![Show help text; Illegal options](/images/ss1.png)
![Show article where preferences aren't set](/images/ss2.png)
![Set preferences](/images/ss3.png)
![Show article where preferences are set](/images/ss4.png)