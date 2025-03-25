bundle exec rubocop -a
git add .
git commit -m "Commit: Fixed Tests"
git push -u origin
git checkout main
git pull