bundle exec rubocop -a
git add .
git commit -m "fixed migrations"
git push -u origin
git checkout main
git pull