
##### BigQuery project structure

# Project names
project_bioinf = 'github-bioinformatics-157418'
project_bq_public_data = 'bigquery-public-data'
project_github_archive = 'githubarchive'

# Dataset names within public data
dataset_github_repos = 'github_repos'
dataset_gh_archive_year = 'year'

# Table names within public data
table_github_repos_commits = 'commits'
table_github_repos_files = 'files'
table_github_repos_contents = 'contents'
table_github_repos_languages = 'languages'
table_github_repos_licenses = 'licenses'

# Table names within GitHub bioinformatics dataset
def table_archive(year):
    return 'github_archive_%s' % year
table_archive_2011_2016 = 'github_archive_2011_2016'
table_commits = 'commits'
table_contents = 'contents'
table_files = 'files'
table_languages = 'languages'
table_licenses = 'licenses'
table_lines_of_code = 'lines_of_code'

# Table names for query results
table_bytes_by_language = 'bytes_by_language'
table_language_list_by_repo = 'language_list_by_repo'
table_num_actors_by_repo = 'num_actors_by_repo'
table_num_forks_by_repo = 'num_forks_by_repo'
table_num_languages_by_repo = 'num_languages_by_repo'
table_num_recent_actors_by_repo = 'num_recent_actors_by_repo'
table_num_todo_fix_by_repo = 'num_todo_fix_by_repo'
table_num_watch_events_by_repo = 'num_watch_events_by_repo'
table_num_repos_by_language = 'num_repos_by_language'






