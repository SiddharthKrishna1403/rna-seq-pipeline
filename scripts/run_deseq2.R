library(DESeq2)

# Load count data
countData <- read.table("/data/counts.txt", header=TRUE, row.names=1)

# Load sample information
colData <- read.table("/data/sample_info.txt", header=TRUE, row.names=1)

# Create DESeqDataSet object
dds <- DESeqDataSetFromMatrix(countData = countData,
                              colData = colData,
                              design = ~ condition)

# Run DESeq2
dds <- DESeq(dds)

# Get results
res <- results(dds)

# Write results to file
write.csv(as.data.frame(res), file="/data/deseq2_results.csv")
