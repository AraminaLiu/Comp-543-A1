Use SQL to analyze a graph data set.
The data set to analyze contains citation information for about 5000 papers from the Arxiv high-energy
physics theory paper archive. The data set has around 14,400 citations between those papers. The data set
is comprised of two database tables:
nodes (paperID, paperTitle);
edges (paperID, citedPaperID);
The first table gives a unique paper identifier, as well as the paper title. The second table indicates citations
between the papers (note that citations have a direction).
Task is to write two stored procedures that analyze this data.
