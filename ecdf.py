
import argparse
import statsmodels.api as sm
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import re
import matplotlib.font_manager as fm

parser = argparse.ArgumentParser()
parser.add_argument('-e', '--ecdf', action = 'store_true', default = False, help = 'Option to plot ECDF.' )
parser.add_argument('-v', '--violin', action = 'store_true', default = False, help = 'Option to plot violin plot.' )
parser.add_argument('-d', '--data', type=str, nargs='+', help='Input tab-separated file(s) with gene_id (column 1) and protein size (column 2).')
parser.add_argument('-l', '--labels', type=str, nargs='+', help='Labels for each input file.')
parser.add_argument('-t', '--title', type = str, default = 'ECDF of provided data', help = 'Title of produced ECDF Figure.' )
parser.add_argument('-xlab', '--xlabel', type = str, default = 'Protein Size (amino-acids)', help = 'Label of x-axis of produced ECDF Figure.' )
parser.add_argument('-ylab', '--ylabel', type = str, default = 'Empirical Cumulative Distribution Function', help = 'Label of y-axis of produced ECDF Figure.' )
parser.add_argument('-s', '--show', action = 'store_true', default = False, help = 'Option to show the produced ECDF Figure.' )
parser.add_argument('-o', '--output', type = str, help = 'Name of output file.' )
parser.add_argument('-f', '--format', type = str, default = "svg", help = 'Format of output file.' )

args = parser.parse_args()

if not any(vars(args).values()):
    parser.print_help()
    sys.exit('Error: No arguments provided.')


fm.fontManager.addfont('/home/jason/Programs/inter/extras/ttf/Inter-Regular.ttf')
fm.fontManager.addfont('/home/jason/Programs/inter/extras/ttf/Inter-Bold.ttf')
fm.fontManager.addfont('/home/jason/Programs/inter/extras/ttf/Inter-Italic.ttf')

# Set the font family to Inter
plt.rcParams['font.family'] = 'Inter'

def ecdf(values, labels, title, output, format, xlabel='Protein Size (amino-acids)', ylabel='Empirical Cumulative Distribution Function', show=False):
    plt.figure(figsize=(12, 10))
    plt.rcParams['font.family'] = 'Inter'
    plt.rcParams['font.size'] = 14
    colors = plt.cm.tab20(np.linspace(0, 1, len(values)))
    
    for i, (value, label, color) in enumerate(zip(values, labels, colors)):
        df = pd.read_csv(value, sep='\t')
        data = df.iloc[:, 1]  # Keep only the second column that contains protein sizes
        sorted_data = np.sort(data)
        y_values = np.arange(1, len(sorted_data) + 1) / float(len(sorted_data))
        
        if re.search(" gene", label, re.IGNORECASE):
            plt.plot(sorted_data, y_values, marker ='o',  markersize=5, color=color, linestyle='none', label=f"{label}")
        elif re.search("pseudogene", label, re.IGNORECASE):
            plt.plot(sorted_data, y_values, marker='^', markersize=5, linestyle='none', color=color, label=f"{label}")
        elif re.search("fragment", label, re.IGNORECASE):
            plt.plot(sorted_data, y_values, marker='.', markersize=5, linestyle='none', color=color, label=f"{label}")
    
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.title(title)
    plt.grid(False)
    
    plt.legend(loc='center', bbox_to_anchor=(0.5, -0.15), ncol=2, fontsize=12, borderaxespad=0.3)
    plt.tight_layout()
    
    plt.savefig(re.sub(" ", "_", output + ".") + format, format=format, bbox_inches='tight')
    if show:
        plt.show()

def violin_and_bar(files, labels, title, output, format, xlabel='Protein Size (amino-acids)', ylabel='Distribution', show=False):
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 12), gridspec_kw={'height_ratios': [3, 1]})
    plt.rcParams['font.family'] = 'arial'
    
    # Prepare data and compute statistics
    all_data = []
    means = []
    medians = []
    counts = []
    unique_counts = []
    
    for file, label in zip(files, labels):
        df = pd.read_csv(file, sep='\t', header=None)
        data = df.iloc[:, 2]  # Third column that contains protein sizes
        all_data.append(pd.DataFrame({'Size': data, 'Group': label}))
        means.append(data.mean())
        medians.append(data.median())
        counts.append(len(data))
        unique_counts.append(df.iloc[:, 1].nunique())  # Count unique strings in second column
    
    # Combine all data
    combined_data = pd.concat(all_data, ignore_index=True)
    
    # Create the violin plot
    sns.violinplot(x='Group', y='Size', data=combined_data, palette='rainbow', cut=0, ax=ax1)
    
    # Add mean and median points
    for i, (mean, median) in enumerate(zip(means, medians)):
        ax1.plot(i, mean, 'k', markersize=8, label='Mean' if i == 0 else "")
        ax1.plot(i, median, 'r^', markersize=8, label='Median' if i == 0 else "")
    
    ax1.set_xlabel(xlabel)
    ax1.set_ylabel(ylabel)
    ax1.set_title(title)
    ax1.grid(False)
    
    # Create new x-axis labels with statistics
    new_labels = [f"{label}\n\nMean: {mean:.2f}\nMedian: {median:.2f}\nCount: {count}" 
                  for label, mean, median, count in zip(labels, means, medians, counts)]
    
    # Set new x-axis labels
    ax1.set_xticklabels(new_labels)
    ax1.tick_params(axis='x', rotation=0)
    
    # Add legend for mean and median markers
    ax1.legend(loc='upper right')
    
    # Create the bar plot
    ax2.bar(labels, unique_counts, color='skyblue')
    ax2.set_ylabel('Unique Count')
    ax2.set_title('Number of Unique Strings in Second Column')
    ax2.tick_params(axis='x', rotation=45)

    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)
    
    for i, v in enumerate(unique_counts):
        ax2.text(i, v, str(v), ha='center', va='bottom')
    
    plt.tight_layout()
    plt.savefig(re.sub(" ", "_", output + ".") + format, format=format, bbox_inches='tight')

    
    if show:
        plt.show()
    
    return means, medians, counts, unique_counts  # Return statistics


if __name__ == '__main__':

    if args.ecdf:
        ecdf(
            values=args.data,
            labels=args.labels if args.labels else [f"Dataset {i+1}" for i in range(len(args.data))],
            title=args.title,
            xlabel=args.xlabel if args.xlabel else 'Protein Size (amino-acids)',
            ylabel=args.ylabel if args.ylabel else 'Empirical Cumulative Distribution Function',
            show=args.show,
            output=args.output if args.output else args.title,
            format=args.format if args.format else 'svg'
        )

    elif args.violin:
        violin_and_bar(
            files=args.data,
            labels=args.labels if args.labels else [f"Dataset {i+1}" for i in range(len(args.data))],
            title=args.title,
            xlabel=args.xlabel if args.xlabel else 'Protein Size (amino-acids)',
            ylabel=args.ylabel if args.ylabel else 'Distribution',
            show=args.show,
            output=args.output if args.output else args.title,
            format=args.format if args.format else 'svg'
        )    
