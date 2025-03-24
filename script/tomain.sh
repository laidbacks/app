bundle exec rubocop -a
git add .
git commit -m "Commit: Rubocop linting implemented"
git push -u origin
git checkout main
git pull