use strict;
use warnings;


# ********************************************************************************************************
# ********************************************   PARAMETERS   ********************************************
# ********************************************************************************************************


# -----------------------------------------------------------------
#                    Choose steps to run 
# -----------------------------------------------------------------

# Extract GitHub repo names from literature search - includes non-bioinformatics repos
my $extract_repos_from_lit_search = 0;

# Check for issues with repository names that have been manually curated
my $check_repo_existence = 0;

# Query Eutils for article metadata
my $query_eutils_article_metadata = 0;

# Use GitHub API to get repo data
my $generate_language_bytes = 0;
my $generate_licenses = 0;
my $generate_commits = 0;
my $generate_file_info = 0;
my $generate_contents = 0;
my $generate_repo_metrics = 0;
my $generate_pr_data = 0;

# Run BigQuery analysis queries against GitHub bioinformatics dataset and save results to tables
my $run_bq_analysis_queries = 0;

# Count lines of code and push to BigQuery table along with comment-stripped versions of source files
my $run_cloc = 0;

# Extract comments from source files and push to BigQuery table
my $run_extract_comments = 0;

# Analyze frequency of code chunks
my $run_code_chunk_frequency = 0;



# -----------------------------------------------------------------
#                   BigQuery project structure
# -----------------------------------------------------------------


### BigQuery public data ###
# Project
my $bq_proj_public_data = "bigquery-public-data";
# Datasets
my $bq_ds_public_data_repos = "github_repos";
# Tables
my $bq_tb_public_data_commits = "commits";
my $bq_tb_public_data_files = "files";
my $bq_tb_public_data_contents = "contents";
my $bq_tb_public_data_languages = "languages";
my $bq_tb_public_data_licenses = "licenses";

### GitHub archive ###
# Project
my $bq_proj_gh_archive = "githubarchive";
# Datasets
my $bq_ds_gh_archive_year = "year";

### GitHub bioinformatics project ###
# Project
my $bq_proj_gh_bioinf = "github-bioinformatics-171721";
# Datasets
my $bq_ds_repos = "repos";
my $bq_ds_analysis_results = "analysis";
my $bq_ds_lit_search = "lit_search";
# Data tables with data pulled from GitHub API
my $bq_tb_repo_metrics = "repo_metrics";
my $bq_tb_commits = "commits";
my $bq_tb_contents = "contents";
my $bq_tb_files = "file_info";
my $bq_tb_languages = "languages";
my $bq_tb_licenses = "licenses";
my $bq_tb_prs = "pull_requests";
# Analysis tables
my $bq_tb_repo_article = "repo_and_article"; # Repo names and articles they're mentioned in, including non-bioinformatics
my $bq_tb_eutils = "article_info_eutils"; # Article metadata from Eutils
my $bq_tb_loc_by_file = "lines_of_code_by_file"; # Computed table with language and lines of code per source file
my $bq_tb_loc_by_repo = "lines_of_code_by_repo"; # Computed table with total lines of code by repo
my $bq_tb_contents_comments_stripped = "contents_comments_stripped"; # Computed table with language and lines of code per source file
my $bq_tb_comments = "comments"; # Computed table with comments extracted from source files
my $bq_tb_code_chunk_freq = "code_chunk_freq"; # Frequency of groups of lines of code


# -----------------------------------------------------------------
#                   Google Drive project structure
# -----------------------------------------------------------------

my $gsheet_repos_curated = "gh_repos_in_articles_curated";


# -----------------------------------------------------------------
#                    Local project structure
# -----------------------------------------------------------------

# Source directories
my $src_dir = "/Users/prussell/Documents/Github_mining/src/";
my $src_dir_R = "$src_dir/R/";
my $src_dir_python = "$src_dir/python/";

# Programs
my $script_check_repo_existence = "$src_dir_python/check_repo_existence.py";
my $script_article_metadata_eutils = "$src_dir_R/ncbi/paper_metadata_eutils.R";
my $script_extract_repos_from_lit_search = "$src_dir_python/extract_repos_from_articles.py";
my $script_gh_api_repo_metrics = "$src_dir_python/gh_api_repo_metrics.py";
my $script_gh_api_languages = "$src_dir_python/gh_api_languages.py";
my $script_gh_api_licenses = "$src_dir_python/gh_api_licenses.py";
my $script_gh_api_commits = "$src_dir_python/gh_api_commits.py";
my $script_gh_api_file_info = "$src_dir_python/gh_api_file_info.py";
my $script_gh_api_contents = "$src_dir_python/gh_api_contents.py";
my $script_gh_api_pr_data = "$src_dir_python/gh_api_pr_data.py";
my $script_cloc = "$src_dir_python/cloc_and_strip_comments.py";
my $script_run_bq_queries_analysis = "$src_dir_python/run_bq_queries_analysis.py";
my $script_extract_comments = "$src_dir_python/extract_comments.py";
my $script_code_chunk_frequency = "$src_dir_python/code_chunk_frequency.py";

# Output directories
my $out_results_dir = "/Users/prussell/Documents/Github_mining/results/";
my $out_results_dir_cloc = "$out_results_dir/cloc/";

# Literature search
my $lit_search_metadata_dir = "/Users/prussell/Dropbox/github_mining/articles/article_metadata/";
my $lit_search_pdf_dir = "/Users/prussell/Dropbox/github_mining/articles/pdfs/";


# -----------------------------------------------------------------
#                        External tools
# -----------------------------------------------------------------

my $python3 = "/Library/Frameworks/Python.framework/Versions/3.6/bin/python3";
my $cloc_exec = "/Users/prussell/Software/cloc-1.72.pl";


# -----------------------------------------------------------------
#                        Other parameters
# -----------------------------------------------------------------

my $languages = "C++,Python,JavaScript,C,Java,Groff,PHP,Matlab,Perl,R,Mathematica,".
				"Ruby,Shell,Groovy,Objective-C,Fortran,C#,Go,Roff,Scala,Cuda,Lua,".
				"M4,Julia,D,Haskell,Prolog,XSLT,Tcl,Gosu,Perl6,M,Lex";


# ********************************************************************************************************
# ***********************************   NO PARAMETERS BEYOND THIS POINT   ********************************
# ********************************************************************************************************


# -----------------------------------------------------------------
#                     Run parts of the workflow
# -----------------------------------------------------------------

# Extract GitHub repo names from literature search - includes non-bioinformatics repos
if($extract_repos_from_lit_search) {
	run_cmmd("$python3 $script_extract_repos_from_lit_search --metadata-dir $lit_search_metadata_dir ".
	"--pdf-dir $lit_search_pdf_dir --bq-ds $bq_ds_lit_search --bq-tb $bq_tb_repo_article")
} else {print("\nSkipping step: extract repo names from literature search\n")}

# Check for issues with repository names that have been manually curated
if($check_repo_existence) {
	run_cmmd("$python3 $script_check_repo_existence --sheet $gsheet_repos_curated");
} else {print("\nSkipping step: check for repo existence\n")}

# Get article metadata from Eutils
if($query_eutils_article_metadata) {
	run_cmmd("Rscript $script_article_metadata_eutils --project $bq_proj_gh_bioinf --dataset $bq_ds_lit_search --table-r " .
	"$bq_tb_repo_article --table-w $bq_tb_eutils")
} else {print("\nSkipping step: get article metadata from Eutils\n")}

# Get repo metrics from GitHub API
if($generate_repo_metrics) {
	run_cmmd("$python3 $script_gh_api_repo_metrics --ds $bq_ds_repos --table $bq_tb_repo_metrics ".
	"--sheet $gsheet_repos_curated")
} else {print("\nSkipping step: get repo info from GitHub API\n")}

# Get language info from GitHub API
if($generate_language_bytes) {
	run_cmmd("$python3 $script_gh_api_languages --ds $bq_ds_repos --table $bq_tb_languages ".
	"--sheet $gsheet_repos_curated")
} else {print("\nSkipping step: get language info from GitHub API\n")}

# Get licenses from GitHub API
if($generate_licenses) {
	run_cmmd("$python3 $script_gh_api_licenses --ds $bq_ds_repos --table $bq_tb_licenses ".
	"--sheet $gsheet_repos_curated")
} else {print("\nSkipping step: get licenses from GitHub API\n")}

# Get commits from GitHub API
if($generate_commits) {
	run_cmmd("$python3 $script_gh_api_commits --ds $bq_ds_repos --table $bq_tb_commits ".
	"--sheet $gsheet_repos_curated")
} else {print("\nSkipping step: get commits from GitHub API\n")}

# Get file info from GitHub API
if($generate_file_info) {
	run_cmmd("$python3 $script_gh_api_file_info --ds $bq_ds_repos --table $bq_tb_files ".
	"--sheet $gsheet_repos_curated")
} else {print("\nSkipping step: get file info from GitHub API\n")}

# Get file contents from GitHub API
if($generate_contents) {
	run_cmmd("$python3 $script_gh_api_contents --ds $bq_ds_repos --table $bq_tb_contents ".
	"--sheet $gsheet_repos_curated")
} else {print("\nSkipping step: get file contents from GitHub API\n")}

# Get pull request info from GitHub API
if($generate_pr_data) {
	run_cmmd("$python3 $script_gh_api_pr_data --ds $bq_ds_repos --table $bq_tb_prs ".
	"--sheet $gsheet_repos_curated")
} else {print("\nSkipping step: get pull request info from GitHub API\n")}

# Run BigQuery analysis queries against GitHub bioinformatics dataset and save results to tables
if($run_bq_analysis_queries) {
	run_cmmd("$python3 $script_run_bq_queries_analysis --github_ds $bq_ds_repos --results_ds $bq_ds_analysis_results")
} else {print("\nSkipping step: run BigQuery analysis queries against GitHub bioinformatics dataset and " .
	"save results to tables\n")}

# Count lines of code and push to BigQuery table along with comment-stripped versions of source files
if($run_cloc) {
	my $out_log_cloc = "$out_results_dir_cloc/run.out";
	my $cmmd_cloc = "$python3 $script_cloc --in_ds $bq_ds_repos " .
	"--out_ds $bq_ds_analysis_results " .
	"--table_loc $bq_tb_loc_by_file " .
	"--table_sc $bq_tb_contents_comments_stripped " .
	"--outfile $out_log_cloc --cloc $cloc_exec";
	run_cmmd($cmmd_cloc, $out_log_cloc)
} else {print("\nSkipping step: count lines of code\n")}

# Extract comments from source files and push to BigQuery table
if($run_extract_comments) {
	my $cmmd_extract_comments = "$python3 $script_extract_comments --ds_gh $bq_ds_repos --ds_loc " .
	"$bq_ds_analysis_results --out_ds $bq_ds_analysis_results --table $bq_tb_comments";
	run_cmmd($cmmd_extract_comments)
} else {print("\nSkipping step: extract comments\n")}

# Analyze frequency of code chunks
if($run_code_chunk_frequency) {
	my $cmmd_code_chunk_freq = "$python3 $script_code_chunk_frequency --ds_gh $bq_ds_repos --ds_res $bq_ds_analysis_results ".
	"--table_files $bq_tb_files --table_sc $bq_tb_contents_comments_stripped --table_out $bq_tb_code_chunk_freq ".
	"--table_loc $bq_tb_loc_by_file --langs $languages";
	run_cmmd($cmmd_code_chunk_freq);
} else {print("\nSkipping step: analyze code chunk frequency\n")}


print("\n\nAll done: $0.\n\n");


# -----------------------------------------------------------------
#                          Subroutines
# -----------------------------------------------------------------

# Run a command and delete a previous version of the output if it exists
# Args:
#   1. The command
#   2. (Optional parameter) The output file to delete before running the command 
sub run_cmmd {
	my ($cmmd, $output) = @_;
	$output //= 0;
	print("\nRunning command: $cmmd\n");
	# Delete the previous version of the output file if it exists
	if($output && -e $output) {
		system("rm", $output);
		if( $? != 0 ) {die "Could not remove previous output file $output\n";}
		print("Deleted previous output file $output\n");
	}
	system($cmmd);
	if ( $? != 0 ) {die;}
}














